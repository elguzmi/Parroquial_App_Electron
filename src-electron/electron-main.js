import {
  app,
  BrowserWindow,
  dialog,
  ipcMain,
  shell,
} from "electron";
import path from "path";
import os from "os";
const sql = require("mssql");
var fs = require("fs");

// Nombre fijo para userData (evita caer en %APPDATA%\Electron)
const APP_FOLDER_NAME = "parroquia_app";
app.setName(APP_FOLDER_NAME);
app.setPath("userData", path.join(app.getPath("appData"), APP_FOLDER_NAME));

const configStore = require("./configStore");
const templateStore = require("./templateStore");
const dbMigrator = require("./db/dbMigrator");
const pdfExport = require("./pdfExport");
const auditLog = require("./auditLog");

const platform = process.platform || os.platform();
let mainWindow;
let pool = null;
/** Último resultado de migraciones en esta sesión */
let lastMigrationResult = null;
let migrationsAttemptedForPool = false;

function resolveRuntimeConfig() {
  const stored = configStore.loadConfig();
  if (stored) return stored;
  return null;
}

function resolveWindowIcon() {
  const stored = resolveRuntimeConfig();
  if (stored?.parroquia?.logo) {
    const assetPath = configStore.getAssetPath(stored.parroquia.logo);
    if (assetPath) return assetPath;
  }
  return path.resolve(__dirname, "icons/icon.ico");
}

function createWindow() {
  /* Initial window options*/
  mainWindow = new BrowserWindow({
    icon: resolveWindowIcon(),
    width: 1300,
    height: 760,
    useContentSize: true,
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
    webPreferences: {
      contextIsolation: true,
      sandbox: false,
      // More info: /quasar-cli/developing-electron-apps/electron-preload-script
      preload: path.resolve(__dirname, process.env.QUASAR_ELECTRON_PRELOAD),
      //preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
      //preload: path.resolve(__dirname, "electron-preload.js"),
      nodeIntegration: true,
    },
  });

  mainWindow.loadURL(process.env.APP_URL);
  if (process.env.DEBUGGING) {
    // if on DEV or Production with debug enabled
    mainWindow.webContents.openDevTools();
  } else {
    // we're on production; no access to devtools pls
    mainWindow.webContents.on("devtools-opened", () => {
      mainWindow.webContents.closeDevTools();
    });
  }

  mainWindow.on("closed", () => {
    mainWindow = null;
  });
}

const { setupAutoUpdater } = require("./autoUpdate");

