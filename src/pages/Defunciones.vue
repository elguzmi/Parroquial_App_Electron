<template>
  <q-page class="flex" padding>
    <section style="width: 100%">
      <div class="form">
        <q-form
          @submit="saveDefuncion()"
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
                v-model="No_Defuncion"
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
            <div class="col-5">
              <q-input
                v-model="dataDefunciones.Nombre_Difunto"
                type="text"
                label="Nombre del difunto"
                :dense="isDense"
              />
            </div>

            <div class="col-5">
              <q-input
                v-model="dataDefunciones.Fecha_Sepelio"
                type="text"
                label="Fecha sepelio"
                :dense="isDense"
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-4">
              <q-input
                v-model="dataDefunciones.Ciudad_Origen"
                type="text"
                label="Natural de"
                :dense="isDense"
              />
            </div>

            <div class="col-1">
              <q-input
                v-model="dataDefunciones.Edad"
                type="text"
                label="Edad"
                :dense="isDense"
              />
            </div>

            <div class="col-4">
              <q-input
                v-model="dataDefunciones.Padres"
                type="text"
                label="Hijo de"
                :dense="isDense"
              />
            </div>
          </div>

          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <q-input
                v-model="dataDefunciones.Estado_Civil"
                type="text"
                label="Estado civil"
                :dense="isDense"
              />
            </div>

            <div class="col-5">
              <q-input
                v-model="dataDefunciones.Ocacion_Muerte"
                type="text"
                label="Murio de"
                :dense="isDense"
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-11">
              <div class="q-pa-sm q-gutter-sm">
                <label for="">Nota Marginal</label>
                <q-editor
                  v-model="dataDefunciones.NotaMarginal"
                  min-height="5rem"
                />
              </div>
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-4">
              <q-select
                v-model="dataDefunciones.Id_DoyFe"
                label="Doy Fe"
                use-input
                option-value="Id"
                option-label="Nombre"
                emit-value
                map-options
                :options="ListDoyFe"
                filled
                dense
              />
            </div>
            <div class="col-4">
              <q-select
                v-model="dataDefunciones.Id_Firmante"
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
                v-model="dataDefunciones.Cargo_Firmante"
                type="text"
                label="Cargo Firmante"
                :dense="isDense"
                disable
              />
            </div>
          </div>
          <div class="q-pa-sm">
            <q-btn-group spread>
              <q-btn
                color="green"
                :label="Id != null && Id != '' ? 'Guardar' : 'Guardar'"
                type="submit"
                icon="save"
              />
              <q-btn
                color="red"
                :label="Id != null && Id != '' ? 'Cancelar' : 'Limpiar'"
                type="reset"
                icon="restart_alt"
              />
            </q-btn-group>
          </div>
        </q-form>
      </div>
    </section>
    <section style="width: 100%">
      <Table_Component
        v-if="rows.length > 0 && (perfil == 1 || perfil == 2)"
        ref="tableComponent"
        title="Defunciones"
        tablaDirectTo="fact_Defunciones"
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
      //console.log(e, data);
      this.perfil = data.Id_Perfil;
      this.getId_MinistroDoyFe();
      if (this.perfil == 1 || this.perfil == 2) this.getDefunciones();
      else this.hideLoading();
    });
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
      ListId_MinistroDoyFe: ref([]),
      ListMinistros: ref([]),
    };
  },
  methods: {
    getId_MinistroDoyFe() {
      window.myAPI.loadMinistros().then((e) => {
        //console.log("Ministros juntos ", e);
        this.ListDoyFe = e[0];
        this.ListMinistros = e[1];
      });
    },
    getDefunciones() {
      window.ApiList.loadDataTables("Defunciones").then((e) => {
        this.columns = [];
        let { Columnas, Columnas_Label, Columnas_Visibles } = e[1][0];
        //console.log(e[0]);
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
    saveDefuncion() {
      this.makeValidation((result) => {
        if (result === "OK") {
          let DatosIns = this.dataDefunciones;
          DatosIns.Libro = this.Libro;
          DatosIns.Folio = this.Folio;
          DatosIns.Numero = this.Numero;
          if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;
          if (this.Id != null && this.Id != "") {
            window.myAPI
              .updRecord(JSON.stringify(DatosIns), "Defuncion")
              .then((e) => {
                if (e.toLowerCase().indexOf("error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.resetValues();
                  this.getDefunciones();
                }
              });
          } else {
            window.myAPI
              .insRecord(JSON.stringify(DatosIns), "Defuncion")
              .then((e) => {
                if (e.toLowerCase().indexOf("error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.resetValues();
                  this.$refs.tableComponent.cleanSelectedRow();
                  this.getDefunciones();
                }
              });
          }
        } else this.showMessage(result, "red", "danger");
      });
    },
    makeValidation(res) {
      if (this.No_Defuncion != this.Libro + this.Folio + this.Numero)
        return res("Error - El codigo de partida no coincide");

      let msj = "";
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
      if (msj == "") res("OK");
      else res(msj);
    },
    setrecord(data) {
      this.Id = data.Id;
      this.No_Defuncion = data.No_Defuncion;
      this.Libro = data.Libro;
      this.Folio = data.Folio;
      this.Numero = data.Numero;
      for (const key in this.dataDefunciones) {
        this.dataDefunciones[key] = data[key];
      }
      this.setCargoFirm();
    },

    setCargoFirm() {
      this.dataDefunciones.Cargo_Firmante = this.ListMinistros.find(
        (e) => e.Id == this.dataDefunciones.Id_Firmante
      )?.Cargo;
    },
    invtrecord(Id) {
      this.showLoading("Realizando Eliminacion, Espera un momento...");
      let data = { Id: Id, Sp: "BD_Invt_Defuncion" };
      window.myAPI.InvtRecord(data).then((e) => {
        //console.log(e);
        if (e[0][""]) {
          if (e[0][""].includes("Error"))
            this.showMessage(e[0][""], "red", "error");
          else {
            this.showMessage(e[0][""], "positive", "check");
            this.getDefunciones();
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
      this.$refs.tableComponent.cleanSelectedRow();
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
