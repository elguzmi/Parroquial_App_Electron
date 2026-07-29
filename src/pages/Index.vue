<template>
  <q-page class="dash-page">
    <div class="dash-shell">
      <!-- Hero -->
      <section class="dash-hero">
        <div class="dash-hero__copy">
          <p class="dash-hero__eyebrow">Centro de gestión</p>
          <h1 class="dash-hero__title">Bienvenido al Centro de Gestión</h1>
          <p class="dash-hero__subtitle">
            {{ greetingLine }}
          </p>
        </div>
        <div class="dash-hero__date">
          <q-icon name="event" size="18px" />
          <span>{{ todayLabel }}</span>
        </div>
      </section>

      <!-- KPI cards -->
      <section class="dash-kpis" aria-label="Indicadores por módulo">
        <article
          v-for="kpi in kpiCards"
          :key="kpi.key"
          class="dash-kpi"
          role="button"
          tabindex="0"
          @click="goTo(kpi.route)"
          @keyup.enter="goTo(kpi.route)"
        >
          <div class="dash-kpi__top">
            <div class="dash-kpi__icon" :class="`dash-kpi__icon--${kpi.tone}`">
              <q-icon :name="kpi.icon" size="20px" />
            </div>
            <span class="dash-kpi__badge" :class="`dash-kpi__badge--${kpi.badgeTone}`">
              {{ kpi.badge }}
            </span>
          </div>
          <div class="dash-kpi__label">{{ kpi.label }}</div>
          <div class="dash-kpi__value">{{ formatNumber(kpi.value) }}</div>
          <div class="dash-kpi__hint">{{ kpi.hint }}</div>
        </article>
      </section>

      <!-- Main grid -->
      <section class="dash-grid">
        <!-- Recent activity -->
        <article class="dash-panel dash-activity">
          <header class="dash-panel__head">
            <div class="dash-panel__title-wrap">
              <q-icon name="schedule" size="18px" />
              <h2 class="dash-panel__title">Actividad reciente</h2>
            </div>
            <span class="dash-panel__chip">Datos de demostración</span>
          </header>

          <ul class="dash-activity__list">
            <li
              v-for="item in recentActivity"
              :key="item.id"
              class="dash-activity__row"
            >
              <div
                class="dash-activity__icon"
                :class="`dash-activity__icon--${item.tone}`"
                aria-hidden="true"
              >
                <q-icon :name="item.icon" size="18px" />
              </div>
              <div class="dash-activity__body">
                <div class="dash-activity__main">
                  <strong>{{ item.title }}</strong>
                </div>
                <div class="dash-activity__meta">{{ item.meta }}</div>
              </div>
              <div class="dash-activity__time">{{ item.time }}</div>
            </li>
          </ul>

          <p class="dash-activity__note">
            La auditoría real se conectará cuando exista el SP de actividad.
          </p>
        </article>

        <!-- Side column -->
        <aside class="dash-side">
          <article class="dash-panel">
            <header class="dash-panel__head">
              <div class="dash-panel__title-wrap">
                <q-icon name="bolt" size="18px" />
                <h2 class="dash-panel__title">Accesos directos</h2>
              </div>
            </header>

            <div class="dash-shortcuts">
              <button
                v-for="(action, index) in shortcutActions"
                :key="action.route"
                type="button"
                class="dash-shortcut"
                :class="{
                  'dash-shortcut--primary': index === 0,
                  'dash-shortcut--muted': index > 0,
                }"
                @click="goTo(action.route)"
              >
                <div class="dash-shortcut__icon" aria-hidden="true">
                  <q-icon :name="action.icon" size="20px" />
                </div>
                <div class="dash-shortcut__text">
                  <span class="dash-shortcut__kicker">{{ action.kicker }}</span>
                  <span class="dash-shortcut__label">{{ action.label }}</span>
                </div>
                <q-icon name="chevron_right" size="18px" class="dash-shortcut__chevron" />
              </button>

              <p v-if="!shortcutActions.length" class="dash-empty">
                No hay módulos disponibles para acceso rápido.
              </p>
            </div>
          </article>

          <article v-if="showMonthGlance" class="dash-panel dash-glance">
            <header class="dash-panel__head">
              <div class="dash-panel__title-wrap">
                <q-icon name="calendar_month" size="18px" />
                <h2 class="dash-panel__title">Mes de un vistazo</h2>
              </div>
            </header>

            <ul class="dash-glance__list">
              <li v-for="event in monthGlance" :key="event.id" class="dash-glance__item">
                <div class="dash-glance__date">
                  <span class="dash-glance__month">{{ event.month }}</span>
                  <span class="dash-glance__day">{{ event.day }}</span>
                </div>
                <div class="dash-glance__info">
                  <div class="dash-glance__name">{{ event.title }}</div>
                  <div class="dash-glance__detail">{{ event.detail }}</div>
                </div>
              </li>
            </ul>

            <button
              type="button"
              class="dash-glance__cta"
              @click="goTo(primaryModuleRoute)"
            >
              <q-icon name="add" size="18px" />
              Ir al módulo principal
            </button>
          </article>
        </aside>
      </section>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed } from "vue";