app.whenReady().then(() => {
  console.log("[config] userData:", app.getPath("userData"));
  const seed = templateStore.ensureTemplatesSeeded();
  console.log("[templates]", seed);
  createWindow();
  setupAutoUpdater(() => mainWindow);
});
app.on("window-all-closed", () => {
  if (platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (mainWindow === null) {
    createWindow();
  }
});

async function closePool() {
  if (pool) {
    try {
      await pool.close();
    } catch (err) {
      console.error("closePool:", err);
    }
    pool = null;
  }
  migrationsAttemptedForPool = false;
  auditLog.resetCatalogCache();
}

function resolveAppVersionForMigrations() {
  try {
    if (app.isPackaged) return app.getVersion();
    const pkgPath = path.join(process.cwd(), "package.json");
    if (fs.existsSync(pkgPath)) {
      const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
      if (pkg?.version) return String(pkg.version);
    }
  } catch (_) {
    /* ignore */
  }
  return app.getVersion();
}

/**
 * Aplica migraciones pendientes una vez por ciclo de pool/conexión.
 */
async function ensureDatabaseMigrations(force = false) {
  const activePool = await getConnection({ skipMigrations: true });
  if (!force && migrationsAttemptedForPool && lastMigrationResult) {
    return lastMigrationResult;
  }
  const result = await dbMigrator.runMigrations(activePool, {
    appVersion: resolveAppVersionForMigrations(),
  });
  lastMigrationResult = result;
  migrationsAttemptedForPool = true;
  if (result.ok) {
    if (result.newlyApplied?.length) {
      console.log(
        "[db-migrations] Aplicadas:",
        result.newlyApplied.join(", ")
      );
    } else {
      console.log("[db-migrations] Esquema al día");
    }
  } else {
    console.error("[db-migrations] Error:", result.error);
  }
  return result;
}

async function getConnection(options = {}) {
  const skipMigrations = Boolean(options.skipMigrations);
  if (!pool) {
    const stored = resolveRuntimeConfig();
    const sqlConfig = stored ? configStore.toSqlConfig(stored.sql) : null;
    if (!sqlConfig) {
      throw new Error("La aplicación aún no está configurada.");
    }
    pool = await sql.connect(sqlConfig);
    migrationsAttemptedForPool = false;
  }

  if (!skipMigrations && !migrationsAttemptedForPool) {
    await ensureDatabaseMigrations(false);
  }

  return pool;
}

//#region Setup / Config runtime

ipcMain.handle("ApiSetup:isConfigured", async () => {
  try {
    return { success: true, configured: configStore.isConfigured() };
  } catch (err) {
    return { success: false, configured: false, message: err.message };
  }
});

ipcMain.handle("ApiSetup:getPublicConfig", async () => {
  try {
    const stored = configStore.getPublicConfig();
    if (stored) return { success: true, data: stored };
    return { success: true, data: { configured: false } };
  } catch (err) {
    return { success: false, message: err.message };
  }
});

ipcMain.handle("ApiSetup:testConnection", async (_ev, sqlInput) => {
  let testPool = null;
  try {
    const sqlConfig = configStore.toSqlConfig(sqlInput);
    testPool = await new sql.ConnectionPool(sqlConfig).connect();
    await testPool.request().query("SELECT 1 AS ok");
    return { success: true, message: "Conexión exitosa" };
  } catch (err) {
    return { success: false, message: err.message || String(err) };
  } finally {
    if (testPool) {
      try {
        await testPool.close();
      } catch (_) {
        /* ignore */
      }
    }
  }
});

ipcMain.handle("ApiSetup:pickImage", async (_ev, kind) => {
  try {
    const result = await dialog.showOpenDialog(mainWindow, {
      title: "Seleccionar imagen",
      properties: ["openFile"],
      filters: [
        { name: "Imágenes", extensions: ["png", "jpg", "jpeg", "webp", "gif"] },
      ],
    });
    if (result.canceled || !result.filePaths?.length) {
      return { success: false, canceled: true };
    }
    const sourcePath = result.filePaths[0];
    const targetName = kind || `asset_${Date.now()}`;
    const savedName = configStore.saveAssetFromPath(sourcePath, targetName);
    const dataUrl = configStore.getAssetDataUrl(savedName);
    return { success: true, filename: savedName, dataUrl };
  } catch (err) {
    return { success: false, message: err.message };
  }
});

ipcMain.handle("ApiSetup:getAssetDataUrl", async (_ev, filename) => {
  try {
    const dataUrl = configStore.getAssetDataUrl(filename);
    return { success: Boolean(dataUrl), dataUrl };
  } catch (err) {
    return { success: false, message: err.message };
  }
});

ipcMain.handle("ApiSetup:saveConfig", async (_ev, payload) => {
  try {
    if (!payload?.sql || !payload?.parroquia) {
      return { success: false, message: "Configuración incompleta" };
    }
    const config = {
      version: 1,
      id: payload.id || 1,
      sql: {
        server: payload.sql.server,
        port: payload.sql.port || null,
        database: payload.sql.database,
        user: payload.sql.user,
        password: payload.sql.password,
        encrypt: Boolean(payload.sql.encrypt),
        trustServerCertificate: payload.sql.trustServerCertificate !== false,
      },
      parroquia: {
        nombre: payload.parroquia.nombre,
        color: payload.parroquia.color || "#0f4c81",
        logo: payload.parroquia.logo || "",
        fondo_login: payload.parroquia.fondo_login || "",
        logo_login: payload.parroquia.logo_login || "",
      },
      updatedAt: new Date().toISOString(),
    };
    configStore.saveConfig(config);
    // Asegura plantillas en AppData al completar el setup de la parroquia
    templateStore.ensureTemplatesSeeded();
    await closePool();

    // Primera conexión post-setup: aplica migraciones de esquema
    let migrations = null;
    try {
      migrations = await ensureDatabaseMigrations(true);
    } catch (migErr) {
      migrations = {
        ok: false,
        error: migErr?.message || String(migErr),
      };
    }

    return {
      success: true,
      data: configStore.getPublicConfig(config),
      migrations,
    };
  } catch (err) {
    return { success: false, message: err.message };
  }
});

ipcMain.handle("ApiSetup:getTemplatesStatus", async () => {
  try {
    return { success: true, data: templateStore.getTemplatesStatus() };
  } catch (err) {
    return { success: false, message: err.message };
  }
});

//#endregion

//#region Api DB migrations

ipcMain.handle("ApiDb:ensureMigrations", async () => {
  try {
    if (!configStore.isConfigured()) {
      return {
        success: false,
        skipped: true,
        message: "La aplicación aún no está configurada.",
      };
    }
    const result = await ensureDatabaseMigrations(true);
    return { success: result.ok, ...result };
  } catch (err) {
    return {
      success: false,
      ok: false,
      error: err?.message || String(err),
    };
  }
});

ipcMain.handle("ApiDb:getMigrationStatus", async () => {
  try {
    if (!configStore.isConfigured()) {
      return {
        success: false,
        message: "La aplicación aún no está configurada.",
      };
    }
    const activePool = await getConnection({ skipMigrations: true });
    const status = await dbMigrator.getMigrationStatus(activePool);
    return {
      success: status.ok,
      ...status,
      lastRun: lastMigrationResult,
    };
  } catch (err) {
    return {
      success: false,
      ok: false,
      error: err?.message || String(err),
    };
  }
});

//#endregion

//#region Api login

// ********** API DE LOGIN
ipcMain.handle("ApiLogin:getConfigParroquia", async () => {
  try {
    const stored = configStore.getPublicConfig();
    if (stored) return stored;
    return { configured: false };
  } catch (err) {
    return { isError: true, errorMessage: "getConfigParroquia " + err };
  }
});

// ********** API DE LOGIN

ipcMain.handle("ApiLogin:login", async (ev, arg) => {
  try {
    const { user, clave } = arg;
    const pool = await getConnection();
    const request = pool.request();
    request.input("Usuario", sql.VarChar(50), user);
    request.input("Clave", sql.VarChar(50), clave);
    const result = await request.execute("BD_Get_Login");
    const rows = result.recordset || [];
    if (rows.length) {
      auditLog.setSession(rows[0], user);
    } else {
      auditLog.clearSession();
    }
    return {
      success: true,
      data: rows,
      migrations: lastMigrationResult,
    };
  } catch (err) {
    console.error("Login error:", err);
    auditLog.clearSession();
    return {
      success: false,
      message: err.message,
      migrations: lastMigrationResult,
    };
  }
});

ipcMain.handle("ApiLogin:logout", async () => {
  auditLog.clearSession();
  return { success: true };
});


ipcMain.handle("ApiLogin:Load_Modules", async (ev, IdPerfil) => {
  try {
    const pool = await getConnection();
    const request = pool.request();
    request.input("IdPerfil", sql.Int, IdPerfil);
    let exec = await request.execute("BD_Get_ModulosPerfil");
    return {
      success: true,
      data: exec.recordsets[0]
    };
    
  } catch (err) {
    return {
      success: false,
      message: err.message
    };
  }
});

//#endregion

//** procedimiento  que se ejecuta y devuelve un string  */
ipcMain.handle("myAPI:executeSp_St", async (ev, data, sp) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp(sp);
    let arg = JSON.parse(data);
    const pool = await getConnection();
    const request = pool.request();
      parametersIn.map((e) => {
        request.input(
          e["ParameterN"],
          getTypeData(e["Type"], e["max_length"]),
          arg[e["ParameterN"]]
        );
      });
    const result = await request.execute(sp);
    const message = result.recordset[0][""];
    if (!auditLog.isErrorMessage(message)) {
      await auditLog.recordSpAudit(getConnection, sp, arg, message);
    }
    return message;
  } catch (err) {
    return "Error - executeSp_St " + err;
  }
});

