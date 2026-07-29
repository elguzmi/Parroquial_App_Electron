<template>
  <q-page class="sac-page">
    <div class="sac-shell">
      <header class="sac-header">
        <h1 class="sac-header__title">Defunciones</h1>
        <div
          class="sac-mode"
          :class="{ 'sac-mode--edit': isEditing }"
          role="status"
        >
          <q-icon :name="isEditing ? 'edit' : 'add_circle_outline'" size="16px" />
          {{ isEditing ? "Editando registro" : "Nuevo registro" }}
        </div>
      </header>

      <section class="sac-panel" aria-labelledby="defunciones-form-title">
        <h2 id="defunciones-form-title" class="sr-only">
          Formulario de defunción
        </h2>
        <q-form
          class="sac-form"
          @submit="saveDefuncion()"
          @reset="resetValues()"
        >
          <!-- Partida -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="menu_book" size="16px" />
              </div>
              <h3 class="sac-section__title">Partida</h3>
            </div>
            <div class="sac-grid sac-grid--partida">
              <div class="sac-field">
                <label class="sac-label" for="def-codigo">Nº de defunción</label>
                <q-input
                  id="def-codigo"
                  v-model="No_Defuncion"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  readonly
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-libro">Libro</label>
                <q-input
                  id="def-libro"
                  v-model="Libro"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-folio">Folio</label>
                <q-input
                  id="def-folio"
                  v-model="Folio"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-numero">Número</label>
                <q-input
                  id="def-numero"
                  v-model="Numero"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <!-- Difunto -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="person" size="16px" />
              </div>
              <h3 class="sac-section__title">Datos del difunto</h3>
            </div>
            <div class="sac-grid sac-grid--2">
              <div class="sac-field">
                <label class="sac-label" for="def-nombre">Nombre del difunto</label>
                <q-input
                  id="def-nombre"
                  v-model="dataDefunciones.Nombre_Difunto"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-fecha-sepelio">Fecha de sepelio</label>
                <q-input
                  id="def-fecha-sepelio"
                  v-model="dataDefunciones.Fecha_Sepelio"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-ciudad">Natural de</label>
                <q-input
                  id="def-ciudad"
                  v-model="dataDefunciones.Ciudad_Origen"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-edad">Edad</label>
                <q-input
                  id="def-edad"
                  v-model="dataDefunciones.Edad"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field sac-field--full">
                <label class="sac-label" for="def-padres">Hijo de</label>
                <q-input
                  id="def-padres"
                  v-model="dataDefunciones.Padres"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-estado-civil">Estado civil</label>
                <q-input
                  id="def-estado-civil"
                  v-model="dataDefunciones.Estado_Civil"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-ocasion">Murió de</label>
                <q-input
                  id="def-ocasion"
                  v-model="dataDefunciones.Ocacion_Muerte"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <!-- Firmas -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="draw" size="16px" />
              </div>
              <h3 class="sac-section__title">Firmas del documento</h3>
            </div>
            <div class="sac-grid sac-grid--firma">
              <div class="sac-field">
                <label class="sac-label" for="def-doyfe">Doy fe</label>
                <q-select
                  id="def-doyfe"
                  v-model="dataDefunciones.Id_DoyFe"
                  class="sac-select"
                  dense
                  outlined
                  use-input
                  option-value="Id"
                  option-label="Nombre"
                  emit-value
                  map-options
                  :options="ListDoyFe"
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-firma">Firma del documento</label>
                <q-select
                  id="def-firma"
                  v-model="dataDefunciones.Id_Firmante"
                  class="sac-select"
                  dense
                  outlined
                  use-input
                  option-value="Id"
                  option-label="Nombre"
                  emit-value
                  map-options
                  :options="[...ListMinistros, ...(ListMinistrosNoActive || [])]"
                  hide-bottom-space
                  @update:model-value="setCargoFirm()"
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="def-cargo">Cargo firmante</label>
                <q-input
                  id="def-cargo"
                  v-model="dataDefunciones.Cargo_Firmante"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  disable
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <!-- Nota -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="notes" size="16px" />
              </div>
              <h3 class="sac-section__title">Nota marginal</h3>
            </div>
            <div class="sac-editor-wrap">
              <label class="sac-label" for="def-nota">Observaciones (opcional)</label>
              <q-editor
                id="def-nota"
                v-model="dataDefunciones.NotaMarginal"
                class="sac-editor"
                min-height="3rem"
                :toolbar="[
                  ['bold', 'italic', 'underline'],
                  ['unordered', 'ordered'],
                  ['undo', 'redo'],
                ]"
              />
            </div>
          </div>

          <div class="sac-actions">
            <q-btn
              class="sac-btn sac-btn--ghost"
              outline
              no-caps
              type="reset"
              icon="restart_alt"
              :label="isEditing ? 'Cancelar edición' : 'Limpiar formulario'"
            />
            <q-btn
              class="sac-btn sac-btn--primary"
              unelevated
              no-caps
              type="submit"
              icon="save"
              :label="isEditing ? 'Actualizar defunción' : 'Guardar defunción'"
            />
          </div>
        </q-form>
      </section>

      <section
        v-if="perfil == 1 || perfil == 2"
        class="sac-panel sac-registry"
        aria-labelledby="defunciones-registry-title"
      >
        <h2 id="defunciones-registry-title" class="sr-only">
          Listado de defunciones
        </h2>
        <Table_Component
          v-if="rows.length > 0"
          ref="tableComponent"
          title="Registros de defunciones"
          tablaDirectTo="fact_Defunciones"
          :columns="columns"
          :rows="rows"
          :visibleColumns="visibleColumns"
          @eventedited="setrecord"
          @eventinvt="invtrecord"
          @loadingShow="showLoading"
          @loadingHide="hideLoading"
          @msjShow="showMessage"
        />
        <p v-else class="sac-registry__empty">
          Aún no hay defunciones cargadas o está consultando el listado…
        </p>
      </section>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import Table_Component from "components/Table_Component.vue";
