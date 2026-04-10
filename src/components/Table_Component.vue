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
      <!-- <q-btn
        style="width: 30%"
        color="blue"
        label="Imprimir"
        @click="PrintSelected()"
        icon="print"
        :disabled="this.selected.length == 0"
      /> -->
      <q-btn
        style="width: 30%"
        color="blue"
        label="Word"
        @click="PrintWord()"
        icon="text_snippet"
        :disabled="this.selected.length == 0"
      />
      <q-btn
        style="width: 30%"
        color="red"
        label="Pdf"
        @click="PrintPdf()"
        icon="picture_as_pdf"
        :disabled="this.selected.length == 0"
      />
    </div>
    <!-- <Previsualizacion
      v-if="IdSelected != NULL"
      :title="title"
      :tabla="tablaDirectTo"
      :id="IdSelected"
      ref="previsualizacion_comp"
    ></Previsualizacion> -->
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
import { useQuasar } from "quasar";
import { jsPDF } from "jspdf";
export default defineComponent({
  name: "Table_Component",
  components: {
    // Previsualizacion,
  },
  props: {
    title: { type: String },
    tablaDirectTo: { type: String },
    columns: { type: Array },
    rows: { type: Array },
    visibleColumns: { type: Array },
  },
  setup() {
    const $q = useQuasar();
    return {
      selected: ref([]),
      fullscreen: ref(false),
      IdSelected: ref(null),
      showDialog: ref(false),
      filterText: ref(null),
      $q,
    };
  },

  mounted() {},
  methods: {
    sendSelectedRow() {
      if (this.selected.length == 0) return;
      else this.$emit("eventedited", this.selected[0]);
    },

    cleanSelectedRow() {
      this.selected = [];
    },

    async invtRecord() {
      try {
        if (this.selected.length == 0) return;
        this.$q
          .dialog({
            title: "Confirm",
            message: "Esta seguro de eliminar el registro?",
            cancel: true,
            persistent: true,
          })
          .onOk(() => {
            this.$emit("eventinvt", this.selected[0].Id);
          })
          .onCancel(() => {});
      } catch (err) {}
    },
    PrintSelected() {
      this.$emit("loadingShow", "Cargando archivo");
      this.IdSelected = this.selected[0].Id;
    },
    async PrintWord() {
      this.$emit("loadingShow", "Generando Word");
      this.IdSelected = this.selected[0].Id;
      const datosDoc = await this.searchDoc("word");
      console.log('DatosDoc',datosDoc);

      const res = await window.myAPI.convertToDocxZip(JSON.stringify(datosDoc));
      if (!res.isError) {
        setTimeout(this.$emit, 2000, "loadingHide", null);
      } else {
        this.$emit("loadingHide", null);
        this.$emit("msjShow", res.errorMessage, "red", "error");
      }
    },
    async PrintPdf() {
      this.$emit("loadingShow", "Generando Pdf");
      try {
        this.IdSelected = this.selected[0].Id;
        const datosPdf = await this.searchDoc("pdf");
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
  
        const footer = datosPdf.Html_Footer_Docx.replaceAll("<br>", "\n")
          .replaceAll("<br />", "\n")
          .replaceAll("<center>", "")
          .replaceAll("</center>", "");

  
        // // Footer
        doc.setFontSize(12);
        doc.text(footer, 600 / 2, pageHeight - 30, {
          baseline: "bottom",
          align: "center",
        });
        // doc.text(footer, 600 - doc.getTextWidth(footer) / 2, pageHeight - 30, {
        //   baseline: "bottom",
        //   align: "center",
        // });
        doc.html(datosPdf.Html_Header + datosPdf.Html_Body, {
          callback: (doc) => {
            doc.line(30, pageHeight - 45, pageWidth - 30, pageHeight - 45);
            window.open(doc.output("bloburl"));
            this.$emit("loadingHide", null);
          },
          x: 15,
          y: 15,
          width: pageWidth - 20, //target width in the PDF document
          windowWidth: 750, //window width in CSS pixels
        });
      } catch (error) {
        this.$emit("loadingHide", null);
        console.error('Error',error);
        this.$emit("msjShow", error.message, "red", "error");
      }
    },

    async searchDoc(type) {
      try {
        let Tabla = this.tablaDirectTo;
        let Id = this.IdSelected;
        if (!Tabla || !Id) throw "Error - No tabla detected";
        const e = await window.myAPI.executeSp_Ds(
          JSON.stringify({ Id, Tabla }),
          "BD_Get_Documento"
        );
        return type == "word" ? e[1][0] : e[0][0];
      } catch (err) {
        this.$emit("msjShow", err, "red", "error");
      }
    },
  },
});
</script>
