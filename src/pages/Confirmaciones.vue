<template>
  <q-page class="flex" padding>
    <section style="width: 100%">
      <div class="form">
        <q-form
          @submit="saveConfirmacion()"
          @reset="resetValues()"
          class="q-gutter-md"
        >
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-2">
              <q-input
                type="text"
                label="Codigo de partida"
                readonly
                v-model="Codigo_Partida"
                :dense="isDense"
              />
            </div>
            <div class="col-2">
              <q-input
                type="text"
                label="Libro"
                v-model="Libro"
                :dense="isDense"
              />
            </div>
            <div class="col-2">
              <q-input
                type="text"
                label="Folio"
                v-model="Folio"
                :dense="isDense"
              />
            </div>
            <div class="col-2">
              <q-input
                type="text"
                label="Numero"
                v-model="Numero"
                :dense="isDense"
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-4">
              <q-input
                v-model="dataConfirmacion.Fecha_Confirmacion"
                type="text"
                label="Fecha_Confirmacion"
                :dense="isDense"
              />
            </div>

            <div class="col-6">
              <q-input
                v-model="dataConfirmacion.Nombre_Confirmado"
                type="text"
                label="Nombre Confirmado"
                :dense="isDense"
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <q-input
                v-model="dataConfirmacion.Lugar_Nacimiento"
                type="text"
                label="Lugar Nacimiento"
                :dense="isDense"
              />
            </div>

            <div class="col-5">
              <q-input
                v-model="dataConfirmacion.Fecha_Nacimiento"
                type="text"
                label="Fecha Nacimiento"
                :dense="isDense"
              />
            </div>
          </div>

          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-11">
              <q-input
                v-model="dataConfirmacion.Nombre_Padres"
                type="text"
                label="Nombre Padres"
                :dense="isDense"
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <q-input
                v-model="dataConfirmacion.Diocesis"
                type="text"
                label="Diocesis"
                :dense="isDense"
              />
            </div>

            <div class="col-5">
              <q-input
                v-model="dataConfirmacion.Parroquia_Bautizo"
                type="text"
                label="Bautizado en la parroquia de"
                :dense="isDense"
              />
            </div>
          </div>

          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <q-input
                v-model="dataConfirmacion.Fecha_Bautismo"
                type="text"
                label="Fecha Bautismo"
                :dense="isDense"
              />
            </div>

            <div class="col-1">
              <q-input
                v-model="dataConfirmacion.Libro_B"
                type="text"
                label="Libro"
                :dense="isDense"
              />
            </div>
            <div class="col-1">
              <q-input
                v-model="dataConfirmacion.Folio_B"
                type="text"
                label="Folio"
                :dense="isDense"
              />
            </div>
            <div class="col-1">
              <q-input
                v-model="dataConfirmacion.Numero_B"
                type="text"
                label="Numero"
                :dense="isDense"
              />
            </div>
          </div>
          <div class="full-width row no-wrap justify-around items-start">
            <div class="col-11">
              <q-input
                type="text"
                label="Padrino o Madrina"
                v-model="dataConfirmacion.Padrinos"
                :dense="isDense"
              />
            </div>
          </div>
          <div class="full-width row no-wrap justify-around items-start">
            <div class="col-3">
              <q-select
                v-model="dataConfirmacion.Ministro"
                :options="[
                  'YOEL GÓMEZ RAMÍREZ. Pbro.',
                  'LORENZO ALZATE ARBOLEDA. Pbro',
                  'MARIO DE JESÚS ACOSTA RAMÍREZ. Pbro.',
                  'MONSEÑOR ENRIQUE SARMIENTO ANGULO',
                  'MONSEÑOR JUAN VICENTE CÓRDOBA VILLOTA. SJ.',
                ]"
                label="Ministro"
                filled
                dense
              />
            </div>
            <div class="col-3">
              <q-select
                v-model="dataConfirmacion.Id_MinistroDoyFe"
                label="Doy Fe"
                use-input
                option-value="Id"
                option-label="Nombre"
                emit-value
                map-options
                :options="ListId_MinistroDoyFe"
                filled
                dense
              />
            </div>
            <div class="col-3">
              <q-select
                v-model="dataConfirmacion.Id_Ministro"
                use-input
                option-value="Id"
                option-label="Nombre"
                emit-value
                map-options
                :options="ListMinistros"
                label="Firma Documento"
                filled
                dense
                @update:model-value="setCargoFirm()"
              />
            </div>
            <div class="col-2">
              <q-input
                type="text"
                label="Cargo Id_Ministro"
                v-model="dataConfirmacion.Cargo"
                :disable="true"
                :dense="isDense"
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-12">
              <div class="q-pa-md q-gutter-sm">
                <label for="">Nota Correciones</label>
                <q-editor
                  v-model="dataConfirmacion.Notas_Correcciones"
                  min-height="5rem"
                />
              </div>
            </div>
          </div>

          <div class="q-pa-sm">
            <q-btn-group spread>
              <q-btn
                color="green"
                :label="Id != null && Id != '' ? 'Editar' : 'Guardar'"
                type="submit"
                icon="save"
              />
              <q-btn
                color="red"
                :label="Id != null && Id != '' ? 'Cancelar' : 'Reset'"
                type="reset"
                icon="restart_alt"
              />
            </q-btn-group>
          </div>
        </q-form>
      </div>
    </section>
    <hr />
    <section style="width: 100%">
      <Table_Component
        v-if="rows.length > 0 && (perfil == 1 || perfil == 2)"
        ref="tableComponent"
        title="Confirmaciones"
        tablaDirectTo="fact_Confirmaciones"
        :columns="columns"
        :rows="rows"
        :visibleColumns="visibleColumns"
        @eventedited="setrecord"
        @eventinvt="invtrecord"
        @loadingShow="showLoading"
        @loadingHide="hideLoading"
      ></Table_Component>
    </section>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";
