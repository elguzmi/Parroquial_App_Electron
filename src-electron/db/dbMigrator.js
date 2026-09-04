const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { app } = require("electron");

const MIGRATIONS_TABLE = "dbo.__DbMigrations";

function resolveDbSubdir(subdir, fallbackRelative) {
  try {
    if (app && app.isPackaged) {
      return path.join(process.resourcesPath, "db", subdir);
    }
  } catch (_) {
    /* fuera de Electron o app no lista */
  }

  const candidates = [
    path.join(__dirname, subdir),
    path.join(process.cwd(), "src-electron", "db", subdir),
  ];

  try {
    if (app && typeof app.getAppPath === "function") {
      candidates.push(
        path.join(app.getAppPath(), "src-electron", "db", subdir)
      );
    }
  } catch (_) {
    /* ignore */
  }

  for (const dir of candidates) {
    if (fs.existsSync(dir)) return dir;
  }
  return fallbackRelative || candidates[0];
}

/**
 * Resuelve la carpeta de migraciones incrementales empaquetadas.
 * Prod: resources/db/migrations
 * Dev:  src-electron/db/migrations
 */
function getMigrationsDir() {
  return resolveDbSubdir("migrations");
}

/**
 * SP de producto (CREATE OR ALTER). Se reaplican si cambia el checksum.
 * Prod: resources/db/repeatable
 * Dev:  src-electron/db/repeatable
 */
function getRepeatableDir() {
  return resolveDbSubdir("repeatable");
}

function checksum(content) {
  return crypto.createHash("sha256").update(content, "utf8").digest("hex");
}

function normalizeChecksum(value) {
  return String(value || "")
    .trim()
    .toLowerCase();
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

function mapSqlFiles(dir, nameFilter, describe) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((name) => nameFilter.test(name))
    .sort((a, b) => a.localeCompare(b, "en"))
    .map((fileName) => {
      const fullPath = path.join(dir, fileName);
      const content = fs.readFileSync(fullPath, "utf8");
      const migrationId = fileName.replace(/\.sql$/i, "");
      return {
        fileName,
        migrationId,
        description: describe(migrationId),
        fullPath,
        content,
        checksum: checksum(content),
      };
    });
}

function listMigrationFiles(dir) {
  return mapSqlFiles(
    dir,
    /^\d{8}_\d{3}_.+\.sql$/i,
    (migrationId) =>
      migrationId.replace(/^\d{8}_\d{3}_/, "").replace(/_/g, " ")
  );
}

function listRepeatableFiles(dir) {
  return mapSqlFiles(dir, /^R__.+\.sql$/i, (migrationId) =>
    `SP repetible ${migrationId.replace(/^R__/, "").replace(/_/g, " ")}`
  );
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
  const rows = await getAppliedMigrationRows(pool);
  return new Set(rows.map((r) => r.MigrationId));
}

async function getAppliedMigrationRows(pool) {
  const result = await pool.request().query(`
SELECT MigrationId, Checksum
FROM ${MIGRATIONS_TABLE}
`);
  return result.recordset || [];
}

async function executeSqlBatches(pool, migration) {
  const batches = splitBatches(migration.content);
  if (!batches.length) {
    throw new Error(`Script vacío: ${migration.migrationId}`);
  }
  for (const batch of batches) {
    await pool.request().query(batch);
  }
}

/**
 * Aplica una migración incremental por lotes (separados por GO).
 * El historial se escribe solo si TODO ok (INSERT).
 */
