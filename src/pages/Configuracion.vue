<template>
  <q-page class="config-page">
    <div class="config-shell">
      <header class="config-page__intro">
        <p class="config-eyebrow">Administración</p>
        <h1 class="config-page__title">Configuración</h1>
        <p class="config-page__subtitle">
          Gestione celebrantes, firmantes, plantillas y datos institucionales de la parroquia.
        </p>
      </header>

      <q-tabs
        v-model="activeTab"
        class="config-tabs"
        dense
        align="left"
        active-color="primary"
        indicator-color="primary"
        narrow-indicator
        no-caps
      >
        <q-tab name="ministros" icon="groups" label="Ministros y firmantes" />
        <q-tab name="plantillas" icon="description" label="Plantillas de documentos" />
        <q-tab name="parroquia" icon="account_balance" label="Datos de la parroquia" />
      </q-tabs>

      <q-tab-panels v-model="activeTab" animated class="config-panels">
        <!-- TAB: Ministros -->
        <q-tab-panel name="ministros" class="config-panel">
          <div class="config-panel__header">
            <div>
              <h2 class="config-panel__title">Gestión de personal</h2>
              <p class="config-panel__desc">
                Administre celebrantes de sacramentos, firmantes y quienes dan fe
                en actas y certificados.
              </p>
            </div>
          </div>
          <ConfigUsers
            ref="configUser"
            @mostrarMsj="showMessage"
            @openModal="openModalEdited"
          />
        </q-tab-panel>

        <!-- TAB: Plantillas -->
        <q-tab-panel name="plantillas" class="config-panel">
          <div class="config-panel__header">
            <div>
              <h2 class="config-panel__title">Plantillas y documentos</h2>
              <p class="config-panel__desc">
                Edite plantillas Word, atajos de reemplazo y la plantilla PDF
                (encabezado institucional y pie de página).
              </p>
            </div>
          </div>

          <div class="config-stack">
            <article class="config-surface">
              <div class="config-surface__icon" aria-hidden="true">
                <q-icon name="folder_open" size="22px" />
              </div>
              <div class="config-surface__body">
                <h3 class="config-surface__title">Plantillas Word</h3>
                <p class="config-surface__text">
                  Los certificados (bautismos, confirmaciones, defunciones y
                  matrimonios) se editan en archivos
                  <strong>Template*.docx</strong> dentro de la carpeta de datos de
                  la aplicación (AppData). Así cada parroquia personaliza sin perder
                  cambios al actualizar.
                </p>
                <ul class="config-file-list">
                  <li><code>TemplateBautismo.docx</code></li>
                  <li><code>TemplateConfirmacion.docx</code></li>
                  <li><code>TemplateDefuncion.docx</code></li>
                  <li><code>TemplateMatrimonio.docx</code></li>
                </ul>
                <p class="config-surface__hint">
                  Al terminar, guarde y cierre Word. Puede reemplazar cualquier
                  archivo manteniendo el mismo nombre.
                </p>
                <q-btn
                  class="cfg-btn cfg-btn--primary"
                  unelevated
                  no-caps
                  icon="visibility"
                  label="Abrir carpeta de plantillas"
                  :loading="openingTemplates"
                  @click="showOpenFileTemplates"
                />
              </div>
            </article>

            <article class="config-surface">
              <ConfigShortCurts
                ref="shortCuts"
                @mostrarMsj="showMessage"
                @openModal="openModalEdited"
              />
            </article>

            <article class="config-surface">
              <div class="config-surface__icon config-surface__icon--gold" aria-hidden="true">
                <q-icon name="picture_as_pdf" size="22px" />
              </div>
              <div class="config-surface__body full-width">
                <h3 class="config-surface__title">Plantilla PDF</h3>
                <p class="config-surface__text">
                  El certificado PDF se arma con el encabezado institucional, el
                  cuerpo del sacramento y este pie. Puede cambiar el pie aquí;
                  el encabezado toma los datos de
                  <strong>Datos de la parroquia</strong>.
                </p>

                <div class="config-pdf-preview" aria-label="Encabezado actual">
                  <p class="config-pdf-preview__label">Encabezado actual</p>
                  <div
                    v-if="headerDocPdf"
                    class="config-pdf-preview__html"
                    v-html="headerDocPdf"
                  />
                  <p v-else class="config-surface__hint">
                    Aún no hay encabezado cargado. Revise las variables
                    institucionales en la pestaña Datos de la parroquia.
                  </p>
                </div>

                <p class="config-pdf-preview__label q-mt-md">Pie de página</p>
                <q-editor
                  v-model="footerDocPdf"
                  class="config-editor"
                  min-height="140px"
                  :toolbar="editorToolbar"
                />
                <p class="config-surface__hint">
                  Use negrita, alineación y saltos de línea. Guarde para que los
                  certificados usen este pie. La vista previa muestra el
                  contenido actual del editor, aunque aún no lo haya guardado.
                </p>
                <div class="config-pdf-actions">
                  <q-btn
                    class="cfg-btn cfg-btn--ghost"
                    outline
                    no-caps
                    icon="visibility"
                    label="Vista previa PDF"
                    :loading="previewingPdf"
                    @click="previewPdfTemplate"
                  />
                  <q-btn
                    class="cfg-btn cfg-btn--primary"
                    unelevated
                    no-caps
                    icon="save"
                    label="Guardar pie de página"
                    :loading="savingFooter"
                    @click="saveFooterPdf"
                  />
                </div>
              </div>
            </article>
          </div>
        </q-tab-panel>

        <!-- TAB: Datos parroquia -->
        <q-tab-panel name="parroquia" class="config-panel">
          <div class="config-panel__header">
            <div>
              <h2 class="config-panel__title">Datos institucionales</h2>
              <p class="config-panel__desc">
                Variables del encabezado PDF (nombre, dirección, ciudad),
                exportación y estado del esquema SQL de esta parroquia.
              </p>
            </div>
          </div>

          <div class="config-stack">
            <article class="config-surface">
              <ConfigVariablesGlobales @mostrarMsj="showMessage" />
            </article>

            <article class="config-surface config-export">
              <div class="config-surface__icon" aria-hidden="true">
                <q-icon name="file_download" size="22px" />
              </div>
              <div class="config-surface__body full-width">
                <h3 class="config-surface__title">Exportar información</h3>
                <p class="config-surface__text">
                  Genere un archivo Excel con los registros de la tabla
                  seleccionada.
                </p>
                <div class="config-export__row">
                  <q-select
                    v-model="selectExportData"
                    class="cfg-input config-export__select"
                    dense
                    outlined
                    emit-value
                    map-options
                    :options="exportOptions"
                    label="Tabla a exportar"
                    hide-bottom-space
                  />
                  <q-btn
                    class="cfg-btn cfg-btn--primary"
                    unelevated
                    no-caps
                    icon="download"
                    label="Exportar"
                    :disable="!selectExportData"
                    :loading="exporting"
                    @click="exportData"
                  />
                </div>
              </div>
            </article>

            <article class="config-surface config-schema">
              <div
                class="config-surface__icon"
                :class="{
                  'config-surface__icon--gold': schemaStatusTone === 'ok',
                  'config-surface__icon--warn': schemaStatusTone === 'pending',
                  'config-surface__icon--danger': schemaStatusTone === 'error',
                }"
                aria-hidden="true"
              >
                <q-icon name="storage" size="22px" />
              </div>
              <div class="config-surface__body full-width">
                <div class="config-schema__head">
                  <div>
                    <h3 class="config-surface__title">Esquema de base de datos</h3>
                    <p class="config-surface__text">
                      Versiones SQL aplicadas en esta parroquia. La app actualiza
                      el esquema al iniciar; aquí puede verificar o reintentar.
                    </p>
                  </div>
                  <span
                    class="config-schema__badge"
                    :class="'config-schema__badge--' + schemaStatusTone"
                  >
                    {{ schemaStatusLabel }}
                  </span>
                </div>

                <dl class="config-schema__meta">
                  <div>
                    <dt>Última migración</dt>
                    <dd>
                      <code>{{ migrationStatus.lastMigrationId || "—" }}</code>
                    </dd>
                  </div>
                  <div>
                    <dt>Aplicadas</dt>
                    <dd>{{ migrationStatus.applied.length }}</dd>
                  </div>
                  <div>
                    <dt>Pendientes</dt>
                    <dd>{{ migrationStatus.pending.length }}</dd>
                  </div>
                </dl>

                <div
                  v-if="migrationStatus.pending.length"
                  class="config-schema__list-wrap"
                >
                  <p class="config-schema__list-title">Pendientes de aplicar</p>
                  <ul class="config-schema__list">
                    <li
                      v-for="id in migrationStatus.pending"
                      :key="'p-' + id"
                    >
                      <code>{{ id }}</code>
                    </li>
                  </ul>
                </div>

                <div
                  v-else-if="migrationStatus.applied.length"
                  class="config-schema__list-wrap"
                >
                  <p class="config-schema__list-title">
                    Últimas aplicadas
                    <button
                      type="button"
                      class="config-schema__toggle"
                      @click="showAllMigrations = !showAllMigrations"
                    >
                      {{ showAllMigrations ? "Ver menos" : "Ver todas" }}
                    </button>
                  </p>
                  <ul class="config-schema__list">
                    <li
                      v-for="id in visibleAppliedMigrations"
                      :key="'a-' + id"
                    >
                      <code>{{ id }}</code>
                    </li>
                  </ul>
                </div>

                <p v-if="migrationStatus.error" class="config-schema__error">
                  {{ migrationStatus.error }}
                </p>

                <div class="config-schema__actions">
                  <q-btn
                    class="cfg-btn cfg-btn--ghost"
                    outline
                    no-caps
                    icon="refresh"
                    label="Verificar estado"
                    :loading="loadingSchemaStatus"
                    @click="loadMigrationStatus"
                  />
                  <q-btn
                    class="cfg-btn cfg-btn--primary"
                    unelevated
                    no-caps
                    icon="system_update_alt"
                    label="Actualizar esquema"
                    :loading="runningMigrations"
                    @click="runSchemaMigrations"
                  />
                </div>
              </div>
            </article>
          </div>
        </q-tab-panel>
      </q-tab-panels>
    </div>

    <!-- Create dialogs -->
    <q-dialog v-model="persistent" persistent>
      <q-card class="cfg-dialog">
        <q-card-section class="cfg-dialog__header">
          <div>
            <h2 class="cfg-dialog__title">{{ createTitle }}</h2>
            <p class="cfg-dialog__subtitle">{{ createSubtitle }}</p>
          </div>
          <q-btn
            flat
            round
            dense
            icon="close"
            aria-label="Cerrar"
            @click="closeCreateModal"
          />
        </q-card-section>

        <q-card-section class="cfg-dialog__body">
          <template v-if="editedModl === 1">
            <label class="cfg-field-label">Nombre doy fe</label>
            <q-input
              v-model="newDoyFe.Nombre_DoyFe"
              class="cfg-input"
              dense
              outlined
              autofocus
              placeholder="Nombre completo"
              hide-bottom-space
              @keyup.enter="guardarConfig"
            />
          </template>

          <template v-else-if="editedModl === 2">
            <label class="cfg-field-label">Nombre del ministro</label>
            <q-input
              v-model="newMinistro.Nombre_Ministro"
              class="cfg-input"
              dense
              outlined
              autofocus
              placeholder="Ej. Pbro. Juan Pérez"
              hide-bottom-space
            />
            <label class="cfg-field-label q-mt-md">Cargo</label>
            <q-input
              v-model="newMinistro.Cargo"
              class="cfg-input"
              dense
              outlined
              placeholder="Ej. Párroco, Diácono…"
              hide-bottom-space
              @keyup.enter="guardarConfig"
            />
          </template>

          <template v-else-if="editedModl === 3">
            <label class="cfg-field-label">Atajo</label>
            <q-input
              v-model="newShortCut.ShortCut"
              class="cfg-input"
              dense
              outlined
              autofocus
              placeholder="Ej. {{NOMBRE}}"
              hide-bottom-space
            />
            <label class="cfg-field-label q-mt-md">Plantilla / valor</label>
            <q-input
              v-model="newShortCut.Template"
              class="cfg-input"
              dense
              outlined
              hide-bottom-space
              @keyup.enter="guardarConfig"
            />
          </template>

          <template v-else-if="editedModl === 4">
            <label class="cfg-field-label">Nombre del celebrante</label>
            <q-input
              v-model="newCelebrante.Nombre"
              class="cfg-input"
              dense
              outlined
              autofocus
              placeholder="Ej. LUIS HERNANDO RÍOS ALDANA. PBRO."
              hide-bottom-space
              @keyup.enter="guardarConfig"
            />
            <p class="cfg-dialog__hint">
              Este nombre aparecerá en Bautizos, Confirmaciones y Matrimonios
              (Ministro / Presidió).
            </p>
          </template>
        </q-card-section>

        <q-card-actions class="cfg-dialog__actions" align="right">
          <q-btn flat no-caps label="Cancelar" @click="closeCreateModal" />
          <q-btn
            class="cfg-btn cfg-btn--primary"
            unelevated
            no-caps
            label="Guardar"
            :loading="savingCreate"
            @click="guardarConfig"
          />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";
