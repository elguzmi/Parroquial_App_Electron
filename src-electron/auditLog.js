/**
 * Bitácora del home. Electron escribe; un fallo aquí nunca tumba el sacramento.
 */
const sql = require("mssql");

const AUDIT_SP = "BD_Ins_Auditoria";
const CATALOG_SP = "BD_Get_AuditoriaAcciones";

const TEMPLATE_TO_TABLE = {
  "TemplateBautismo.docx": "fact_bautismos",
  "TemplateConfirmacion.docx": "fact_Confirmaciones",
  "TemplateMatrimonio.docx": "fact_Matrimonios",
  "TemplateDefuncion.docx": "fact_Defunciones",
};

const FALLBACK_EVENTS = [
  {
    EventKey: "BD_Ins_Bautismo",
    SourceSp: "BD_Ins_Bautismo",
    Accion: "CREAR",
    Modulo: "Bautismos",
    Tabla: "fact_bautismos",
    TitleTemplate: "Bautizo registrado: {Nombre}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Upd_Bautismo",
    SourceSp: "BD_Upd_Bautismo",
    Accion: "EDITAR",
    Modulo: "Bautismos",
    Tabla: "fact_bautismos",
    TitleTemplate: "Bautizo actualizado: {Nombre}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Invt_Bautismo",
    SourceSp: "BD_Invt_Bautismo",
    Accion: "ELIMINAR",
    Modulo: "Bautismos",
    Tabla: "fact_bautismos",
    TitleTemplate: "Bautizo eliminado",
    DetailTemplate: "Id {Id}",
  },
  {
    EventKey: "BD_Ins_Confirmacion",
    SourceSp: "BD_Ins_Confirmacion",
    Accion: "CREAR",
    Modulo: "Confirmaciones",
    Tabla: "fact_Confirmaciones",
    TitleTemplate: "Confirmación registrada: {Nombre_Confirmado}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Upd_Confirmacion",
    SourceSp: "BD_Upd_Confirmacion",
    Accion: "EDITAR",
    Modulo: "Confirmaciones",
    Tabla: "fact_Confirmaciones",
    TitleTemplate: "Confirmación actualizada: {Nombre_Confirmado}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Invt_Confirmacion",
    SourceSp: "BD_Invt_Confirmacion",
    Accion: "ELIMINAR",
    Modulo: "Confirmaciones",
    Tabla: "fact_Confirmaciones",
    TitleTemplate: "Confirmación eliminada",
    DetailTemplate: "Id {Id}",
  },
  {
    EventKey: "BD_Ins_Matrimonio",
    SourceSp: "BD_Ins_Matrimonio",
    Accion: "CREAR",
    Modulo: "Matrimonios",
    Tabla: "fact_Matrimonios",
    TitleTemplate: "Matrimonio registrado: {Novio} y {Novia}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Upd_Matrimonio",
    SourceSp: "BD_Upd_Matrimonio",
    Accion: "EDITAR",
    Modulo: "Matrimonios",
    Tabla: "fact_Matrimonios",
    TitleTemplate: "Matrimonio actualizado: {Novio} y {Novia}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Invt_Matrimonio",
    SourceSp: "BD_Invt_Matrimonio",
    Accion: "ELIMINAR",
    Modulo: "Matrimonios",
    Tabla: "fact_Matrimonios",
    TitleTemplate: "Matrimonio eliminado",
    DetailTemplate: "Id {Id}",
  },
  {
    EventKey: "BD_Ins_Defuncion",
    SourceSp: "BD_Ins_Defuncion",
    Accion: "CREAR",
    Modulo: "Defunciones",
    Tabla: "fact_Defunciones",
    TitleTemplate: "Defunción registrada: {Nombre_Difunto}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Upd_Defuncion",
    SourceSp: "BD_Upd_Defuncion",
    Accion: "EDITAR",
    Modulo: "Defunciones",
    Tabla: "fact_Defunciones",
    TitleTemplate: "Defunción actualizada: {Nombre_Difunto}",
    DetailTemplate: "Libro {Libro} · Folio {Folio} · N° {Numero}",
  },
  {
    EventKey: "BD_Invt_Defuncion",
    SourceSp: "BD_Invt_Defuncion",
    Accion: "ELIMINAR",
    Modulo: "Defunciones",
    Tabla: "fact_Defunciones",
    TitleTemplate: "Defunción eliminada",
    DetailTemplate: "Id {Id}",
  },
];

