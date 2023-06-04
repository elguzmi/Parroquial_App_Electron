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
            Accion
            <q-menu>
              <q-list dense style="min-width: 100px">
                <q-item clickable>
                  <q-item-section>Exportar</q-item-section>
                  <q-item-section side>
                    <q-icon name="keyboard_arrow_right" />
                  </q-item-section>
                  <q-menu anchor="top end" self="top start">
                    <q-list>
                      <q-item dense clickable @click="goToPdf()">
                        <q-item-section>
                          <q-item-section>PDF</q-item-section>
                        </q-item-section>
                      </q-item>
                      <q-item dense clickable @click="goToWord()">
                        <q-item-section>
                          <q-item-section>Word</q-item-section>
                        </q-item-section>
                      </q-item>
                    </q-list>
                  </q-menu>
                </q-item>
                <q-separator />
                <q-item clickable v-close-popup="2">
                  <q-item-section>Salir</q-item-section>
                </q-item>
              </q-list>
            </q-menu>
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
      window.myAPI.goToPdf(JSON.stringify(this.CurrentData)).then((e) => {
        console.log(e);
      });
    },
    goToWord() {
      // console.log(this.CurrentData);
      // window.myAPI.convertToDocx(JSON.stringify(this.CurrentData)).then((e) => {
      //   console.log(e);
      // });
      let htmlDoc =
        '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8" /><title></title>';
      htmlDoc =
        htmlDoc +
        "</head><body>" +
        this.CurrentData.Html_Header +
        '<div style="width: 500px;>' +
        this.CurrentData.Html_Body +
        "</div>" +
        '<div style="text-align: center; position: absolute; bottom: 0px">' +
        this.CurrentData.Html_Footer +
        "</div>" +
        "</body></html>";

      let converted = htmlDocx.asBlob(htmlDoc, {
        orientation: "portrait",
        margins: { top: 720, right: 1600, left: 1600, bottom: 100 },
      });
      saveAs(converted, this.title + "_doc");
    },
  },
});
</script>
