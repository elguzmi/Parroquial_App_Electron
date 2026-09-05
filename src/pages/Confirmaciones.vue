<template>
  <q-page class="sac-page">
    <div class="sac-shell">
      <header class="sac-header">
        <h1 class="sac-header__title">Confirmaciones</h1>
        <div
          class="sac-mode"
          :class="{ 'sac-mode--edit': isEditing }"
          role="status"
        >
          <q-icon :name="isEditing ? 'edit' : 'add_circle_outline'" size="16px" />
          {{ isEditing ? "Editando registro" : "Nuevo registro" }}
        </div>
      </header>

      <section class="sac-panel" aria-labelledby="confirmaciones-form-title">
        <h2 id="confirmaciones-form-title" class="sr-only">
          Formulario de confirmación
        </h2>
        <q-form
          class="sac-form"
          @submit="saveConfirmacion()"
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
                <label class="sac-label" for="conf-codigo">Código de partida</label>
                <q-input
                  id="conf-codigo"
                  v-model="Codigo_Partida"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  readonly
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-libro">Libro</label>
                <q-input
                  id="conf-libro"
                  v-model="Libro"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-folio">Folio</label>
                <q-input
                  id="conf-folio"
                  v-model="Folio"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-numero">Número</label>
                <q-input
                  id="conf-numero"
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

          <!-- Confirmado -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="person" size="16px" />
              </div>
              <h3 class="sac-section__title">Datos del confirmado</h3>
            </div>
            <div class="sac-grid sac-grid--2">
              <div class="sac-field">
                <label class="sac-label" for="conf-fecha">Fecha de confirmación</label>
                <q-input
                  id="conf-fecha"
                  v-model="dataConfirmacion.Fecha_Confirmacion"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-nombre">Nombre del confirmado</label>
                <q-input
                  id="conf-nombre"
                  v-model="dataConfirmacion.Nombre_Confirmado"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-lugar-n">Lugar de nacimiento</label>
                <q-input
                  id="conf-lugar-n"
                  v-model="dataConfirmacion.Lugar_Nacimiento"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-fecha-n">Fecha de nacimiento</label>
                <q-input
                  id="conf-fecha-n"
                  v-model="dataConfirmacion.Fecha_Nacimiento"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field sac-field--full">
                <label class="sac-label" for="conf-padres">Nombre de los padres</label>
                <q-input
                  id="conf-padres"
                  v-model="dataConfirmacion.Nombre_Padres"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-diocesis">Diócesis</label>
                <q-input
                  id="conf-diocesis"
                  v-model="dataConfirmacion.Diocesis"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-parroquia-b">
                  Bautizado en la parroquia de
                </label>
                <q-input
                  id="conf-parroquia-b"
                  v-model="dataConfirmacion.Parroquia_Bautizo"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <!-- Referencia de bautismo -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="water_drop" size="16px" />
              </div>
              <h3 class="sac-section__title">Referencia de bautismo</h3>
            </div>
            <div class="sac-grid sac-grid--bautismo-ref">
              <div class="sac-field">
                <label class="sac-label" for="conf-fecha-bautismo">Fecha de bautismo</label>
                <q-input
                  id="conf-fecha-bautismo"
                  v-model="dataConfirmacion.Fecha_Bautismo"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-libro-b">Libro</label>
                <q-input
                  id="conf-libro-b"
                  v-model="dataConfirmacion.Libro_B"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-folio-b">Folio</label>
                <q-input
                  id="conf-folio-b"
                  v-model="dataConfirmacion.Folio_B"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-numero-b">Número</label>
                <q-input
                  id="conf-numero-b"
                  v-model="dataConfirmacion.Numero_B"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <!-- Padrinos y ministro -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="family_restroom" size="16px" />
              </div>
              <h3 class="sac-section__title">Padrinos y ministro</h3>
            </div>
            <div class="sac-grid sac-grid--2">
              <div class="sac-field sac-field--full">
                <label class="sac-label" for="conf-padrinos">Padrino o madrina</label>
                <q-input
                  id="conf-padrinos"
                  v-model="dataConfirmacion.Padrinos"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-ministro">Ministro</label>
                <q-select
                  id="conf-ministro"
                  v-model="dataConfirmacion.Ministro"
                  class="sac-select"
                  dense
                  outlined
                  use-input
                  hide-selected
                  fill-input
                  input-debounce="0"
                  :options="ministroOptions"
                  hide-bottom-space
                  @input-value="setModel"
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
                <label class="sac-label" for="conf-doyfe">Doy fe</label>
                <q-select
                  id="conf-doyfe"
                  v-model="dataConfirmacion.Id_MinistroDoyFe"
                  class="sac-select"
                  dense
                  outlined
                  use-input
                  option-value="Id"
                  option-label="Nombre"
                  emit-value
                  map-options
                  :options="ListId_MinistroDoyFe"
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="conf-firma">Firma del documento</label>
                <q-select
                  id="conf-firma"
                  v-model="dataConfirmacion.Id_Ministro"
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
                <label class="sac-label" for="conf-cargo">Cargo firmante</label>
                <q-input
                  id="conf-cargo"
                  v-model="dataConfirmacion.Cargo"
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

          <!-- Notas -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="notes" size="16px" />
              </div>
              <h3 class="sac-section__title">Notas y correcciones</h3>
            </div>
            <div class="sac-editor-wrap">
              <label class="sac-label" for="conf-notas">Notas y correcciones</label>
              <q-editor
                id="conf-notas"
                v-model="dataConfirmacion.Notas_Correcciones"
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
              :label="isEditing ? 'Actualizar confirmación' : 'Guardar confirmación'"
            />
          </div>
        </q-form>
      </section>

      <section
        v-if="perfil == 1 || perfil == 2"
        class="sac-panel sac-registry"
        aria-labelledby="confirmaciones-registry-title"
      >
        <h2 id="confirmaciones-registry-title" class="sr-only">
          Listado de confirmaciones
        </h2>
        <Table_Component
          v-if="rows.length > 0"
          ref="tableComponent"
          title="Registros de confirmaciones"
          tablaDirectTo="fact_Confirmaciones"
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
          Aún no hay confirmaciones cargadas o está consultando el listado…
        </p>
      </section>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";
