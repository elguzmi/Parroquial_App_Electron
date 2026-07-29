<template>
  <q-layout>
    <q-page-container>
      <q-page class="login-page">
        <div class="login-shell" :style="backgroundStyle">
          <div class="login-shell__veil" aria-hidden="true" />
          <div class="login-shell__glow login-shell__glow--a" aria-hidden="true" />
          <div class="login-shell__glow login-shell__glow--b" aria-hidden="true" />

          <article class="login-card">
            <header class="login-card__header">
              <div class="login-card__logo-wrap">
                <img
                  v-if="logoSrc"
                  class="login-card__logo"
                  :src="logoSrc"
                  :alt="`Logo ${parroquiaName || 'parroquia'}`"
                />
                <div v-else class="login-card__logo-fallback" aria-hidden="true">
                  <q-icon name="account_balance" size="32px" />
                </div>
              </div>

              <h1 class="login-card__title">
                {{ parroquiaName || "Gestión Parroquial" }}
              </h1>
              <p class="login-card__subtitle">Registros eclesiásticos</p>
            </header>

            <q-form class="login-form" autofocus @submit.prevent="tryLogin">
              <div class="login-field">
                <label class="login-field__label" for="login-user">Usuario</label>
                <q-input
                  id="login-user"
                  v-model="userName"
                  class="login-input"
                  type="text"
                  dense
                  outlined
                  placeholder="Nombre de usuario"
                  autocomplete="username"
                  :rules="[(v) => !!v || 'El usuario es obligatorio']"
                  hide-bottom-space
                  required
                >
                  <template #prepend>
                    <q-icon name="person_outline" class="login-input__icon" />
                  </template>
                </q-input>
              </div>

              <div class="login-field">
                <div class="login-field__row">
                  <label class="login-field__label" for="login-password">
                    Contraseña
                  </label>
                </div>
                <q-input
                  id="login-password"
                  v-model="clave"
                  class="login-input"
                  dense
                  outlined
                  placeholder="••••••••"
                  autocomplete="current-password"
                  :type="isPwd ? 'password' : 'text'"
                  :rules="[(v) => !!v || 'La contraseña es obligatoria']"
                  hide-bottom-space
                  required
                >
                  <template #prepend>
                    <q-icon name="lock_outline" class="login-input__icon" />
                  </template>
                  <template #append>
                    <q-icon
                      :name="isPwd ? 'visibility_off' : 'visibility'"
                      class="cursor-pointer login-input__icon"
                      :aria-label="isPwd ? 'Mostrar contraseña' : 'Ocultar contraseña'"
                      @click="isPwd = !isPwd"
                    />
                  </template>
                </q-input>
              </div>

              <q-btn
                class="login-submit"
                type="submit"
                unelevated
                no-caps
                label="Iniciar sesión"
                icon-right="arrow_forward"
              />

              <div class="login-card__footer">
                <p class="login-help">
                  ¿Olvidó sus credenciales?
                  <button
                    type="button"
                    class="login-help__link"
                    @click="showSupportDialog = true"
                  >
                    Contacte al administrador
                  </button>
                </p>

                <q-btn
                  class="login-reconfig"
                  flat
                  dense
                  no-caps
                  icon="settings"
                  label="Reconfigurar"
                  @click="$router.push('/setup/database')"
                />

                <div class="login-card__divider" aria-hidden="true" />

                <p class="login-card__secure">
                  <q-icon name="verified_user" size="14px" />
                  Sistema de gestión parroquial
                </p>
              </div>
            </q-form>
          </article>

          <q-dialog v-model="showSupportDialog">
            <q-card class="login-support">
              <q-card-section class="login-support__header">
                <div class="login-support__badge" aria-hidden="true">
                  <q-icon name="support_agent" size="28px" />
                </div>
                <div>
                  <h2 class="login-support__title">Soporte técnico</h2>
                  <p class="login-support__subtitle">
                    Contacte al administrador para recuperar sus credenciales
                  </p>
                </div>
                <q-btn
                  class="login-support__close"
                  flat
                  round
                  dense
                  icon="close"
                  aria-label="Cerrar"
                  v-close-popup
                />
              </q-card-section>

              <q-card-section class="login-support__body">
                <div class="login-support__company">Kapritecnology</div>
                <div class="login-support__person">Kamilo Prieto</div>

                <ul class="login-support__contacts">
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
              </q-card-section>

              <q-card-actions class="login-support__actions" align="right">
                <q-btn
                  class="login-support__btn"
                  unelevated
                  no-caps
                  label="Entendido"
                  v-close-popup
                />
              </q-card-actions>
            </q-card>
          </q-dialog>
        </div>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";