import ConfigUsers from "components/ConfigUsers.vue";
import ConfigShortCurts from "components/ConfigShortCurts.vue";
import ConfigVariablesGlobales from "components/ConfigVariablesGlobales.vue";
import { printPdf } from "src/utils/printPdf";

export default defineComponent({
  name: "Configuracion",
  components: { ConfigUsers, ConfigShortCurts, ConfigVariablesGlobales },
  mounted() {
    this.getHeaderPdf();
    this.loadMigrationStatus();
  },
  setup() {
    const $q = useQuasar();

    function showLoading(msj) {
      $q.loading.show({ message: msj });
    }

    const hideLoading = () => $q.loading.hide();

    const showMessage = (msj, color, icon) => {
      $q.loading.hide();
      const tone =
        color === "red" || color === "danger" ? "negative" : color || "primary";
      $q.notify({
        progress: true,
        message: msj,
        icon: icon || "info",
        color: tone,
        textColor: "white",
      });
    };

    return {
      showLoading,
      hideLoading,
      showMessage,
      activeTab: ref("ministros"),
      selectExportData: ref(null),
      exportOptions: [
        { label: "Bautismos", value: "Bautismos" },
        { label: "Confirmaciones", value: "Confirmaciones" },
        { label: "Matrimonios", value: "Matrimonios" },
        { label: "Defunciones", value: "Defunciones" },
      ],
      persistent: ref(false),
      editedModl: ref(0),
      savingCreate: ref(false),
      savingFooter: ref(false),
      previewingPdf: ref(false),
      exporting: ref(false),
      openingTemplates: ref(false),
      loadingSchemaStatus: ref(false),
      runningMigrations: ref(false),
      showAllMigrations: ref(false),
      migrationStatus: ref({
        applied: [],
        pending: [],
        available: [],
        lastMigrationId: null,
        error: null,
      }),
      newShortCut: ref({
        ShortCut: "",
        Template: "",
      }),
      newMinistro: ref({
        Nombre_Ministro: "",
        Cargo: "",
      }),
      newDoyFe: ref({
        Nombre_DoyFe: "",
      }),
      newCelebrante: ref({
        Nombre: "",
      }),
      headerDocPdf: ref(""),
      footerDocPdf: ref(""),
      editorToolbar: [
        ["left", "center", "right"],
        ["bold", "italic", "underline"],
        ["hr", "link"],
        ["unordered", "ordered"],
        ["undo", "redo"],
      ],
    };
  },
  computed: {
    createTitle() {
      if (this.editedModl === 1) return "Añadir ministro doy fe";
      if (this.editedModl === 2) return "Añadir ministro firmante";
      if (this.editedModl === 3) return "Añadir atajo";
      if (this.editedModl === 4) return "Añadir ministro celebrante";
      return "Nuevo registro";
    },
    createSubtitle() {
      if (this.editedModl === 1) {
        return "Quedará disponible en actas y certificados.";
      }
      if (this.editedModl === 2) {
        return "Podrá seleccionarlo al firmar documentos oficiales.";
      }
      if (this.editedModl === 3) {
        return "Se usará al generar plantillas Word.";
      }
      if (this.editedModl === 4) {
        return "Aparecerá en el selector Ministro / Presidió de los sacramentos.";
      }
      return "";
    },
    schemaStatusTone() {
      if (this.migrationStatus.error) return "error";
      if (this.migrationStatus.pending.length) return "pending";
      if (this.migrationStatus.applied.length) return "ok";
      return "pending";
    },
    schemaStatusLabel() {
      if (this.migrationStatus.error) return "Error";
      if (this.migrationStatus.pending.length) {
        return `${this.migrationStatus.pending.length} pendiente(s)`;
      }
      if (this.migrationStatus.applied.length) return "Al día";
      return "Sin historial";
    },
    visibleAppliedMigrations() {
      const list = [...(this.migrationStatus.applied || [])].reverse();
      if (this.showAllMigrations) return list;
      return list.slice(0, 5);
    },
  },
  methods: {
    resetCreateForms() {
      this.newDoyFe = { Nombre_DoyFe: "" };
      this.newMinistro = { Nombre_Ministro: "", Cargo: "" };
      this.newShortCut = { ShortCut: "", Template: "" };
      this.newCelebrante = { Nombre: "" };
    },
    async loadMigrationStatus() {
      if (!window.ApiDb?.getMigrationStatus) {
        this.migrationStatus = {
          applied: [],
          pending: [],
          available: [],
          lastMigrationId: null,
          error: "API de migraciones no disponible (modo Electron requerido).",
        };
        return;
      }
      this.loadingSchemaStatus = true;
      try {
        const status = await window.ApiDb.getMigrationStatus();
        this.migrationStatus = {
          applied: Array.isArray(status?.applied) ? status.applied : [],
          pending: Array.isArray(status?.pending) ? status.pending : [],
          available: Array.isArray(status?.available) ? status.available : [],
          lastMigrationId: status?.lastMigrationId || null,
          error:
            status?.ok === false || status?.success === false
              ? status.error || status.message || "No se pudo leer el esquema"
              : null,
        };
      } catch (err) {
        this.migrationStatus = {
          applied: [],
          pending: [],
          available: [],
          lastMigrationId: null,
          error: err?.message || String(err),
        };
      } finally {
        this.loadingSchemaStatus = false;
      }
    },
    async runSchemaMigrations() {
      if (!window.ApiDb?.ensureMigrations) {
        this.showMessage(
          "API de migraciones no disponible",
          "warning",
          "warning"
        );
        return;
      }
      this.runningMigrations = true;
      try {
        const result = await window.ApiDb.ensureMigrations();
        await this.loadMigrationStatus();
        if (result?.ok === false || result?.success === false) {
          this.showMessage(
            result.error || result.message || "Falló la actualización del esquema",
            "negative",
            "error"
          );
          return;
        }
        if (result?.newlyApplied?.length) {
          this.showMessage(
            `Esquema actualizado (${result.newlyApplied.length} migración(es)).`,
            "positive",
            "check"
          );
        } else {
          this.showMessage("El esquema ya está al día.", "positive", "check");
        }
      } catch (err) {
        this.showMessage(
          err?.message || "Error al actualizar el esquema",
          "negative",
          "error"
        );
      } finally {
        this.runningMigrations = false;
      }
    },
    closeCreateModal() {
      this.persistent = false;
      this.editedModl = 0;
      this.resetCreateForms();
    },
    openModalEdited(mdlEdited) {
      this.resetCreateForms();
      this.editedModl = mdlEdited;
      this.persistent = true;
    },
    validateCreate() {
      if (this.editedModl === 1) {
        if (!String(this.newDoyFe.Nombre_DoyFe || "").trim()) {
          this.showMessage("El nombre es obligatorio", "warning", "warning");
          return false;
        }
      } else if (this.editedModl === 2) {
        if (!String(this.newMinistro.Nombre_Ministro || "").trim()) {
          this.showMessage("El nombre es obligatorio", "warning", "warning");
          return false;
        }
      } else if (this.editedModl === 3) {
        if (!String(this.newShortCut.ShortCut || "").trim()) {
          this.showMessage("El atajo es obligatorio", "warning", "warning");
          return false;
        }
      } else if (this.editedModl === 4) {
        if (!String(this.newCelebrante.Nombre || "").trim()) {
          this.showMessage("El nombre es obligatorio", "warning", "warning");
          return false;
        }
      } else {
        return false;
      }
      return true;
    },
    async exportData() {
      if (!this.selectExportData) {
        this.showMessage("Seleccione una tabla para exportar", "warning", "warning");
        return;
      }
      this.exporting = true;
      try {
        const path = await window.myAPI.ExportData(this.selectExportData);
        if (!path || String(path).toLowerCase().includes("error")) {
          this.showMessage(
            path || "No se pudo exportar la información",
            "negative",
            "error"
          );
          return;
        }
        this.showMessage(
          "Se ha guardado exitosamente en: " + path,
          "positive",
          "check"
        );
      } catch (err) {
        this.showMessage(
          err?.message || "Error al exportar",
          "negative",
          "error"
        );
      } finally {
        this.exporting = false;
      }
    },
    async getHeaderPdf() {
      try {
        const result = await window.myAPI.executeSp_Dt("{}", "BD_Get_Setting_Pdf");
        this.footerDocPdf = result?.Html_Footer_Docx || "";
        this.headerDocPdf = result?.Html_Header || "";
      } catch (_) {
        this.footerDocPdf = "";
        this.headerDocPdf = "";
      }
    },
    async guardarConfig() {
      if (!this.validateCreate()) return;

      let sp = "";
      let payload = null;

      if (this.editedModl === 1) {
        sp = "BD_Ins_NewDoyFe";
        payload = {
          Nombre_DoyFe: String(this.newDoyFe.Nombre_DoyFe).trim(),
        };
      } else if (this.editedModl === 2) {
        sp = "BD_Ins_NewMinistro";
        payload = {
          Nombre_Ministro: String(this.newMinistro.Nombre_Ministro).trim(),
          Cargo: String(this.newMinistro.Cargo || "").trim(),
        };
      } else if (this.editedModl === 3) {
        sp = "BD_Ins_ShortCut";
        payload = {
          ShortCut: String(this.newShortCut.ShortCut).trim(),
          Template: String(this.newShortCut.Template || "").trim(),
        };
      } else if (this.editedModl === 4) {
        sp = "BD_Ins_NewMinistroCelebrante";
        payload = {
          Nombre: String(this.newCelebrante.Nombre).trim(),
        };
      }

      this.savingCreate = true;
      try {
        const e = await window.myAPI.executeSp_St(JSON.stringify(payload), sp);
        if (String(e).includes("Error")) {
          this.showMessage(e, "negative", "error");
        } else {
          this.showMessage(e, "positive", "check");
          this.closeCreateModal();
          this.$refs.configUser?.getListConfigs?.();
          this.$refs.shortCuts?.getListConfigs?.();
        }
      } catch (err) {
        this.showMessage(
          err?.message || "No se pudo guardar",
          "negative",
          "error"
        );
      } finally {
        this.savingCreate = false;
      }
    },
    async previewPdfTemplate() {
      this.previewingPdf = true;
      try {
        const res = await printPdf({
          headerHtml: this.headerDocPdf || "",
          bodyHtml: `
            <div style="text-align:center;margin-top:56px;font-family:Arial,Helvetica,sans-serif">
              <p style="font-size:22px;font-weight:700;margin:0 0 10px">VISTA PREVIA DE CERTIFICADO</p>
              <p style="font-size:15px;margin:0 0 28px">Este documento muestra el encabezado y el pie actuales de la parroquia.</p>
              <p style="font-size:13px;color:#444;margin:0">Al exportar un registro, aquí aparecerán los datos del sacramento.</p>
            </div>
          `,
          footerHtml: this.footerDocPdf || "",
          title: "Vista previa de certificado",
          fileName: "VistaPrevia_Certificado.pdf",
        });
        if (res?.isError) {
          this.showMessage(res.errorMessage, "negative", "error");
        } else if (res?.warning) {
          this.showMessage(res.warning, "warning", "warning");
        } else {
          this.showMessage(
            "Vista previa generada. Recuerde guardar el pie si desea usarlo en los certificados.",
            "positive",
            "check"
          );
        }
      } catch (err) {
        this.showMessage(
          err?.message || "No se pudo generar la vista previa",
          "negative",
          "error"
        );
      } finally {
        this.previewingPdf = false;
      }
    },
    async saveFooterPdf() {
      this.savingFooter = true;
      try {
        const json = { FooterDocPdf: this.footerDocPdf || "" };
        const res = await window.myAPI.executeSp_St(
          JSON.stringify(json),
          "BD_Upd_FooterPdf"
        );
        if (String(res).includes("Error")) {
          this.showMessage(res, "negative", "error");
        } else {
          this.showMessage(res, "positive", "check");
        }
      } catch (err) {
        this.showMessage(
          err?.message || "No se pudo guardar el pie de página",
          "negative",
          "error"
        );
      } finally {
        this.savingFooter = false;
      }
    },
    async showOpenFileTemplates() {
      this.openingTemplates = true;
      try {
        await window.myAPI.openFileTemplate();
      } catch (err) {
        this.showMessage(
          err?.message || "No se pudo abrir la carpeta de plantillas",
          "negative",
          "error"
        );
      } finally {
        this.openingTemplates = false;
      }
    },
  },
});
</script>

