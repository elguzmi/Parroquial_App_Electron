<template>
  <div class="responsive q-pa-md">
    <q-input v-model="filterText" type="text" label="Buscar" rounded filled>
      <template v-slot:prepend>
        <q-icon name="search" />
      </template>
    </q-input>
    <q-table
      style="height: 400px"
      class="my-sticky-header-column-table"
      :title="title"
      :rows="rows"
      :columns="columns"
      row-key="Id"
      selection="single"
      v-model:selected="selected"
      v-model:pagin="selected"
      :dense="true"
      flat
      bordered
      :rows-per-page-options="[20, 50]"
      virtual-scroll
      :visible-columns="visibleColumns"
      :filter="filterText"
    >
    </q-table>
    <div class="q-mt-md hidden">Selected: {{ JSON.stringify(selected) }}</div>
    <div style="display: flex; justify-content: space-around; margin-top: 10px">
      <q-btn
        style="width: 30%"
        color="primary"
        icon="check"
        label="Editar"
        @click="sendSelectedRow()"
        :disabled="this.selected.length == 0"
      />
      <q-btn
        style="width: 30%"
        color="negative"
        icon="error"
        label="Eliminar"
        @click="invtRecord()"
        :disabled="this.selected.length == 0"
      />
      <q-btn
        style="width: 30%"
        color="blue"
        label="Imprimir"
        @click="PrintSelected()"
        icon="print"
        :disabled="this.selected.length == 0"
      />
    </div>
    <Previsualizacion
      :title="title"
      :tabla="tablaDirectTo"
      :id="IdSelected"
      ref="previsualizacion_comp"
    ></Previsualizacion>
  </div>
</template>

<style>
::-webkit-scrollbar-thumb {
  width: 10px;
  background-color: #919191;
  border-radius: 10px;
  z-index: 12;
  border: 4px solid rgba(0, 0, 0, 0);
  background-clip: padding-box;
  -webkit-transition: background-color 0.28s ease-in-out;
  transition: background-color 0.28s ease-in-out;
  margin: 4px;
  min-height: 32px;
  min-width: 32px;
}
</style>

<script>
import { defineComponent, ref } from "vue";
import Previsualizacion from "components/Previsualizacion.vue";

export default defineComponent({
  name: "Table_Component",
  components: {
    Previsualizacion,
  },
  props: {
    title: { type: String },
    tablaDirectTo: { type: String },
    columns: { type: Array },
    rows: { type: Array },
    visibleColumns: { type: Array },
  },
  setup() {
    return {
      selected: ref([]),
      fullscreen: ref(false),
      IdSelected: ref(null),
      showDialog: ref(false),
      filterText: ref(null),
    };
  },

  mounted() {
    //console.log("Montado table");
  },
  methods: {
    sendSelectedRow() {
      console.log(this.selected.length);
      if (this.selected.length == 0) return;
      else this.$emit("eventedited", this.selected[0]);
    },

    cleanSelectedRow() {
      this.selected = [];
    },

    invtRecord() {
      if (this.selected.length == 0) return;
      else this.$emit("eventinvt", this.selected[0].Id);
    },
    PrintSelected() {
      this.$emit("loadingShow", "Cargando archivo");
      //console.log(this.selected[0]);
      this.IdSelected = this.selected[0].Id;
      //console.log(this.selected[0].Id);
      //console.log(this.$refs.previsualizacion_comp);
      setTimeout(() => {
        this.$emit("loadingHide");
        this.$refs.previsualizacion_comp.searchDoc();
      }, 1000);
    },
  },
});
</script>
