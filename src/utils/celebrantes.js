/**
 * Catálogo de ministros celebrantes (Nombre) y visibilidad por sacramento.
 *
 * Códigos alineados con dbo.Dim_SacramentosCelebrantes.
 */

export const SACRAMENTO_CELEBRANTE = {
  BAUTISMO: "BAUTISMO",
  CONFIRMACION: "CONFIRMACION",
  MATRIMONIO: "MATRIMONIO",
};

export const DEFAULT_SACRAMENTOS_CELEBRANTE = [
  { Codigo: "BAUTISMO", Nombre: "Bautismo", Orden: 1 },
  { Codigo: "CONFIRMACION", Nombre: "Confirmación", Orden: 2 },
  { Codigo: "MATRIMONIO", Nombre: "Matrimonio", Orden: 3 },
];

export function normalizeSacramentosCatalog(rows) {
  if (Array.isArray(rows) && rows.length) {
    return rows
      .map((r) => ({
        Codigo: String(r.Codigo || "").trim().toUpperCase(),
        Nombre: String(r.Nombre || r.Codigo || "").trim(),
        Orden: Number(r.Orden) || 0,
      }))
      .filter((r) => r.Codigo)
      .sort((a, b) => a.Orden - b.Orden || a.Nombre.localeCompare(b.Nombre, "es"));
  }
  return DEFAULT_SACRAMENTOS_CELEBRANTE.map((r) => ({ ...r }));
}

export function allSacramentoCodigos(catalog) {
  return normalizeSacramentosCatalog(catalog).map((s) => s.Codigo);
}

export function parseCodigosSacramento(value, catalog) {
  if (value == null || value === undefined) {
    return allSacramentoCodigos(catalog);
  }
  return String(value)
    .split(",")
    .map((s) => s.trim().toUpperCase())
    .filter(Boolean);
}

export function joinCodigosSacramento(codigos) {
  return (Array.isArray(codigos) ? codigos : [])
    .map((s) => String(s || "").trim().toUpperCase())
    .filter(Boolean)
    .join(",");
}

export function sacramentoCheckboxOptions(catalog) {
  return normalizeSacramentosCatalog(catalog).map((s) => ({
    label: s.Nombre,
    value: s.Codigo,
  }));
}

export function mergeCurrentCelebranteOption(options, currentNombre) {
  const list = Array.isArray(options) ? [...options] : [];
  const name = String(currentNombre || "").trim();
  if (name && !list.includes(name)) list.unshift(name);
  return list;
}

/**
 * Opciones (nombres) para el combo de un sacramento.
 */
export async function loadCelebranteNombreOptions(codigoSacramento, currentNombre) {
  try {
    const payload = codigoSacramento
      ? { CodigoSacramento: codigoSacramento }
      : {};
    const rows = await window.myAPI.executeSp_Ds(
      JSON.stringify(payload),
      "BD_Get_MinistrosCelebrantes"
    );
    if (rows?.isError) {
      return mergeCurrentCelebranteOption([], currentNombre);
    }
    const list = Array.isArray(rows?.[0]) ? rows[0] : [];
    const names = list.map((r) => r.Nombre).filter(Boolean);
    return mergeCurrentCelebranteOption(names, currentNombre);
  } catch (_) {
    return mergeCurrentCelebranteOption([], currentNombre);
  }
}

/**
 * Filas completas (Id, Nombre, Orden, CodigosSacramento) para Configuración.
 */
export async function loadCelebranteRows(listConfigsRecordsets) {
  if (Array.isArray(listConfigsRecordsets?.[4]) && listConfigsRecordsets[4].length) {
    return listConfigsRecordsets[4];
  }

  try {
    const rows = await window.myAPI.executeSp_Ds(
      "{}",
      "BD_Get_MinistrosCelebrantes"
    );
    if (rows?.isError) return [];
    return Array.isArray(rows?.[0]) ? rows[0] : [];
  } catch (_) {
    return [];
  }
}

export function loadSacramentosCatalog(listConfigsRecordsets) {
  return normalizeSacramentosCatalog(listConfigsRecordsets?.[5]);
}
