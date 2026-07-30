<template>
  <section class="setup-panel">
    <header class="setup-panel__header">
      <div class="setup-panel__kicker">
        <q-icon name="dns" size="16px" />
        Conexión SQL Server
      </div>
      <h2 class="setup-panel__title">Configura tu base de datos</h2>
      <p class="setup-panel__subtitle">
        Estos datos se guardan solo en este equipo
        (<strong>AppData</strong>). El mismo instalador sirve para cualquier
        parroquia.
      </p>
    </header>

    <div class="setup-panel__body">
      <q-form class="setup-form-grid" @submit.prevent="onContinue">
        <div class="full">
          <label class="setup-field-label">Servidor / instancia</label>
          <q-input
            v-model="form.server"
            class="setup-input"
            dense
            outlined
            placeholder="EJ: DESKTOP-ABC\\SQLEXPRESS o 192.168.0.10"
            :rules="[(v) => !!v || 'El servidor es obligatorio']"
            hide-bottom-space
          >
            <template #prepend>
              <q-icon name="computer" color="teal-8" />
            </template>
          </q-input>
        </div>

        <div>
          <label class="setup-field-label">Puerto (opcional)</label>
          <q-input
            v-model="form.port"
            class="setup-input"
            dense
            outlined
            type="number"
            placeholder="1433"
            hide-bottom-space
          >
            <template #prepend>
              <q-icon name="settings_ethernet" color="teal-8" />
            </template>
          </q-input>
        </div>

        <div>
          <label class="setup-field-label">Base de datos</label>
          <q-input
            v-model="form.database"
            class="setup-input"
            dense
            outlined
            placeholder="Parroquia_ejemplo"
            :rules="[(v) => !!v || 'La base de datos es obligatoria']"
            hide-bottom-space
          >
            <template #prepend>
              <q-icon name="storage" color="teal-8" />
            </template>
          </q-input>
        </div>

        <div>
          <label class="setup-field-label">Usuario</label>
          <q-input
            v-model="form.user"
            class="setup-input"
            dense
            outlined
            placeholder="sa"
            :rules="[(v) => !!v || 'El usuario es obligatorio']"
            hide-bottom-space
          >
            <template #prepend>
              <q-icon name="person" color="teal-8" />
            </template>
          </q-input>
        </div>

        <div>
          <label class="setup-field-label">Contraseña</label>
          <q-input
            v-model="form.password"
            class="setup-input"
            dense
            outlined
            :type="showPassword ? 'text' : 'password'"
            placeholder="••••••••"
            :rules="[(v) => (v != null && v !== '') || 'La contraseña es obligatoria']"
            hide-bottom-space
          >
            <template #prepend>
              <q-icon name="lock" color="teal-8" />
            </template>
            <template #append>
              <q-icon
                :name="showPassword ? 'visibility_off' : 'visibility'"
                class="cursor-pointer"
                @click="showPassword = !showPassword"
              />
            </template>
          </q-input>
        </div>

        <div class="full row items-center q-gutter-md q-mt-xs">
          <q-toggle
            v-model="form.encrypt"
            color="teal-7"
            label="Cifrado (encrypt)"
            dense
          />
          <q-toggle
            v-model="form.trustServerCertificate"
            color="teal-7"
            label="Confiar en certificado del servidor"
            dense
          />
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
              class="setup-btn setup-btn--outline"
              unelevated
              :loading="testing"
              icon="wifi_tethering"
              label="Probar conexión"
              @click.prevent="testConnection"
            />
          </div>
          <div class="setup-actions__right">
            <q-btn
              class="setup-btn setup-btn--primary"
              unelevated
              type="submit"
              icon-right="arrow_forward"
              label="Continuar"
              :disable="!canContinue"
            />
          </div>
        </div>
      </q-form>
    </div>
  </section>
</template>

<script>
import { computed, defineComponent, onMounted, reactive, ref } from "vue";
import { useRouter } from "vue-router";
import { useQuasar } from "quasar";
import { loadSetupDraft, saveSetupDraft } from "src/utils/setupDraft";

export default defineComponent({
  name: "SetupDatabase",
  setup() {
    const router = useRouter();
    const $q = useQuasar();
    const testing = ref(false);
    const showPassword = ref(false);
    const verified = ref(false);
    const status = reactive({ type: "", message: "" });

    const form = reactive({
      server: "",
      port: "",
      database: "",
      user: "sa",
      password: "",
      encrypt: false,
      trustServerCertificate: true,
    });

    const canContinue = computed(() => {
      return (
        Boolean(form.server && form.database && form.user) &&
        form.password != null &&
        form.password !== "" &&
        verified.value
      );
    });

    function sqlPayload() {
      return {
        server: form.server.trim(),
        port: form.port ? Number(form.port) : null,
        database: form.database.trim(),
        user: form.user.trim(),
        password: form.password,
        encrypt: form.encrypt,
        trustServerCertificate: form.trustServerCertificate,
      };
    }

    onMounted(() => {
      const draft = loadSetupDraft();
      if (draft?.sql) {
        Object.assign(form, {
          server: draft.sql.server || "",
          port: draft.sql.port || "",
          database: draft.sql.database || "",
          user: draft.sql.user || "sa",
          password: draft.sql.password || "",
          encrypt: Boolean(draft.sql.encrypt),
          trustServerCertificate: draft.sql.trustServerCertificate !== false,
        });
        verified.value = Boolean(draft.sqlVerified);
        if (verified.value) {
          status.type = "ok";
          status.message = "Conexión verificada anteriormente. Puedes continuar.";
        }
      }
    });

    async function testConnection() {
      if (!form.server || !form.database || !form.user || form.password === "") {
        status.type = "error";
        status.message = "Completa servidor, base de datos, usuario y contraseña.";
        verified.value = false;
        return;
      }

      if (!window.ApiSetup?.testConnection) {
        status.type = "error";
        status.message =
          "API de configuración no disponible. Ejecuta la app en modo Electron.";
        return;
      }

      testing.value = true;
      status.type = "info";
      status.message = "Probando conexión con SQL Server…";
      verified.value = false;

      try {
        const result = await window.ApiSetup.testConnection(sqlPayload());
        if (result.success) {
          verified.value = true;
          status.type = "ok";
          status.message =
            "Conexión exitosa. La base de datos responde correctamente.";
          saveSetupDraft({ sql: sqlPayload(), sqlVerified: true });
          $q.notify({
            type: "positive",
            message: "Conexión SQL verificada",
            position: "top",
          });
        } else {
          status.type = "error";
          status.message = result.message || "No se pudo conectar al servidor.";
        }
      } catch (err) {
        status.type = "error";
        status.message = err.message || String(err);
      } finally {
        testing.value = false;
      }
    }

    function onContinue() {
      if (!verified.value) {
        status.type = "error";
        status.message = "Debes probar la conexión antes de continuar.";
        return;
      }
      saveSetupDraft({ sql: sqlPayload(), sqlVerified: true });
      router.push("/setup/parroquia");
    }

    return {
      form,
      showPassword,
      testing,
      status,
      canContinue,
      testConnection,
      onContinue,
    };
  },
});
</script>
