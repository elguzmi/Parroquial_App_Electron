<template>
  <q-page class="sac-page">
    <div class="sac-shell">
      <header class="sac-header">
        <h1 class="sac-header__title">Matrimonios</h1>
        <div
          class="sac-mode"
          :class="{ 'sac-mode--edit': isEditing }"
          role="status"
        >
          <q-icon :name="isEditing ? 'edit' : 'add_circle_outline'" size="16px" />
          {{ isEditing ? "Editando registro" : "Nuevo registro" }}
        </div>
      </header>

      <section class="sac-panel" aria-labelledby="matrimonios-form-title">
        <h2 id="matrimonios-form-title" class="sr-only">
          Formulario de matrimonio
        </h2>
        <q-form
          class="sac-form"
          @submit="insMatrimonio()"
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
                <label class="sac-label" for="mat-codigo">Código de partida</label>
                <q-input
                  id="mat-codigo"
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
                <label class="sac-label" for="mat-libro">Libro</label>
                <q-input
                  id="mat-libro"
                  v-model="Libro"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="mat-folio">Folio</label>
                <q-input
                  id="mat-folio"
                  v-model="Folio"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="mat-numero">Número</label>
                <q-input
                  id="mat-numero"
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

          <!-- Ceremonia -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="church" size="16px" />
              </div>
              <h3 class="sac-section__title">Ceremonia</h3>
            </div>
            <div class="sac-grid sac-grid--2">
              <div class="sac-field">
                <label class="sac-label" for="mat-presencio">Presenció</label>
                <q-select
                  id="mat-presencio"
                  v-model="dataMatrimonio.Presencio"
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
              <div class="sac-field">
                <label class="sac-label" for="mat-fecha">Fecha de matrimonio</label>
                <q-input
                  id="mat-fecha"
                  v-model="dataMatrimonio.Fecha_Matrimonio"
                  class="sac-input"
                  type="text"
                  dense
                  outlined
                  hide-bottom-space
                />
              </div>
            </div>
          </div>

          <!-- Novios -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="favorite" size="16px" />
              </div>
              <h3 class="sac-section__title">Datos de los novios</h3>
            </div>
            <div class="sac-grid sac-grid--novios">
              <CardNovios
                title="Información del novio"
                card="Novio"
                :dataForm="dataMatrimonio"
                ref="cards1"
                prefijo="o"
                @SetInfo="SetearInfoCards"
              />
              <CardNovios
                title="Información de la novia"
                card="Novia"
                :dataForm="dataMatrimonio"
                ref="cards"
                prefijo="a"
                @SetInfo="SetearInfoCards"
              />
            </div>
          </div>

          <!-- Firmas y testigos -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="draw" size="16px" />
              </div>
              <h3 class="sac-section__title">Firmas y testigos</h3>
            </div>
            <div class="sac-field">
              <label class="sac-label" for="mat-testigos">Testigos</label>
              <q-input
                id="mat-testigos"
                v-model="dataMatrimonio.Testigos"
                class="sac-input"
                type="text"
                dense
                outlined
                hide-bottom-space
              />
            </div>
            <div class="sac-grid sac-grid--firma">
              <div class="sac-field">
                <label class="sac-label" for="mat-doyfe">Doy fe</label>
                <q-select
                  id="mat-doyfe"
                  v-model="dataMatrimonio.Id_MinistroDoyFe"
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
                <label class="sac-label" for="mat-firma">Firma del documento</label>
                <q-select
                  id="mat-firma"
                  v-model="dataMatrimonio.Id_Ministro"
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
                <label class="sac-label" for="mat-cargo">Cargo firmante</label>
                <q-input
                  id="mat-cargo"
                  v-model="dataMatrimonio.Cargo"
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
              <label class="sac-label" for="mat-nota">Observaciones (opcional)</label>
              <q-editor
                id="mat-nota"
                v-model="dataMatrimonio.Nota_Marginal"
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
              :label="isEditing ? 'Actualizar matrimonio' : 'Guardar matrimonio'"
            />
          </div>
        </q-form>
      </section>

      <section
        v-if="perfil == 1 || perfil == 2"
        class="sac-panel sac-registry"
        aria-labelledby="matrimonios-registry-title"
      >
        <h2 id="matrimonios-registry-title" class="sr-only">
          Listado de matrimonios
        </h2>
        <Table_Component
          v-if="rows.length > 0"
          ref="tableComponent"
          title="Registros de matrimonios"
          tablaDirectTo="fact_Matrimonios"
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
          Aún no hay matrimonios cargados o está consultando el listado…
        </p>
      </section>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import Table_Component from "components/Table_Component.vue";
