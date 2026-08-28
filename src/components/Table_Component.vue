<template>
  <div class="sac-table">
    <div class="sac-table__toolbar">
      <h3 class="sac-table__title">{{ title }}</h3>
      <q-input
        v-model="filterText"
        class="sac-table__search sac-input"
        type="search"
        dense
        outlined
        clearable
        placeholder="Buscar en el registro…"
        aria-label="Buscar en el registro"
      >
        <template #prepend>
          <q-icon name="search" />
        </template>
      </q-input>
    </div>

    <q-table
      class="sac-table__grid my-sticky-header-column-table"
      style="height: 300px"
      :rows="rows"
      :columns="columns"
      row-key="Id"
      selection="single"
      v-model:selected="selected"
      :dense="true"
      flat
      :rows-per-page-options="[20, 50]"
      virtual-scroll
      :visible-columns="visibleColumns"
      :filter="filterText"
      no-data-label="No hay registros para mostrar"
      binary-state-sort
    />

    <div class="sac-table__actions" role="group" aria-label="Acciones del registro">
      <q-btn
        class="sac-btn sac-btn--primary"
        unelevated
        no-caps
        icon="edit"
        label="Editar"
        :disable="!hasSelection"
        @click="sendSelectedRow"
      />
      <q-btn
        class="sac-btn"
        outline
        no-caps
        color="negative"
        icon="delete_outline"
        label="Eliminar"
        :disable="!hasSelection"
        @click="invtRecord"
      />
      <q-btn
        class="sac-btn sac-btn--ghost"
        outline
        no-caps
        icon="text_snippet"
        label="Word"
        :disable="!hasSelection"
        @click="PrintWord"
      />
      <q-btn
        class="sac-btn sac-btn--ghost"
        outline
        no-caps
        icon="picture_as_pdf"
        label="PDF"
        :disable="!hasSelection"
        @click="PrintPdf"
      />
    </div>
  </div>
</template>

<script>
import { defineComponent, ref, computed } from "vue";
import { useQuasar } from "quasar";
import { jsPDF } from "jspdf";
import { dialogBtnCancel, dialogBtnDanger } from "src/utils/appDialog";

export default defineComponent({
  name: "Table_Component",
  props: {
    title: { type: String },
    tablaDirectTo: { type: String },
    columns: { type: Array },
    rows: { type: Array },
    visibleColumns: { type: Array },
  },
  emits: [
    "eventedited",
    "eventinvt",
    "loadingShow",
    "loadingHide",
    "msjShow",
  ],
  setup() {
    const q = useQuasar();
    const selected = ref([]);
    const hasSelection = computed(() => selected.value.length > 0);

    return {
      selected,
      hasSelection,
      fullscreen: ref(false),
      IdSelected: ref(null),
      showDialog: ref(false),
      filterText: ref(""),
      q,
    };
  },
  methods: {
    sendSelectedRow() {
      if (!this.hasSelection) return;
      this.$emit("eventedited", this.selected[0]);
    },
    cleanSelectedRow() {
      this.selected = [];
    },
    async invtRecord() {
      if (!this.hasSelection) return;
      this.q
        .dialog({
          title: "Confirmar eliminación",
          message:
            "¿Está seguro de eliminar este registro? Esta acción no se puede deshacer.",
          cancel: dialogBtnCancel(),
          ok: dialogBtnDanger("Eliminar"),
          persistent: true,
        })
        .onOk(() => {
          this.$emit("eventinvt", this.selected[0].Id);
        });
    },
    PrintSelected() {
      this.$emit("loadingShow", "Cargando archivo");
      this.IdSelected = this.selected[0].Id;
    },
    async PrintWord() {
      if (!this.hasSelection) return;
      this.$emit("loadingShow", "Generando Word");
      this.IdSelected = this.selected[0].Id;
      const datosDoc = await this.searchDoc("word");
      const res = await window.myAPI.convertToDocxZip(JSON.stringify(datosDoc));
      if (!res.isError) {
        setTimeout(this.$emit, 2000, "loadingHide", null);
      } else {
        this.$emit("loadingHide", null);
        this.$emit("msjShow", res.errorMessage, "negative", "error");
      }
    },
    async PrintPdf() {
      if (!this.hasSelection) return;
      this.$emit("loadingShow", "Generando Pdf");
      try {
        this.IdSelected = this.selected[0].Id;
        const datosPdf = await this.searchDoc("pdf");
        const doc = new jsPDF({
          format: "legal",
          unit: "px",
          orientation: "portrait",
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

        doc.setFontSize(12);
        doc.text(footer, 600 / 2, pageHeight - 30, {
          baseline: "bottom",
          align: "center",
        });
        doc.html(datosPdf.Html_Header + datosPdf.Html_Body, {
          callback: (docPdf) => {
            docPdf.line(30, pageHeight - 45, pageWidth - 30, pageHeight - 45);
            window.open(docPdf.output("bloburl"));
            this.$emit("loadingHide", null);
          },
          x: 15,
          y: 15,
          width: pageWidth - 20,
          windowWidth: 750,
        });
      } catch (error) {
        this.$emit("loadingHide", null);
        console.error("Error", error);
        this.$emit("msjShow", error.message, "negative", "error");
      }
    },
    async searchDoc(type) {
      try {
        const Tabla = this.tablaDirectTo;
        const Id = this.IdSelected;
        if (!Tabla || !Id) throw "Error - No tabla detected";
        const e = await window.myAPI.executeSp_Ds(
          JSON.stringify({ Id, Tabla }),
          "BD_Get_Documento"
        );
        return type == "word" ? e[1][0] : e[0][0];
      } catch (err) {
        this.$emit("msjShow", err, "negative", "error");
      }
    },
  },
});
</script>