import Table_Component from "components/Table_Component.vue";

//import { ipcRenderer } from "electron";
//const { ipcRenderer } = require("electron");
export default defineComponent({
  name: "Confirmaciones",
  components: {
    Table_Component,
  },
  mounted() {
    this.showLoading("Cargando Datos...");

    this.getDataLogin((e, data) => {
      console.log(e, data);
      this.perfil = data.Id_Perfil;
      this.getId_MinistroDoyFe();
      if (this.perfil == 1 || this.perfil == 2) this.getConfirmaciones();
      else this.hideLoading();
    });
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
    };
  },
  methods: {
    getId_MinistroDoyFe() {
      window.myAPI.loadMinistros().then((e) => {
        console.log("Ministros juntos ", e);
        this.ListId_MinistroDoyFe = e[0];
        this.ListMinistros = e[1];
      });
    },
    getConfirmaciones() {
      window.ApiList.loadDataTables("Confirmaciones").then((e) => {
        this.columns = [];
        let { Columnas, Columnas_Label, Columnas_Visibles } = e[1][0];
        console.log(e[0]);
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
    },
    saveConfirmacion() {
      this.makeValidation((result) => {
        if (result === "OK") {
          let DatosIns = this.dataConfirmacion;
          DatosIns.Libro = this.Libro;
          DatosIns.Folio = this.Folio;
          DatosIns.Numero = this.Numero;
          if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;
          if (this.Id != null && this.Id != "") {
            window.myAPI
              .updRecord(JSON.stringify(DatosIns), "Confirmacion")
              .then((e) => {
                console.log(e);
                if (e.toLowerCase().indexOf("error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.resetValues();
                  this.$refs.tableComponent.cleanSelectedRow();
                  this.getConfirmaciones();
                }
              });
          } else {
            window.myAPI
              .insRecord(JSON.stringify(DatosIns), "Confirmacion")
              .then((e) => {
                console.log(e);
                if (e.toLowerCase().indexOf("error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.getConfirmaciones();
                  this.resetValues();
                }
              });
          }
        } else this.showMessage(result, "red", "error");
      });
    },
    makeValidation(res) {
      console.log(this.dataConfirmacion);
      if (this.Codigo_Partida != this.Libro + this.Folio + this.Numero)
        return res("Error - El codigo de partida no coincide");

      let msj = "";
      Object.keys(this.dataConfirmacion).map((elem) => {
        if (elem != "Nota_Marginal") {
          if (
            this.dataConfirmacion[elem] == null ||
            this.dataConfirmacion[elem] == ""
          )
            msj += "Error - Completa el campo " + elem;
        }
      });
      if (msj == "") res("OK");
      else res(msj);
    },
    setCargoFirm() {
      this.dataConfirmacion.Cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataConfirmacion.Id_Ministro
      )?.Cargo;
    },

    setrecord(data) {
      console.log("Recogido desde el compoentn padre", data);
      this.Id = data.Id;
      this.Libro = data.Libro;
      this.Folio = data.Folio;
      this.Numero = data.Numero;

      for (const key in this.dataConfirmacion) {
        this.dataConfirmacion[key] = data[key];
      }
      this.setCargoFirm();
    },

    invtrecord(Id) {
      this.showLoading("Realizando Eliminacion, Espera un momento...");
      console.log("Id de inactivacion", Id);
      let data = { Id: Id, Sp: "BD_Invt_Confirmacion" };
      window.myAPI.InvtRecord(data).then((e) => {
        console.log(e);
        if (e[0][""]) {
          if (e[0][""].includes("Error"))
            this.showMessage(e[0][""], "red", "error");
          else {
            this.showMessage(e[0][""], "positive", "check");
            this.getConfirmaciones();
          }
        }
      });
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
      this.$refs.tableComponent.cleanSelectedRow();
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