import { useQuasar } from "quasar";
import { useStore } from "vuex";

/** Mock KPIs — reemplazar con SP de totales por módulo */
const MOCK_KPI_BY_MODULE = {
  Bautismos: {
    key: "bautismos",
    label: "Total de bautizos",
    value: 1284,
    badge: "Archivo",
    badgeTone: "blue",
    hint: "Registros históricos simulados",
    icon: "opacity",
    tone: "blue",
  },
  Confirmaciones: {
    key: "confirmaciones",
    label: "Total de confirmaciones",
    value: 742,
    badge: "+8%",
    badgeTone: "gold",
    hint: "Variación ilustrativa del mes",
    icon: "verified_user",
    tone: "teal",
  },
  Matrimonios: {
    key: "matrimonios",
    label: "Total de matrimonios",
    value: 318,
    badge: "Activo",
    badgeTone: "gold",
    hint: "Expedientes en libro parroquial",
    icon: "favorite",
    tone: "gold",
  },
  Defunciones: {
    key: "defunciones",
    label: "Total de defunciones",
    value: 456,
    badge: "Archivo",
    badgeTone: "slate",
    hint: "Partidas registradas (mock)",
    icon: "nights_stay",
    tone: "slate",
  },
};

/** Mock de actividad — reemplazar con SP de auditoría */
const MOCK_RECENT_ACTIVITY = [
  {
    id: 1,
    title: "Bautizo registrado: Sofía V. Méndez",
    meta: "Padres: Roberto Méndez y Ana Lucía V.",
    time: "hace 15 min",
    icon: "opacity",
    tone: "blue",
  },
  {
    id: 2,
    title: "Matrimonio actualizado: Carlos R. y María L.",
    meta: "Expediente Nº 214 · Ministro: Pbro. Juan Pérez",
    time: "hace 1 h",
    icon: "favorite",
    tone: "gold",
  },
  {
    id: 3,
    title: "Confirmación registrada: Andrés P. Ruiz",
    meta: "Grupo pastoral · Libro III, folio 42",
    time: "Ayer",
    icon: "verified_user",
    tone: "teal",
  },
  {
    id: 4,
    title: "Acta de defunción emitida: Elena G. Soto",
    meta: "Documento Word generado desde plantilla",
    time: "Ayer",
    icon: "description",
    tone: "slate",
  },
  {
    id: 5,
    title: "Plantilla Word abierta desde Configuración",
    meta: "TemplateBautismo.docx · carpeta AppData",
    time: "hace 2 días",
    icon: "settings",
    tone: "navy",
  },
];