["fact_bautismos", "fact_Confirmaciones", "fact_Matrimonios", "fact_Defunciones"].forEach(
  (tabla) => {
    const labels = {
      fact_bautismos: "bautizo",
      fact_Confirmaciones: "confirmación",
      fact_Matrimonios: "matrimonio",
      fact_Defunciones: "defunción",
    };
    const modulos = {
      fact_bautismos: "Bautismos",
      fact_Confirmaciones: "Confirmaciones",
      fact_Matrimonios: "Matrimonios",
      fact_Defunciones: "Defunciones",
    };
    const noun = labels[tabla];
    FALLBACK_EVENTS.push(
      {
        EventKey: `WORD:${tabla}`,
        SourceSp: null,
        Accion: "WORD",
        Modulo: modulos[tabla],
        Tabla: tabla,
        TitleTemplate: `Certificado Word de ${noun}`,
        DetailTemplate: "Id {Id}",
      },
      {
        EventKey: `PDF:${tabla}`,
        SourceSp: null,
        Accion: "PDF",
        Modulo: modulos[tabla],
        Tabla: tabla,
        TitleTemplate: `Certificado PDF de ${noun}`,
        DetailTemplate: "Id {Id}",
      }
    );
  }
);

let currentSession = null;
let catalogCache = null;
let catalogLoadedAt = 0;
const CATALOG_TTL_MS = 10 * 60 * 1000;

function setSession(row, fallbackUser) {
  if (!row || typeof row !== "object") {
    currentSession = fallbackUser
      ? { usuario: String(fallbackUser), nombre: String(fallbackUser) }
      : null;
    return currentSession;
  }
  const usuario =
    pickScalar(row, ["Usuario", "User", "Login"]) || fallbackUser || "";
  const nombre =
    pickScalar(row, ["Nombre", "Nombre_Completo", "NombreCompleto"]) ||
    usuario;
  currentSession = {
    usuario: String(usuario || ""),
    nombre: String(nombre || usuario || ""),
    idPerfil: toInt(row.Id_Perfil ?? row.IdPerfil),
    idUsuario: toInt(row.Id ?? row.Id_Usuario),
  };
  return currentSession;
}

function clearSession() {
  currentSession = null;
}

function getSession() {
  return currentSession;
}

function resetCatalogCache() {
  catalogCache = null;
  catalogLoadedAt = 0;
}

function sessionUserLabel() {
  if (!currentSession) return "Sistema";
  return currentSession.nombre || currentSession.usuario || "Sistema";
}

function pickScalar(obj, keys) {
  if (!obj) return "";
  for (const key of keys) {
    const value = unwrapScalar(obj[key]);
    if (value) return value;
  }
  return "";
}

function unwrapScalar(value) {
  if (value == null || value === "") return "";
  if (typeof value === "object" && !Array.isArray(value) && "value" in value) {
    return unwrapScalar(value.value);
  }
  if (typeof value === "object") return "";
  return String(value).trim();
}

function toInt(value) {
  const n = Number(unwrapScalar(value));
  if (!Number.isFinite(n) || n <= 0) return null;
  return Math.trunc(n);
}

function clip(text, max) {
  const value = String(text || "").trim();
  if (value.length <= max) return value;
  return value.slice(0, Math.max(0, max - 3)) + "...";
}

function isErrorMessage(message) {
  const text = String(message || "");
  return !text || /^error\b/i.test(text.trim());
}

function applyTemplate(template, payload) {
  if (!template) return "";
  return String(template).replace(/\{([A-Za-z0-9_]+)\}/g, (_, key) =>
    unwrapScalar(payload?.[key])
  );
}

function compactText(text) {
  return String(text || "")
    .replace(/:\s*y\s+/gi, ": ")
    .split("·")
    .map((part) => part.trim())
    .filter((part) => {
      if (!part) return false;
      if (/^(Libro|Folio|N°|Nº|Id)\s*$/i.test(part)) return false;
      if (/:\s*$/.test(part)) return false;
      if (/\by\s*$/i.test(part)) return false;
      return true;
    })
    .join(" · ")
    .replace(/\s{2,}/g, " ")
    .replace(/\s+y\s*$/i, "")
    .trim();
}

function lookupCatalog(map, key) {
  if (!map || key == null || key === "") return null;
  const direct = map.get(key);
  if (direct) return direct;
  const wanted = String(key).toLowerCase();
  for (const [entryKey, value] of map.entries()) {
    if (String(entryKey).toLowerCase() === wanted) return value;
  }
  return null;
}

