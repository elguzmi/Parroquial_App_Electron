<template>
  <q-card-section>
    <div class="text-h6">ShortCuts</div>
    <div>
      <q-btn
        color="primary"
        icon="check"
        label="Agregar Shortcut"
        @click="addNew(3)"
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
    :visible-columns="['Shortcut', 'Template']"
  >
    <template v-slot:body="props">
      <q-tr :props="props">
        <q-td key="Id" :props="props">
          {{ props.row.Id }}
        </q-td>
        <q-td key="Shortcut" :props="props">
          <div class="text-pre-wrap">{{ props.row.Shortcut }}</div>
          <q-popup-edit
            v-model="props.row.Shortcut"
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
        <q-td key="Template" :props="props">
          <div class="text-pre-wrap">{{ props.row.Template }}</div>
          <q-popup-edit
            v-model="props.row.Template"
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
</template>

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
    name: "Shortcut",
    align: "center",
    label: "Shotcut",
    field: "Shortcut",
    sortable: true,
  },
  {
    name: "Template",
    align: "center",
    label: "Template",
    field: "Template",
    sortable: true,
  },
];

export default defineComponent({
  name: "ConfigShortCuts",
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
      if (val.length > 3) return true;
      else return false;
    },
    saveRecord(value) {
      console.log(value);
      window.myAPI.updVaribalesGlobales(JSON.stringify(value)).then((e) => {
        console.log("Data result", e[0][""]);
        if (("Data result", e[0][""].includes("Error")))
          this.$emit("mostrarMsj", e[0][""], "negative", "danger");
        else this.$emit("mostrarMsj", e[0][""], "positive", "check");
      });
    },
    getListConfigs() {
      window.myAPI.getListOfConfigs().then((e) => {
        console.log("Data Config ShortCuts", e[2]);
        this.rows = e[2];
      });
    },
    addNew(ev) {
      this.$emit("openModal", ev);
    },
  },
});
</script>
