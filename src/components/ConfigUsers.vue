<template>
  <div style="display: flex; justify-content: space-around">
    <div class="Doy_Fe" style="width: 50%">
      <q-card-section>
        <div class="text-h6">Ministros Doy Fe</div>
        <div>
          <q-btn
            color="primary"
            icon="check"
            label="Agregar Doy Fe"
            @click="addNew(1)"
          />
        </div>
      </q-card-section>

      <q-table
        flat
        bordered
        :rows="rows"
        :columns="columns"
        row-key="Id"
        binary-state-sort
        style="width: 100%"
      >
        <template v-slot:body="props">
          <q-tr :props="props">
            <q-td key="Id" :props="props">
              {{ props.row.Id }}
            </q-td>
            <q-td key="Nombre_DoyFe" :props="props">
              <div class="text-pre-wrap">{{ props.row.Nombre_DoyFe }}</div>
              <q-popup-edit
                v-model="props.row.Nombre_DoyFe"
                v-slot="scope"
                :validate="validacionInput"
                @hide="saveRecord(props.row, 'BD_Upd_MinistroDoyFe')"
              >
                <q-input
                  type="text"
                  v-model="scope.value"
                  dense
                  autofocus
                  @keyup.enter="scope.set"
                  hint="Ingresa el Nombre"
                />
              </q-popup-edit>
            </q-td>
            <q-td key="Accion" :props="props">
              <q-btn
                color="negative"
                icon="delete"
                @click="deleteRecord(props.key, 'BD_Invt_MinistrosDoyFe')"
              />
            </q-td>
          </q-tr>
        </template>
      </q-table>
    </div>

    <div class="MinistrosFirmante" style="width: 45%">
      <!-- Tabla De ministros firmantes -->
      <q-card-section>
        <div class="text-h6">Ministros Firmantes</div>
        <div>
          <q-btn
            color="primary"
            icon="check"
            label="Agregar Ministro"
            @click="addNew(2)"
          />
        </div>
      </q-card-section>
      <q-table
        flat
        bordered
        :rows="rows_Ministros"
        :columns="columnsMinistros"
        row-key="Id"
        binary-state-sort
      >
        <template v-slot:body="props">
          <q-tr :props="props">
            <q-td key="Id" :props="props">
              {{ props.row.Id }}
            </q-td>

            <q-td key="Nombre_Firmante" :props="props">
              <div class="text-pre-wrap">{{ props.row.Nombre_Firmante }}</div>
              <q-popup-edit
                v-model="props.row.Nombre_Firmante"
                v-slot="scope"
                buttons
                @cancel="validacionInput('cancel')"
                @save="saveRecord(props.row, 'BD_Upd_MinistroFirmante')"
              >
                <q-input
                  type="text"
                  v-model="scope.value"
                  dense
                  autofocus
                  hint="Ingresa el Nombre del firmante"
                />
              </q-popup-edit>
            </q-td>

            <q-td key="Cargo" :props="props">
              <div class="text-pre-wrap">{{ props.row.Cargo }}</div>
              <q-popup-edit
                v-model="props.row.Cargo"
                v-slot="scope"
                buttons
                @cancel="validacionInput('cancel')"
                @save="saveRecord(props.row, 'BD_Upd_MinistroFirmante')"
              >
                <q-input
                  type="text"
                  v-model="scope.value"
                  dense
                  autofocus
                  hint="Ingresa el Cargo del Ministro"
                />
              </q-popup-edit>
            </q-td>
            <q-td key="Accion" :props="props">
              <q-btn
                color="negative"
                icon="delete"
                @click="deleteRecord(props.key, 'BD_Invt_MinistrosFirmantes')"
              />
            </q-td>
          </q-tr>
        </template>
      </q-table>
    </div>
    <ConfirmModal ref="confirmModal"></ConfirmModal>
  </div>
</template>

<script>
import { defineComponent, ref } from "vue";
import ConfirmModal from "components/ConfirmModal.vue";
const columns = [
  {
    name: "Id",
    required: true,
    label: "No",
    align: "center",
    field: (row) => row.Id,
    sortable: true,
  },
  {
    name: "Nombre_DoyFe",
    align: "center",
    label: "Nombre",
    field: "Nombre_DoyFe",
    sortable: true,
  },
  {
    name: "Accion",
    align: "center",
    label: "Accion",
    field: "Accion",
  },
];
const columnsMinistros = [
  {
    name: "Id",
    required: true,
    label: "No",
    align: "center",
    field: (row) => row.Id,
    sortable: true,
  },
  {
    name: "Nombre_Firmante",
    align: "center",
    label: "Nombre Firmante",
    field: "Nombre_Firmante",
    sortable: true,
  },
  {
    name: "Cargo",
    align: "center",
    label: "Cargo",
    field: "Cargo",
    sortable: true,
  },
  {
    name: "Accion",
    align: "center",
    label: "Accion",
    field: "Accion",
  },
];

export default defineComponent({
  name: "ConfigUsers",
  components: {
    ConfirmModal,
  },
  props: {
    title: { type: String },
  },
  setup() {
    return {
      columns,
      rows: ref([]),

      columnsMinistros,
      rows_Ministros: ref([]),
    };
  },

  mounted() {
    this.getListConfigs();
  },
  methods: {
    validacionInput(val) {},
    saveRecord(row, Sp) {
      try {
        setTimeout(() => {
          let ObjBuilt = {};
          if (Sp.includes("MinistroFirmante"))
            ObjBuilt = {
              Id: row.Id,
              Nombre_Firmante: row.Nombre_Firmante,
              Cargo: row.Cargo,
            };
          else ObjBuilt = { Id: row.Id, Nombre_DoyFe: row.Nombre_DoyFe };
          window.myAPI.executeSp_St(JSON.stringify(ObjBuilt), Sp).then((e) => {
            this.$emit("mostrarMsj", e, "positive", "check");
            //this.getListConfigs();
          });
        }, 500);
      } catch (error) {
        this.getListConfigs();
      }
    },
    getListConfigs() {
      window.myAPI.executeSp_Ds("{}", "BD_Get_Lists_Configs").then((e) => {
        this.rows = e[0];
        this.rows_Ministros = e[1];
      });
    },
    addNew(ev) {
      this.$emit("openModal", ev);
    },
    async deleteRecord(Id, Sp) {
      try {
        await this.$refs.confirmModal.confirm();
        window.myAPI.executeSp_St(JSON.stringify({ Id: Id }), Sp).then((e) => {
          if (e.includes("Error")) this.$emit("mostrarMsj", e, "red", "danger");
          else this.$emit("mostrarMsj", e, "positive", "check");
          this.getListConfigs();
        });
      } catch (err) {}
    },
  },
});
</script>
