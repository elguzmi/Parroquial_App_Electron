/**
 * Ministro firmante con isCurrent = 1 (misma lista que los formularios).
 */
export async function loadFirmanteVigente() {
  try {
    const e = await window.myAPI.executeSp_Ds("{}", "BD_Get_Lists_Ministros");
    const list = Array.isArray(e?.[1]) ? e[1] : [];
    return (
      list.find((m) => {
        const current = m.isCurrent;
        const isOn =
          current === true ||
          current === 1 ||
          current === "1" ||
          Number(current) === 1;
        return isOn && Number(m.Id) > 0;
      }) || null
    );
  } catch (_) {
    return null;
  }
}

function firmanteNombre(vigente) {
  return String(vigente?.Nombre || vigente?.Nombre_Firmante || "").trim();
}

/**
 * Prioriza el vigente. Si no hay isCurrent, deja el firmante del registro.
 */
export function applyFirmanteVigente(target, vigente) {
  if (!target || !vigente) return target;
  const nombre = firmanteNombre(vigente);
  if (!nombre) return target;
  target.Firmante = nombre;
  if (vigente.Cargo) {
    target.Cargo = vigente.Cargo;
    target.cargo = vigente.Cargo;
  }
  return target;
}

export function applyFirmanteVigenteToHtml(html, vigente) {
  if (!html || !vigente) return html;
  const nombre = firmanteNombre(vigente);
  if (!nombre) return html;
  const cargo = String(vigente.Cargo || "").trim();
  return String(html)
    .replace(/@Firmante/g, nombre)
    .replace(/@cargo/gi, cargo);
}
