<template>
  <q-page class="flex">
    <div class="q-pa-sm full-width">
      <div
        class="full-width row wrap justify-around items-start content-around"
      >
        <div class="col-12">
          <ConfigUsers
            @mostrarMsj="showMessage"
            @openModal="openModalEdited"
            ref="configUser"
          ></ConfigUsers>
        </div>
      </div>

      <div
        class="full-width row no-wrap justify-around items-start content-around"
      >
        <div class="col-5">
          <ConfigShortCurts
            @mostrarMsj="showMessage"
            @openModal="openModalEdited"
            ref="shortCuts"
          ></ConfigShortCurts>
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
    <div>
      <q-dialog
        v-model="persistent"
        persistent
        transition-show="scale"
        transition-hide="scale"
      >
        <div v-show="editedModl == 1">
          <q-card class="bg-white text-white" style="width: 300px">
            <q-card-section>
              <q-input
                v-model="newDoyFe.Nombre_DoyFe"
                type="text"
                label="Nombre Doy Fe"
              />
            </q-card-section>

            <q-card-actions align="right" class="bg-white text-teal">
              <q-btn flat label="Guardar" @click="guardarConfig()" />
              <q-btn flat label="Cancelar" v-close-popup />
            </q-card-actions>
          </q-card>
        </div>

        <div v-show="editedModl == 2">
          <q-card class="bg-white text-white" style="width: 300px">
            <q-card-section>
              <q-input
                v-model="newMinistro.Nombre_Ministro"
                type="text"
                label="Nombre Ministro"
              />
              <q-input v-model="newMinistro.Cargo" type="text" label="Cargo" />
            </q-card-section>

            <q-card-actions align="right" class="bg-white text-teal">
              <q-btn flat label="Guardar" @click="guardarConfig()" />
              <q-btn flat label="Cancelar" v-close-popup />
            </q-card-actions>
          </q-card>
        </div>

        <div v-show="editedModl == 3">
          <q-card class="bg-white text-white" style="width: 300px">
            <q-card-section>
              <q-input
                v-model="newShortCut.ShortCut"
                type="text"
                label="ShortCut"
              />
              <q-input
                v-model="newShortCut.Template"
                type="text"
                label="Template"
              />
            </q-card-section>

            <q-card-actions align="right" class="bg-white text-teal">
              <q-btn flat label="Guardar" @click="guardarConfig()" />
              <q-btn flat label="Cancelar" v-close-popup />
            </q-card-actions>
          </q-card>
        </div>
      </q-dialog>
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
      persistent: ref(false),
      editedModl: ref(0),
      newShortCut: ref({
        ShortCut: ref(null),
        Template: ref(null),
      }),
      newMinistro: ref({
        Nombre_Ministro: ref(null),
        Cargo: ref(null),
      }),
      newDoyFe: ref({
        Nombre_DoyFe: ref(null),
      }),
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
    openModalEdited(mdlEdited) {
      console.log(mdlEdited);
      this.editedModl = mdlEdited;
      this.persistent = true;
    },
    guardarConfig() {
      let sp = "";
      let objName = "";
      if (this.editedModl == 1) {
        sp = "BD_Ins_NewDoyFe";
        objName = "newDoyFe";
      } else if (this.editedModl == 2) {
        sp = "BD_Ins_NewMinistro";
        objName = "newMinistro";
      } else if (this.editedModl == 3) {
        sp = "BD_Ins_ShortCut";
        objName = "newShortCut";
      }

      console.log(window.myAPI.insConfig);
      let dataJson = JSON.stringify(this[objName]);
      console.log(dataJson);
      window.myAPI.insConfig(dataJson, sp).then((e) => {
        console.log("Data insConfig ", e);
        if (e.includes("Error")) {
          this.showMessage(e, "red", "danger");
        } else {
          this.showMessage(e, "positive", "check");
          this.editedModl = 0;
          this.persistent = false;
          this.$refs.configUser.getListConfigs();
          this.$refs.shortCuts.getListConfigs();
        }
      });
    },
  },
});
</script>
