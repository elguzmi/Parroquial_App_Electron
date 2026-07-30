<template>
  <div class="cfg-users">
    <!-- Celebrantes (Ministro / Presidió) -->
    <section class="cfg-users__section">
      <div class="cfg-users__section-head">
        <div>
          <h3 class="cfg-users__section-title">Ministros celebrantes</h3>
          <p class="cfg-users__section-desc">
            Aparecen en Bautizos, Confirmaciones y Matrimonios (campo Ministro /
            Presidió). En el registro se guarda el <strong>nombre</strong>.
          </p>
        </div>
        <q-btn
          class="cfg-btn cfg-btn--primary"
          unelevated
          no-caps
          icon="person_add"
          label="Añadir celebrante"
          @click="addNew(4)"
        />
      </div>

      <div class="cfg-card-grid">
        <article
          v-for="row in rows_Celebrantes"
          :key="'c-' + row.Id"
          class="cfg-person-card cfg-person-card--accent"
        >
          <div class="cfg-person-card__top">
            <div class="cfg-person-card__avatar" aria-hidden="true">
              <q-icon name="account_balance" size="22px" />
            </div>
            <div class="cfg-person-card__identity">
              <div class="cfg-person-card__name">{{ row.Nombre }}</div>
              <span class="cfg-badge cfg-badge--gold">Celebrante</span>
            </div>
            <div class="cfg-person-card__actions">
              <q-btn
                flat
                dense
                round
                icon="edit"
                color="grey-7"
                aria-label="Editar celebrante"
                @click="openEditCelebrante(row)"
              />
              <q-btn
                flat
                dense
                round
                icon="delete_outline"
                color="negative"
                aria-label="Eliminar celebrante"
                @click="deleteRecord(row.Id, 'BD_Invt_MinistroCelebrante')"
              />
            </div>
          </div>
          <div class="cfg-person-card__meta">
            <q-icon name="church" size="16px" />
            <span>Usado en sacramentos · ID {{ row.Id }}</span>
          </div>
        </article>

        <button
          type="button"
          class="cfg-person-card cfg-person-card--add"
          @click="addNew(4)"
        >
          <span class="cfg-person-card__add-icon" aria-hidden="true">
            <q-icon name="add" size="28px" />
          </span>
          <span>Añadir nuevo celebrante</span>
        </button>
      </div>
    </section>

    <!-- Firmantes -->
    <section class="cfg-users__section">
      <div class="cfg-users__section-head">
        <div>
          <h3 class="cfg-users__section-title">Ministros firmantes</h3>
          <p class="cfg-users__section-desc">
            Sacerdotes, diáconos y personal autorizado para firmar documentos.
          </p>
        </div>
        <q-btn
          class="cfg-btn cfg-btn--primary"
          unelevated
          no-caps
          icon="person_add"
          label="Añadir ministro"
          @click="addNew(2)"
        />
      </div>

      <div class="cfg-card-grid">
        <article
          v-for="row in rows_Ministros"
          :key="'f-' + row.Id"
          class="cfg-person-card"
          :class="{ 'cfg-person-card--accent': isPrimaryCargo(row.Cargo) }"
        >
          <div class="cfg-person-card__top">
            <div class="cfg-person-card__avatar" aria-hidden="true">
              <q-icon name="person" size="22px" />
            </div>
            <div class="cfg-person-card__identity">
              <div class="cfg-person-card__name">{{ row.Nombre_Firmante }}</div>
              <span
                class="cfg-badge"
                :class="badgeClass(row.Cargo)"
              >
                {{ row.Cargo || "Sin cargo" }}
              </span>
            </div>
            <div class="cfg-person-card__actions">
              <q-btn
                flat
                dense
                round
                icon="edit"
                color="grey-7"
                aria-label="Editar ministro"
                @click="openEditFirmante(row)"
              />
              <q-btn
                flat
                dense
                round
                icon="delete_outline"
                color="negative"
                aria-label="Eliminar ministro"
                @click="deleteRecord(row.Id, 'BD_Invt_MinistrosFirmantes')"
              />
            </div>
          </div>
          <div class="cfg-person-card__meta">
            <q-icon name="badge" size="16px" />
            <span>Firmante autorizado · ID {{ row.Id }}</span>
          </div>
        </article>

        <button
          type="button"
          class="cfg-person-card cfg-person-card--add"
          @click="addNew(2)"
        >
          <span class="cfg-person-card__add-icon" aria-hidden="true">
            <q-icon name="add" size="28px" />
          </span>
          <span>Añadir nuevo firmante</span>
        </button>
      </div>
    </section>

    <!-- Doy Fe -->
    <section class="cfg-users__section">
      <div class="cfg-users__section-head">
        <div>
          <h3 class="cfg-users__section-title">Ministros “Doy fe”</h3>
          <p class="cfg-users__section-desc">
            Personas que dan fe en actas y certificados sacramentales.
          </p>
        </div>
        <q-btn
          class="cfg-btn cfg-btn--ghost"
          outline
          no-caps
          icon="person_add"
          label="Añadir doy fe"
          @click="addNew(1)"
        />
      </div>

      <div class="cfg-card-grid">
        <article
          v-for="row in rows"
          :key="'d-' + row.Id"
          class="cfg-person-card"
        >
          <div class="cfg-person-card__top">
            <div class="cfg-person-card__avatar cfg-person-card__avatar--gold" aria-hidden="true">
              <q-icon name="verified_user" size="22px" />
            </div>
            <div class="cfg-person-card__identity">
              <div class="cfg-person-card__name">{{ row.Nombre_DoyFe }}</div>
              <span class="cfg-badge cfg-badge--gold">Doy fe</span>
            </div>
            <div class="cfg-person-card__actions">
              <q-btn
                flat
                dense
                round
                icon="edit"
                color="grey-7"
                aria-label="Editar doy fe"
                @click="openEditDoyFe(row)"
              />
              <q-btn
                flat
                dense
                round
                icon="delete_outline"
                color="negative"
                aria-label="Eliminar doy fe"
                @click="deleteRecord(row.Id, 'BD_Invt_MinistrosDoyFe')"
              />
            </div>
          </div>
          <div class="cfg-person-card__meta">
            <q-icon name="history_edu" size="16px" />
            <span>Registro · ID {{ row.Id }}</span>
          </div>
        </article>

        <button
          type="button"
          class="cfg-person-card cfg-person-card--add"
          @click="addNew(1)"
        >
          <span class="cfg-person-card__add-icon" aria-hidden="true">
            <q-icon name="add" size="28px" />
          </span>
          <span>Añadir nuevo doy fe</span>
        </button>
      </div>
    </section>

    <!-- Edit dialogs -->
    <q-dialog v-model="editOpen" persistent>
      <q-card class="cfg-dialog">
        <q-card-section class="cfg-dialog__header">
          <div>
            <h2 class="cfg-dialog__title">{{ editTitle }}</h2>
            <p class="cfg-dialog__subtitle">{{ editSubtitle }}</p>
          </div>
          <q-btn flat round dense icon="close" v-close-popup aria-label="Cerrar" />
        </q-card-section>

        <q-card-section class="cfg-dialog__body">
          <template v-if="editMode === 'firmante'">
            <label class="cfg-field-label">Nombre</label>
            <q-input
              v-model="editForm.Nombre_Firmante"
              class="cfg-input"
              dense
              outlined
              placeholder="Ej. Pbro. Juan Pérez"
              :rules="[(v) => !!String(v || '').trim() || 'El nombre es obligatorio']"
              hide-bottom-space
            />
            <label class="cfg-field-label q-mt-md">Cargo</label>
            <q-input
              v-model="editForm.Cargo"
              class="cfg-input"
              dense
              outlined
              placeholder="Ej. Párroco, Diácono…"
              hide-bottom-space
            />
          </template>

          <template v-else-if="editMode === 'doyfe'">
            <label class="cfg-field-label">Nombre</label>
            <q-input
              v-model="editForm.Nombre_DoyFe"
              class="cfg-input"
              dense
              outlined
              placeholder="Nombre completo"
              :rules="[(v) => !!String(v || '').trim() || 'El nombre es obligatorio']"
              hide-bottom-space
            />
          </template>

          <template v-else>
            <label class="cfg-field-label">Nombre del celebrante</label>
            <q-input
              v-model="editForm.Nombre"
              class="cfg-input"
              dense
              outlined
              placeholder="Ej. LUIS HERNANDO RÍOS ALDANA. PBRO."
              :rules="[(v) => !!String(v || '').trim() || 'El nombre es obligatorio']"
              hide-bottom-space
              @keyup.enter="saveEdit"
            />
            <p class="cfg-dialog__hint">
              Este texto es el que se guarda en los sacramentos (no el Id).
            </p>
          </template>
        </q-card-section>

        <q-card-actions class="cfg-dialog__actions" align="right">
          <q-btn flat no-caps label="Cancelar" v-close-popup />
          <q-btn
            class="cfg-btn cfg-btn--primary"
            unelevated
            no-caps
            label="Guardar cambios"
            :loading="saving"
            @click="saveEdit"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>

    <ConfirmModal ref="confirmModal" />
  </div>