<style lang="scss">
@import url("https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,650;9..144,700&family=Outfit:wght@300;400;500;600;700&display=swap");

:root {
  --cfg-navy: #0b2431;
  --cfg-navy-mid: #16303c;
  --cfg-gold: #c9a227;
  --cfg-gold-soft: #b8922a;
  --cfg-muted: #5b7380;
  --cfg-line: rgba(11, 36, 49, 0.1);
  --cfg-surface: #ffffff;
  --cfg-bg: #f3f5f7;
  --cfg-blue-soft: #e8f1f6;
  --cfg-radius: 16px;
}

.config-page {
  min-height: 100%;
  background:
    radial-gradient(ellipse 70% 40% at 0% 0%, rgba(42, 157, 143, 0.07), transparent 55%),
    radial-gradient(ellipse 50% 30% at 100% 0%, rgba(201, 162, 39, 0.08), transparent 50%),
    var(--cfg-bg);
  font-family: "Outfit", sans-serif;
  color: var(--cfg-navy-mid);
}

.config-shell {
  width: min(1120px, 100%);
  margin: 0 auto;
  padding: clamp(1rem, 2.5vw, 1.75rem) clamp(0.9rem, 2.5vw, 1.5rem) 2rem;
}

.config-eyebrow {
  margin: 0 0 0.35rem;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  color: var(--cfg-gold-soft);
}

