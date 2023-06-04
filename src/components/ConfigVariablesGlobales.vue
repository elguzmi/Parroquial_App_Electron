<template>
  <q-card-section>
    <div class="text-h6">Datos Generales</div>
  </q-card-section>

  <q-table
    flat
    bordered
    :rows="rows"
    :columns="columns"
    row-key="Id"
    binary-state-sort
    class="my-sticky-column-table"
    :visible-columns="['Nombre', 'Valor']"
  >
    <template v-slot:body="props">
      <q-tr :props="props">
        <q-td key="Id" :props="props">
          {{ props.row.Id }}
        </q-td>
        <q-td key="Nombre" :props="props">
          <div class="text-pre-wrap">{{ props.row.Nombre }}</div>
        </q-td>
        <q-td key="Valor" :props="props">
          <div class="text-pre-wrap">{{ props.row.Valor }}</div>
          <q-popup-edit
            v-model="props.row.Valor"
            v-slot="scope"
            :validate="validacionInput"
            @hide="saveRecord(props.row)"
          >
            <q-input
              type="text"
              v-model="scope.value"
              dense
              autofocus
              @keyup.enter="scope.set"
              hint="Ingresa el valor de la propiedad"
            />
          </q-popup-edit>
        </q-td>
      </q-tr>
    </template>
  </q-table>
</template>
<style lang="sass">
.my-sticky-column-table
  /* specifying max-width so the example can
    highlight the sticky column on any browser window */
  max-width: 600px

  thead tr:first-child th:first-child
    /* bg color is important for th; just specify one */
    /*background-color: #f5c539*/

  td:first-child
    background-color: #f5c539
    color: black
    font-weight: bolder

  th:first-child,
  td:first-child
    position: sticky
    left: 0
    z-index: 1
</style>
<script>
import { defineComponent, ref } from "vue";
const columns = [
  {
    name: "Id",

    label: "Id",
    align: "center",
    field: (row) => row.Id,
    sortable: true,
  },
  {
    name: "Nombre",
    align: "center",
    label: "Nombre",
    field: "Nombre",
    sortable: true,
  },
  {
    name: "Valor",
    align: "center",
    label: "Valor",
    field: "Valor",
    sortable: true,
  },
];

export default defineComponent({
  name: "ConfigVariablesGlobales",
  props: {
    title: { type: String },
  },
  setup() {
    return {
      columns,
      rows: ref([]),
    };
  },

  mounted() {
    this.getListConfigs();
  },
  methods: {
    validacionInput(val) {
      console.log("valor" + val);
      if (val.length > 5) return true;
      else return false;
    },
    saveRecord(value) {
      console.log(value);
      window.myAPI.updVaribalesGlobales(JSON.stringify(value)).then((e) => {
        console.log("Data result", e[0][""]);
        this.$emit("mostrarMsj", e[0][""], "positive", "check");
      });
    },
    getListConfigs() {
      window.myAPI.getListOfConfigs().then((e) => {
        console.log("Data Config Variables Globales", e[3]);
        this.rows = e[3];
      });
    },
  },
});
</script>