import { useStore } from "vuex";

export default defineComponent({
  name: "PageLogin",
  data() {
    return {
      fondoSrc: "",
      logoSrc: "",
      showSupportDialog: false,
    };
  },
  computed: {
    parroquiaName() {
      return this.store.state.appConfig.appConfig?.parroquia || "";
    },
    backgroundStyle() {
      if (this.fondoSrc) {
        return { backgroundImage: `url(${this.fondoSrc})` };
      }
      return {
        backgroundImage:
          "linear-gradient(145deg, #0b2431 0%, #123848 42%, #1a4d57 100%)",
      };
    },
  },
  async mounted() {
    if (window.ApiSetup?.isConfigured) {
      const check = await window.ApiSetup.isConfigured();
      if (!check.configured) {
        this.$router.replace("/setup/database");
        return;
      }
    }

    const config = await window.ApiLogin.getConfigParroquia();
    this.store.commit("appConfig/setAppConfig", config);
    await this.loadVisualAssets(config);
  },
  setup() {
    const q = useQuasar();
    const store = useStore();

    function saveLogin(data, cl) {
      store.commit("userInfo/setUserInfo", data);
      q.localStorage.set("SK", JSON.stringify(data));
      if (q.localStorage.has("SK")) cl(true);
      else cl(false);
    }

    function showLoading(msj) {
      q.loading.show({
        message: msj,
      });
    }

    const hideLoading = () => q.loading.hide();

    const showMessage = (msj, color, icon) => {
      q.loading.hide();
      q.notify({
        progress: true,
        message: msj,
        icon: icon,
        color: color,
        textColor: "white",
      });
    };

    return {
      store,
      userName: ref(null),
      clave: ref(null),
      tries: ref(0),
      isPwd: ref(true),
      saveLogin,
      showLoading,
      hideLoading,
      showMessage,
    };
  },
  methods: {
    async resolveAsset(filename) {
      if (!filename) return "";
      if (window.ApiSetup?.getAssetDataUrl) {
        const res = await window.ApiSetup.getAssetDataUrl(filename);
        if (res?.success && res.dataUrl) return res.dataUrl;
      }
      try {
        return require(`src/assets/img/${filename}`);
      } catch (_) {
        return "";
      }
    },
    async loadVisualAssets(config) {
      this.logoSrc = await this.resolveAsset(config?.logo_login);
      this.fondoSrc = await this.resolveAsset(config?.fondo_login);
    },
    tryLogin() {
      const data = { user: this.userName, clave: this.clave };
      this.showLoading("Cargando.. Por favor espera");
      window.ApiLogin.loadLogin(data).then((e) => {
        if (e.success == false) {
          this.showMessage(
            "Error -" + (e.message || e.errorMessage),
            "negative",
            "error"
          );
        } else if (e.data.length > 0) {
          this.saveLogin(e.data[0], () => {
            this.hideLoading();
            this.showMessage(
              "Sesion Iniciada correctamente",
              "positive",
              "check"
            );
            this.$router.push("/Home");
          });
        } else {
          this.tries += 1;
          this.showMessage(
            "Usuario o contraseña incorrecta.",
            "negative",
            "error"
          );
          this.hideLoading();
        }
      });
    },
  },
});
</script>

<style lang="scss" scoped>
@import url("https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,650;9..144,700&family=Outfit:wght@300;400;500;600;700&display=swap");

.login-page {
  --login-navy: #0b2431;
  --login-navy-deep: #16303c;
  --login-gold: #c9a227;
  --login-gold-soft: #b8922a;
  --login-muted: #5b7380;
  --login-line: rgba(11, 36, 49, 0.12);
  --login-fog: rgba(248, 250, 252, 0.55);
  --login-card: rgba(255, 255, 255, 0.96);
  --login-radius: 16px;

  min-height: 100vh;
  padding: 0;
}

