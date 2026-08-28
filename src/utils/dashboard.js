/**
 * Home dashboard: BD_Get_Dashboard
 * [0] KPIs por módulo  [1] actividad (vacío hasta Fact_Auditoria)
 */

const DASHBOARD_SP = "BD_Get_Dashboard";
const ACTIVITY_LIMIT = 8;

export const KPI_PRESENTATION = {
  Bautismos: {
    icon: "opacity",
    tone: "blue",
    badgeTone: "blue",
  },
  Confirmaciones: {
    icon: "verified_user",
    tone: "teal",
    badgeTone: "gold",
  },
  Matrimonios: {
    icon: "favorite",
    tone: "gold",
    badgeTone: "gold",
  },
  Defunciones: {
    icon: "nights_stay",
    tone: "slate",
    badgeTone: "slate",
  },
};

const FALLBACK_KPI_KEYS = Object.keys(KPI_PRESENTATION);

const DEFAULT_PRESENTATION = {
  icon: "folder",
  tone: "slate",
  badgeTone: "slate",
};

function asList(value) {
  return Array.isArray(value) ? value : [];
}

function toCount(value) {
  const n = Number(value);
  return Number.isFinite(n) && n > 0 ? Math.trunc(n) : 0;
}

const FALLBACK_LABELS = {
  Bautismos: "Total de bautizos",
  Confirmaciones: "Total de confirmaciones",
  Matrimonios: "Total de matrimonios",
  Defunciones: "Total de defunciones",
};

function fallbackKpiRows() {
  return FALLBACK_KPI_KEYS.map((ModuleKey) => ({
    ModuleKey,
    Label: FALLBACK_LABELS[ModuleKey] || ModuleKey,
    TotalCount: 0,
    MonthCount: 0,
    SourceAvailable: 0,
  }));
}

function parseSqlLocalDate(value) {
  if (!value && value !== 0) return null;

  if (value instanceof Date) {
    if (Number.isNaN(value.getTime())) return null;
    // mssql (useUTC: true) trata DATETIME2 sin zona como UTC.
    // GETDATE() guarda hora local de la parroquia: relectura a hora local.
    return new Date(
      value.getUTCFullYear(),
      value.getUTCMonth(),
      value.getUTCDate(),
      value.getUTCHours(),
      value.getUTCMinutes(),
      value.getUTCSeconds(),
      value.getUTCMilliseconds()
    );
  }

  const text = String(value).trim();
  if (!text) return null;

  const isoZ = text.match(
    /^(\d{4}-\d{2}-\d{2})[T ](\d{2}:\d{2}:\d{2})(?:\.\d+)?Z$/
  );
  if (isoZ) {
    const local = new Date(`${isoZ[1]}T${isoZ[2]}`);
    return Number.isNaN(local.getTime()) ? null : local;
  }

  const date = new Date(text.includes(" ") ? text.replace(" ", "T") : text);
  return Number.isNaN(date.getTime()) ? null : date;
}

function labelFromMinutes(minutes, dateForFallback) {
  const elapsed = Math.max(0, Math.floor(Number(minutes) || 0));
  if (elapsed < 1) return "ahora";
  if (elapsed < 60) return `hace ${elapsed} min`;
  const hours = Math.floor(elapsed / 60);
  if (hours < 24) return `hace ${hours} h`;
  const days = Math.floor(hours / 24);
  if (days === 1) return "Ayer";
  if (days < 7) return `hace ${days} días`;
  if (dateForFallback instanceof Date && !Number.isNaN(dateForFallback.getTime())) {
    return dateForFallback.toLocaleDateString("es-CO", {
      day: "numeric",
      month: "short",
    });
  }
  return `hace ${days} días`;
}

export function formatRelativeTime(value, minutesAgo) {
  if (minutesAgo != null && minutesAgo !== "" && Number.isFinite(Number(minutesAgo))) {
    return labelFromMinutes(minutesAgo, parseSqlLocalDate(value));
  }

  const date = parseSqlLocalDate(value);
  if (!date) return "";
  return labelFromMinutes(Math.floor((Date.now() - date.getTime()) / 60000), date);
}

export function buildKpiCards(rows, { loading = false } = {}) {
  const source = asList(rows).length ? asList(rows) : fallbackKpiRows();

  return source.map((row) => {
    const key = row.ModuleKey || row.moduleKey;
    const presentation = KPI_PRESENTATION[key] || DEFAULT_PRESENTATION;
    const total = toCount(row.TotalCount);
    const month = toCount(row.MonthCount);
    const available =
      row.SourceAvailable === true || Number(row.SourceAvailable) === 1;

    let badge = "Archivo";
    let badgeTone = presentation.badgeTone;
    let hint = "Total de registros en archivo";

    if (loading) {
      hint = "Consultando archivo parroquial…";
    } else if (!available && !asList(rows).length) {
      hint = "Sin conexión a los totales";
    } else if (!available) {
      hint = "Tabla de registros no disponible";
    } else if (month > 0) {
      badge = `+${month} mes`;
      badgeTone = "gold";
      hint = `${new Intl.NumberFormat("es-CO").format(month)} este mes`;
    }

    return {
      key,
      route: key,
      label: row.Label || `Total de ${key || "registros"}`,
      value: loading ? 0 : total,
      badge,
      badgeTone,
      hint,
      icon: presentation.icon,
      tone: presentation.tone,
      loading,
    };
  });
}

export function mapActivityRows(rows) {
  return asList(rows)
    .filter((row) => row && (row.Id != null || row.Titulo))
    .map((row, index) => {
      const moduleKey = row.Modulo || "";
      const presentation = KPI_PRESENTATION[moduleKey] || DEFAULT_PRESENTATION;
      return {
        id: row.Id ?? `activity-${index}`,
        title: row.Titulo || "Actividad registrada",
        meta: row.Detalle || row.Usuario || "",
        time: formatRelativeTime(row.Fecha, row.MinutosAtras),
        icon:
          row.Accion === "WORD" || row.Accion === "PDF"
            ? "description"
            : presentation.icon,
        tone: presentation.tone,
      };
    });
}

export async function fetchDashboard(topActividad = ACTIVITY_LIMIT) {
  if (!window.myAPI?.executeSp_Ds) {
    throw new Error("API de base de datos no disponible");
  }

  const result = await window.myAPI.executeSp_Ds(
    JSON.stringify({ TopActividad: topActividad }),
    DASHBOARD_SP
  );

  if (result?.isError) {
    throw new Error(result.errorMessage || "No se pudo cargar el dashboard");
  }

  return {
    kpis: asList(result?.[0]),
    activity: mapActivityRows(result?.[1]),
  };
}
