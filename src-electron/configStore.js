const fs = require("fs");
const path = require("path");
const { app } = require("electron");

const CONFIG_FILE = "config.json";
const ASSETS_DIR = "assets";

function getConfigDir() {
  return app.getPath("userData");
}

function getConfigPath() {
  return path.join(getConfigDir(), CONFIG_FILE);
}

function getAssetsDir() {
  const dir = path.join(getConfigDir(), ASSETS_DIR);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

function ensureConfigDir() {
  const dir = getConfigDir();
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  return dir;
}

function loadConfig() {
  const file = getConfigPath();
  if (!fs.existsSync(file)) return null;
  try {
    const raw = fs.readFileSync(file, "utf8");
    return JSON.parse(raw);
  } catch (err) {
    console.error("configStore.loadConfig:", err);
    return null;
  }
}

function saveConfig(config) {
  ensureConfigDir();
  const file = getConfigPath();
  const tmp = `${file}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(config, null, 2), "utf8");
  fs.renameSync(tmp, file);
  return loadConfig();
}

function isConfigured() {
  const config = loadConfig();
  if (!config || !config.sql || !config.parroquia) return false;
  const { server, database, user, password } = config.sql;
  return Boolean(server && database && user && password != null && config.parroquia.nombre);
}

function getPublicConfig(config = loadConfig()) {
  if (!config) return null;
  return {
    id: config.id || 1,
    parroquia: config.parroquia?.nombre || "",
    color: config.parroquia?.color || "#0f4c81",
    logo: config.parroquia?.logo || "",
    fondo_login: config.parroquia?.fondo_login || "",
    logo_login: config.parroquia?.logo_login || "",
    configured: true,
  };
}

function toSqlConfig(sql) {
  if (!sql) return null;
  const port = sql.port ? Number(sql.port) : undefined;
  return {
    user: sql.user,
    password: sql.password,
    server: sql.server,
    database: sql.database,
    ...(port && !Number.isNaN(port) ? { port } : {}),
    options: {
      encrypt: Boolean(sql.encrypt),
      trustServerCertificate: sql.trustServerCertificate !== false,
      ...(sql.instanceName ? { instanceName: sql.instanceName } : {}),
    },
  };
}

function saveAssetFromPath(sourcePath, targetName) {
  const assetsDir = getAssetsDir();
  const ext = path.extname(sourcePath) || path.extname(targetName) || ".png";
  const safeName = targetName.endsWith(ext) ? targetName : `${targetName}${ext}`;
  const dest = path.join(assetsDir, safeName);
  fs.copyFileSync(sourcePath, dest);
  return safeName;
}

function getAssetPath(filename) {
  if (!filename) return null;
  const full = path.join(getAssetsDir(), filename);
  return fs.existsSync(full) ? full : null;
}

function getAssetDataUrl(filename) {
  const full = getAssetPath(filename);
  if (!full) return null;
  const ext = path.extname(full).toLowerCase().replace(".", "");
  const mime =
    ext === "jpg" || ext === "jpeg"
      ? "image/jpeg"
      : ext === "webp"
      ? "image/webp"
      : ext === "gif"
      ? "image/gif"
      : "image/png";
  const base64 = fs.readFileSync(full).toString("base64");
  return `data:${mime};base64,${base64}`;
}

module.exports = {
  getConfigDir,
  getConfigPath,
  getAssetsDir,
  loadConfig,
  saveConfig,
  isConfigured,
  getPublicConfig,
  toSqlConfig,
  saveAssetFromPath,
  getAssetPath,
  getAssetDataUrl,
};
