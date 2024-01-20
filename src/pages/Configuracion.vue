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
        <div class="col-6">
          <ConfigShortCurts
            @mostrarMsj="showMessage"
            @openModal="openModalEdited"
            ref="shortCuts"
          ></ConfigShortCurts>
        </div>
        <div class="col-5">
          <h6>Exportar información</h6>
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
      <br />
      <q-card
        class="my-card text-white q-pt-10 q-mt-md q-pa-md"
        style="background: radial-gradient(circle, #ff8585 0%, #bc2900 100%)"
      >
        <div class="row" v-if="headerDocPdf != null">
          <div class="col-6">
            <ConfigVariablesGlobales
              class="full-width"
              @mostrarMsj="showMessage"
            ></ConfigVariablesGlobales>
          </div>
          <div class="col-6 text-center">
            <h5>Editar pie de pagina (UNICAMENTE PARA FORMATO PDF)</h5>
            <q-editor
              v-model="footerDocPdf"
              toolbar-text-color="red"
              color="red"
              :content-style="{  color: 'black' }"
            />
            <q-btn
              class="q-my-md"
              color="secondary"
              icon="save"
              label="Guardar Footer"
              @click="saveFooterPdf()"
            />
          </div>
        </div>
      </q-card>

      <q-card
        class="my-card text-white q-mt-md q-pa-md"
        style="background: radial-gradient(circle, #35a2ff 0%, #0778db 100%)"
      >
        <q-card-section class="text-center text-h5">
          Editar cabezales y pie de pagina en formato de word
          <q-icon name="description" />
        </q-card-section>
        <q-separator inset />

        <q-card-section>
          <p class="text-h7">
            <strong>Nota :</strong> Los documentos de word (bautismos ,
            confirmaciones , defunciones y matrimonios) se editan directamente
            en las plantillas con nombre que comienza por "Template" vistas al
            darle click en el boton de "Ver plantillas"
          </p>
          <p>
            <ol>
              <li>TemplateBautismo.docx</li>
              <li>TemplateConfirmacion.docx</li>
              <li>TemplateDefuncion.docx</li>
              <li>TemplateMatrimonio.docx</li>
            </ol>
          </p>
          <p>
            Al finalizar de editar por favor guardar y cerrar el word.
          </p>
        </q-card-section>
        <q-card-section>
          <q-btn
            color="secondary"
            icon="visibility"
            label="Ver plantillas"
            @click="showOpenFileTemplates()"
          />
        </q-card-section>
      </q-card>
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
    this.getHeaderPdf();
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
      headerDocPdf: ref(null),
      footerDocPdf: ref(null),
    };
  },
  methods: {
    exportData() {
      if (this.selectExportData == "Seleccionar Tabla") return;
      window.myAPI.ExportData(this.selectExportData).then((e) => {
        this.showMessage(
          "Se ha guardado exitosamente en la siguiente ruta : " + e,
          "positive",
          "check"
        );
      });
    },
    async getHeaderPdf() {
      const result = await window.myAPI.executeSp_Dt(
        "{}",
        "BD_Get_Setting_Pdf"
      );
      console.log(result);
      this.footerDocPdf = result.Html_Footer_Docx;
      this.headerDocPdf = result.Html_Header;
    },
    openModalEdited(mdlEdited) {
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

      let dataJson = JSON.stringify(this[objName]);
      window.myAPI.executeSp_St(dataJson, sp).then((e) => {
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
    async saveFooterPdf() {
      console.log(this.footerDocPdf);
      let json = { FooterDocPdf: this.footerDocPdf };
      const res = await window.myAPI.executeSp_St(
        JSON.stringify(json),
        "BD_Upd_FooterPdf"
      );
      if (res.includes("Error")) {
        this.showMessage(res, "red", "danger");
      } else {
        this.showMessage(res, "positive", "check");
        this.editedModl = 0;
        this.persistent = false;
      }
    },
    async showOpenFileTemplates() {
      const res = await window.myAPI.openFileTemplate();
      console.log(res);
    },
  },
});
</script>
