<template>
  <div class="preview">
    <q-dialog
      v-model="dialog"
      persistent
      :maximized="maximizedToggle"
      transition-show="slide-up"
      transition-hide="slide-down"
    >
      <q-card class="preview-dialog">
        <header class="preview-dialog__toolbar">
          <div class="preview-dialog__actions" role="group" aria-label="Exportar">
            <q-btn
              class="preview-dialog__btn"
              unelevated
              no-caps
              icon="description"
              label="Word"
              @click="goToWordZip()"
            />
            <q-btn
              class="preview-dialog__btn preview-dialog__btn--ghost"
              outline
              no-caps
              icon="picture_as_pdf"
              label="PDF"
              @click="goToPdf()"
            />
          </div>
          <q-space />
          <div class="preview-dialog__window">
            <q-btn
              flat
              dense
              round
              icon="minimize"
              aria-label="Minimizar"
              :disable="!maximizedToggle"
              @click="maximizedToggle = false"
            >
              <q-tooltip>Minimizar</q-tooltip>
            </q-btn>
            <q-btn
              flat
              dense
              round
              icon="crop_square"
              aria-label="Maximizar"
              :disable="maximizedToggle"
              @click="maximizedToggle = true"
            >
              <q-tooltip>Maximizar</q-tooltip>
            </q-btn>
            <q-btn
              flat
              dense
              round
              icon="close"
              aria-label="Cerrar"
              v-close-popup
            >
              <q-tooltip>Cerrar</q-tooltip>
            </q-btn>
          </div>
        </header>

        <form
          class="preview-dialog__body"
          autocorrect="on"
          autocapitalize="on"
          autocomplete="on"
          spellcheck="false"
        >
          <div class="preview-dialog__section-label">Cabezal</div>
          <q-editor v-model="CurrentData.Html_Header" class="preview-dialog__editor" />
          <div class="preview-dialog__section-label">Cuerpo</div>
          <q-editor v-model="CurrentData.Html_Body" class="preview-dialog__editor" />
          <div class="preview-dialog__section-label">Pie</div>
          <q-editor
            v-model="CurrentData.Html_Footer_Docx"
            class="preview-dialog__editor"
          />
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
      window.myAPI.convertToDocx(JSON.stringify(this.CurrentData)).then(() => {
        this.hideLoading();
      });
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
          this.showMessage(e.errorMessage, "negative", "error");
        }
      });
    },
  },
  watch: {
    dialog(news) {
      if (news == false) {
        this.$parent.IdSelected = null;
      }
    },
  },
});
</script>

<style lang="scss">
.preview-dialog {
  --preview-navy: #0b2431;
  --preview-navy-mid: #16303c;
  --preview-muted: #5b7380;
  --preview-line: rgba(11, 36, 49, 0.1);
  --preview-fog: #f3f5f7;

  width: 100%;
  max-width: 100%;
  font-family: "Outfit", sans-serif;
  color: var(--preview-navy-mid);
  background: #fff;
}

.preview-dialog__toolbar {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
  padding: 0.65rem 0.85rem;
  border-bottom: 1px solid var(--preview-line);
  background: var(--preview-fog);
}

.preview-dialog__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}

.preview-dialog__btn {
  min-height: 36px;
  padding: 0 0.9rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.84rem;
  background: var(--preview-navy) !important;
  color: #fff !important;
}

.preview-dialog__btn--ghost {
  background: transparent !important;
  color: var(--preview-navy) !important;
  border-color: rgba(11, 36, 49, 0.28) !important;
}

.preview-dialog__window .q-btn {
  color: var(--preview-navy-mid) !important;
}

.preview-dialog__body {
  padding: 0.75rem 0.85rem 1rem;
  background: #fff;
}

.preview-dialog__section-label {
  margin: 0.65rem 0 0.35rem;
  padding: 0.35rem 0.65rem;
  border-radius: 8px;
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--preview-muted);
  background: rgba(11, 36, 49, 0.05);
}

.preview-dialog__section-label:first-child {
  margin-top: 0;
}

.preview-dialog__editor {
  border: 1px solid var(--preview-line);
  border-radius: 10px;
  overflow: hidden;
}
</style>
