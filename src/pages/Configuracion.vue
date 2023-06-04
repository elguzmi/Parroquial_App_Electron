<template>
  <q-page class="flex">
    <div class="q-pa-sm full-width">
      <div
        class="full-width row wrap justify-around items-start content-around"
      >
        <div class="col-12">
          <ConfigUsers @mostrarMsj="showMessage"></ConfigUsers>
        </div>
      </div>

      <div
        class="full-width row no-wrap justify-around items-start content-around"
      >
        <div class="col-5">
          <ConfigShortCurts @mostrarMsj="showMessage"></ConfigShortCurts>
        </div>
        <div class="col-5">
          <ConfigVariablesGlobales
            @mostrarMsj="showMessage"
          ></ConfigVariablesGlobales>
        </div>
      </div>
      <br />
      <div
        class="full-width row no-wrap justify-around items-start content-around"
      >
        <div class="col-5">
          <q-select
            v-model="selectExportData"
            :options="[
              'Seleccionar Tabla',
              'Bautismos',
              'Confirmaciones',
              'Matrimonios',
              'Defunciones',
            ]"
            label="Tabla"
            filled
          />
          <q-btn
            color="primary"
            icon="check"
            label="Exportar"
            @click="exportData()"
          />
        </div>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";
import ConfigUsers from "components/ConfigUsers.vue";
import ConfigShortCurts from "components/ConfigShortCurts.vue";
import ConfigVariablesGlobales from "components/ConfigVariablesGlobales.vue";

export default defineComponent({
  name: "Configuracion",
  components: { ConfigUsers, ConfigShortCurts, ConfigVariablesGlobales },
  mounted() {
    this.getListConfigs();
  },
  setup() {
    const $q = useQuasar();

    function showLoading(msj) {
      $q.loading.show({
        message: msj,
      });
    }
    const showMessage = (msj, color, icon) => {
      $q.loading.hide();
      $q.notify({
        progress: true,
        message: msj,
        icon: icon,
        color: color,
        textColor: "white",
      });
    };
    const hideLoading = () => $q.loading.hide();
    return {
      showLoading,
      hideLoading,
      showMessage,
      selectExportData: ref("Seleccionar Tabla"),
    };
  },
  methods: {
    getListConfigs() {
      window.myAPI.getListOfConfigs().then((e) => {
        console.log("Data Config ", e);
      });
    },
    exportData() {
      console.log(this.selectExportData);
      if (this.selectExportData == "Seleccionar Tabla") return;
      window.myAPI.ExportData(this.selectExportData).then((e) => {
        console.log("Data Config ", e);
        this.showMessage(
          "Se ha guardado exitosamente en la siguiente ruta : " + e,
          "positive",
          "check"
        );
      });
    },
  },
});
</script>
