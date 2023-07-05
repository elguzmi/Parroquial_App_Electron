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
          <q-editor v-model="CurrentData.Html_Footer" />
        </form>
      </q-card>
    </q-dialog>
  </div>
</template>

<script>
import { defineComponent, ref } from "vue";
import * as htmlDocx from "html-docx-js/dist/html-docx";
import { jsPDF } from "jspdf";
//var HtmlDocx = require("html-docx-js");
import { saveAs } from "file-saver";
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
    return {
      dialog: ref(false),
      maximizedToggle: ref(true),

      FirtData: ref({}),
      CurrentData: ref({}),
    };
  },

  mounted() {
    console.log("Montado Componente previsualizacion");
    this.searchDoc();
    //this.searchDoc();
    // this.FirtData = this.Doc;
    // this.CurrentData = this.Doc;
  },
  updated() {
    console.log("Se actuializo!!");
    //this.searchDoc();
  },
  methods: {
    searchDoc() {
      console.log("Buscando Documento");
      console.log(this.tabla, this.id);
      let tabla = this.tabla;
      let id = this.id;
      if (!tabla || !id) return;
      window.myAPI.GetDocumentoHtml(tabla, id).then((e) => {
        console.log("Documento", e);
        this.FirtData = e;
        this.CurrentData = e;
        this.dialog = true;
        //this.dialog = true;
        //this.showDialog = true;
      });
    },
    goToPdf() {
      console.log(this.CurrentData);
      const doc = new jsPDF({
        //format: "letter",
        format: [816, 1344],
        unit: "px",
        orientation: "portrait",
        //compress: true,
      });
      const pageSize = doc.internal.pageSize;
      console.log(pageSize);
      console.log(pageSize.width);
      console.log(pageSize.height);
      console.log(pageSize.getHeight());

      const pageWidth = pageSize.width ? pageSize.width : pageSize.getWidth();
      const pageHeight = pageSize.height
        ? pageSize.height
        : pageSize.getHeight();
      // const header = "Report 2014";
      const footer = `Autenticación en la curia Diocesana de Fontibón, Carrera 98 # 17 A - 81 Fontibón - Centro. \n Tel (601)4181036, Horario de atención, Lunes a Viernes de 9:00 a 1:00 P.M (Validez a 3 Meses)`;

      // // Footer
      doc.setFontSize(20);
      doc.text(footer, 1030 - doc.getTextWidth(footer) / 2, pageHeight - 25, {
        baseline: "bottom",
        align: "center",
      });

      doc.html(
        this.CurrentData.Html_Header + this.CurrentData.Html_Body,
        //this.CurrentData.Html_Footer,
        {
          callback: function (doc) {
            doc.line(30, pageHeight - 45, pageWidth - 30, pageHeight - 45);
            window.open(doc.output("bloburl"));
          },
          x: 15,
          y: 15,
          width: pageWidth - 20, //target width in the PDF document
          windowWidth: 750, //window width in CSS pixels
        }
      );
      // window.myAPI.goToPdf(JSON.stringify(this.CurrentData)).then((e) => {
      //   console.log(e);
      // });
    },

    goToWord() {
      // console.log(this.CurrentData);
      // window.myAPI.convertToDocx(JSON.stringify(this.CurrentData)).then((e) => {
      //   console.log(e);
      // });
      let { Html_Body, Html_Header, Html_Footer } = this.CurrentData;
      console.log(Html_Header);

      Html_Header =
        '<div class="header" style="font-family: Arial, Helvetica, sans-serif;font-size: 18px;margin-top:3px;width:100%">  <div style="width: 100%; text-align: center;line-height: 3px;" class="title">     <br>   <span style="font-size: 24px;font-weight: 700;width:100%">DIÓCESIS DE FONTIBÓN</span>   <br>     <span style="font-weight: 700;width:100%">PARROQUIA JESÚS EUCARISTÍA</span>      <br>  <span style="width:100%"> Diagonal 16 # 104 - 51 local 117 Cel.322-7447219</span>   <br>    <span style="width:100%">Correo: despachojesuseucaristia@gmail.com</span>    <br>    <span style="width:100%"> Bogotá - Cundinamarca </span>      </div>  </div>';
      // return;
      // Html_Header = this.CurrentData.Html_Header.replace(
      //   "line-height: 8px;",
      //   "line-height: 4px;"
      // );

      Html_Body = this.CurrentData.Html_Body.replace(
        "line-height: 24px",
        "line-height: 12px"
      );

      Html_Body = Html_Body.replace("width: 90%", "width: 100%");

      let htmlDoc =
        '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><title></title>';
      htmlDoc =
        htmlDoc +
        "</head><body>" +
        Html_Header +
        '<div style="width: 100%;">' +
        Html_Body +
        "</div>" +
        '<div style="text-align: center; position: absolute; bottom: 3px"></style="width: 60%;margin:0 auto;" hr>' +
        Html_Footer +
        "</div>" +
        "</body></html>";

      let converted = htmlDocx.asBlob(htmlDoc, {
        orientation: "portrait",
        margins: { top: 720, right: 1000, left: 1000, bottom: 0, footer: 0 },
      });
      saveAs(converted, this.title + "_document");
    },
  },
});
</script>