const MOCK_MONTH_GLANCE = [
  {
    id: 1,
    month: "AGO",
    day: "03",
    title: "Jornada de bautizos",
    detail: "Preparación documental · 10:00 a.m.",
  },
  {
    id: 2,
    month: "AGO",
    day: "12",
    title: "Retiro de confirmación",
    detail: "Grupo juvenil · salón parroquial",
  },
  {
    id: 3,
    month: "AGO",
    day: "24",
    title: "Matrimonios comunitarios",
    detail: "Revisión de expedientes pendientes",
  },
];

const SHORTCUT_META = {
  Bautismos: {
    kicker: "Acceso directo",
    label: "Registrar / consultar bautizos",
    icon: "opacity",
  },
  Confirmaciones: {
    kicker: "Sacramentos",
    label: "Gestionar confirmaciones",
    icon: "verified_user",
  },
  Matrimonios: {
    kicker: "Expedientes",
    label: "Gestionar matrimonios",
    icon: "favorite",
  },
  Defunciones: {
    kicker: "Archivo",
    label: "Consultar defunciones",
    icon: "nights_stay",
  },
  Configuracion: {
    kicker: "Ajustes globales",
    label: "Configurar plantillas y firmantes",
    icon: "settings",
  },
  AcercaDe: {
    kicker: "Institucional",
    label: "Acerca del software",
    icon: "info",
  },
};

export default defineComponent({
  name: "PageIndex",
  setup() {
    const $q = useQuasar();
    const store = useStore();

    const getKeyModules = () => $q.localStorage.getItem("KeyMod");

    return {
      store,
      getKeyModules,
      modulesCards: ref([]),
      recentActivity: MOCK_RECENT_ACTIVITY,
      monthGlance: MOCK_MONTH_GLANCE,
      showMonthGlance: false, // oculto hasta tener datos reales de agenda
    };
  },
  computed: {
    userInfo() {
      return this.store.getters["userInfo/getUserInfo"] || {};
    },
    parishName() {
      return (
        this.userInfo.Parroquia ||
        this.store.state.appConfig?.appConfig?.parroquia ||
        "su parroquia"
      );
    },
    userDisplayName() {
      return (
        this.userInfo.Nombre ||
        this.userInfo.Usuario ||
        this.userInfo.User ||
        "Usuario"
      );
    },
    greetingLine() {
      return `${this.userDisplayName} — ${this.parishName}. Servir con orden es servir con amor.`;
    },
    todayLabel() {
      const raw = new Date().toLocaleDateString("es-CO", {
        weekday: "long",
        day: "numeric",
        month: "long",
      });
      return `Hoy es ${raw}`;
    },
    availableModules() {
      return this.modulesCards.length
        ? this.modulesCards
        : this.allModulesSafe;
    },
    allModulesSafe() {
      try {
        const raw = this.getKeyModules();
        const parsed = raw ? JSON.parse(raw) : [];
        return Array.isArray(parsed) ? parsed : [];
      } catch (_) {
        return [];
      }
    },
    kpiCards() {
      const sacramental = ["Bautismos", "Confirmaciones", "Matrimonios", "Defunciones"];
      const fromModules = sacramental
        .map((mod) => {
          const hasAccess = this.allModulesSafe.some((m) => m.Modulo === mod);
          const mock = MOCK_KPI_BY_MODULE[mod];
          if (!mock) return null;
          return {
            ...mock,
            route: mod,
            // Mostrar KPI aunque el módulo no esté en inicio; si no hay acceso, igual mock visual
            disabled: !hasAccess && this.allModulesSafe.length > 0,
          };
        })
        .filter(Boolean);

      // Si no hay módulos cargados aún, mostrar los 4 mock
      return fromModules.length ? fromModules : Object.values(MOCK_KPI_BY_MODULE).map((m) => ({
        ...m,
        route: m.key === "bautismos"
          ? "Bautismos"
          : m.key === "confirmaciones"
            ? "Confirmaciones"
            : m.key === "matrimonios"
              ? "Matrimonios"
              : "Defunciones",
      }));
    },
    shortcutActions() {
      const preferred = [
        "Bautismos",
        "Confirmaciones",
        "Matrimonios",
        "Defunciones",
        "Configuracion",
      ];
      const mods = this.allModulesSafe.filter((m) => preferred.includes(m.Modulo));
      const list = (mods.length ? mods : this.modulesCards).slice(0, 4);

      return list.map((m) => {
        const meta = SHORTCUT_META[m.Modulo] || {
          kicker: "Módulo",
          label: m.Nombre_Modulo || m.Modulo,
          icon: m.Icono || "folder",
        };
        return {
          route: m.Modulo,
          kicker: meta.kicker,
          label: meta.label,
          icon: meta.icon || m.Icono || "folder",
        };
      });
    },
    primaryModuleRoute() {
      return this.shortcutActions[0]?.route || "Bautismos";
    },
  },
  mounted() {
    this.loadModuleCards();
  },
  methods: {
    loadModuleCards() {
      try {
        const dataModule = JSON.parse(this.getKeyModules() || "[]");
        this.modulesCards = Array.isArray(dataModule)
          ? dataModule.filter((e) => e.Mostrar_Inicio == true)
          : [];
      } catch (_) {
        this.modulesCards = [];
      }
    },
    formatNumber(value) {
      return new Intl.NumberFormat("es-CO").format(Number(value) || 0);
    },
    goTo(nameModule) {
      if (!nameModule) return;
      this.$router.push("/" + nameModule);
    },
    redirect(nameModule) {
      this.goTo(nameModule);
    },
  },
});
</script>

