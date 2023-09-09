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
            <q-item clickable @click="goToWord()">
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
          autocorrect="off"
          autocapitalize="off"
          autocomplete="off"
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
// import * as htmlDocx from "html-docx-js/dist/html-docx";
import { jsPDF } from "jspdf";
//var HtmlDocx = require("html-docx-js");
// import { saveAs } from "file-saver";
import { useQuasar } from "quasar";
export default defineComponent({
  name: "Previsualizacion",
  props: {
    title: { type: String },
    Doc: { type: Object },
    tabla: { type: String },
    id: { type: Number },
    openDialog: { type: Boolean },
  },
  setup() {
    const $q = useQuasar();
    function showLoading(msj) {
      $q.loading.show({
        message: msj,
      });
    }
    const hideLoading = () => $q.loading.hide();
    return {
      dialog: ref(false),
      maximizedToggle: ref(true),

      FirtData: ref({}),
      CurrentData: ref({}),

      showLoading,
      hideLoading,
    };
  },

  mounted() {
    this.searchDoc();
  },
  updated() {},
  methods: {
    searchDoc() {
      let tabla = this.tabla;
      let id = this.id;
      if (!tabla || !id) return;
      window.myAPI.GetDocumentoHtml(tabla, id).then((e) => {
        //e.Html_Footer =
        //  "Autenticación en la curia Diocesana de Fontibón, Carrera 98 # 17 A - 81 Fontibón - Centro. <br> Tel (601) 4181036, Horario de atención, Lunes a Viernes de 9:00 a 1:00 P.M (Validez a 3 Meses)";
        this.FirtData = e;
        this.CurrentData = e;
        this.dialog = true;
      });
    },
    goToPdf() {
      this.showLoading("Cargando Documento ...");
      //console.log(this.CurrentData);
      const doc = new jsPDF({
        format: "legal",
        unit: "px",
        orientation: "portrait",
        //compress: true,
      });
      const pageSize = doc.internal.pageSize;
      const pageWidth = pageSize.width ? pageSize.width : pageSize.getWidth();
      const pageHeight = pageSize.height
        ? pageSize.height
        : pageSize.getHeight();

      const footer = this.CurrentData.Html_Footer_Docx.replace("<br>", "\n")
        .replace("<center>", "")
        .replace("</center>", "");

      // // Footer
      doc.setFontSize(12);
      doc.text(footer, 600 - doc.getTextWidth(footer) / 2, pageHeight - 30, {
        baseline: "bottom",
        align: "center",
      });

      doc.html(this.CurrentData.Html_Header + this.CurrentData.Html_Body, {
        callback: (doc) => {
          doc.line(30, pageHeight - 45, pageWidth - 30, pageHeight - 45);
          window.open(doc.output("bloburl"));
          this.hideLoading();
        },
        x: 15,
        y: 15,
        width: pageWidth - 20, //target width in the PDF document
        windowWidth: 750, //window width in CSS pixels
      });
      // window.myAPI.goToPdf(JSON.stringify(this.CurrentData)).then((e) => {
      //   console.log(e);
      // });
    },

    goToWord() {
      this.showLoading("Creando Documento ...");
      window.myAPI.convertToDocx(JSON.stringify(this.CurrentData)).then((e) => {
        console.log(e);
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
  },
});
</script>