</template>

<script>
import { defineComponent, ref } from "vue";
import ConfirmModal from "components/ConfirmModal.vue";
import { loadCelebranteRows } from "src/utils/celebrantes";

export default defineComponent({
  name: "ConfigUsers",
  components: { ConfirmModal },
  emits: ["mostrarMsj", "openModal"],
  setup() {
    return {
      rows: ref([]),
      rows_Ministros: ref([]),
      rows_Celebrantes: ref([]),
      editOpen: ref(false),
      editMode: ref("firmante"),
      saving: ref(false),
      editForm: ref({
        Id: null,
        Nombre_Firmante: "",
        Cargo: "",
        Nombre_DoyFe: "",
        Nombre: "",
      }),
    };
  },
  computed: {
    editTitle() {
      if (this.editMode === "firmante") return "Editar ministro firmante";
      if (this.editMode === "doyfe") return "Editar ministro doy fe";
      return "Editar ministro celebrante";
    },
    editSubtitle() {
      if (this.editMode === "celebrante") {
        return "El nombre actualizado se usará en nuevos registros sacramentales.";
      }
      return "Los cambios se reflejan en nuevos documentos.";
    },
  },
  mounted() {
    this.getListConfigs();
  },
  methods: {
    isPrimaryCargo(cargo) {
      const c = String(cargo || "").toLowerCase();
      return c.includes("párroco") || c.includes("parroco");
    },
    badgeClass(cargo) {
      return this.isPrimaryCargo(cargo)
        ? "cfg-badge--gold"
        : "cfg-badge--blue";
    },
    async getListConfigs() {
      try {
        const e = await window.myAPI.executeSp_Ds("{}", "BD_Get_Lists_Configs");
        this.rows = Array.isArray(e?.[0]) ? e[0] : [];
        this.rows_Ministros = Array.isArray(e?.[1]) ? e[1] : [];
        this.rows_Celebrantes = await loadCelebranteRows(e);
      } catch (_) {
        this.rows = [];
        this.rows_Ministros = [];
        this.rows_Celebrantes = [];
      }
    },
    addNew(ev) {
      this.$emit("openModal", ev);
    },
    openEditFirmante(row) {
      this.editMode = "firmante";
      this.editForm = {
        Id: row.Id,
        Nombre_Firmante: row.Nombre_Firmante || "",
        Cargo: row.Cargo || "",
        Nombre_DoyFe: "",
        Nombre: "",
      };
      this.editOpen = true;
    },
    openEditDoyFe(row) {
      this.editMode = "doyfe";
      this.editForm = {
        Id: row.Id,
        Nombre_Firmante: "",
        Cargo: "",
        Nombre_DoyFe: row.Nombre_DoyFe || "",
        Nombre: "",
      };
      this.editOpen = true;
    },
    openEditCelebrante(row) {
      this.editMode = "celebrante";
      this.editForm = {
        Id: row.Id,
        Nombre_Firmante: "",
        Cargo: "",
        Nombre_DoyFe: "",
        Nombre: row.Nombre || "",
      };
      this.editOpen = true;
    },
    async saveEdit() {
      if (this.editMode === "firmante") {
        if (!String(this.editForm.Nombre_Firmante || "").trim()) {
          this.$emit("mostrarMsj", "El nombre es obligatorio", "warning", "warning");
          return;
        }
      } else if (this.editMode === "doyfe") {
        if (!String(this.editForm.Nombre_DoyFe || "").trim()) {
          this.$emit("mostrarMsj", "El nombre es obligatorio", "warning", "warning");
          return;
        }
      } else if (!String(this.editForm.Nombre || "").trim()) {
        this.$emit("mostrarMsj", "El nombre es obligatorio", "warning", "warning");
        return;
      }

      this.saving = true;
      try {
        let sp = "";
        let payload = {};

        if (this.editMode === "firmante") {
          sp = "BD_Upd_MinistroFirmante";
          payload = {
            Id: this.editForm.Id,
            Nombre_Firmante: String(this.editForm.Nombre_Firmante).trim(),
            Cargo: String(this.editForm.Cargo || "").trim(),
          };
        } else if (this.editMode === "doyfe") {
          sp = "BD_Upd_MinistroDoyFe";
          payload = {
            Id: this.editForm.Id,
            Nombre_DoyFe: String(this.editForm.Nombre_DoyFe).trim(),
          };
        } else {
          sp = "BD_Upd_MinistroCelebrante";
          payload = {
            Id: this.editForm.Id,
            Nombre: String(this.editForm.Nombre).trim(),
          };
        }

        const e = await window.myAPI.executeSp_St(JSON.stringify(payload), sp);
        if (String(e).includes("Error")) {
          this.$emit("mostrarMsj", e, "negative", "error");
        } else {
          this.$emit("mostrarMsj", e, "positive", "check");
          this.editOpen = false;
          this.getListConfigs();
        }
      } catch (err) {
        this.$emit(
          "mostrarMsj",
          err?.message || "No se pudo guardar el registro",
          "negative",
          "error"
        );
      } finally {
        this.saving = false;
      }
    },
    async deleteRecord(Id, Sp) {
      try {
        await this.$refs.confirmModal.confirm();
        const e = await window.myAPI.executeSp_St(
          JSON.stringify({ Id }),
          Sp
        );
        if (String(e).includes("Error")) {
          this.$emit("mostrarMsj", e, "negative", "error");
        } else {
          this.$emit("mostrarMsj", e, "positive", "check");
        }
        this.getListConfigs();
      } catch (_) {
        // cancelado
      }
    },
  },
});
</script>

<style lang="scss">
.cfg-dialog__hint {
  margin: 0.55rem 0 0;
  font-size: 0.78rem;
  color: var(--cfg-muted, #5b7380);
  line-height: 1.4;
}
</style>
