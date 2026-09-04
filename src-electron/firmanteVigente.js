function quoteIdent(name) {
  return `[${String(name || "").replace(/]/g, "]]")}]`;
}

function isCurrentValue(value) {
  if (value === true || value === 1 || value === "1") return true;
  if (Buffer.isBuffer(value)) return value[0] === 1;
  if (value && typeof value === "object" && value.data) {
    return Number(value.data[0]) === 1;
  }
  return Number(value) === 1;
}

function replaceLast(text, search, replacement) {
  if (!text || !search || search === replacement) return text;
  const haystack = String(text);
  const needle = String(search);
  const i = haystack.lastIndexOf(needle);
  if (i === -1) return haystack;
  return haystack.slice(0, i) + replacement + haystack.slice(i + needle.length);
}

async function getFirmanteVigente(getConnection) {
  const pool = await getConnection();
  if (!pool) return null;

  const cols = await pool.request().query(`
    SELECT TOP (1) name
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Dim_Ministros_Firmantes', N'U')
      AND LOWER(REPLACE(name, N'_', N'')) = N'iscurrent'
    ORDER BY CASE WHEN LOWER(name) = N'iscurrent' THEN 0 ELSE 1 END
  `);
  const colName = cols.recordset?.[0]?.name;
  if (!colName) return null;

  const result = await pool.request().query(`
    SELECT TOP (1)
      F.Nombre_Firmante AS Nombre,
      F.Cargo
    FROM dbo.Dim_Ministros_Firmantes AS F
    WHERE ISNULL(F.${quoteIdent(colName)}, 0) = 1
    ORDER BY CASE WHEN ISNULL(F.Is_Active, 1) = 1 THEN 0 ELSE 1 END, F.Id_Ministro
  `);
  const row = result.recordset?.[0];
  const nombre = String(row?.Nombre || "").trim();
  if (!nombre) return null;
  return {
    Nombre: nombre,
    Cargo: String(row.Cargo || "").trim(),
  };
}

function applyFirmanteToWordData(obj, vigente) {
  if (!obj || !vigente?.Nombre) return obj;
  obj.Firmante = vigente.Nombre;
  obj.Nombre_Firmante = vigente.Nombre;
  if (vigente.Cargo) {
    obj.Cargo = vigente.Cargo;
    obj.cargo = vigente.Cargo;
  }
  return obj;
}

function applyFirmanteToHtml(html, vigente, anterior = {}) {
  if (!html || !vigente?.Nombre) return html;
  let next = String(html)
    .replace(/@Firmante/g, vigente.Nombre)
    .replace(/@cargo/gi, vigente.Cargo || "");

  const oldName = String(anterior.Firmante || "").trim();
  if (oldName && oldName !== vigente.Nombre) {
    next = replaceLast(next, oldName, vigente.Nombre);
  }
  const oldCargo = String(anterior.Cargo || "").trim();
  if (oldCargo && vigente.Cargo && oldCargo !== vigente.Cargo) {
    next = replaceLast(next, oldCargo, vigente.Cargo);
  }
  return next;
}

module.exports = {
  isCurrentValue,
  getFirmanteVigente,
  applyFirmanteToWordData,
  applyFirmanteToHtml,
};
