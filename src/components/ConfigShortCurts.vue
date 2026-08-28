<template>
  <div class="cfg-shortcuts">
    <div class="cfg-panel-head">
      <div>
        <h3 class="cfg-panel-title">Atajos de plantilla</h3>
        <p class="cfg-panel-desc">
          Tokens cortos que el sistema reemplaza al generar documentos Word.
        </p>
      </div>
      <q-btn
        class="cfg-btn cfg-btn--primary"
        unelevated
        no-caps
        icon="add"
        label="Añadir atajo"
        @click="addNew(3)"
      />
    </div>

    <q-table
      class="cfg-table"
      flat
      :rows="rows"
      :columns="columns"
      row-key="Id"
      binary-state-sort
      :loading="loading"
      :pagination="{ rowsPerPage: 8 }"
      no-data-label="No hay atajos configurados"
    >
      <template #body="props">
        <q-tr :props="props" class="cfg-table__row">
          <q-td key="Shortcut" :props="props">
            <code class="cfg-code">{{ props.row.Shortcut }}</code>
          </q-td>
          <q-td key="Template" :props="props">
            <span class="cfg-table__muted">{{ props.row.Template }}</span>
          </q-td>
          <q-td key="Accion" :props="props" auto-width>
            <q-btn
              flat
              dense
              round
              icon="edit"
              color="grey-7"
              aria-label="Editar atajo"
              @click="openEdit(props.row)"
            />
            <q-btn
              flat
              dense
              round
              icon="delete_outline"
              color="negative"
              aria-label="Eliminar atajo"
              @click="deleteRecord(props.row.Id, 'BD_Invt_ShortCut')"
            />
          </q-td>
        </q-tr>
      </template>
    </q-table>

    <q-dialog v-model="editOpen" persistent>
      <q-card class="cfg-dialog">
        <q-card-section class="cfg-dialog__header">
          <div>
            <h2 class="cfg-dialog__title">Editar atajo</h2>
            <p class="cfg-dialog__subtitle">
              Mantenga el mismo formato que usan las plantillas.
            </p>
          </div>
          <q-btn flat round dense icon="close" v-close-popup aria-label="Cerrar" />
        </q-card-section>
        <q-card-section class="cfg-dialog__body">
          <label class="cfg-field-label">Atajo</label>
          <q-input
            v-model="editForm.Shortcut"
            class="cfg-input"
            dense
            outlined
            hide-bottom-space
          />
          <label class="cfg-field-label q-mt-md">Plantilla / valor</label>
          <q-input
            v-model="editForm.Template"
            class="cfg-input"
            dense
            outlined
            hide-bottom-space
          />
        </q-card-section>
        <q-card-actions class="cfg-dialog__actions" align="right">
          <q-btn
            flat
            no-caps
            class="cfg-dialog__cancel"
            label="Cancelar"
            v-close-popup
          />
          <q-btn
            class="cfg-btn cfg-btn--primary"
            unelevated
            no-caps
            label="Guardar"
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

const columns = [
  {
    name: "Shortcut",
    align: "left",
    label: "Atajo",
    field: "Shortcut",
    sortable: true,
  },
  {
    name: "Template",
    align: "left",
    label: "Valor / plantilla",
    field: "Template",
    sortable: true,
  },
  {
    name: "Accion",
    align: "right",
    label: "Acciones",
    field: "Accion",
  },
];

export default defineComponent({
  name: "ConfigShortCuts",
  components: { ConfirmModal },
  emits: ["mostrarMsj", "openModal"],
  setup() {
    return {
      columns,
      rows: ref([]),
      loading: ref(false),
      editOpen: ref(false),
      saving: ref(false),
      editForm: ref({ Id: null, Shortcut: "", Template: "" }),
    };
  },
  mounted() {
    this.getListConfigs();
  },
  methods: {
    getListConfigs() {
      this.loading = true;
      window.myAPI
        .executeSp_Ds("{}", "BD_Get_Lists_Configs")
        .then((e) => {
          this.rows = Array.isArray(e?.[2]) ? e[2] : [];
        })
        .finally(() => {
          this.loading = false;
        });
    },
    addNew(ev) {
      this.$emit("openModal", ev);
    },
    openEdit(row) {
      this.editForm = {
        Id: row.Id,
        Shortcut: row.Shortcut || "",
        Template: row.Template || "",
      };
      this.editOpen = true;
    },
    async saveEdit() {
      if (!String(this.editForm.Shortcut || "").trim()) {
        this.$emit("mostrarMsj", "El atajo es obligatorio", "warning", "warning");
        return;
      }
      this.saving = true;
      try {
        const payload = {
          Id: this.editForm.Id,
          Shortcut: String(this.editForm.Shortcut).trim(),
          Template: String(this.editForm.Template || "").trim(),
        };
        const e = await window.myAPI.executeSp_St(
          JSON.stringify(payload),
          "BD_Upd_ShortCuts"
        );
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
          err?.message || "No se pudo guardar el atajo",
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
        const e = await window.myAPI.executeSp_St(JSON.stringify({ Id }), Sp);
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