<style lang="scss" scoped>
@import url("https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,650;9..144,700&family=Outfit:wght@300;400;500;600;700&display=swap");

.dash-page {
  --dash-navy: #0b2431;
  --dash-navy-mid: #16303c;
  --dash-gold: #c9a227;
  --dash-gold-soft: #b8922a;
  --dash-muted: #5b7380;
  --dash-line: rgba(11, 36, 49, 0.1);
  --dash-surface: #ffffff;
  --dash-bg: #f3f5f7;
  --dash-radius: 16px;

  min-height: 100%;
  background: var(--dash-bg);
  font-family: "Outfit", sans-serif;
  color: var(--dash-navy-mid);
}

.dash-shell {
  width: min(1180px, 100%);
  margin: 0 auto;
  padding: clamp(1rem, 2.4vw, 1.6rem) clamp(0.9rem, 2.4vw, 1.4rem) 2rem;
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
}

.dash-hero {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 1rem;
  flex-wrap: wrap;
  padding: clamp(1.25rem, 3vw, 1.75rem);
  border-radius: var(--dash-radius);
  background:
    radial-gradient(ellipse 60% 80% at 100% 0%, rgba(201, 162, 39, 0.18), transparent 55%),
    linear-gradient(135deg, #0b2431 0%, #123848 55%, #1a4d57 100%);
  color: #f4f7f8;
  box-shadow: 0 16px 40px rgba(11, 36, 49, 0.18);
}

.dash-hero__eyebrow {
  margin: 0 0 0.35rem;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: rgba(232, 213, 181, 0.9);
}

.dash-hero__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: clamp(1.45rem, 3vw, 2rem);
  font-weight: 700;
  line-height: 1.15;
  color: #f3e7c5;
  letter-spacing: -0.02em;
}

.dash-hero__subtitle {
  margin: 0.55rem 0 0;
  max-width: 52ch;
  font-size: 0.92rem;
  line-height: 1.45;
  color: rgba(244, 247, 248, 0.78);
}

.dash-hero__date {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  padding: 0.65rem 0.9rem;
  border-radius: 12px;
  background: rgba(8, 28, 38, 0.45);
  border: 1px solid rgba(255, 255, 255, 0.1);
  font-size: 0.84rem;
  font-weight: 500;
  color: rgba(244, 247, 248, 0.92);
  text-transform: capitalize;
}

