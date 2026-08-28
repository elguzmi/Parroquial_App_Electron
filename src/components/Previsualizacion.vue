<template>
  <div class="responsive q-pa-md">
    <q-dialog
      v-model="dialog"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card class="bg-white text-dark">
        <q-bar>
          <div class="cursor-pointer non-selectable">
            <q-item clickable @click="goToWordZip()">
              <q-item-section>Word</q-item-section>
            </q-item>
          </div>
          <div class="cursor-pointer non-selectable">
            <q-item clickable @click="goToPdf()">
              <q-item-section>Pdf</q-item-section>
            </q-item>
          </div>
          <div>
            <q-item clickable v-close-popup="2">
              <q-item-section>Salir</q-item-section>
            </q-item>
          </div>
          <q-space />
          <q-btn
            dense
            flat
            icon="minimize"
            @click="maximizedToggle = false"
            :disable="!maximizedToggle"
          >
            <q-tooltip v-if="maximizedToggle" class="bg-white text-primary"
              >Minimize</q-tooltip
            >
          </q-btn>
          <q-btn
            dense
            flat
            icon="crop_square"
            @click="maximizedToggle = true"
            :disable="maximizedToggle"
          >
            <q-tooltip v-if="!maximizedToggle" class="bg-white text-primary"
              >Maximize</q-tooltip
            >
          </q-btn>
          <q-btn dense flat icon="close" v-close-popup>
            <q-tooltip class="bg-white text-primary">Close</q-tooltip>
          </q-btn>
        </q-bar>
        <form
          autocorrect="on"
          autocapitalize="on"
          autocomplete="on"
          spellcheck="false"
        >
          <q-banner dense class="bg-dark text-white text-center">
            Cabezal
          </q-banner>
          <q-editor v-model="CurrentData.Html_Header" />
          <q-banner dense class="bg-dark text-white text-center">
            Cuerpo
          </q-banner>
          <q-editor v-model="CurrentData.Html_Body" />
          <q-banner dense class="bg-dark text-white text-center">
            Pie
          </q-banner>
          <q-editor v-model="CurrentData.Html_Footer_Docx" />
        </form>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";
import { printPdf } from "src/utils/printPdf";
export default defineComponent({
  name: "Previsualizacion",
  props: {
    title: { type: String },
    Doc: { type: Object },
    tabla: { type: String },
    id: { type: Number },
  },
  setup() {
    const $q = useQuasar();
    function showLoading(msj) {
      $q.loading.show({
        message: msj,
      });
    }
    const hideLoading = () => $q.loading.hide();
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
    return {
      dialog: ref(false),
      maximizedToggle: ref(true),

      FirtData: ref({}),
      CurrentData: ref({}),
      datosDoc: ref(null),

      showLoading,
      hideLoading,
      showMessage,
    };
  },

  mounted() {
    this.searchDoc();
  },
  updated() {},
  methods: {
    searchDoc() {
      this.showLoading("Cargando Datos");
      let tabla = this.tabla;
      let id = this.id;
      if (!tabla || !id) return;
      window.myAPI.GetDocumentoHtml(tabla, id).then((e) => {
        //e.Html_Footer =
        //  "Autenticación en la curia Diocesana de Fontibón, Carrera 98 # 17 A - 81 Fontibón - Centro. <br> Tel (601) 4181036, Horario de atención, Lunes a Viernes de 9:00 a 1:00 P.M (Validez a 3 Meses)";

        this.FirtData = e[0][0];
        this.CurrentData = e[0][0];
        this.datosDoc = e[1][0];
        this.dialog = true;
        this.hideLoading();
      });
    },
    async goToPdf() {
      this.showLoading("Generando Pdf");
      try {
        const res = await printPdf({
          headerHtml: this.CurrentData?.Html_Header || "",
          bodyHtml: this.CurrentData?.Html_Body || "",
          footerHtml:
            this.CurrentData?.Html_Footer_Docx ||
            this.CurrentData?.Html_Footer ||
            "",
          title: this.title || "Certificado parroquial",
          fileName: `Certificado_${this.tabla || "documento"}_${
            this.id || "preview"
          }.pdf`,
        });
        if (res?.isError) {
          this.showMessage(res.errorMessage, "negative", "error");
        } else if (res?.warning) {
          this.showMessage(res.warning, "warning", "warning");
        }
      } catch (err) {
        this.showMessage(
          err?.message || "No se pudo generar el PDF",
          "negative",
          "error"
        );
      } finally {
        this.hideLoading();
      }
    },

    goToWord() {
      this.showLoading("Creando Documento ...");
      window.myAPI.convertToDocx(JSON.stringify(this.CurrentData)).then((e) => {
        this.hideLoading();
      });
      //   return;
      //   let { Html_Body_Docx, Html_Header_Docx, Html_Footer, Html_Footer_Docx } =
      //     this.CurrentData;

      //   const footer = Html_Footer_Docx.replace("<center>", "").replace(
      //     "</center>",
      //     ""
      //   );

      //   let htmlDoc =
      //     '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8" /><title></title>';
      //   htmlDoc =
      //     htmlDoc +
      //     "</head><body>" +
      //     Html_Header_Docx +
      //     '<div style="width: 100%;>' +
      //     Html_Body_Docx +
      //     "</div>" +
      //     '<div style="text-align: center;border-top:1px solid black">' +
      //     footer +
      //     "</div>" +
      //     "</body></html>";

      //   htmlDocx;
      //   let converted = htmlDocx.asBlob(htmlDoc, {
      //     orientation: "portrait",
      //     margins: { top: 300, right: 1000, left: 1000, bottom: 20, footer: 0 },
      //   });
      //   saveAs(converted, this.title + "_document");
    },

    goToWordZip() {
      this.showLoading("Creando Documento ...");
      window.myAPI.convertToDocxZip(JSON.stringify(this.datosDoc)).then((e) => {
        if (!e.isError) {
          this.hideLoading();
          this.showLoading("Abriendo Documento ...");
          setTimeout(this.hideLoading, 2000);
        } else {
          this.hideLoading();
          this.showMessage(e.errorMessage, "red", "error");
        }
      });
    },
  },
  watch: {
    dialog(news, old) {
      if (news == false) {
        this.$parent.IdSelected = null;
      }
    },
  },
});
</script>
