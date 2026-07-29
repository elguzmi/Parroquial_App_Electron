<template>
  <q-page class="about-page">
    <div class="about-shell">
      <!-- Header -->
      <section class="about-hero">
        <div class="about-hero__copy">
          <p class="about-eyebrow">Institucional</p>
          <h1 class="about-hero__title">
            Software de Gestión Parroquial
          </h1>
          <p class="about-hero__desc">
            Plataforma de escritorio desarrollada por
            <strong>Kapritecnology</strong> para administrar registros
            sacramentales con excelencia tecnológica, uniendo la tradición
            parroquial con una operación digital eficiente, segura y fácil de
            usar.
          </p>

          <div class="about-hero__actions">
            <q-btn
              class="about-btn about-btn--primary"
              unelevated
              no-caps
              icon="menu_book"
              label="Guía rápida"
              @click="showGuideDialog = true"
            />
            <q-btn
              class="about-btn about-btn--ghost"
              outline
              no-caps
              icon="gavel"
              label="Ver licencia"
              @click="showLicenseDialog = true"
            />
          </div>
        </div>

        <aside class="about-brand-card">
          <div class="about-brand-card__logo">
            <img
              src="../assets/img/logo_kapri.jpg"
              alt="Logo Kapritecnology"
            />
          </div>
          <div class="about-brand-card__name">Kapritecnology</div>
          <div class="about-brand-card__meta">
            Soluciones de software a medida
          </div>
          <div class="about-brand-card__team">
            Kamilo Prieto · Santiago Guzmán
          </div>
        </aside>
      </section>

      <!-- Info grid -->
      <section class="about-grid">
        <article class="about-card">
          <div class="about-card__icon about-card__icon--gold">
            <q-icon name="flag" size="22px" />
          </div>
          <h2 class="about-card__title">Nuestra misión</h2>
          <p class="about-card__text">
            Facilitar el trabajo pastoral mediante herramientas digitales
            intuitivas para bautismos, confirmaciones, matrimonios y
            defunciones: consulta ágil, emisión de documentos y control de
            acceso por perfiles, sin perder el rigor de los registros
            eclesiásticos.
          </p>
        </article>

        <article class="about-card">
          <div class="about-card__icon about-card__icon--navy">
            <q-icon name="desktop_windows" size="22px" />
          </div>
          <h2 class="about-card__title">Información del sistema</h2>
          <ul class="about-specs">
            <li>
              <span>Producto</span>
              <strong>{{ productName }}</strong>
            </li>
            <li>
              <span>Versión de software</span>
              <strong>v{{ appVersion }}</strong>
            </li>
            <li>
              <span>Plataforma</span>
              <strong>Escritorio · Electron</strong>
            </li>
            <li>
              <span>Base de datos</span>
              <strong>Microsoft SQL Server</strong>
            </li>
            <li>
              <span>Parroquia activa</span>
              <strong>{{ parroquiaName }}</strong>
            </li>
            <li>
              <span>Estado</span>
              <strong class="about-status">
                <span class="about-status__dot" aria-hidden="true" />
                Operativo
              </strong>
            </li>
          </ul>
        </article>

        <article class="about-card">
          <div class="about-card__icon about-card__icon--gold">
            <q-icon name="headset_mic" size="22px" />
          </div>
          <h2 class="about-card__title">Soporte técnico</h2>
          <p class="about-card__text">
            Asistencia dedicada para instalación, configuración de parroquia,
            recuperación de accesos y acompañamiento en el uso del sistema.
          </p>
          <ul class="about-contacts">
            <li>
              <q-icon name="mail_outline" size="18px" />
              <a href="mailto:kapritecnology@gmail.com">
                kapritecnology@gmail.com
              </a>
            </li>
            <li>
              <q-icon name="phone" size="18px" />
              <a href="tel:+573204102229">320 410 2229</a>
            </li>
          </ul>
        </article>
      </section>

      <!-- Privacy / capabilities banner -->
      <section class="about-banner">
        <div class="about-banner__content">
          <h2 class="about-banner__title">Compromiso de privacidad</h2>
          <p class="about-banner__text">
            Los datos sacramentales permanecen en la infraestructura de la
            parroquia. La aplicación opera en escritorio local con SQL Server,
            perfiles de acceso y actualizaciones controladas para proteger la
            información pastoral.
          </p>
          <ul class="about-banner__list">
            <li>
              <q-icon name="check_circle" size="18px" />
              Acceso por roles y perfiles de usuario
            </li>
            <li>
              <q-icon name="check_circle" size="18px" />
              Configuración local por parroquia (AppData)
            </li>
            <li>
              <q-icon name="check_circle" size="18px" />
              Generación de certificados y exportación a Excel
            </li>
            <li>
              <q-icon name="check_circle" size="18px" />
              Actualizaciones automáticas del cliente de escritorio
            </li>
          </ul>
        </div>

        <div class="about-banner__aside" aria-hidden="true">
          <div class="about-banner__modules">
            <div
              v-for="mod in modules"
              :key="mod.label"
              class="about-banner__chip"
            >
              <q-icon :name="mod.icon" size="18px" />
              {{ mod.label }}
            </div>
          </div>
          <p class="about-banner__aside-copy">
            De la tradición sacramental a una gestión digital ordenada,
            auditable y lista para el día a día parroquial.
          </p>
        </div>
      </section>

      <footer class="about-footer">
        © {{ currentYear }} Kapritecnology · {{ productName }} v{{ appVersion }}
      </footer>
    </div>

    <!-- Guide dialog -->
    <q-dialog v-model="showGuideDialog">
      <q-card class="about-dialog">
        <q-card-section class="about-dialog__header">
          <div>
            <h2 class="about-dialog__title">Guía rápida de uso</h2>
            <p class="about-dialog__subtitle">
              Resumen de los módulos principales del sistema
            </p>
          </div>
          <q-btn flat round dense icon="close" v-close-popup aria-label="Cerrar" />
        </q-card-section>
        <q-card-section class="about-dialog__body">
          <ol class="about-guide">
            <li>
              <strong>Inicio</strong>
              — Acceda a los módulos habilitados según su perfil.
            </li>
            <li>
              <strong>Sacramentos</strong>
              — Registre y consulte bautismos, confirmaciones, matrimonios y
              defunciones.
            </li>
            <li>
              <strong>Documentos</strong>
              — Genere certificados en Word y exporte listados a Excel desde
              cada módulo.
            </li>
            <li>
              <strong>Configuración</strong>
              — Ajuste plantillas y parámetros administrativos según permisos.
            </li>
            <li>
              <strong>Reconfiguración</strong>
              — Desde el login puede volver al asistente de base de datos y
              parroquia si cambia el entorno.
            </li>
          </ol>
          <p class="about-dialog__note">
            Para capacitación o soporte personalizado, contacte a
            Kapritecnology.
          </p>
        </q-card-section>
        <q-card-actions align="right" class="about-dialog__actions">
          <q-btn
            class="about-btn about-btn--primary"
            unelevated
            no-caps
            label="Entendido"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <!-- License dialog -->
    <q-dialog v-model="showLicenseDialog">
      <q-card class="about-dialog">
        <q-card-section class="about-dialog__header">
          <div>
            <h2 class="about-dialog__title">Licencia de uso</h2>
            <p class="about-dialog__subtitle">
              Software propietario · Kapritecnology
            </p>
          </div>
          <q-btn flat round dense icon="close" v-close-popup aria-label="Cerrar" />
        </q-card-section>
        <q-card-section class="about-dialog__body">
          <p>
            <strong>{{ productName }}</strong> es un software de escritorio
            desarrollado y licenciado por <strong>Kapritecnology</strong>
            (Kamilo Prieto · Santiago Guzmán) para la gestión de registros
            parroquiales.
          </p>
          <p>
            El uso está autorizado para la institución parroquial titular de la
            instalación. Queda prohibida la redistribución, ingeniería inversa o
            cesión a terceros sin autorización expresa del proveedor.
          </p>
          <p>
            Los datos ingresados pertenecen a la parroquia. Kapritecnology no
            aloja ni comercializa dicha información; el sistema opera de forma
            local sobre la infraestructura configurada por el cliente.
          </p>
          <p class="about-dialog__note">
            Consultas de licencia:
            <a href="mailto:kapritecnology@gmail.com">kapritecnology@gmail.com</a>
            · 320 410 2229
          </p>
        </q-card-section>
        <q-card-actions align="right" class="about-dialog__actions">
          <q-btn
            class="about-btn about-btn--primary"
            unelevated
            no-caps
            label="Cerrar"
            v-close-popup
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { defineComponent } from "vue";
import { useStore } from "vuex";
import packageInfo from "../../package.json";

