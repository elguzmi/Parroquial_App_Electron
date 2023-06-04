<template>
  <div style="display: flex; justify-content: space-around">
    <div class="Doy_Fe" style="width: 40%">
      <q-card-section>
        <div class="text-h6">Ministros Doy Fe</div>
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
          </q-tr>
        </template>
      </q-table>
    </div>
    <div class="MinistrosFirmante" style="width: 40%">
      <!-- Tabla De ministros firmantes -->
      <q-card-section>
        <div class="text-h6">Ministros Firmantes</div>
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
                :validate="validacionInput"
              >
                <q-input
                  type="text"
                  v-model="scope.value"
                  dense
                  autofocus
                  @keyup.enter="scope.set"
                  hint="Ingresa el Nombre del firmante"
                />
              </q-popup-edit>
            </q-td>

            <q-td key="Cargo" :props="props">
              <div class="text-pre-wrap">{{ props.row.Cargo }}</div>
              <q-popup-edit
                v-model="props.row.Cargo"
                v-slot="scope"
                :validate="validacionInput"
              >
                <q-input
                  type="text"
                  v-model="scope.value"
                  dense
                  autofocus
                  @keyup.enter="scope.set"
                  hint="Ingresa el Cargo del Ministro"
                />
              </q-popup-edit>
            </q-td>
          </q-tr>
        </template>
      </q-table>
    </div>
  </div>
</template>

<script>
import { defineComponent, ref } from "vue";
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
];

export default defineComponent({
  name: "ConfigUsers",
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
    console.log("Montado cards");
  },
  methods: {
    validacionInput(val) {
      console.log("valor" + val);
      if (val.length > 5) return true;
      else return false;
    },
    getListConfigs() {
      window.myAPI.getListOfConfigs().then((e) => {
        console.log("Data Config ", e);
        this.rows = e[0];
        console.log(e[1]);
        this.rows_Ministros = e[1];

        //this.hideLoading();
      });
    },
  },
});
</script>
