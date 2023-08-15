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
            buttons
            @cancel="validacionInput('cancel')"
            @save="saveRecord(props.row, 'BD_Upd_VariablesGlobales')"
          >
            <q-input
              type="text"
              v-model="scope.value"
              dense
              autofocus
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
    saveRecord(row, Sp) {
      try {
        setTimeout(() => {
          let ObjBuilt = {
            Id: row.Id,
            NombreLocal: row.NombreLocal,
            Valor: row.Valor,
          };
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
      window.myAPI.getListOfConfigs().then((e) => {
        console.log("Data Config Variables Globales", e[3]);
        this.rows = e[3];
      });
    },
  },
});
</script>