//** procedimiento  que se ejecuta y devuelve un array de json  */
ipcMain.handle("myAPI:executeSp_Dt", async (ev, data, sp) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp(sp);
    let arg = JSON.parse(data);
    const pool = await getConnection();
    const request = pool.request();
      parametersIn.map((e) => {
        request.input(
          e["ParameterN"],
          getTypeData(e["Type"], e["max_length"]),
          arg[e["ParameterN"]]
        );
      });
    const result = await request.execute(sp);
    return result.recordset[0];
    
  } catch (ex) {
    return "Error - executeSp_St " + err;
  }
});

//** procedimiento  que se ejecuta y devuelve varios arrays de json  */
ipcMain.handle("myAPI:executeSp_Ds", async (ev, data, sp) => {
  try {
    let parametersIn = null;
    parametersIn = await getParametersSp(sp);
    let arg = JSON.parse(data);
    const pool = await getConnection();
    const request = pool.request();
    parametersIn.map((e) => {
      request.input(
        e["ParameterN"],
        getTypeData(e["Type"], e["max_length"]),
        arg[e["ParameterN"]]
      );
    });
    const result = await request.execute(sp);
    return result.recordsets;
    
  } catch (ex) {
    return { isError: true, errorMessage: "executeSp_Ds " + ex };
  }
});

ipcMain.handle("myAPI:Export_Data", async (ev, tabla) => {
  try {
    if (!tabla) return "Error - No Data to search";
    const pool = await getConnection();
    const request = pool.request();
    request.input("Tabla", sql.VarChar(20), tabla);
    const result = await request.execute("BD_GetData_FromTable");
    const datos = result.recordsets[0];
    const headers = Object.keys(datos[0]);
    const msj = await exportData(headers, datos, tabla);
    return msj;
  } catch (err) {
    return { isError: true, errorMessage: "Fn_Export_Data " + err };
  }
});