.login-shell {
  position: relative;
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: clamp(1.25rem, 4vw, 2.5rem);
  background-color: var(--login-navy);
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  overflow: hidden;
  font-family: "Outfit", sans-serif;
  color: var(--login-navy-deep);
}

.login-shell__veil {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(
      160deg,
      rgba(11, 36, 49, 0.55) 0%,
      rgba(18, 56, 72, 0.42) 45%,
      rgba(11, 36, 49, 0.62) 100%
    ),
    radial-gradient(
      ellipse 70% 50% at 50% 40%,
      rgba(255, 255, 255, 0.08),
      transparent 70%
    );
  pointer-events: none;
}

.login-shell__glow {
  position: absolute;
  width: min(420px, 70vw);
  height: min(420px, 70vw);
  border-radius: 50%;
  filter: blur(90px);
  opacity: 0.28;
  pointer-events: none;
  animation: loginFloat 14s ease-in-out infinite;
}

.login-shell__glow--a {
  top: -12%;
  left: -8%;
  background: #2a9d8f;
}

.login-shell__glow--b {
  right: -10%;
  bottom: -16%;
  background: #c9a227;
  animation-delay: -5s;
}

@keyframes loginFloat {
  0%,
  100% {
    transform: translate(0, 0) scale(1);
  }
  50% {
    transform: translate(16px, -20px) scale(1.05);
  }
}

.login-card {
  position: relative;
  z-index: 1;
  width: min(420px, 100%);
  padding: clamp(1.75rem, 4vw, 2.35rem) clamp(1.5rem, 4vw, 2.1rem)
    clamp(1.35rem, 3vw, 1.75rem);
  border-radius: var(--login-radius);
  background: var(--login-card);
  border: 1px solid rgba(255, 255, 255, 0.65);
  box-shadow:
    0 24px 60px rgba(8, 28, 38, 0.28),
    0 2px 8px rgba(8, 28, 38, 0.08);
  backdrop-filter: blur(12px);
  animation: loginCardIn 0.55s cubic-bezier(0.22, 1, 0.36, 1) both;
}

@keyframes loginCardIn {
  from {
    opacity: 0;
    transform: translateY(14px) scale(0.98);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.login-card__header {
  text-align: center;
  margin-bottom: 1.65rem;
}

.login-card__logo-wrap {
  display: grid;
  place-items: center;
  margin: 0 auto 1rem;
  width: 76px;
  height: 76px;
  border-radius: 50%;
  background: var(--login-navy);
  box-shadow: 0 8px 20px rgba(11, 36, 49, 0.22);
  overflow: hidden;
}

.login-card__logo {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.login-card__logo-fallback {
  display: grid;
  place-items: center;
  width: 100%;
  height: 100%;
  color: var(--login-gold);
}

.login-card__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: clamp(1.35rem, 3.2vw, 1.7rem);
  font-weight: 650;
  line-height: 1.2;
  color: var(--login-navy);
  letter-spacing: -0.01em;
}

.login-card__subtitle {
  margin: 0.4rem 0 0;
  font-size: 0.72rem;
  font-weight: 500;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--login-muted);
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.05rem;
}

.login-field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.login-field__row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
}

.login-field__label {
  font-size: 0.82rem;
  font-weight: 500;
  color: var(--login-navy-deep);
}

.login-input {
  font-family: "Outfit", sans-serif;
}

.login-input :deep(.q-field__control) {
  border-radius: 10px;
  background: #fff;
}

.login-input :deep(.q-field__control::before) {
  border-color: var(--login-line);
}

.login-input :deep(.q-field--outlined.q-field--highlighted .q-field__control::before) {
  border-color: var(--login-navy);
}

.login-input :deep(.q-field__native),
.login-input :deep(.q-field__input) {
  color: var(--login-navy-deep);
}

.login-input :deep(.q-placeholder) {
  color: rgba(91, 115, 128, 0.75);
}

.login-input__icon {
  color: rgba(91, 115, 128, 0.85);
}