.dash-kpis {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 0.9rem;
}

.dash-kpi {
  background: var(--dash-surface);
  border: 1px solid var(--dash-line);
  border-radius: var(--dash-radius);
  box-shadow: 0 10px 28px rgba(11, 36, 49, 0.05);
  padding: 1rem 1.05rem 1.05rem;
  cursor: pointer;
  transition:
    transform 0.15s ease,
    box-shadow 0.15s ease;
}

.dash-kpi:hover,
.dash-kpi:focus-visible {
  transform: translateY(-2px);
  box-shadow: 0 14px 32px rgba(11, 36, 49, 0.1);
  outline: none;
}

.dash-kpi__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
  margin-bottom: 0.85rem;
}

.dash-kpi__icon {
  width: 38px;
  height: 38px;
  border-radius: 11px;
  display: grid;
  place-items: center;
}

.dash-kpi__icon--blue {
  background: rgba(30, 136, 229, 0.12);
  color: #1565c0;
}

.dash-kpi__icon--teal {
  background: rgba(42, 157, 143, 0.14);
  color: #1f6f78;
}

.dash-kpi__icon--gold {
  background: rgba(201, 162, 39, 0.16);
  color: var(--dash-gold-soft);
}

.dash-kpi__icon--slate {
  background: rgba(11, 36, 49, 0.08);
  color: var(--dash-navy);
}

.dash-kpi__badge {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.02em;
  padding: 0.2rem 0.5rem;
  border-radius: 999px;
}

.dash-kpi__badge--gold {
  background: rgba(201, 162, 39, 0.16);
  color: #8a6a12;
}

.dash-kpi__badge--blue {
  background: rgba(30, 136, 229, 0.12);
  color: #0b5ea8;
}

.dash-kpi__badge--slate {
  background: rgba(11, 36, 49, 0.08);
  color: var(--dash-muted);
}

.dash-kpi__label {
  font-size: 0.84rem;
  color: var(--dash-muted);
  font-weight: 500;
}

.dash-kpi__value {
  margin-top: 0.25rem;
  font-family: "Fraunces", serif;
  font-size: clamp(1.7rem, 3vw, 2.1rem);
  font-weight: 700;
  color: var(--dash-navy);
  line-height: 1.1;
}

.dash-kpi__hint {
  margin-top: 0.35rem;
  font-size: 0.74rem;
  color: rgba(91, 115, 128, 0.9);
}

.dash-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.55fr) minmax(260px, 0.85fr);
  gap: 1rem;
  align-items: start;
}

.dash-panel {
  background: var(--dash-surface);
  border: 1px solid var(--dash-line);
  border-radius: var(--dash-radius);
  box-shadow: 0 10px 28px rgba(11, 36, 49, 0.05);
  padding: 1.05rem 1.1rem 1.15rem;
}

.dash-panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  margin-bottom: 0.85rem;
}

.dash-panel__title-wrap {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  color: var(--dash-navy);
}

.dash-panel__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: 1.12rem;
  font-weight: 650;
}

.dash-panel__chip {
  font-size: 0.7rem;
  font-weight: 600;
  color: var(--dash-gold-soft);
  background: rgba(201, 162, 39, 0.12);
  padding: 0.22rem 0.55rem;
  border-radius: 999px;
}

.dash-activity__list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.dash-activity__row {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 0.75rem;
  align-items: start;
  padding: 0.8rem 0;
  border-bottom: 1px solid var(--dash-line);
}

.dash-activity__row:last-child {
  border-bottom: 0;
  padding-bottom: 0.2rem;
}

.dash-activity__icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: grid;
  place-items: center;
}

.dash-activity__icon--blue {
  background: rgba(30, 136, 229, 0.1);
  color: #1565c0;
}