function indexCatalog(rows) {
  const bySp = new Map();
  const byKey = new Map();
  for (const row of rows || []) {
    if (row.SourceSp) bySp.set(String(row.SourceSp), row);
    if (row.EventKey) byKey.set(String(row.EventKey), row);
  }
  return { bySp, byKey };
}

function fallbackCatalog() {
  return indexCatalog(FALLBACK_EVENTS);
}

async function loadCatalog(getConnection) {
  const fresh =
    catalogCache && Date.now() - catalogLoadedAt < CATALOG_TTL_MS;
  if (fresh) return catalogCache;

  try {
    const pool = await getConnection();
    const result = await pool.request().execute(CATALOG_SP);
    const rows = result.recordset || [];
    catalogCache = rows.length ? indexCatalog(rows) : fallbackCatalog();
  } catch (err) {
    console.error("[audit] catálogo:", err?.message || err);
    catalogCache = fallbackCatalog();
  }
  catalogLoadedAt = Date.now();
  return catalogCache;
}

function resolveTabla(payload = {}) {
  const direct =
    unwrapScalar(payload.tabla) ||
    unwrapScalar(payload.Tabla) ||
    unwrapScalar(payload.tablaDirectTo);
  if (direct) return direct;
  const template = unwrapScalar(payload.Nombre_Archivo);
  if (template && TEMPLATE_TO_TABLE[template]) {
    return TEMPLATE_TO_TABLE[template];
  }
  const fileName = unwrapScalar(payload.fileName);
  const fromFile = fileName.match(/^Certificado_(.+)_\d+\.pdf$/i);
  if (fromFile) return fromFile[1];
  return "";
}

function resolveId(payload = {}) {
  return (
    toInt(payload.Id) ||
    toInt(payload.idRegistro) ||
    toInt(payload.IdSelected) ||
    null
  );
}

async function insertAudit(getConnection, event) {
  const pool = await getConnection();
  const request = pool.request();
  request.input("Modulo", sql.NVarChar(50), clip(event.Modulo, 50));
  request.input("Accion", sql.NVarChar(50), clip(event.Accion, 50));
  request.input("Titulo", sql.NVarChar(200), clip(event.Titulo, 200));
  request.input("Detalle", sql.NVarChar(400), clip(event.Detalle, 400) || null);
  request.input("Usuario", sql.NVarChar(120), clip(event.Usuario, 120) || null);
  request.input("IdRegistro", sql.Int, event.IdRegistro);
  request.input("Tabla", sql.NVarChar(128), clip(event.Tabla, 128) || null);
  await request.execute(AUDIT_SP);
}

async function writeFromDefinition(getConnection, definition, payload) {
  if (!definition) return;
  const merged = {
    ...payload,
    Id: resolveId(payload) || unwrapScalar(payload?.Id),
  };
  const titulo =
    compactText(applyTemplate(definition.TitleTemplate, merged)) ||
    definition.TitleTemplate.replace(/\{[^}]+\}/g, "").replace(/:\s*$/, "").trim();
  const detalle = compactText(applyTemplate(definition.DetailTemplate, merged));

  await insertAudit(getConnection, {
    Modulo: definition.Modulo,
    Accion: definition.Accion,
    Titulo: titulo,
    Detalle: detalle,
    Usuario: sessionUserLabel(),
    IdRegistro: resolveId(merged),
    Tabla: definition.Tabla || resolveTabla(merged),
  });
}

async function recordSpAudit(getConnection, spName, payload, resultMessage) {
  try {
    if (isErrorMessage(resultMessage)) return;
    if (!spName || spName === AUDIT_SP) return;
    const catalog = await loadCatalog(getConnection);
    const definition = lookupCatalog(catalog.bySp, spName);
    if (!definition) return;
    await writeFromDefinition(getConnection, definition, payload || {});
  } catch (err) {
    console.error("[audit] SP:", err?.message || err);
  }
}

async function recordDocumentAudit(getConnection, kind, payload) {
  try {
    const data = payload && typeof payload === "object" ? payload : {};
    const tabla = resolveTabla(data);
    if (!tabla) return;
    const catalog = await loadCatalog(getConnection);
    const eventKey = `${String(kind || "").toUpperCase()}:${tabla}`;
    const definition = lookupCatalog(catalog.byKey, eventKey);
    if (!definition) return;
    await writeFromDefinition(getConnection, definition, data);
  } catch (err) {
    console.error("[audit] documento:", err?.message || err);
  }
}

module.exports = {
  setSession,
  clearSession,
  getSession,
  resetCatalogCache,
  recordSpAudit,
  recordDocumentAudit,
  isErrorMessage,
};