export default defineComponent({
  name: "AcercaDe",
  data() {
    return {
      // Fuente confiable: package.json del producto (no la de Electron).
      appVersion: packageInfo.version || "0.0.0",
      productName: "Parroquia App",
      showGuideDialog: false,
      showLicenseDialog: false,
      modules: [
        { label: "Bautismos", icon: "opacity" },
        { label: "Confirmaciones", icon: "auto_awesome" },
        { label: "Matrimonios", icon: "favorite" },
        { label: "Defunciones", icon: "nights_stay" },
      ],
    };
  },
  computed: {
    parroquiaName() {
      const fromConfig = this.store.state.appConfig?.appConfig?.parroquia;
      const fromUser = this.store.getters["userInfo/getUserInfo"]?.Parroquia;
      return fromConfig || fromUser || "Parroquia configurada";
    },
    currentYear() {
      return new Date().getFullYear();
    },
  },
  async mounted() {
    try {
      if (window.ApiUpdate?.getVersion) {
        const version = await window.ApiUpdate.getVersion();
        // Preferimos la API solo si ya corregida (dev/prod); package.json es fallback.
        if (version) this.appVersion = String(version);
      }
    } catch (_) {
      // Se mantiene packageInfo.version
    }
  },
  setup() {
    const store = useStore();
    return { store };
  },
});
</script>

