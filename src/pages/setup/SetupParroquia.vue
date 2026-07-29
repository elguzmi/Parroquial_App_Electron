<template>
  <section class="setup-panel">
    <header class="setup-panel__header">
      <div class="setup-panel__kicker">
        <q-icon name="account_balance" size="16px" />
        Identidad visual
      </div>
      <h2 class="setup-panel__title">Personaliza la parroquia</h2>
      <p class="setup-panel__subtitle">
        Define el nombre, el color institucional y las imágenes que verán los
        usuarios en el login. Puedes omitir assets y usar valores por defecto.
      </p>
    </header>

    <div class="setup-panel__body">
      <q-form class="setup-form-grid" @submit.prevent="onFinish">
        <div class="full">
          <label class="setup-field-label">Nombre de la parroquia</label>
          <q-input
            v-model="form.nombre"
            class="setup-input"
            dense
            outlined
            placeholder="Ej: Parroquia Jesús Eucaristía"
            :rules="[(v) => !!v || 'El nombre es obligatorio']"
            hide-bottom-space
          >
            <template #prepend>
              <q-icon name="badge" color="teal-8" />
            </template>
          </q-input>
        </div>

        <div class="full">
          <label class="setup-field-label">Color institucional</label>
          <div class="setup-color-row">
            <div
              class="setup-color-swatch"
              :style="{ background: form.color }"
            />
            <q-input
              v-model="form.color"
              class="setup-input col"
              dense
              outlined
              placeholder="#0f4c81"
              hide-bottom-space
            >
              <template #append>
                <q-icon name="palette" class="cursor-pointer">
                  <q-popup-proxy cover transition-show="scale" transition-hide="scale">
                    <q-color v-model="form.color" />
                  </q-popup-proxy>
                </q-icon>
              </template>
            </q-input>
          </div>
        </div>

        <div class="full">
          <label class="setup-field-label">Assets visuales</label>
          <div class="setup-asset-grid">
            <article class="setup-asset-card">
              <div
                class="setup-asset-card__preview is-logo"
                :class="{ 'has-image': Boolean(previews.logo_login) }"
              >
                <img
                  v-if="previews.logo_login"
                  :src="previews.logo_login"
                  alt="Logo login"
                />
                <q-icon v-else name="image" size="36px" color="blue-grey-4" />
              </div>
              <div class="setup-asset-card__meta">
                <div class="setup-asset-card__name">Logo de login</div>
                <div class="setup-asset-card__hint">PNG / JPG recomendado</div>
                <q-btn
                  class="setup-btn setup-btn--ghost"
                  dense
                  unelevated
                  size="sm"
                  icon="upload"
                  :label="form.logo_login ? 'Cambiar' : 'Subir'"
                  :loading="picking === 'logo_login'"
                  @click.prevent="pickAsset('logo_login')"
                />
              </div>
            </article>

            <article class="setup-asset-card">
              <div class="setup-asset-card__preview">
                <img
                  v-if="previews.fondo_login"
                  :src="previews.fondo_login"
                  alt="Fondo login"
                />
                <q-icon
                  v-else
                  name="wallpaper"
                  size="36px"
                  color="blue-grey-4"
                />
              </div>
              <div class="setup-asset-card__meta">
                <div class="setup-asset-card__name">Fondo de login</div>
                <div class="setup-asset-card__hint">Imagen panorámica</div>
                <q-btn
                  class="setup-btn setup-btn--ghost"
                  dense
                  unelevated
                  size="sm"
                  icon="upload"
                  :label="form.fondo_login ? 'Cambiar' : 'Subir'"
                  :loading="picking === 'fondo_login'"
                  @click.prevent="pickAsset('fondo_login')"
                />
              </div>
            </article>

            <article class="setup-asset-card">
              <div class="setup-asset-card__preview is-logo">
                <img
                  v-if="previews.logo"
                  :src="previews.logo"
                  alt="Icono app"
                />
                <q-icon
                  v-else
                  name="apps"
                  size="36px"
                  color="blue-grey-4"
                />
              </div>
              <div class="setup-asset-card__meta">
                <div class="setup-asset-card__name">Icono de ventana</div>
                <div class="setup-asset-card__hint">Cuadrado, ideal .ico/.png</div>
                <q-btn
                  class="setup-btn setup-btn--ghost"
                  dense
                  unelevated
                  size="sm"
                  icon="upload"
                  :label="form.logo ? 'Cambiar' : 'Subir'"
                  :loading="picking === 'logo'"
                  @click.prevent="pickAsset('logo')"
                />
              </div>
            </article>
          </div>
        </div>

        <div v-if="status.message" class="full">
          <div
            class="setup-status"
            :class="{
              'setup-status--ok': status.type === 'ok',
              'setup-status--error': status.type === 'error',
              'setup-status--info': status.type === 'info',
            }"
          >
            <q-icon
              :name="
                status.type === 'ok'
                  ? 'check_circle'
                  : status.type === 'error'
                  ? 'error'
                  : 'info'
              "
              size="20px"
            />
            <span>{{ status.message }}</span>
          </div>
        </div>

        <div class="full setup-actions">
          <div class="setup-actions__left">
            <q-btn
              class="setup-btn setup-btn--ghost"
              unelevated
              icon="arrow_back"
              label="Volver"
              @click.prevent="goBack"
            />
          </div>
          <div class="setup-actions__right">
            <q-btn
              class="setup-btn setup-btn--primary"
              unelevated
              type="submit"
              icon-right="check"
              label="Guardar y finalizar"
              :loading="saving"
            />
          </div>
        </div>
      </q-form>
    </div>
  </section>