.dash-activity__icon--gold {
  background: rgba(201, 162, 39, 0.14);
  color: var(--dash-gold-soft);
}

.dash-activity__icon--teal {
  background: rgba(42, 157, 143, 0.12);
  color: #1f6f78;
}

.dash-activity__icon--slate,
.dash-activity__icon--navy {
  background: rgba(11, 36, 49, 0.08);
  color: var(--dash-navy);
}

.dash-activity__main {
  font-size: 0.92rem;
  color: var(--dash-navy);
  line-height: 1.35;
}

.dash-activity__meta {
  margin-top: 0.2rem;
  font-size: 0.8rem;
  color: var(--dash-muted);
}

.dash-activity__time {
  font-size: 0.75rem;
  color: var(--dash-muted);
  white-space: nowrap;
  padding-top: 0.15rem;
}

.dash-activity__note {
  margin: 0.85rem 0 0;
  font-size: 0.76rem;
  color: var(--dash-muted);
}

.dash-side {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.dash-shortcuts {
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}

.dash-shortcut {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 0.7rem;
  width: 100%;
  text-align: left;
  border-radius: 12px;
  border: 1px solid var(--dash-line);
  background: #fff;
  padding: 0.8rem 0.85rem;
  cursor: pointer;
  font-family: inherit;
  transition:
    transform 0.15s ease,
    box-shadow 0.15s ease,
    background-color 0.15s ease;
}

.dash-shortcut--primary {
  background: linear-gradient(135deg, rgba(201, 162, 39, 0.22), rgba(232, 213, 181, 0.35));
  border-color: rgba(201, 162, 39, 0.35);
}

.dash-shortcut:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 20px rgba(11, 36, 49, 0.08);
}

.dash-shortcut__icon {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: grid;
  place-items: center;
  background: rgba(11, 36, 49, 0.06);
  color: var(--dash-navy);
}

.dash-shortcut--primary .dash-shortcut__icon {
  background: rgba(11, 36, 49, 0.12);
  color: var(--dash-navy);
}

.dash-shortcut__text {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.12rem;
}

.dash-shortcut__kicker {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--dash-muted);
}

.dash-shortcut--primary .dash-shortcut__kicker {
  color: #8a6a12;
}

.dash-shortcut__label {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--dash-navy);
}

.dash-shortcut__chevron {
  color: var(--dash-muted);
}

.dash-empty {
  margin: 0;
  font-size: 0.86rem;
  color: var(--dash-muted);
}

.dash-glance__list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.dash-glance__item {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.dash-glance__date {
  width: 46px;
  height: 46px;
  border-radius: 12px;
  background: rgba(11, 36, 49, 0.05);
  border: 1px solid var(--dash-line);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.dash-glance__month {
  font-size: 0.62rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  color: var(--dash-gold-soft);
}

.dash-glance__day {
  font-family: "Fraunces", serif;
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--dash-navy);
  line-height: 1;
}

.dash-glance__name {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--dash-navy);
}

.dash-glance__detail {
  margin-top: 0.15rem;
  font-size: 0.78rem;
  color: var(--dash-muted);
}

.dash-glance__cta {
  margin-top: 1rem;
  width: 100%;
  min-height: 42px;
  border-radius: 12px;
  border: 1.5px dashed rgba(11, 36, 49, 0.22);
  background: transparent;
  color: var(--dash-navy);
  font-family: inherit;
  font-weight: 600;
  font-size: 0.88rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  cursor: pointer;
}

.dash-glance__cta:hover {
  background: rgba(11, 36, 49, 0.04);
  border-color: var(--dash-navy);
}

@media (max-width: 1024px) {
  .dash-kpis {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .dash-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 600px) {
  .dash-kpis {
    grid-template-columns: 1fr;
  }

  .dash-activity__row {
    grid-template-columns: auto 1fr;
  }

  .dash-activity__time {
    grid-column: 2;
    padding-top: 0;
  }
}
</style>