.config-page__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: clamp(1.55rem, 2.8vw, 2rem);
  font-weight: 700;
  color: var(--cfg-navy);
  letter-spacing: -0.02em;
}

.config-page__subtitle {
  margin: 0.4rem 0 0;
  color: var(--cfg-muted);
  font-size: 0.95rem;
  max-width: 58ch;
}

.config-tabs {
  margin-top: 1.25rem;
  border-bottom: 1px solid var(--cfg-line);

  .q-tab {
    min-height: 44px;
    padding: 0 1rem;
    color: var(--cfg-muted);
    font-weight: 500;
  }

  .q-tab--active {
    color: var(--cfg-navy);
    font-weight: 600;
  }

  .q-tabs__content {
    overflow: auto;
  }

  /* indicator uses Quasar primary; force gold-like via CSS var override on page */
  .q-tab__indicator {
    background: var(--cfg-gold-soft) !important;
    height: 2px;
  }
}

.config-panels {
  background: transparent;
}

.config-panel {
  padding: 1.25rem 0 0;
}

.config-panel__header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.15rem;
}

.config-panel__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: 1.35rem;
  font-weight: 650;
  color: var(--cfg-navy);
}

.config-panel__desc {
  margin: 0.35rem 0 0;
  color: var(--cfg-muted);
  font-size: 0.92rem;
  max-width: 60ch;
}