ipcMain.handle("myAPI:openFilesTemplates", async () => {
  try {
    const status = templateStore.getTemplatesStatus();
    const templatesDir = status.templatesDir;
    const sample =
      status.files?.[0] ||
      templateStore.REQUIRED_TEMPLATES[0];
    const samplePath = path.join(templatesDir, sample);

    if (fs.existsSync(samplePath)) {
      shell.showItemInFolder(samplePath);
    } else {
      await shell.openPath(templatesDir);
    }

    return {
      isError: false,
      templatesDir,
      files: status.files,
    };
  } catch (err) {
    return { isError: true, errorMessage: "openFilesTemplates " + err };
  }
});

ipcMain.handle("myAPI:convertTo_Docx_Zip", async (ev, data) => {
  const PizZip = require("pizzip");
  const Docxtemplater = require("docxtemplater");
  const cheerio = require("cheerio");

  try {
    let obj = JSON.parse(data);
    const templateName = obj["Nombre_Archivo"];
    const templatePath = templateStore.resolveTemplatePath(templateName);
    const content = fs.readFileSync(templatePath, "binary");
    const zip = new PizZip(content);
    const doc = new Docxtemplater(zip, {
      paragraphLoop: true,
      linebreaks: true,
    });

    if (templateName == "TemplateConfirmacion.docx") {
      const textoEnCheer = cheerio.load(obj["Notas_Correcciones"] ?? "");
      obj["Notas_Correcciones"] = textoEnCheer.text();
    } else if (templateName == "TemplateDefuncion.docx") {
      const textoEnCheer = cheerio.load(obj["NotaMarginal"] ?? "");
      obj["NotaMarginal"] = textoEnCheer.text();
    } else {
      const textoEnCheer = cheerio.load(obj["Nota_Marginal"] ?? "");
      obj["Nota_Marginal"] = textoEnCheer.text();
    }

    doc.render(obj);
    const buf = doc.getZip().generate({
      type: "nodebuffer",
      compression: "DEFLATE",
    });

    const outputPath = templateStore.resolveExportPath(
      "output_" + templateName
    );
    fs.writeFileSync(outputPath, buf);
    shell.openPath(outputPath);

    await auditLog.recordDocumentAudit(getConnection, "WORD", obj);

    return { isError: false, data: "OK", path: outputPath };
  } catch (err) {
    return { isError: true, errorMessage: "convertTo_Docx_Zip " + err };
  }
});

ipcMain.handle("myAPI:printToPdf", async (_ev, payload) => {
  try {
    console.log("[pdf] solicitud recibida");
    const result = await pdfExport.printHtmlToPdf(payload || {});
    if (!result?.isError) {
      await auditLog.recordDocumentAudit(getConnection, "PDF", payload || {});
    }
    return result;
  } catch (err) {
    console.error("[pdf] handler:", err);
    return {
      isError: true,
      errorMessage: "printToPdf " + (err?.message || err),
    };
  }
});

// APILIST
function exportData(headers, datos, tabla) {
  return new Promise((res, rej) => {
    const xl = require("excel4node");
    const wb = new xl.Workbook();
    const ws = wb.addWorksheet("Worksheet Name");
    const data = datos;
    const headingColumnNames = headers;
    //Write Column Title in Excel file
    let headingColumnIndex = 1;
    headingColumnNames.forEach((heading) => {
      ws.cell(1, headingColumnIndex++).string(heading);
    });
    //Write Data in Excel file
    let rowIndex = 2;
    data.forEach((record) => {
      let columnIndex = 1;
      Object.keys(record).forEach((columnName) => {
        ws.cell(rowIndex, columnIndex++).string(record[columnName]);
      });
      rowIndex++;
    });
    let route = os.homedir() + "/desktop/" + tabla + "_data.xlsx";
    //wb.write("C:Users/santi/Desktop/data.xlsx");
    wb.write(route);
    res(route);
  });
}

function getParametersSp(Sp) {
  return new Promise(async (resolve) => {
    const pool = await getConnection();
    const request = pool.request();
    request.input("Sp", sql.VarChar(50), Sp);
    const result = await request.execute("BD_Get_Lists_Parameters");
    resolve(result.recordset);
  });
}

function getTypeData(dato, longitud) {
  if (dato == "int") return sql.Int;
  else if (dato == "varchar")
    return sql.VarChar(longitud == -1 ? "max" : longitud);
  else if (dato == "nvarchar")
    return sql.NVarChar(longitud == -1 ? "max" : longitud);
}