<style lang="scss" scoped>
@import url("https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,650;9..144,700&family=Outfit:wght@300;400;500;600;700&display=swap");

.about-page {
  --about-navy: #0b2431;
  --about-navy-mid: #16303c;
  --about-gold: #c9a227;
  --about-gold-soft: #b8922a;
  --about-muted: #5b7380;
  --about-line: rgba(11, 36, 49, 0.1);
  --about-surface: #ffffff;
  --about-bg: #f3f5f7;
  --about-ok: #067647;
  --about-radius: 16px;

  min-height: 100%;
  background:
    radial-gradient(ellipse 80% 50% at 0% 0%, rgba(42, 157, 143, 0.08), transparent 55%),
    radial-gradient(ellipse 60% 40% at 100% 10%, rgba(201, 162, 39, 0.1), transparent 50%),
    var(--about-bg);
  font-family: "Outfit", sans-serif;
  color: var(--about-navy-mid);
}

.about-shell {
  width: min(1120px, 100%);
  margin: 0 auto;
  padding: clamp(1.25rem, 3vw, 2rem) clamp(1rem, 3vw, 1.75rem) 2rem;
  display: flex;
  flex-direction: column;
  gap: 1.35rem;
}

.about-hero {
  display: grid;
  grid-template-columns: minmax(0, 1.55fr) minmax(240px, 0.7fr);
  gap: 1.25rem;
  align-items: stretch;
}

.about-eyebrow {
  margin: 0 0 0.55rem;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--about-gold-soft);
}

.about-hero__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: clamp(1.7rem, 3.2vw, 2.35rem);
  font-weight: 700;
  line-height: 1.15;
  color: var(--about-navy);
  letter-spacing: -0.02em;
}

.about-hero__desc {
  margin: 0.9rem 0 0;
  max-width: 54ch;
  font-size: 0.98rem;
  line-height: 1.55;
  color: var(--about-muted);
}

.about-hero__desc strong {
  color: var(--about-navy-mid);
  font-weight: 600;
}

.about-hero__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-top: 1.35rem;
}

.about-btn {
  min-height: 42px;
  padding: 0 1.1rem;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.9rem;
}

.about-btn--primary {
  background: var(--about-navy) !important;
  color: #fff !important;
}

.about-btn--ghost {
  color: var(--about-navy) !important;
  border-color: rgba(11, 36, 49, 0.35) !important;
}

.about-brand-card {
  background: var(--about-surface);
  border: 1px solid var(--about-line);
  border-radius: var(--about-radius);
  box-shadow: 0 14px 36px rgba(11, 36, 49, 0.07);
  padding: 1.35rem 1.2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: 0.45rem;
}

.about-brand-card__logo {
  width: 88px;
  height: 88px;
  border-radius: 18px;
  overflow: hidden;
  background: var(--about-navy);
  box-shadow: 0 10px 24px rgba(11, 36, 49, 0.18);
  margin-bottom: 0.55rem;
}

.about-brand-card__logo img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.about-brand-card__name {
  font-family: "Fraunces", serif;
  font-size: 1.2rem;
  font-weight: 650;
  color: var(--about-navy);
}

.about-brand-card__meta {
  font-size: 0.82rem;
  color: var(--about-muted);
}

.about-brand-card__team {
  margin-top: 0.25rem;
  font-size: 0.78rem;
  font-weight: 500;
  color: var(--about-navy-mid);
}

.about-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1rem;
}

.about-card {
  background: var(--about-surface);
  border: 1px solid var(--about-line);
  border-radius: var(--about-radius);
  box-shadow: 0 10px 28px rgba(11, 36, 49, 0.05);
  padding: 1.25rem 1.2rem 1.35rem;
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}

.about-card__icon {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  display: grid;
  place-items: center;
}

.about-card__icon--gold {
  background: rgba(201, 162, 39, 0.14);
  color: var(--about-gold-soft);
}

.about-card__icon--navy {
  background: rgba(11, 36, 49, 0.08);
  color: var(--about-navy);
}

.about-card__title {
  margin: 0;
  font-size: 1.05rem;
  font-weight: 650;
  color: var(--about-navy);
  font-family: "Fraunces", serif;
}

.about-card__text {
  margin: 0;
  font-size: 0.9rem;
  line-height: 1.5;
  color: var(--about-muted);
}

.about-specs {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}

