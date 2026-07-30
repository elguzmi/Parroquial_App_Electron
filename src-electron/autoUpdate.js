const path = require("path");
const fs = require("fs");
const { app, ipcMain } = require("electron");
const { autoUpdater } = require("electron-updater");

let mainWindowRef = null;
let checking = false;

function sendStatus(payload) {
  if (mainWindowRef && !mainWindowRef.isDestroyed()) {
    mainWindowRef.webContents.send("ApiUpdate:status", payload);
  }
}

/**
 * En `quasar dev`, Electron no empaqueta el package.json de la app, así que
 * `app.getVersion()` suele devolver la versión de Electron (ej. 23.2.0).
 * Preferimos el version del package.json del proyecto.
 */
function getAppVersion() {
  try {
    if (app.isPackaged) {
      return app.getVersion();
    }

    const candidates = [
      path.join(process.cwd(), "package.json"),
      path.join(__dirname, "..", "package.json"),
      path.join(app.getAppPath(), "package.json"),
    ];

    for (const pkgPath of candidates) {
      if (!fs.existsSync(pkgPath)) continue;
      const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
      if (pkg?.version && pkg?.name !== "electron") {
        return String(pkg.version);
      }
    }
  } catch (err) {
    console.warn("[autoUpdate] getAppVersion fallback:", err?.message || err);
  }

  return app.getVersion();
}

function setupAutoUpdater(getMainWindow) {
  mainWindowRef = typeof getMainWindow === "function" ? getMainWindow() : getMainWindow;

  ipcMain.handle("ApiUpdate:getVersion", async () => getAppVersion());

  ipcMain.handle("ApiUpdate:check", async () => {
    if (!app.isPackaged) {
      return { ok: false, reason: "dev" };
    }
    try {
      checking = true;
      const result = await autoUpdater.checkForUpdates();
      return {
        ok: true,
        version: result?.updateInfo?.version || null,
      };
    } catch (err) {
      sendStatus({ type: "error", message: err.message || String(err) });
      return { ok: false, reason: err.message || String(err) };
    } finally {
      checking = false;
    }
  });

  ipcMain.handle("ApiUpdate:install", async () => {
    if (!app.isPackaged) return { ok: false };
    // isSilent=false, isForceRunAfter=true
    setImmediate(() => autoUpdater.quitAndInstall(false, true));
    return { ok: true };
  });

  if (!app.isPackaged) {
    console.log("[autoUpdate] Deshabilitado en desarrollo");
    return;
  }

  autoUpdater.autoDownload = true;
  autoUpdater.autoInstallOnAppQuit = true;

  autoUpdater.on("checking-for-update", () => {
    sendStatus({ type: "checking" });
  });

  autoUpdater.on("update-available", (info) => {
    sendStatus({ type: "available", info });
  });

  autoUpdater.on("update-not-available", (info) => {
    sendStatus({ type: "not-available", info });
  });

  autoUpdater.on("download-progress", (progress) => {
    sendStatus({
      type: "progress",
      progress: {
        percent: progress.percent,
        transferred: progress.transferred,
        total: progress.total,
        bytesPerSecond: progress.bytesPerSecond,
      },
    });
  });

  autoUpdater.on("update-downloaded", (info) => {
    sendStatus({ type: "downloaded", info });
  });

  autoUpdater.on("error", (err) => {
    console.error("[autoUpdate]", err);
    sendStatus({ type: "error", message: err?.message || String(err) });
  });

  // Esperar a que la ventana esté lista antes de consultar
  setTimeout(() => {
    mainWindowRef =
      typeof getMainWindow === "function" ? getMainWindow() : getMainWindow;
    if (!checking) {
      autoUpdater.checkForUpdates().catch((err) => {
        console.error("[autoUpdate] checkForUpdates:", err);
      });
    }
  }, 4000);
}

module.exports = { setupAutoUpdater };