.config-stack {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.config-surface {
  background: var(--cfg-surface);
  border: 1px solid var(--cfg-line);
  border-radius: var(--cfg-radius);
  box-shadow: 0 10px 28px rgba(11, 36, 49, 0.05);
  padding: 1.25rem;
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}

.config-surface__icon {
  flex-shrink: 0;
  width: 42px;
  height: 42px;
  border-radius: 12px;
  display: grid;
  place-items: center;
  background: rgba(11, 36, 49, 0.07);
  color: var(--cfg-navy);
}

.config-surface__icon--gold {
  background: rgba(201, 162, 39, 0.14);
  color: var(--cfg-gold-soft);
}

.config-surface__icon--warn {
  background: rgba(217, 119, 6, 0.12);
  color: #b45309;
}

.config-surface__icon--danger {
  background: rgba(185, 28, 28, 0.1);
  color: #b91c1c;
}

.config-schema__head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.config-schema__badge {
  display: inline-flex;
  align-items: center;
  padding: 0.28rem 0.7rem;
  border-radius: 999px;
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  flex-shrink: 0;
}

.config-schema__badge--ok {
  background: rgba(15, 118, 110, 0.12);
  color: #0f766e;
}

.config-schema__badge--pending {
  background: rgba(217, 119, 6, 0.14);
  color: #b45309;
}

.config-schema__badge--error {
  background: rgba(185, 28, 28, 0.12);
  color: #b91c1c;
}

.config-schema__meta {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 0.75rem 1rem;
  margin: 1rem 0 0;
}

.config-schema__meta dt {
  margin: 0;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: var(--cfg-muted);
}

.config-schema__meta dd {
  margin: 0.25rem 0 0;
  color: var(--cfg-navy);
  font-size: 0.9rem;
  font-weight: 600;
  word-break: break-word;
}

.config-schema__meta code,
.config-schema__list code {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 0.78rem;
  font-weight: 500;
  background: rgba(11, 36, 49, 0.05);
  padding: 0.1rem 0.35rem;
  border-radius: 6px;
}

.config-schema__list-wrap {
  margin-top: 1rem;
}

.config-schema__list-title {
  margin: 0 0 0.45rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--cfg-navy-mid);
}

