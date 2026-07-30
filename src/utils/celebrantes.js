/**
 * Carga opciones de ministros celebrantes (Nombre).
 * Preferencia:
 *  1) result set [2] de BD_Get_Lists_Ministros (si ya se extendió a mano)
 *  2) SP dedicado BD_Get_MinistrosCelebrantes (migración automática)
 */
export async function loadCelebranteNombreOptions(listMinistrosRecordsets) {
  const fromLists = Array.isArray(listMinistrosRecordsets?.[2])
    ? listMinistrosRecordsets[2]
    : [];

  if (fromLists.length) {
    return fromLists.map((r) => r.Nombre).filter(Boolean);
  }

  try {
    const rows = await window.myAPI.executeSp_Ds(
      "{}",
      "BD_Get_MinistrosCelebrantes"
    );
    if (rows?.isError) return [];
    const list = Array.isArray(rows?.[0]) ? rows[0] : [];
    return list.map((r) => r.Nombre).filter(Boolean);
  } catch (_) {
    return [];
  }
}

/**
 * Filas completas (Id, Nombre, Orden) para Configuración.
 */
export async function loadCelebranteRows(listConfigsRecordsets) {
  if (Array.isArray(listConfigsRecordsets?.[4]) && listConfigsRecordsets[4].length) {
    return listConfigsRecordsets[4];
  }

  try {
    const fromMinistros = await window.myAPI.executeSp_Ds(
      "{}",
      "BD_Get_Lists_Ministros"
    );
    if (Array.isArray(fromMinistros?.[2]) && fromMinistros[2].length) {
      return fromMinistros[2];
    }
  } catch (_) {
    /* continue */
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
