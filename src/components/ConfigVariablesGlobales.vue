<template>
  <div class="cfg-vars">
    <div class="cfg-panel-head">
      <div>
        <h3 class="cfg-panel-title">Variables del encabezado PDF</h3>
        <p class="cfg-panel-desc">
          Datos institucionales que se insertan en el cabezal de documentos PDF.
          Haga clic en un valor para editarlo.
        </p>
      </div>
    </div>

    <q-table
      class="cfg-table"
      flat
      :rows="rows"
      :columns="columns"
      row-key="Id"
      binary-state-sort
      :loading="loading"
      :pagination="{ rowsPerPage: 10 }"
      no-data-label="No hay variables configuradas"
    >
      <template #body="props">
        <q-tr :props="props" class="cfg-table__row">
          <q-td key="Nombre" :props="props">
            <span class="cfg-table__label">{{ props.row.Nombre }}</span>
          </q-td>
          <q-td key="Valor" :props="props">
            <div class="cfg-table__value-wrap">
              <span class="cfg-table__muted">{{ props.row.Valor || "—" }}</span>
              <q-btn
                flat
                dense
                round
                size="sm"
                icon="edit"
                color="grey-7"
                aria-label="Editar valor"
                @click="openEdit(props.row)"
              />
            </div>
          </q-td>
        </q-tr>
      </template>
    </q-table>

    <q-dialog v-model="editOpen" persistent>
      <q-card class="cfg-dialog">
        <q-card-section class="cfg-dialog__header">
          <div>
            <h2 class="cfg-dialog__title">Editar variable</h2>
            <p class="cfg-dialog__subtitle">{{ editForm.Nombre }}</p>
          </div>
          <q-btn flat round dense icon="close" v-close-popup aria-label="Cerrar" />
        </q-card-section>
        <q-card-section class="cfg-dialog__body">
          <label class="cfg-field-label">Valor</label>
          <q-input
            v-model="editForm.Valor"
            class="cfg-input"
            dense
            outlined
            autogrow
            hide-bottom-space
          />
        </q-card-section>
        <q-card-actions class="cfg-dialog__actions" align="right">
          <q-btn flat no-caps label="Cancelar" v-close-popup />
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
  </div>
</template>

<script>
import { defineComponent, ref } from "vue";

const columns = [
  {
    name: "Nombre",
    align: "left",
    label: "Variable",
    field: "Nombre",
    sortable: true,
  },
  {
    name: "Valor",
    align: "left",
    label: "Valor",
    field: "Valor",
    sortable: true,
  },
];

export default defineComponent({
  name: "ConfigVariablesGlobales",
  emits: ["mostrarMsj"],
  setup() {
    return {
      columns,
      rows: ref([]),
      loading: ref(false),
      editOpen: ref(false),
      saving: ref(false),
      editForm: ref({
        Id: null,
        Nombre: "",
        NombreLocal: "",
        Valor: "",
      }),
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
          this.rows = Array.isArray(e?.[3]) ? e[3] : [];
        })
        .finally(() => {
          this.loading = false;
        });
    },
    openEdit(row) {
      this.editForm = {
        Id: row.Id,
        Nombre: row.Nombre || "",
        NombreLocal: row.NombreLocal || row.Nombre || "",
        Valor: row.Valor || "",
      };
      this.editOpen = true;
    },
    async saveEdit() {
      this.saving = true;
      try {
        const payload = {
          Id: this.editForm.Id,
          NombreLocal: this.editForm.NombreLocal,
          Valor: String(this.editForm.Valor ?? "").trim(),
        };
        const e = await window.myAPI.executeSp_St(
          JSON.stringify(payload),
          "BD_Upd_VariablesGlobales"
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
          err?.message || "No se pudo guardar la variable",
          "negative",
          "error"
        );
      } finally {
        this.saving = false;
      }
    },
  },
});
</script>