.config-schema__toggle {
  border: 0;
  background: transparent;
  color: var(--cfg-gold-soft);
  font: inherit;
  font-size: 0.78rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0;
}

.config-schema__toggle:hover {
  text-decoration: underline;
}

.config-schema__list {
  margin: 0;
  padding-left: 1.1rem;
  color: var(--cfg-navy-mid);
  font-size: 0.84rem;
  max-height: 160px;
  overflow: auto;
}

.config-schema__list li + li {
  margin-top: 0.25rem;
}

.config-schema__error {
  margin: 0.85rem 0 0;
  font-size: 0.84rem;
  color: #b91c1c;
  line-height: 1.4;
}

.config-schema__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.65rem;
  margin-top: 1rem;
}

.config-surface__body {
  min-width: 0;
  flex: 1;
}

.config-surface__title {
  margin: 0 0 0.35rem;
  font-size: 1.05rem;
  font-weight: 650;
  font-family: "Fraunces", serif;
  color: var(--cfg-navy);
}

.config-surface__text {
  margin: 0;
  font-size: 0.9rem;
  line-height: 1.5;
  color: var(--cfg-muted);
}

.config-surface__hint {
  margin: 0.75rem 0 1rem;
  font-size: 0.84rem;
  color: var(--cfg-muted);
}

