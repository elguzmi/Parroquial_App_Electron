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
    :visible-columns="['Shortcut', 'Template', 'Accion']"
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
            buttons
            @save="saveRecord(props.row, 'BD_Upd_ShortCuts')"
          >
            <q-input
              type="text"
              v-model="scope.value"
              dense
              autofocus
              hint="Ingresa el Nombre"
            />
          </q-popup-edit>
        </q-td>
        <q-td key="Template" :props="props">
          <div class="text-pre-wrap">{{ props.row.Template }}</div>
          <q-popup-edit
            v-model="props.row.Template"
            v-slot="scope"
            buttons
            @save="saveRecord(props.row, 'BD_Upd_ShortCuts')"
          >
            <q-input
              type="text"
              v-model="scope.value"
              dense
              autofocus
              hint="Ingresa el Nombre"
            />
          </q-popup-edit>
        </q-td>
        <q-td key="Accion" :props="props">
          <q-btn
            color="negative"
            icon="delete"
            @click="deleteRecord(props.key, 'BD_Invt_ShortCut')"
          />
        </q-td>
      </q-tr>
    </template>
  </q-table>
  <ConfirmModal ref="confirmModal"></ConfirmModal>
</template>

<script>
import { defineComponent, ref } from "vue";
import ConfirmModal from "components/ConfirmModal.vue";
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
  {
    name: "Accion",
    align: "center",
    label: "Accion",
    field: "Accion",
  },
];

export default defineComponent({
  name: "ConfigShortCuts",
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
    };
  },

  mounted() {
    this.getListConfigs();
  },
  methods: {
    saveRecord(row, Sp) {
      try {
        setTimeout(() => {
          let ObjBuilt = {
            Id: row.Id,
            Shortcut: row.Shortcut,
            Template: row.Template,
          };
          window.myAPI.executeSp_St(JSON.stringify(ObjBuilt), Sp).then((e) => {
            this.$emit("mostrarMsj", e, "positive", "check");
          });
        }, 500);
      } catch (error) {
        this.getListConfigs();
      }
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

    async deleteRecord(Id, Sp) {
      try {
        await this.$refs.confirmModal.confirm();
        window.myAPI.executeSp_St(JSON.stringify({ Id: Id }), Sp).then((e) => {
          //console.log("Data Result", e);
          if (e.includes("Error")) this.$emit("mostrarMsj", e, "red", "danger");
          else this.$emit("mostrarMsj", e, "positive", "check");
          this.getListConfigs();
        });
      } catch (err) {}
    },
  },
});
</script>