async function applyMigration(pool, migration) {
  await executeSqlBatches(pool, migration);
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
 * CREATE OR ALTER de un SP de producto. Reaplica si el archivo cambió.
 */
async function applyRepeatable(pool, migration) {
  await executeSqlBatches(pool, migration);
  await pool
    .request()
    .input("MigrationId", migration.migrationId)
    .input("Description", migration.description)
    .input("AppVersion", migration.appVersion || null)
    .input("Checksum", migration.checksum)
    .query(`
IF EXISTS (
    SELECT 1 FROM ${MIGRATIONS_TABLE} WHERE MigrationId = @MigrationId
)
BEGIN
    UPDATE ${MIGRATIONS_TABLE}
    SET Description = @Description,
        AppVersion = @AppVersion,
        Checksum = @Checksum,
        AppliedAt = SYSUTCDATETIME()
    WHERE MigrationId = @MigrationId;
END
ELSE
BEGIN
    INSERT INTO ${MIGRATIONS_TABLE} (MigrationId, Description, AppVersion, Checksum)
    VALUES (@MigrationId, @Description, @AppVersion, @Checksum);
END
`);
}

function pendingRepeatables(files, appliedRows) {
  const checksumById = new Map(
    appliedRows.map((row) => [
      row.MigrationId,
      normalizeChecksum(row.Checksum),
    ])
  );
  return files.filter((file) => {
    if (!checksumById.has(file.migrationId)) return true;
    return checksumById.get(file.migrationId) !== normalizeChecksum(file.checksum);
  });
}

/**
 * Ejecuta migraciones pendientes sobre un pool mssql ya conectado.
 * Primero incrementales (una vez); luego SP repetibles (si cambió el checksum).
 */
async function runMigrations(pool, options = {}) {
  const appVersion = options.appVersion || null;
  const migrationsDir = getMigrationsDir();
  const repeatableDir = getRepeatableDir();
  const files = listMigrationFiles(migrationsDir);
  const repeatableFiles = listRepeatableFiles(repeatableDir);

  const result = {
    ok: true,
    migrationsDir,
    repeatableDir,
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
    let appliedRows = await getAppliedMigrationRows(pool);
    const appliedSet = new Set(appliedRows.map((r) => r.MigrationId));
    result.applied = Array.from(appliedSet).sort();
    result.lastMigrationId = result.applied.length
      ? result.applied[result.applied.length - 1]
      : null;

    const pendingIncremental = files.filter((f) => !appliedSet.has(f.migrationId));
    const pendingRepeatable = pendingRepeatables(repeatableFiles, appliedRows);
    result.pendingBefore = [
      ...pendingIncremental.map((p) => p.migrationId),
      ...pendingRepeatable.map((p) => p.migrationId),
    ];

    if (!pendingIncremental.length && !pendingRepeatable.length) {
      result.skipped = true;
      return result;
    }

    for (const migration of pendingIncremental) {
      migration.appVersion = appVersion;
      await applyMigration(pool, migration);
      result.newlyApplied.push(migration.migrationId);
      result.applied.push(migration.migrationId);
      result.lastMigrationId = migration.migrationId;
    }

    for (const migration of pendingRepeatable) {
      migration.appVersion = appVersion;
      await applyRepeatable(pool, migration);
      result.newlyApplied.push(migration.migrationId);
      if (!result.applied.includes(migration.migrationId)) {
        result.applied.push(migration.migrationId);
      }
      result.lastMigrationId = migration.migrationId;
    }

    result.applied = [...new Set(result.applied)].sort();
    return result;
  } catch (err) {
    result.ok = false;
    result.error = err?.message || String(err);
    return result;
  }
}

async function getMigrationStatus(pool) {
  const migrationsDir = getMigrationsDir();
  const repeatableDir = getRepeatableDir();
  const files = listMigrationFiles(migrationsDir);
  const repeatableFiles = listRepeatableFiles(repeatableDir);
  const allFiles = [...files, ...repeatableFiles];
  const status = {
    ok: true,
    migrationsDir,
    repeatableDir,
    available: allFiles.map((f) => f.migrationId),
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
    const appliedRows = await getAppliedMigrationRows(pool);
    const appliedSet = new Set(appliedRows.map((r) => r.MigrationId));
    status.applied = Array.from(appliedSet).sort();
    const pendingIncremental = files
      .filter((f) => !appliedSet.has(f.migrationId))
      .map((f) => f.migrationId);
    const pendingRepeatable = pendingRepeatables(repeatableFiles, appliedRows).map(
      (f) => f.migrationId
    );
    status.pending = [...pendingIncremental, ...pendingRepeatable];
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
  getRepeatableDir,
  listMigrationFiles,
  listRepeatableFiles,
  runMigrations,
  getMigrationStatus,
  ensureMigrationsTable,
};