.config-file-list {
  margin: 0.75rem 0 0;
  padding-left: 1.1rem;
  color: var(--cfg-navy-mid);
  font-size: 0.88rem;
}

.config-file-list code,
.cfg-code {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: 0.82rem;
  background: rgba(11, 36, 49, 0.05);
  padding: 0.1rem 0.35rem;
  border-radius: 6px;
}

.config-editor {
  border: 1px solid var(--cfg-line);
  border-radius: 12px;
  overflow: hidden;
  background: #fff;
}

.config-pdf-preview {
  margin-top: 1rem;
  padding: 0.85rem 1rem;
  border: 1px dashed var(--cfg-line);
  border-radius: 12px;
  background: #f8fafb;
}

.config-pdf-preview__label {
  margin: 0 0 0.45rem;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--cfg-muted);
}

.config-pdf-preview__html {
  color: var(--cfg-navy);
  font-size: 0.92rem;
  line-height: 1.4;
}

.config-pdf-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.7rem;
  margin-top: 1rem;
}

.config-export__row {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  align-items: center;
  margin-top: 0.9rem;
}

.config-export__select {
  min-width: min(280px, 100%);
  flex: 1;
}

/* Shared component styles */
.cfg-btn {
  min-height: 40px;
  padding: 0 1rem;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.88rem;
}

.cfg-btn--primary {
  background: var(--cfg-navy) !important;
  color: #fff !important;
}

