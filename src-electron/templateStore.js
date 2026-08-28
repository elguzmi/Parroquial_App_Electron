const fs = require("fs");
const os = require("os");
const path = require("path");
const { app } = require("electron");

const TEMPLATES_DIR = "templates";
const EXPORTS_DIR = "exports";
const APP_FOLDER_NAME = "parroquia_app";
const EXPORT_MAX_AGE_MS = 48 * 60 * 60 * 1000;
const EXPORT_EXTENSIONS = new Set([".docx", ".pdf"]);
const REQUIRED_TEMPLATES = [
  "TemplateBautismo.docx",
  "TemplateConfirmacion.docx",
  "TemplateDefuncion.docx",
  "TemplateMatrimonio.docx",
];

/**
 * Carpeta empaquetada (producción): resources/templates/default
 * Dev: src-electron/templates/default (junto al main compilado o fuente)
 */
function getBundledTemplatesDir() {
  if (app.isPackaged) {
    return path.join(process.resourcesPath, "templates", "default");
  }

  // Quasar/webpack: __dirname del bundle puede no coincidir con el fuente
  const candidates = [
    path.join(__dirname, "templates", "default"),
    path.join(process.cwd(), "src-electron", "templates", "default"),
    path.join(app.getAppPath(), "src-electron", "templates", "default"),
  ];

  for (const dir of candidates) {
    if (
      fs.existsSync(dir) &&
      REQUIRED_TEMPLATES.every((name) => fs.existsSync(path.join(dir, name)))
    ) {
      return dir;
    }
  }
  return candidates[0];
}

function getTemplatesDir() {
  const dir = path.join(app.getPath("userData"), TEMPLATES_DIR);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

function getExportsDir() {
  const dir = path.join(app.getPath("userData"), EXPORTS_DIR);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

function listTemplateFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((name) => /^Template.+\.docx$/i.test(name) && !name.startsWith("output_"));
}

function missingRequiredTemplates(dir) {
  return REQUIRED_TEMPLATES.filter(
    (name) => !fs.existsSync(path.join(dir, name))
  );
}

/**
 * Copia defaults empaquetados → AppData/templates solo si faltan archivos.
 * No sobrescribe plantillas ya personalizadas por la parroquia.
 */
function ensureTemplatesSeeded() {
  const targetDir = getTemplatesDir();
  const sourceDir = getBundledTemplatesDir();
  const missing = missingRequiredTemplates(targetDir);

  if (missing.length === 0) {
    return {
      success: true,
      seeded: false,
      templatesDir: targetDir,
      bundledDir: sourceDir,
    };
  }

  if (!fs.existsSync(sourceDir)) {
    return {
      success: false,
      seeded: false,
      templatesDir: targetDir,
      bundledDir: sourceDir,
      message: `No se encontró la carpeta de plantillas empaquetadas: ${sourceDir}`,
      missing,
    };
  }

  const copied = [];
  for (const name of missing) {
    const src = path.join(sourceDir, name);
    if (!fs.existsSync(src)) continue;
    fs.copyFileSync(src, path.join(targetDir, name));
    copied.push(name);
  }

  // También copiar cualquier otro Template*.docx del pack que aún no exista
  for (const name of listTemplateFiles(sourceDir)) {
    const dest = path.join(targetDir, name);
    if (!fs.existsSync(dest)) {
      fs.copyFileSync(path.join(sourceDir, name), dest);
      if (!copied.includes(name)) copied.push(name);
    }
  }

  const stillMissing = missingRequiredTemplates(targetDir);
  return {
    success: stillMissing.length === 0,
    seeded: copied.length > 0,
    copied,
    missing: stillMissing,
    templatesDir: targetDir,
    bundledDir: sourceDir,
    message:
      stillMissing.length > 0
        ? `Faltan plantillas: ${stillMissing.join(", ")}`
        : undefined,
  };
}

function resolveTemplatePath(filename) {
  if (!filename || path.basename(filename) !== filename) {
    throw new Error("Nombre de plantilla inválido");
  }
  ensureTemplatesSeeded();
  const full = path.join(getTemplatesDir(), filename);
  if (!fs.existsSync(full)) {
    throw new Error(`Plantilla no encontrada: ${filename}`);
  }
  return full;
}

function ensureWritableDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
  return dir;
}

/**
 * Carpeta de trabajo para certificados que se abren e imprimen.
 * No usa Escritorio ni Documentos: el usuario no necesita archivarlos.
 *
 * Orden: LocalAppData (Windows, no roaming) → temp del SO → userData/exports.
 * LocalAppData evita que actas con datos personales viajen en perfiles roaming
 * y reduce Protected View de Word frente a %TEMP% puro.
 */
function getScratchExportsDir() {
  const candidates = [];

  if (process.platform === "win32" && process.env.LOCALAPPDATA) {
    candidates.push(
      path.join(process.env.LOCALAPPDATA, APP_FOLDER_NAME, EXPORTS_DIR)
    );
  }

  try {
    candidates.push(path.join(app.getPath("temp"), APP_FOLDER_NAME, EXPORTS_DIR));
  } catch (_) {
    candidates.push(path.join(os.tmpdir(), APP_FOLDER_NAME, EXPORTS_DIR));
  }

  try {
    candidates.push(path.join(app.getPath("userData"), EXPORTS_DIR));
  } catch (_) {
    /* app aún no listo: se cubre con temp */
  }

  for (const dir of candidates) {
    try {
      return ensureWritableDir(dir);
    } catch (_) {
      /* probar siguiente */
    }
  }

  return ensureWritableDir(path.join(os.tmpdir(), APP_FOLDER_NAME, EXPORTS_DIR));
}

function uniqueExportName(filename) {
  const safeName = path.basename(String(filename || "documento"));
  const ext = path.extname(safeName);
  const stem =
    (ext ? safeName.slice(0, -ext.length) : safeName).trim() || "documento";
  const stamp = `${Date.now().toString(36)}-${Math.random()
    .toString(36)
    .slice(2, 6)}`;
  return `${stem}_${stamp}${ext}`;
}

function pruneOldExports(dir) {
  let names;
  try {
    names = fs.readdirSync(dir);
  } catch (_) {
    return;
  }

  const now = Date.now();
  for (const name of names) {
    const ext = path.extname(name).toLowerCase();
    if (!EXPORT_EXTENSIONS.has(ext)) continue;
    const full = path.join(dir, name);
    try {
      const st = fs.statSync(full);
      if (st.isFile() && now - st.mtimeMs > EXPORT_MAX_AGE_MS) {
        fs.unlinkSync(full);
      }
    } catch (_) {
      /* archivo abierto en Word/visor o ya eliminado */
    }
  }
}

/**
 * Destino de Word/PDF: carpeta de trabajo oculta, nombre único, limpieza 48 h.
 */
function resolveExportPath(filename) {
  const dir = getScratchExportsDir();
  pruneOldExports(dir);
  return path.join(dir, uniqueExportName(filename));
}

function getTemplatesStatus() {
  const seed = ensureTemplatesSeeded();
  return {
    ...seed,
    files: listTemplateFiles(seed.templatesDir),
    required: REQUIRED_TEMPLATES,
  };
}

module.exports = {
  REQUIRED_TEMPLATES,
  getBundledTemplatesDir,
  getTemplatesDir,
  getExportsDir,
  getScratchExportsDir,
  ensureTemplatesSeeded,
  resolveTemplatePath,
  resolveExportPath,
  getTemplatesStatus,
  listTemplateFiles,
};
