const fs = require("fs");
const os = require("os");
const path = require("path");
const { BrowserWindow, shell } = require("electron");
const templateStore = require("./templateStore");

const MAX_HTML_BYTES = 2 * 1024 * 1024;
const PRINT_OPTIONS = {
  landscape: false,
  printBackground: true,
  pageSize: "Legal",
  margins: {
    marginType: "custom",
    top: 0.18,
    bottom: 0.16,
    left: 0.45,
    right: 0.4,
  },
};

function asHtml(value) {
  if (value == null) return "";
  return String(value);
}

function escapeText(value) {
  return asHtml(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function sanitizeFragment(html) {
  return asHtml(html).replace(/<\/(script|style|iframe|object|embed)/gi, "&lt;/$1");
}

function safePdfFileName(name) {
  const base = path.basename(String(name || "Certificado.pdf"));
  const cleaned = base.replace(/[<>:"/\\|?*\x00-\x1F]/g, "_").trim() || "Certificado.pdf";
  return /\.pdf$/i.test(cleaned) ? cleaned : `${cleaned}.pdf`;
}

function withTimeout(promise, ms, label) {
  let timer;
  const timeout = new Promise((_, reject) => {
    timer = setTimeout(() => {
      reject(new Error(`${label} no respondió (${Math.round(ms / 1000)} s)`));
    }, ms);
  });
  return Promise.race([promise, timeout]).finally(() => clearTimeout(timer));
}

function buildCertificateHtml({ headerHtml, bodyHtml, footerHtml, title } = {}) {
  const header = sanitizeFragment(headerHtml);
  const body = sanitizeFragment(bodyHtml);
  const footer = sanitizeFragment(footerHtml);
  const docTitle = escapeText(title || "Certificado parroquial");

  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <title>${docTitle}</title>
  <style>
    html, body {
      margin: 0;
      padding: 0;
      background: #fff;
      color: #111;
      font-family: Arial, Helvetica, sans-serif;
      font-size: 12pt;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }
    .pdf-sheet {
      min-height: 13.55in;
      display: flex;
      flex-direction: column;
    }
    .pdf-header {
      margin: 0;
      padding: 0;
    }
    .pdf-header,
    .pdf-header .header,
    .pdf-header > *:first-child {
      margin-top: 0 !important;
      padding-top: 0 !important;
    }
    .pdf-header p,
    .pdf-header .title { line-height: 1.35; }
    .pdf-header p { margin: 2px 0; }
    .pdf-body {
      flex: 1 1 auto;
      overflow: hidden;
    }
    .pdf-body::after {
      content: "";
      display: block;
      clear: both;
    }
    .pdf-footer {
      flex: 0 0 auto;
      clear: both;
      width: 100%;
      margin-top: auto;
      margin-bottom: 0;
      padding-top: 6px;
      padding-bottom: 0;
      border-top: 1px solid #111;
      text-align: center;
      font-size: 10.5pt;
      line-height: 1.45;
    }
    .pdf-footer:empty {
      display: none;
      border: 0;
      margin: 0;
      padding: 0;
    }
    .pdf-footer,
    .pdf-footer * {
      float: none !important;
      position: static !important;
      max-width: 100% !important;
    }
    .pdf-footer > * {
      width: 100% !important;
      margin-left: 0 !important;
      margin-right: 0 !important;
      margin-bottom: 0 !important;
      border-top: 0 !important;
    }
    img { max-width: 100%; height: auto; }
    table { border-collapse: collapse; }
  </style>
</head>
<body>
  <div class="pdf-sheet">
    <header class="pdf-header">${header}</header>
    <main class="pdf-body">${body}</main>
    <footer class="pdf-footer">${footer}</footer>
  </div>
</body>
</html>`;
}

function createPrintWindow() {
  return new BrowserWindow({
    show: false,
    width: 850,
    height: 1400,
    skipTaskbar: true,
    focusable: false,
    paintWhenInitiallyHidden: true,
    webPreferences: {
      sandbox: false,
      nodeIntegration: false,
      contextIsolation: true,
      backgroundThrottling: false,
    },
  });
}

async function renderPdfBuffer(win) {
  try {
    return await withTimeout(
      win.webContents.printToPDF(PRINT_OPTIONS),
      12000,
      "Generación del PDF"
    );
  } catch (firstError) {
    console.warn("[pdf] reintento con ventana fuera de pantalla:", firstError.message);
    win.setPosition(-4200, -4200);
    win.showInactive();
    await new Promise((resolve) => setTimeout(resolve, 250));
    return await withTimeout(
      win.webContents.printToPDF(PRINT_OPTIONS),
      12000,
      "Generación del PDF (reintento)"
    );
  }
}

async function printHtmlToPdf(payload = {}) {
  const headerHtml = asHtml(payload.headerHtml);
  const bodyHtml = asHtml(payload.bodyHtml);
  const footerHtml = asHtml(payload.footerHtml);
  const title = asHtml(payload.title || "Certificado parroquial");
  const fileName = safePdfFileName(payload.fileName);

  if (!headerHtml && !bodyHtml && !footerHtml) {
    return { isError: true, errorMessage: "No hay contenido para generar el PDF" };
  }

  const html = buildCertificateHtml({
    headerHtml,
    bodyHtml,
    footerHtml,
    title,
  });

  if (Buffer.byteLength(html, "utf8") > MAX_HTML_BYTES) {
    return { isError: true, errorMessage: "El documento PDF supera el tamaño permitido" };
  }

  const tmpHtml = path.join(
    os.tmpdir(),
    `parroquia-pdf-${Date.now()}-${process.pid}.html`
  );
  fs.writeFileSync(tmpHtml, html, "utf8");
  console.log("[pdf] HTML temporal:", tmpHtml);

  let win = null;
  try {
    win = createPrintWindow();
    await withTimeout(win.loadFile(tmpHtml), 8000, "Carga del documento");

    const buffer = await renderPdfBuffer(win);
    const outPath = templateStore.resolveExportPath(fileName);
    fs.writeFileSync(outPath, buffer);
    console.log("[pdf] archivo:", outPath);

    try {
      const openError = await withTimeout(
        shell.openPath(outPath),
        5000,
        "Apertura del PDF"
      );
      if (openError) {
        return {
          isError: false,
          path: outPath,
          warning: `PDF generado, pero no se pudo abrir automáticamente: ${openError}`,
        };
      }
    } catch (openErr) {
      return {
        isError: false,
        path: outPath,
        warning: `PDF guardado en ${outPath}. ${openErr.message}`,
      };
    }

    return { isError: false, path: outPath };
  } catch (err) {
    console.error("[pdf] error:", err);
    return {
      isError: true,
      errorMessage: err?.message || String(err),
    };
  } finally {
    if (win && !win.isDestroyed()) {
      win.destroy();
    }
    try {
      fs.unlinkSync(tmpHtml);
    } catch (_) {
      /* ignore */
    }
  }
}

module.exports = {
  buildCertificateHtml,
  printHtmlToPdf,
};