.cfg-btn--ghost {
  color: var(--cfg-navy) !important;
  border-color: rgba(11, 36, 49, 0.28) !important;
}

.cfg-users__section + .cfg-users__section {
  margin-top: 1.75rem;
}

.cfg-users__section-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 0.95rem;
  flex-wrap: wrap;
}

.cfg-users__section-title,
.cfg-panel-title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: 1.12rem;
  font-weight: 650;
  color: var(--cfg-navy);
}

.cfg-users__section-desc,
.cfg-panel-desc {
  margin: 0.3rem 0 0;
  color: var(--cfg-muted);
  font-size: 0.88rem;
  max-width: 56ch;
}

.cfg-panel-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1rem;
  flex-wrap: wrap;
}

.cfg-card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 0.9rem;
}

.cfg-person-card {
  background: var(--cfg-surface);
  border: 1px solid var(--cfg-line);
  border-radius: 14px;
  box-shadow: 0 8px 22px rgba(11, 36, 49, 0.05);
  padding: 1rem 1rem 0.9rem;
  text-align: left;
  transition:
    box-shadow 0.18s ease,
    transform 0.18s ease;
}

.cfg-person-card--accent {
  border-left: 4px solid var(--cfg-gold-soft);
}

.cfg-person-card--add {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.55rem;
  min-height: 132px;
  border-style: dashed;
  border-width: 1.5px;
  background: transparent;
  box-shadow: none;
  color: var(--cfg-muted);
  font-weight: 500;
  cursor: pointer;
  font-family: inherit;
}

.cfg-person-card--add:hover {
  border-color: var(--cfg-navy);
  color: var(--cfg-navy);
  background: rgba(255, 255, 255, 0.7);
}

.cfg-person-card__add-icon {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: rgba(11, 36, 49, 0.06);
}

.cfg-person-card__top {
  display: flex;
  align-items: flex-start;
  gap: 0.7rem;
}

.cfg-person-card__avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: var(--cfg-blue-soft);
  color: var(--cfg-navy);
  flex-shrink: 0;
}

.cfg-person-card__avatar--gold {
  background: rgba(201, 162, 39, 0.16);
  color: var(--cfg-gold-soft);
}

.cfg-person-card__identity {
  min-width: 0;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.35rem;
}

.cfg-person-card__name {
  font-weight: 650;
  color: var(--cfg-navy);
  font-size: 0.95rem;
  line-height: 1.25;
  word-break: break-word;
}

.cfg-person-card__actions {
  display: flex;
  gap: 0.1rem;
  margin-left: auto;
}

.cfg-person-card__meta {
  margin-top: 0.85rem;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.78rem;
  color: var(--cfg-muted);
}

.cfg-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.18rem 0.55rem;
  border-radius: 999px;
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}

.cfg-badge--gold {
  background: rgba(201, 162, 39, 0.18);
  color: #8a6a12;
}

.cfg-badge--blue {
  background: rgba(7, 120, 219, 0.12);
  color: #0b5ea8;
}

.cfg-table {
  background: transparent;

  .q-table__top,
  .q-table__bottom,
  thead tr,
  tbody td {
    background: transparent;
  }

  thead th {
    font-weight: 600;
    color: var(--cfg-muted);
    font-size: 0.78rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }

  tbody td {
    border-color: var(--cfg-line);
  }
}

.cfg-table__row:hover {
  background: rgba(11, 36, 49, 0.025);
}

.cfg-table__label {
  font-weight: 600;
  color: var(--cfg-navy);
}

.cfg-table__muted {
  color: var(--cfg-navy-mid);
  font-size: 0.9rem;
}

.cfg-table__value-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
}

.cfg-field-label {
  display: block;
  margin-bottom: 0.35rem;
  font-size: 0.82rem;
  font-weight: 500;
  color: var(--cfg-navy-mid);
}

.cfg-input .q-field__control {
  border-radius: 10px;
}

.cfg-dialog {
  width: min(420px, 94vw);
  border-radius: 16px;
  font-family: "Outfit", sans-serif;
  color: var(--cfg-navy-mid);
}

.cfg-dialog__header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.75rem;
}

.cfg-dialog__title {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: 1.2rem;
  font-weight: 650;
  color: var(--cfg-navy);
}

.cfg-dialog__subtitle {
  margin: 0.3rem 0 0;
  font-size: 0.82rem;
  color: var(--cfg-muted);
}

.cfg-dialog__body {
  padding-top: 0.15rem;
}

.cfg-dialog__actions {
  padding: 0 1rem 1rem;
}

.cfg-dialog__hint {
  margin: 0.55rem 0 0;
  font-size: 0.78rem;
  color: var(--cfg-muted);
  line-height: 1.4;
}

@media (max-width: 720px) {
  .config-surface {
    flex-direction: column;
  }

  .config-tabs .q-tab {
    padding: 0 0.65rem;
  }
}
</style>