import CardNovios from "components/CardNovios.vue";
import { useQuasar } from "quasar";
import { loadCelebranteNombreOptions } from "src/utils/celebrantes";

export default defineComponent({
  name: "Matrimonios",
  components: {
    Table_Component,
    CardNovios,
  },
  mounted() {
    this.showLoading("Cargando Datos...");
    this.getDataLogin((e, data) => {
      this.perfil = data.Id_Perfil;
      this.getDoyFe();
      if (this.perfil == 1 || this.perfil == 2) this.getMatrimonios();
      else this.hideLoading();
    });
  },
  computed: {
    isEditing() {
      return this.Id != null && this.Id !== "";
    },
  },
  setup() {
    const $q = useQuasar();

    const getDataLogin = (cll) => {
      if ($q.localStorage.has("SK"))
        cll(true, JSON.parse($q.localStorage.getItem("SK")));
      else cll(false, {});
    };

    function showLoading(msj) {
      $q.loading.show({
        message: msj,
      });
    }
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
      perfil: ref(null),
      getDataLogin,

      Documento: ref(null),
      showDialog: ref(false),

      showLoading,
      hideLoading,
      showMessage,

      Id: ref(null),
      Codigo_Partida: ref(null),
      Libro: ref(""),
      Folio: ref(""),
      Numero: ref(""),

      ministroOptions: ref([]),

      dataMatrimonio: ref({
        Fecha_Matrimonio: ref(null),
        Presencio: ref(null),

        // data Novio
        Novio: ref(null),
        Padres_Novio: ref(null),
        Parroquia_Novio: ref(null),
        Fecha_Bautismo_Novio: ref(null),
        Lib_Novio: ref(null),
        Fol_Novio: ref(null),
        Acta_Novio: ref(null),

        // data Novia
        Novia: ref(null),
        Padres_Novia: ref(null),
        Parroquia_Novia: ref(null),
        Fecha_Bautismo_Novia: ref(null),
        Lib_Novia: ref(null),
        Fol_Novia: ref(null),
        Acta_Novia: ref(null),

        Testigos: ref(null),
        Id_MinistroDoyFe: ref(0),
        Nota_Marginal: ref(null),
        Id_Ministro: ref(0),
        Cargo: ref(null),
      }),

      isDense: true,
      ListDoyFe: ref([]),
      ListMinistros: ref([]),
      ListMinistrosNoActive: ref([]),
      // *** data de la tabla
      rows: ref([]),
      columns: ref([]),
      visibleColumns: ref([]),
    };
  },
  methods: {
    async getMatrimonios() {
      try {
        const e = await window.myAPI.executeSp_Ds(
          "{}",
          "BD_Get_Lists_Matrimonios"
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
    async getDoyFe() {
      try {
        const e = await window.myAPI.executeSp_Ds(
          JSON.stringify({}),
          "BD_Get_Lists_Ministros"
        );
        this.ListDoyFe = e[0] || [];
        this.ListMinistros = e[1] || [];
        // [2] Celebrantes: el valor guardado en Presencio es el Nombre
        this.ministroOptions = await loadCelebranteNombreOptions(e);
        this.setFirmanteFav();
      } catch (error) {
        this.hideLoading();
        this.showMessage(error, "red", "danger");
      }
    },

    async insMatrimonio() {
      try {
        this.$refs.cards1.getData();
        this.$refs.cards.getData();
        const result = this.makeValidation();
        if (result != "OK") throw result;
        let DatosIns = this.dataMatrimonio;
        DatosIns.Libro = this.Libro;
        DatosIns.Folio = this.Folio;
        DatosIns.Numero = this.Numero;
        if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;
        let e = await window.myAPI.executeSp_St(
          JSON.stringify(DatosIns),
          this.Id != null && this.Id != ""
            ? "BD_Upd_Matrimonio"
            : "BD_Ins_Matrimonio"
        );
        if (e.indexOf("Error") >= 0) this.showMessage(e, "red", "error");
        this.showMessage(e, "positive", "check");
        this.resetValues();
        this.$refs.tableComponent?.cleanSelectedRow?.();
        this.getMatrimonios();
      } catch (error) {
        this.showMessage(error, "red", "danger");
      }
    },
    makeValidation() {
      let msj = "OK";
      if (this.Codigo_Partida != this.Libro + this.Folio + this.Numero)
        msj = "Error - El codigo de partida no coincide";

      Object.keys(this.dataMatrimonio).map((elem) => {
        if (
          elem != "Nota_Marginal" &&
          elem != "Cargo" &&
          elem != "Id_Ministro"
        ) {
          if (
            this.dataMatrimonio[elem] == null ||
            this.dataMatrimonio[elem] == ""
          )
            msj += !msj.includes("Error")
              ? " Error - Completa los siguientes campos :  " + elem
              : " - " + elem;
        }
      });
      return msj;
    },
    setrecord(data) {
      this.Id = data.Id;
      this.Codigo_Partida = data.Codigo_Partida;
      this.Libro = data.Libro;
      this.Folio = data.Folio;
      this.Numero = data.Numero;
      //this.addMinistroToList(data.Id_Ministro, data.Nombre_Firmante);
      for (const key in this.dataMatrimonio) {
        this.dataMatrimonio[key] = data[key];
      }
      this.$refs.cards.updateData();
      this.$refs.cards1.updateData();
      this.setFirmanteFav();
      this.setCargoFirm();
    },

    addMinistroToList(id, name) {
      const verify =
        this.ListMinistros.some((e) => e.Id == id) ||
        this.ListMinistrosNoActive.some((e) => e.Id == id);
      if (!verify) this.ListMinistrosNoActive.push({ Id: id, Nombre: name });
    },

    SetearInfoCards(data, prefijo) {
      this.dataMatrimonio["Novi" + prefijo] = data.Nombre_;
      this.dataMatrimonio["Padres_Novi" + prefijo] = data.Padres_;
      this.dataMatrimonio["Parroquia_Novi" + prefijo] = data.Parroquia_;
      this.dataMatrimonio["Fecha_Bautismo_Novi" + prefijo] =
        data.Fecha_Bautismo_;
      this.dataMatrimonio["Lib_Novi" + prefijo] = data.Lib_;
      this.dataMatrimonio["Fol_Novi" + prefijo] = data.Fol_;
      this.dataMatrimonio["Acta_Novi" + prefijo] = data.Numero_;
    },

    async invtrecord(Id) {
      this.showLoading("Realizando Eliminacion, Espera un momento...");
      const res = await window.myAPI.executeSp_St(
        JSON.stringify({ Id }),
        "BD_Invt_Matrimonio"
      );
      if (res.includes("Error")) this.showMessage(res, "red", "error");
      else this.showMessage(res, "positive", "check");
      this.getMatrimonios();
    },

    setCargoFirm() {
      const cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataMatrimonio.Id_Ministro
      )?.Cargo;
      if (cargo) this.dataMatrimonio.Cargo = cargo;
    },

    setFirmanteFav() {
      const selectDefault = this.ListMinistros.find((e) => e.isCurrent == 1);
      if (selectDefault) {
        this.dataMatrimonio.Id_Ministro = selectDefault.Id;
        this.dataMatrimonio.Cargo = selectDefault.Cargo;
      }
    },

    setModel(val) {
      this.dataMatrimonio.Presencio = val;
    },

    resetValues() {
      this.Id = null;
      this.Codigo_Partida = null;
      this.Libro = "";
      this.Folio = "";
      this.Numero = "";

      this.dataMatrimonio.Fecha_Matrimonio = null;
      this.dataMatrimonio.Presencio = null;
      this.dataMatrimonio.Novio = null;
      this.dataMatrimonio.Padres_Novio = null;
      this.dataMatrimonio.Parroquia_Novio = null;
      this.dataMatrimonio.Fecha_Bautismo_Novio = null;
      this.dataMatrimonio.Lib_Novio = null;
      this.dataMatrimonio.Fol_Novio = null;
      this.dataMatrimonio.Acta_Novio = null;
      this.dataMatrimonio.Novia = null;
      this.dataMatrimonio.Padres_Novia = null;
      this.dataMatrimonio.Parroquia_Novia = null;
      this.dataMatrimonio.Fecha_Bautismo_Novia = null;
      this.dataMatrimonio.Lib_Novia = null;
      this.dataMatrimonio.Fol_Novia = null;
      this.dataMatrimonio.Acta_Novia = null;
      this.dataMatrimonio.Testigos = null;
      this.dataMatrimonio.Id_MinistroDoyFe = 0;
      this.dataMatrimonio.Nota_Marginal = null;
      this.dataMatrimonio.Id_Ministro = 0;
      this.dataMatrimonio.Cargo = null;
      this.$refs.cards.cleanData();
      this.$refs.cards1.cleanData();
      this.$refs.tableComponent?.cleanSelectedRow?.();
      this.ListMinistrosNoActive = [];
      this.setFirmanteFav();
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