</template>

<script>
import { defineComponent, onMounted, reactive, ref } from "vue";
import { useRouter } from "vue-router";
import { useQuasar } from "quasar";
import { useStore } from "vuex";
import {
  clearSetupDraft,
  hasSqlDraft,
  loadSetupDraft,
  saveSetupDraft,
} from "src/utils/setupDraft";

export default defineComponent({
  name: "SetupParroquia",
  setup() {
    const router = useRouter();
    const $q = useQuasar();
    const store = useStore();
    const saving = ref(false);
    const picking = ref("");
    const status = reactive({ type: "", message: "" });

    const form = reactive({
      nombre: "",
      color: "#0f4c81",
      logo: "",
      fondo_login: "",
      logo_login: "",
    });

    const previews = reactive({
      logo: "",
      fondo_login: "",
      logo_login: "",
    });

    onMounted(() => {
      if (!hasSqlDraft()) {
        $q.notify({
          type: "warning",
          message: "Primero configura y verifica la base de datos.",
          position: "top",
        });
        router.replace("/setup/database");
        return;
      }

      const draft = loadSetupDraft();
      if (draft?.parroquia) {
        Object.assign(form, {
          nombre: draft.parroquia.nombre || "",
          color: draft.parroquia.color || "#0f4c81",
          logo: draft.parroquia.logo || "",
          fondo_login: draft.parroquia.fondo_login || "",
          logo_login: draft.parroquia.logo_login || "",
        });
        Object.assign(previews, draft.previews || {});
      }
    });

    async function pickAsset(kind) {
      if (!window.ApiSetup?.pickImage) {
        status.type = "error";
        status.message =
          "API de configuración no disponible. Ejecuta la app en modo Electron.";
        return;
      }

      picking.value = kind;
      try {
        const result = await window.ApiSetup.pickImage(kind);
        if (result.canceled) return;
        if (!result.success) {
          status.type = "error";
          status.message = result.message || "No se pudo cargar la imagen.";
          return;
        }
        form[kind] = result.filename;
        previews[kind] = result.dataUrl;
        saveSetupDraft({
          parroquia: { ...form },
          previews: { ...previews },
        });
        status.type = "ok";
        status.message = "Imagen lista. Se guardará en AppData al finalizar.";
      } catch (err) {
        status.type = "error";
        status.message = err.message || String(err);
      } finally {
        picking.value = "";
      }
    }

    function goBack() {
      saveSetupDraft({
        parroquia: { ...form },
        previews: { ...previews },
      });
      router.push("/setup/database");
    }

    async function onFinish() {
      if (!form.nombre?.trim()) {
        status.type = "error";
        status.message = "El nombre de la parroquia es obligatorio.";
        return;
      }

      const draft = loadSetupDraft();
      if (!draft?.sql || !draft.sqlVerified) {
        router.replace("/setup/database");
        return;
      }

      if (!window.ApiSetup?.saveConfig) {
        status.type = "error";
        status.message =
          "API de configuración no disponible. Ejecuta la app en modo Electron.";
        return;
      }

      saving.value = true;
      status.type = "info";
      status.message = "Guardando configuración en AppData…";

      try {
        const result = await window.ApiSetup.saveConfig({
          sql: draft.sql,
          parroquia: {
            nombre: form.nombre.trim(),
            color: form.color || "#0f4c81",
            logo: form.logo || "",
            fondo_login: form.fondo_login || "",
            logo_login: form.logo_login || "",
          },
        });

        if (!result.success) {
          status.type = "error";
          status.message = result.message || "No se pudo guardar la configuración.";
          return;
        }

        clearSetupDraft();
        if (result.data) {
          store.commit("appConfig/setAppConfig", result.data);
        }

        $q.notify({
          type: "positive",
          message: "Configuración guardada. Ya puedes iniciar sesión.",
          position: "top",
        });
        router.replace("/");
      } catch (err) {
        status.type = "error";
        status.message = err.message || String(err);
      } finally {
        saving.value = false;
      }
    }

    return {
      form,
      previews,
      picking,
      saving,
      status,
      pickAsset,
      goBack,
      onFinish,
    };
  },
});
</script>