import { useQuasar } from "quasar";

export default defineComponent({
  name: "Defunciones",
  components: {
    Table_Component,
  },
  mounted() {
    this.showLoading("Cargando Datos...");
    this.getDataLogin((e, data) => {
      this.perfil = data.Id_Perfil;
      this.getId_MinistroDoyFe();
      if (this.perfil == 1 || this.perfil == 2) this.getDefunciones();
      else this.hideLoading();
    });
  },
  computed: {
    isEditing() {
      return this.Id != null && this.Id !== "";
    },
  },
  setup() {
    const q = useQuasar();

    const getDataLogin = (cll) => {
      if (q.localStorage.has("SK"))
        cll(true, JSON.parse(q.localStorage.getItem("SK")));
      else cll(false, {});
    };

    function showLoading(msj) {
      q.loading.show({
        message: msj,
      });
    }
    const showMessage = (msj, color, icon) => {
      q.loading.hide();
      q.notify({
        progress: true,
        message: msj,
        icon: icon,
        color: color,
        textColor: "white",
      });
    };
    const hideLoading = () => q.loading.hide();
    return {
      perfil: ref(null),
      getDataLogin,

      Documento: ref(null),
      showDialog: ref(false),

      showLoading,
      hideLoading,
      showMessage,
      isDense: ref(true),

      Id: ref(null),
      No_Defuncion: ref(null),
      Libro: ref(""),
      Folio: ref(""),
      Numero: ref(""),
      dataDefunciones: ref({
        Nombre_Difunto: ref(null),
        Fecha_Sepelio: ref(null),
        Ciudad_Origen: ref(null),
        Edad: ref(null),
        Padres: ref(null),
        Estado_Civil: ref(null),
        Ocacion_Muerte: ref(null),
        Id_DoyFe: ref(0),
        NotaMarginal: ref(null),
        Id_Firmante: ref(0),
        Cargo_Firmante: ref(null),
      }),

      rows: ref([]),
      columns: ref([]),
      visibleColumns: ref([]),
      ListDoyFe: ref([]),
      ListMinistros: ref([]),
      ListMinistrosNoActive: ref([]),
    };
  },
  methods: {
    async getId_MinistroDoyFe() {
      try {
        const e = await window.myAPI.executeSp_Ds(
          JSON.stringify({}),
          "BD_Get_Lists_Ministros"
        );
        this.ListDoyFe = e[0];
        this.ListMinistros = e[1];
        this.setFirmanteFav();
      } catch (error) {
        this.showMessage(error, "red", "danger");
      }
    },
    async getDefunciones() {
      try {
        const e = await window.myAPI.executeSp_Ds(
          "{}",
          "BD_Get_Lists_Defunciones"
        );
        this.columns = [];
        let { Columnas, Columnas_Label, Columnas_Visibles } = e[1][0];
        Columnas = Columnas.split("|");
        Columnas_Label = Columnas_Label.split("|");
        Columnas_Visibles = Columnas_Visibles.split("|");
        this.visibleColumns = Columnas_Visibles;
        Object.keys(Columnas).map((el, idx) => {
          this.columns.push({
            name: Columnas[el],
            align: "center",
            label: Columnas_Label[idx],
            field: Columnas[el],
            sortable: true,
          });
        });
        this.rows = e[0];
        this.hideLoading();
      } catch (error) {
        this.hideLoading();
        this.showMessage(error, "red", "danger");
      }
    },
    async saveDefuncion() {
      try {
        const result = this.makeValidation();
        if (result != "OK") throw result;
        let DatosIns = this.dataDefunciones;
        DatosIns.Libro = this.Libro;
        DatosIns.Folio = this.Folio;
        DatosIns.Numero = this.Numero;
        if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;
        const e = await window.myAPI.executeSp_St(
          JSON.stringify(DatosIns),
          this.Id != null && this.Id != ""
            ? "BD_Upd_Defuncion"
            : "BD_Ins_Defuncion"
        );
        if (e.toLowerCase().indexOf("error") >= 0) throw e;
        this.showMessage(e, "positive", "check");
        this.resetValues();
        this.$refs.tableComponent?.cleanSelectedRow?.();
        this.getDefunciones();
      } catch (error) {
        this.hideLoading();
        this.showMessage(error, "red", "danger");
      }
    },
    makeValidation() {
      let msj = "OK";
      if (this.No_Defuncion != this.Libro + this.Folio + this.Numero)
        msj = "Error - El codigo de partida no coincide";
      Object.keys(this.dataDefunciones).map((elem) => {
        if (elem != "NotaMarginal") {
          if (
            this.dataDefunciones[elem] == null ||
            this.dataDefunciones[elem] == ""
          )
            msj += !msj.includes("Error")
              ? "Error - Completa los siguientes campos : " + elem
              : " - " + elem;
        }
      });
      return msj;
    },
    setrecord(data) {
      this.Id = data.Id;
      this.No_Defuncion = data.No_Defuncion;
      this.Libro = data.Libro;
      this.Folio = data.Folio;
      this.Numero = data.Numero;
      this.addMinistroToList(data.Id_Firmante, data.Nombre_Firmante);
      for (const key in this.dataDefunciones) {
        this.dataDefunciones[key] = data[key];
      }
      this.setFirmanteFav();
      this.setCargoFirm();
    },

    addMinistroToList(id, name) {
      const verify =
        this.ListMinistros.some((e) => e.Id == id) ||
        this.ListMinistrosNoActive.some((e) => e.Id == id);
      if (!verify) this.ListMinistrosNoActive.push({ Id: id, Nombre: name });
    },
    setCargoFirm() {
      const cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataDefunciones.Id_Firmante
      )?.Cargo;
      if (cargo) this.dataDefunciones.Cargo_Firmante = cargo;
    },
    async invtrecord(Id) {
      this.showLoading("Realizando Eliminacion, Espera un momento...");
      const res = await window.myAPI.executeSp_St(
        JSON.stringify({ Id }),
        "BD_Invt_Defuncion"
      );
      if (res.includes("Error")) this.showMessage(res, "red", "error");
      else this.showMessage(res, "positive", "check");
      this.getDefunciones();
    },
    resetValues() {
      this.Id = null;
      this.No_Defuncion = null;
      this.Libro = "";
      this.Folio = "";
      this.Numero = "";
      this.dataDefunciones.Nombre_Difunto = null;
      this.dataDefunciones.Fecha_Sepelio = null;
      this.dataDefunciones.Ciudad_Origen = null;
      this.dataDefunciones.Edad = null;
      this.dataDefunciones.Padres = null;
      this.dataDefunciones.Estado_Civil = null;
      this.dataDefunciones.Ocacion_Muerte = null;
      this.dataDefunciones.Id_DoyFe = 0;
      this.dataDefunciones.NotaMarginal = null;
      this.dataDefunciones.Id_Firmante = 0;
      this.dataDefunciones.Cargo_Firmante = null;
      this.$refs.tableComponent?.cleanSelectedRow?.();
      this.ListMinistrosNoActive = [];
      this.setFirmanteFav();
    },
    setFirmanteFav() {
      const selectDefault = this.ListMinistros.find((e) => e.isCurrent == 1);
      if (selectDefault) {
        this.dataDefunciones.Id_Firmante = selectDefault.Id;
        this.dataDefunciones.Cargo_Firmante = selectDefault.Cargo;
      }
    },
  },
  watch: {
    Libro(newValue, oldValue) {
      this.No_Defuncion = newValue + this.Folio + this.Numero;
    },
    Folio(newValue, oldValue) {
      this.No_Defuncion = this.Libro + newValue + this.Numero;
    },
    Numero(newValue, oldValue) {
      this.No_Defuncion = this.Libro + this.Folio + newValue;
    },
  },
});
</script>
