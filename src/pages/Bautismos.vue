<template>
  <q-page class="sac-page">
    <div class="sac-shell">
      <header class="sac-header">
        <h1 class="sac-header__title">Bautizos</h1>
        <div
          class="sac-mode"
          :class="{ 'sac-mode--edit': isEditing }"
          role="status"
        >
          <q-icon :name="isEditing ? 'edit' : 'add_circle_outline'" size="16px" />
          {{ isEditing ? "Editando registro" : "Nuevo registro" }}
        </div>
      </header>

      <section class="sac-panel" aria-labelledby="bautizos-form-title">
        <h2 id="bautizos-form-title" class="sr-only">Formulario de bautizo</h2>
        <q-form class="sac-form" @submit="saveBautismo()" @reset="resetValues()">
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
                <label class="sac-label" for="bau-codigo">Código de partida</label>
                <q-input
                  id="bau-codigo"
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
                <label class="sac-label" for="bau-libro">Libro</label>
                <q-input id="bau-libro" v-model="Libro" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-folio">Folio</label>
                <q-input id="bau-folio" v-model="Folio" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-numero">Número</label>
                <q-input id="bau-numero" v-model="Numero" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
            </div>
          </div>

          <!-- Bautizado -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="person" size="16px" />
              </div>
              <h3 class="sac-section__title">Datos del bautizado</h3>
            </div>
            <div class="sac-grid sac-grid--2">
              <div class="sac-field">
                <label class="sac-label" for="bau-nombre">Nombre completo</label>
                <q-input id="bau-nombre" v-model="dataBautizos.Nombre" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-ministro">Ministro</label>
                <q-select
                  id="bau-ministro"
                  v-model="dataBautizos.Ministro"
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
                <label class="sac-label" for="bau-fecha-b">Fecha de bautismo</label>
                <q-input id="bau-fecha-b" v-model="dataBautizos.Fecha_Bautismo" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-lugar-n">Lugar de nacimiento</label>
                <q-input id="bau-lugar-n" v-model="dataBautizos.Lugar_Nacimiento" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-fecha-n">Fecha de nacimiento</label>
                <q-input id="bau-fecha-n" v-model="dataBautizos.Fecha_Nacimiento" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
            </div>
          </div>

          <!-- Familia -->
          <div class="sac-section">
            <div class="sac-section__head">
              <div class="sac-section__icon" aria-hidden="true">
                <q-icon name="groups" size="16px" />
              </div>
              <h3 class="sac-section__title">Familia y padrinos</h3>
            </div>
            <div class="sac-grid sac-grid--2">
              <div class="sac-field">
                <label class="sac-label" for="bau-padres">Nombre de los padres</label>
                <q-input id="bau-padres" v-model="dataBautizos.Padres" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-abuelos-p">Abuelos paternos</label>
                <q-input id="bau-abuelos-p" v-model="dataBautizos.Abuelos_Paternos" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-abuelos-m">Abuelos maternos</label>
                <q-input id="bau-abuelos-m" v-model="dataBautizos.Abuelos_Maternos" class="sac-input" type="text" dense outlined hide-bottom-space />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-padrinos">Padrinos</label>
                <q-input id="bau-padrinos" v-model="dataBautizos.Padrinos" class="sac-input" type="text" dense outlined hide-bottom-space />
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
                <label class="sac-label" for="bau-doyfe">Doy fe</label>
                <q-select
                  id="bau-doyfe"
                  v-model="dataBautizos.Id_MinistroDoyFe"
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
                <label class="sac-label" for="bau-firma">Firma del documento</label>
                <q-select
                  id="bau-firma"
                  v-model="dataBautizos.Id_Ministro"
                  class="sac-select"
                  dense
                  outlined
                  use-input
                  option-value="Id"
                  option-label="Nombre"
                  emit-value
                  map-options
                  :options="[...ListMinistros, ...ListMinistrosNoActive]"
                  hide-bottom-space
                  @update:model-value="setCargoFirm()"
                />
              </div>
              <div class="sac-field">
                <label class="sac-label" for="bau-cargo">Cargo firmante</label>
                <q-input id="bau-cargo" v-model="dataBautizos.Cargo" class="sac-input" type="text" dense outlined disable hide-bottom-space />
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
              <label class="sac-label" for="bau-nota">Observaciones (opcional)</label>
              <q-editor
                id="bau-nota"
                v-model="dataBautizos.Nota_Marginal"
                class="sac-editor"
                min-height="3rem"
                :toolbar="[['bold', 'italic', 'underline'], ['unordered', 'ordered'], ['undo', 'redo']]"
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
              :label="isEditing ? 'Actualizar bautizo' : 'Guardar bautizo'"
            />
          </div>
        </q-form>
      </section>

      <section
        v-if="perfil == 1 || perfil == 2"
        class="sac-panel sac-registry"
        aria-labelledby="bautizos-registry-title"
      >
        <h2 id="bautizos-registry-title" class="sr-only">Listado de bautizos</h2>
        <Table_Component
          v-if="rows.length > 0"
          ref="tableComponent"
          title="Registros de bautizos"
          tablaDirectTo="fact_bautismos"
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
          Aún no hay bautizos cargados o está consultando el listado…
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
  name: "Bautismos",
  components: {
    Table_Component,
  },
  mounted() {
    this.showLoading("Cargando Datos...");
    this.getDataLogin((e, data) => {
      this.perfil = data.Id_Perfil;
      this.getDoyFe();
      if (this.perfil == 1 || this.perfil == 2) this.getBautismos();
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
      const tone =
        color === "red" || color === "danger" ? "negative" : color || "primary";
      q.notify({
        progress: true,
        message: msj,
        icon: icon,
        color: tone,
        textColor: "white",
      });
    };
    const hideLoading = () => q.loading.hide();
    return {
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

      ministroOptions: [
        "LUIS HERNANDO RÍOS ALDANA. PBRO.",
        "LUIS FERNANDO LEÓN ROBAYO. PBRO",
        "CÉSAR AUGUSTO ALMONACID RUBIO. PBRO",
        "HUMBERTO RENGIFO. PBRO.",
        "JOSÉ CARLOS MANZANO ASCANIO. PBRO.",
        "JOSÉ AQUILINO SABOGAL MORA. PBRO.",
        "OMAR JAVIER OJEDA TEUTA. PBRO.",
        "YOEL GÓMEZ RAMÍREZ. PBRO.",
      ],

      dataBautizos: ref({
        Nombre: ref(null),
        Ministro: ref(null),
        Fecha_Bautismo: ref(null),
        Lugar_Nacimiento: ref(null),
        Fecha_Nacimiento: ref(null),
        Padres: ref(null),
        Abuelos_Paternos: ref(null),
        Abuelos_Maternos: ref(null),
        Padrinos: ref(null),
        Id_MinistroDoyFe: ref(0),
        Nota_Marginal: ref(null),
        Id_Ministro: ref(0),
        Cargo: ref(null),
      }),
      ListDoyFe: ref([]),
      ListMinistros: ref([]),
      ListMinistrosNoActive: ref([]),
      rows: ref([]),
      columns: ref([]),
      visibleColumns: ref([]),
      getDataLogin,
      perfil: ref(null),
    };
  },
  methods: {
    getBautismos() {
      try {
        window.myAPI.executeSp_Ds("{}", "BD_Get_Lists_Bautismos").then((e) => {
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
        });
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
        this.ListDoyFe = e[0];
        this.ListMinistros = e[1];
        this.setFirmanteFav();
      } catch (error) {
        this.hideLoading();
        this.showMessage(error, "red", "error");
      }
    },
    setrecord(data) {
      try {
        this.Id = data.Id;
        this.Codigo_Partida = data.Codigo_Partida;
        this.Libro = data.Libro;
        this.Folio = data.Folio;
        this.Numero = data.Numero;
        this.addMinistroToList(data.Id_Ministro, data.Nombre_Firmante);
        for (const key in this.dataBautizos) {
          this.dataBautizos[key] = data[key];
        }
        this.setFirmanteFav();
        this.setCargoFirm();
      } catch (error) {
        this.hideLoading();
        this.showMessage(error, "negative", "danger");
      }
    },

    addMinistroToList(id , name) {
      const verify = this.ListMinistros.some((e) => e.Id == id) || this.ListMinistrosNoActive.some((e) => e.Id == id);
      if (!verify) this.ListMinistrosNoActive.push({ Id: id, Nombre: name });
    },

    async invtrecord(Id) {
      this.showLoading("Realizando Eliminacion, Espera un momento...");
      const res = await window.myAPI.executeSp_St(
        JSON.stringify({ Id }),
        "BD_Invt_Bautismo"
      );
      if (res.includes("Error")) this.showMessage(res, "red", "error");
      else this.showMessage(res, "positive", "check");
      this.getBautismos();
    },
    async saveBautismo() {
      try {
        const result = this.makeValidation();
        if (result !== "OK") throw result;
        let DatosIns = this.dataBautizos;
        DatosIns.Libro = this.Libro;
        DatosIns.Folio = this.Folio;
        DatosIns.Numero = this.Numero;
        if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;
        const e = await window.myAPI.executeSp_St(
          JSON.stringify(DatosIns),
          this.Id != null && this.Id != ""
            ? "BD_Upd_Bautismo"
            : "BD_Ins_Bautismo"
        );
        if (e.indexOf("Error") >= 0) this.showMessage(e, "red", "error");
        else {
          this.showMessage(e, "positive", "check");
          this.resetValues();
          this.$refs.tableComponent?.cleanSelectedRow?.();
          this.getBautismos();
        }
      } catch (error) {
        this.hideLoading();
        this.showMessage(error, "negative", "danger");
      }
    },

    resetValues() {
      this.Id = null;
      this.Codigo_Partida = null;
      this.Libro = "";
      this.Folio = "";
      this.Numero = "";
      this.dataBautizos.Nombre = null;
      this.dataBautizos.Ministro = null;
      this.dataBautizos.Fecha_Bautismo = null;
      this.dataBautizos.Lugar_Nacimiento = null;
      this.dataBautizos.Fecha_Nacimiento = null;
      this.dataBautizos.Padres = null;
      this.dataBautizos.Abuelos_Paternos = null;
      this.dataBautizos.Abuelos_Maternos = null;
      this.dataBautizos.Padrinos = null;
      this.dataBautizos.Id_MinistroDoyFe = 0;
      this.dataBautizos.Nota_Marginal = null;
      this.dataBautizos.Id_Ministro = 0;
      this.dataBautizos.Cargo = null;
      this.$refs.tableComponent?.cleanSelectedRow?.();
      this.ListMinistrosNoActive = [];
      this.setFirmanteFav();
    },

    setFirmanteFav(){
      const selectDefault = this.ListMinistros.find(
        (e) => e.isCurrent == 1
      );
      if (selectDefault) {
        this.dataBautizos.Id_Ministro = selectDefault.Id;
        this.dataBautizos.Cargo = selectDefault.Cargo;
      }
    },

    makeValidation() {
      let msj = "OK";
      if (this.Codigo_Partida != this.Libro + this.Folio + this.Numero)
        msj = "Error - El codigo de partida no coincide";

      if ( this.Codigo_Partida == null || this.Codigo_Partida.trim().length === 0 || this.Codigo_Partida == "")
        msj = "Error - Completa el codigo de partida, es requerido";

      Object.keys(this.dataBautizos).map((elem) => {
        if (elem != "Nota_Marginal") {
          if (this.dataBautizos[elem] == null || this.dataBautizos[elem] == "")
            msj += !msj.includes("Error")
              ? "Error - Completa los siguientes campos : " + elem
              : " - " + elem;
        }
      });
      return msj;
    },

    setCargoFirm() {
      const cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataBautizos.Id_Ministro
      )?.Cargo;
      if (cargo) this.dataBautizos.Cargo = cargo;
    },
    setModel(val) {
      this.dataBautizos.Ministro = val;
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