.about-specs li {
  display: flex;
  flex-direction: column;
  gap: 0.12rem;
  padding-bottom: 0.55rem;
  border-bottom: 1px solid var(--about-line);
}

.about-specs li:last-child {
  border-bottom: 0;
  padding-bottom: 0;
}

.about-specs span {
  font-size: 0.75rem;
  color: var(--about-muted);
}

.about-specs strong {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--about-navy);
}

.about-status {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  color: var(--about-ok) !important;
}

.about-status__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--about-ok);
  box-shadow: 0 0 0 3px rgba(6, 118, 71, 0.15);
}

.about-contacts {
  list-style: none;
  margin: 0.35rem 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
}

.about-contacts li {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--about-navy);
  font-size: 0.88rem;
  font-weight: 500;
}

.about-contacts a {
  color: inherit;
  text-decoration: none;
  word-break: break-all;
}

.about-contacts a:hover {
  color: var(--about-gold-soft);
}

.about-banner {
  display: grid;
  grid-template-columns: 1.35fr 0.9fr;
  border-radius: var(--about-radius);
  overflow: hidden;
  box-shadow: 0 16px 40px rgba(11, 36, 49, 0.12);
  min-height: 260px;
}

.about-banner__content {
  background: linear-gradient(155deg, #0b2431 0%, #123848 55%, #1a4d57 100%);
  color: #f4f7f8;
  padding: clamp(1.35rem, 3vw, 1.9rem);
}

.about-banner__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: clamp(1.2rem, 2.4vw, 1.45rem);
  font-weight: 650;
  color: var(--about-gold);
}

.about-banner__text {
  margin: 0.7rem 0 0;
  font-size: 0.92rem;
  line-height: 1.5;
  color: rgba(244, 247, 248, 0.78);
  max-width: 52ch;
}

.about-banner__list {
  list-style: none;
  margin: 1.1rem 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
}

.about-banner__list li {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  font-size: 0.88rem;
  color: rgba(244, 247, 248, 0.92);
}

.about-banner__list .q-icon {
  color: var(--about-gold);
  margin-top: 1px;
}

.about-banner__aside {
  background:
    linear-gradient(160deg, rgba(11, 36, 49, 0.08), rgba(201, 162, 39, 0.12)),
    #eef2f4;
  padding: clamp(1.35rem, 3vw, 1.9rem);
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 1rem;
  border-left: 1px solid rgba(11, 36, 49, 0.06);
}

.about-banner__modules {
  display: flex;
  flex-wrap: wrap;
  gap: 0.55rem;
}

.about-banner__chip {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.45rem 0.7rem;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.85);
  border: 1px solid var(--about-line);
  color: var(--about-navy);
  font-size: 0.8rem;
  font-weight: 600;
}

.about-banner__aside-copy {
  margin: 0;
  font-size: 0.9rem;
  line-height: 1.5;
  color: var(--about-muted);
}

.about-footer {
  text-align: center;
  font-size: 0.78rem;
  color: var(--about-muted);
  padding-top: 0.25rem;
}

@media (max-width: 980px) {
  .about-hero,
  .about-grid,
  .about-banner {
    grid-template-columns: 1fr;
  }

  .about-banner__aside {
    border-left: 0;
    border-top: 1px solid rgba(11, 36, 49, 0.06);
  }
}
</style>

<style lang="scss">
/* Dialogs teleported to body */
.about-dialog {
  --about-navy: #0b2431;
  --about-navy-mid: #16303c;
  --about-gold-soft: #b8922a;
  --about-muted: #5b7380;
  --about-line: rgba(11, 36, 49, 0.1);

  width: min(480px, 94vw);
  border-radius: 16px;
  font-family: "Outfit", sans-serif;
  color: var(--about-navy-mid);
}

.about-dialog__header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.75rem;
}

.about-dialog__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: 1.25rem;
  font-weight: 650;
  color: var(--about-navy);
}

.about-dialog__subtitle {
  margin: 0.3rem 0 0;
  font-size: 0.82rem;
  color: var(--about-muted);
}

.about-dialog__body {
  padding-top: 0;
  font-size: 0.92rem;
  line-height: 1.55;
}

.about-dialog__body p {
  margin: 0 0 0.85rem;
}

.about-dialog__body a {
  color: var(--about-gold-soft);
  font-weight: 600;
  text-decoration: none;
}

.about-guide {
  margin: 0;
  padding-left: 1.15rem;
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
}

.about-dialog__note {
  margin-top: 0.5rem !important;
  font-size: 0.84rem;
  color: var(--about-muted);
}

.about-dialog__actions {
  padding: 0 1rem 1rem;
}

.about-dialog .about-btn--primary {
  background: var(--about-navy) !important;
  color: #fff !important;
  border-radius: 10px;
  font-weight: 600;
  min-height: 40px;
}
</style>