.login-submit {
  margin-top: 0.35rem;
  min-height: 46px;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.95rem;
  letter-spacing: 0.01em;
  background: var(--login-navy) !important;
  color: #fff !important;
  transition:
    transform 0.18s ease,
    box-shadow 0.18s ease,
    background-color 0.18s ease;
  box-shadow: 0 10px 24px rgba(11, 36, 49, 0.22);
}

.login-submit:hover {
  background: #123848 !important;
  box-shadow: 0 12px 28px rgba(11, 36, 49, 0.28);
}

.login-submit:active {
  transform: translateY(1px);
}

.login-card__footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.85rem;
  margin-top: 0.25rem;
}

.login-help {
  margin: 0;
  text-align: center;
  font-size: 0.86rem;
  color: var(--login-muted);
  line-height: 1.45;
}

.login-help__link {
  display: inline;
  padding: 0;
  border: 0;
  background: none;
  color: var(--login-gold-soft);
  font: inherit;
  font-weight: 600;
  cursor: pointer;
  text-decoration: underline;
  text-underline-offset: 2px;
}

.login-help__link:hover,
.login-help__link:focus-visible {
  color: var(--login-gold);
  outline: none;
}

.login-reconfig {
  color: var(--login-gold-soft) !important;
  font-weight: 500;
  font-size: 0.88rem;
}

.login-reconfig:hover {
  color: var(--login-gold) !important;
}

.login-card__divider {
  width: 100%;
  height: 1px;
  background: var(--login-line);
}

.login-card__secure {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  margin: 0;
  font-size: 0.75rem;
  color: rgba(91, 115, 128, 0.9);
}

@media (prefers-reduced-motion: reduce) {
  .login-shell__glow,
  .login-card {
    animation: none;
  }
}
</style>

<style lang="scss">
/* Dialog teleported to body — must not be scoped */
.login-support {
  --login-navy: #0b2431;
  --login-navy-deep: #16303c;
  --login-gold: #c9a227;
  --login-gold-soft: #b8922a;
  --login-muted: #5b7380;
  --login-line: rgba(11, 36, 49, 0.12);

  width: min(380px, 92vw);
  border-radius: 16px;
  overflow: hidden;
  font-family: "Outfit", sans-serif;
  color: var(--login-navy-deep);
  box-shadow: 0 24px 60px rgba(8, 28, 38, 0.28);
}

.login-support__header {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 0.85rem;
  align-items: start;
  padding-bottom: 0.5rem;
}

.login-support__badge {
  display: grid;
  place-items: center;
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: var(--login-navy);
  color: var(--login-gold);
}

.login-support__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: 1.2rem;
  font-weight: 650;
  color: var(--login-navy);
  line-height: 1.2;
}

.login-support__subtitle {
  margin: 0.3rem 0 0;
  font-size: 0.82rem;
  color: var(--login-muted);
  line-height: 1.4;
}

.login-support__close {
  color: var(--login-muted);
}

.login-support__body {
  padding-top: 0.25rem;
}

.login-support__company {
  font-family: "Fraunces", serif;
  font-size: 1.05rem;
  font-weight: 650;
  color: var(--login-navy);
}

.login-support__person {
  margin-top: 0.15rem;
  font-size: 0.92rem;
  color: var(--login-muted);
}

.login-support__contacts {
  list-style: none;
  margin: 1rem 0 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
}

.login-support__contacts li {
  display: flex;
  align-items: center;
  gap: 0.55rem;
  padding: 0.7rem 0.8rem;
  border-radius: 10px;
  background: rgba(11, 36, 49, 0.04);
  border: 1px solid var(--login-line);
  color: var(--login-navy);
}

.login-support__contacts a {
  color: inherit;
  text-decoration: none;
  font-weight: 500;
  font-size: 0.9rem;
  word-break: break-all;
}

.login-support__contacts a:hover {
  color: var(--login-gold-soft);
}

.login-support__actions {
  padding: 0 1rem 1rem;
}

.login-support__btn {
  min-height: 40px;
  padding: 0 1.15rem;
  border-radius: 10px;
  font-weight: 600;
  background: var(--login-navy) !important;
  color: #fff !important;
}
</style>
