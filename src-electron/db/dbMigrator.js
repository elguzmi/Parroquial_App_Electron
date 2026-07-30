const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { app } = require("electron");

const MIGRATIONS_TABLE = "dbo.__DbMigrations";

/**
 * Resuelve la carpeta de migraciones empaquetadas.
 * Prod: resources/db/migrations
 * Dev:  src-electron/db/migrations
 */
function getMigrationsDir() {
  try {
    if (app && app.isPackaged) {
      return path.join(process.resourcesPath, "db", "migrations");
    }
  } catch (_) {
    /* fuera de Electron o app no lista */
  }

  const candidates = [
    path.join(__dirname, "migrations"),
    path.join(process.cwd(), "src-electron", "db", "migrations"),
  ];

  try {
    if (app && typeof app.getAppPath === "function") {
      candidates.push(
        path.join(app.getAppPath(), "src-electron", "db", "migrations")
      );
    }
  } catch (_) {
    /* ignore */
  }

  for (const dir of candidates) {
    if (fs.existsSync(dir)) return dir;
  }
  return candidates[0];
}

function checksum(content) {
  return crypto.createHash("sha256").update(content, "utf8").digest("hex");
}

/**
 * mssql no entiende GO. Partimos el script en lotes.
 * Ignora líneas que son solo GO (con espacios opcionales).
 */
function splitBatches(sqlText) {
  const lines = String(sqlText || "").split(/\r?\n/);
  const batches = [];
  let current = [];

  for (const line of lines) {
    if (/^\s*GO\s*(?:--.*)?$/i.test(line)) {
      const batch = current.join("\n").trim();
      if (batch) batches.push(batch);
      current = [];
      continue;
    }
    current.push(line);
  }

  const last = current.join("\n").trim();
  if (last) batches.push(last);
  return batches;
}

function listMigrationFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((name) => /^\d{8}_\d{3}_.+\.sql$/i.test(name))
    .sort((a, b) => a.localeCompare(b, "en"))
    .map((fileName) => {
      const fullPath = path.join(dir, fileName);
      const content = fs.readFileSync(fullPath, "utf8");
      const migrationId = fileName.replace(/\.sql$/i, "");
      const description = migrationId.replace(/^\d{8}_\d{3}_/, "").replace(/_/g, " ");
      return {
        fileName,
        migrationId,
        description,
        fullPath,
        content,
        checksum: checksum(content),
      };
    });
}

async function ensureMigrationsTable(pool) {
  const sql = `
IF OBJECT_ID(N'dbo.__DbMigrations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.__DbMigrations
    (
        Id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_DbMigrations PRIMARY KEY,
        MigrationId NVARCHAR(128) NOT NULL,
        Description NVARCHAR(300) NULL,
        AppVersion NVARCHAR(32) NULL,
        Checksum NVARCHAR(64) NULL,
        AppliedAt DATETIME2 NOT NULL
            CONSTRAINT DF_DbMigrations_AppliedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT UQ_DbMigrations_MigrationId UNIQUE (MigrationId)
    );
END
`;
  await pool.request().query(sql);
}

async function getAppliedMigrationIds(pool) {
  const result = await pool.request().query(`
SELECT MigrationId
FROM ${MIGRATIONS_TABLE}
ORDER BY MigrationId ASC
`);
  return new Set((result.recordset || []).map((r) => r.MigrationId));
}

/**
 * Aplica una migración por lotes (separados por GO).
 * Sin transacción global: CREATE/ALTER PROCEDURE no siempre es compatible.
 * Los scripts deben ser idempotentes; el historial se escribe solo si TODO ok.
 */
async function applyMigration(pool, migration) {
  const batches = splitBatches(migration.content);
  if (!batches.length) {
    throw new Error(`Migración vacía: ${migration.migrationId}`);
  }

  for (const batch of batches) {
    await pool.request().query(batch);
  }

  await pool
    .request()
    .input("MigrationId", migration.migrationId)
    .input("Description", migration.description)
    .input("AppVersion", migration.appVersion || null)
    .input("Checksum", migration.checksum)
    .query(`
INSERT INTO ${MIGRATIONS_TABLE} (MigrationId, Description, AppVersion, Checksum)
VALUES (@MigrationId, @Description, @AppVersion, @Checksum)
`);
}

/**
 * Ejecuta migraciones pendientes sobre un pool mssql ya conectado.
 * @returns {{
 *   ok: boolean,
 *   migrationsDir: string,
 *   applied: string[],
 *   pendingBefore: string[],
 *   newlyApplied: string[],
 *   lastMigrationId: string|null,
 *   error: string|null,
 *   skipped: boolean
 * }}
 */
async function runMigrations(pool, options = {}) {
  const appVersion = options.appVersion || null;
  const migrationsDir = getMigrationsDir();
  const files = listMigrationFiles(migrationsDir);

  const result = {
    ok: true,
    migrationsDir,
    applied: [],
    pendingBefore: [],
    newlyApplied: [],
    lastMigrationId: null,
    error: null,
    skipped: false,
  };

  if (!pool) {
    result.ok = false;
    result.error = "No hay conexión a SQL Server para migrar.";
    return result;
  }

  try {
    await ensureMigrationsTable(pool);
    const appliedSet = await getAppliedMigrationIds(pool);
    result.applied = Array.from(appliedSet).sort();
    result.lastMigrationId = result.applied.length
      ? result.applied[result.applied.length - 1]
      : null;

    const pending = files.filter((f) => !appliedSet.has(f.migrationId));
    result.pendingBefore = pending.map((p) => p.migrationId);

    if (!pending.length) {
      result.skipped = true;
      return result;
    }

    for (const migration of pending) {
      migration.appVersion = appVersion;
      await applyMigration(pool, migration);
      result.newlyApplied.push(migration.migrationId);
      result.applied.push(migration.migrationId);
      result.lastMigrationId = migration.migrationId;
    }

    return result;
  } catch (err) {
    result.ok = false;
    result.error = err?.message || String(err);
    return result;
  }
}

async function getMigrationStatus(pool) {
  const migrationsDir = getMigrationsDir();
  const files = listMigrationFiles(migrationsDir);
  const status = {
    ok: true,
    migrationsDir,
    available: files.map((f) => f.migrationId),
    applied: [],
    pending: [],
    lastMigrationId: null,
    error: null,
  };

  if (!pool) {
    status.ok = false;
    status.error = "Sin conexión";
    status.pending = status.available.slice();
    return status;
  }

  try {
    await ensureMigrationsTable(pool);
    const appliedSet = await getAppliedMigrationIds(pool);
    status.applied = Array.from(appliedSet).sort();
    status.pending = files
      .filter((f) => !appliedSet.has(f.migrationId))
      .map((f) => f.migrationId);
    status.lastMigrationId = status.applied.length
      ? status.applied[status.applied.length - 1]
      : null;
    return status;
  } catch (err) {
    status.ok = false;
    status.error = err?.message || String(err);
    return status;
  }
}

module.exports = {
  getMigrationsDir,
  listMigrationFiles,
  runMigrations,
  getMigrationStatus,
  ensureMigrationsTable,
};