import Table_Component from "components/Table_Component.vue";
import { loadCelebranteNombreOptions, mergeCurrentCelebranteOption, SACRAMENTO_CELEBRANTE } from "src/utils/celebrantes";

export default defineComponent({
  name: "Confirmaciones",
  components: {
    Table_Component,
  },
  mounted() {
    this.showLoading("Cargando Datos...");

    this.getDataLogin(async (e, data) => {
      try {
        this.perfil = data.Id_Perfil;
        await this.getId_MinistroDoyFe();
        if (this.perfil == 1 || this.perfil == 2) this.getConfirmaciones();
        else this.hideLoading();
      } catch (e) {
        this.showMessage(e, "red", "error");
      }
    });
  },
  computed: {
    isEditing() {
      return this.Id != null && this.Id !== "";
    },
  },
  setup() {
    const $q = useQuasar();

    function showLoading(msj) {
      $q.loading.show({
        message: msj,
      });
    }
    const getDataLogin = (cll) => {
      if ($q.localStorage.has("SK"))
        cll(true, JSON.parse($q.localStorage.getItem("SK")));
      else cll(false, {});
    };

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
      getDataLogin,
      perfil: ref(null),

      Documento: ref(null),
      showDialog: ref(false),

      showLoading,
      hideLoading,
      showMessage,

      isDense: true,
      Id: ref(null),
      Codigo_Partida: ref(null),
      Libro: ref(""),
      Folio: ref(""),
      Numero: ref(""),

      ministroOptions: ref([]),

      dataConfirmacion: ref({
        Fecha_Confirmacion: ref(null),
        Nombre_Confirmado: ref(null),
        Lugar_Nacimiento: ref(null),
        Fecha_Nacimiento: ref(null),
        Nombre_Padres: ref(null),
        Parroquia_Bautizo: ref(null),
        Diocesis: ref(null),
        Fecha_Bautismo: ref(null),
        Libro_B: ref(null),
        Folio_B: ref(null),
        Numero_B: ref(null),
        Padrinos: ref(null),
        Ministro: ref(null),
        Id_MinistroDoyFe: ref(0),
        Notas_Correcciones: ref(null),
        Id_Ministro: ref(0),
        Cargo: ref(null),
      }),

      rows: ref([]),
      columns: ref([]),
      visibleColumns: ref([]),
      ListId_MinistroDoyFe: ref([]),
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
        this.ListId_MinistroDoyFe = e[0] || [];
        this.ListMinistros = e[1] || [];
        // [2] Celebrantes: el valor guardado en Ministro es el Nombre
        this.ministroOptions = await loadCelebranteNombreOptions(
          SACRAMENTO_CELEBRANTE.CONFIRMACION
        );
        this.setFirmanteFav();
      } catch (error) {
        this.hideLoading();
        this.showMessage(error, "red", "error");
      }
    },
    async getConfirmaciones() {
      try {
        const e = await window.myAPI.executeSp_Ds(
          "{}",
          "BD_Get_Lists_Confirmaciones"
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
      } catch (e) {
        this.hideLoading();
        this.showMessage(e, "red", "error");
      }
    },
    async saveConfirmacion() {
      try {
        const result = this.makeValidation();
        if (result != "OK") throw result;
        let DatosIns = this.dataConfirmacion;
        DatosIns.Libro = this.Libro;
        DatosIns.Folio = this.Folio;
        DatosIns.Numero = this.Numero;
        if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;
        const e = await window.myAPI.executeSp_St(
          JSON.stringify(DatosIns),
          this.Id != null && this.Id != ""
            ? "BD_Upd_Confirmacion"
            : "BD_Ins_Confirmacion"
        );
        if (e.toLowerCase().indexOf("error") >= 0)
          this.showMessage(e, "red", "error");
        else {
          this.showMessage(e, "positive", "check");
          this.resetValues();
          this.$refs.tableComponent?.cleanSelectedRow?.();
          this.getConfirmaciones();
        }
      } catch (error) {
        this.showMessage(error, "red", "error");
      }
    },
    makeValidation() {
      let msj = "OK";
      if (this.Codigo_Partida != this.Libro + this.Folio + this.Numero)
        msj = "Error - El codigo de partida no coincide";

      Object.keys(this.dataConfirmacion).map((elem) => {
        if (elem != "Notas_Correcciones") {
          if (
            this.dataConfirmacion[elem] == null ||
            this.dataConfirmacion[elem] == ""
          )
            msj += !msj.includes("Error")
              ? "Error - Completa los siguientes campos : " + elem
              : " - " + elem;
        }
      });
      return msj;
    },
    setCargoFirm() {
      const cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataConfirmacion.Id_Ministro
      )?.Cargo;
      if (cargo) this.dataConfirmacion.Cargo = cargo;
    },

    setrecord(data) {
      this.Id = data.Id;
      this.Libro = data.Libro;
      this.Folio = data.Folio;
      this.Numero = data.Numero;
      this.addMinistroToList(data.Id_Ministro, data.Nombre_Firmante);
      for (const key in this.dataConfirmacion) {
        this.dataConfirmacion[key] = data[key];
      }
      this.ministroOptions = mergeCurrentCelebranteOption(
        this.ministroOptions,
        data.Ministro
      );
      this.setFirmanteFav();
      this.setCargoFirm();
    },

    addMinistroToList(id, name) {
      const verify =
        this.ListMinistros.some((e) => e.Id == id) ||
        this.ListMinistrosNoActive.some((e) => e.Id == id);
      if (!verify) this.ListMinistrosNoActive.push({ Id: id, Nombre: name });
    },

    async invtrecord(Id) {
      try {
        this.showLoading("Realizando Eliminacion, Espera un momento...");
        const res = await window.myAPI.executeSp_St(
          JSON.stringify({ Id }),
          "BD_Invt_Confirmacion"
        );
        if (res.includes("Error")) this.showMessage(res, "red", "error");
        else this.showMessage(res, "positive", "check");
        this.getConfirmaciones();
      } catch (error) {
        this.showMessage(error, "red", "error");
      }
    },

    resetValues() {
      this.Id = null;
      this.Codigo_Partida = null;
      this.Libro = "";
      this.Folio = "";
      this.Numero = "";
      this.dataConfirmacion.Fecha_Confirmacion = null;
      this.dataConfirmacion.Nombre_Confirmado = null;
      this.dataConfirmacion.Lugar_Nacimiento = null;
      this.dataConfirmacion.Fecha_Nacimiento = null;
      this.dataConfirmacion.Nombre_Padres = null;
      this.dataConfirmacion.Parroquia_Bautizo = null;
      this.dataConfirmacion.Diocesis = null;
      this.dataConfirmacion.Fecha_Bautismo = null;
      this.dataConfirmacion.Libro_B = null;
      this.dataConfirmacion.Folio_B = null;
      this.dataConfirmacion.Numero_B = null;
      this.dataConfirmacion.Padrinos = null;
      this.dataConfirmacion.Ministro = null;
      this.dataConfirmacion.Id_MinistroDoyFe = 0;
      this.dataConfirmacion.Notas_Correcciones = null;
      this.dataConfirmacion.Id_Ministro = 0;
      this.dataConfirmacion.Cargo = null;
      this.$refs.tableComponent?.cleanSelectedRow?.();
      this.ListMinistrosNoActive = [];
      this.setFirmanteFav();
    },

    setFirmanteFav() {
      const selectDefault = this.ListMinistros.find((e) => e.isCurrent == 1);
      if (selectDefault) {
        this.dataConfirmacion.Id_Ministro = selectDefault.Id;
        this.dataConfirmacion.Cargo = selectDefault.Cargo;
      }
    },

    setModel(val) {
      this.dataConfirmacion.Ministro = val;
    },
  },

  watch: {
    Libro(newValue, oldValue) {
      this.Codigo_Partida = newValue + this.Folio + this.Numero;
    },
    Folio(newValue, oldValue) {
      this.Codigo_Partida = this.Libro + newValue + this.Numero;
    },
    Numero(newValue, oldValue) {
      this.Codigo_Partida = this.Libro + this.Folio + newValue;
    },
  },
});
</script>
