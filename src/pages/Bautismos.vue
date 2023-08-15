<template>
  <q-page class="flex" padding>
    <section style="width: 100%">
      <div class="form">
        <q-form
          @submit="saveBautismo()"
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
                dense
              />
            </div>
            <div class="col-2">
              <q-input type="text" label="Libro" v-model="Libro" dense />
            </div>
            <div class="col-2">
              <q-input type="text" label="Folio" v-model="Folio" dense />
            </div>
            <div class="col-2">
              <q-input type="text" label="Numero" v-model="Numero" dense />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-6">
              <q-input
                v-model="dataBautizos.Nombre"
                type="text"
                label="Nombre"
                dense
              />
            </div>

            <div class="col-4">
              <q-select
                filled
                v-model="dataBautizos.Ministro"
                :model-value="dataBautizos.Ministro"
                use-input
                label="Ministro"
                hide-selected
                fill-input
                input-debounce="0"
                :options="[
                  'YOEL GÓMEZ RAMÍREZ. Pbro.',
                  'LORENZO ALZATE ARBOLEDA. Pbro',
                  'MARIO DE JESÚS ACOSTA RAMÍREZ. Pbro.',
                ]"
                @input-value="setModel"
              >
              </q-select>
              <!-- <q-select
                v-model="dataBautizos.Ministro"
                :options="[
                  'YOEL GÓMEZ RAMÍREZ. Pbro.',
                  'LORENZO ALZATE ARBOLEDA. Pbro',
                  'MARIO DE JESÚS ACOSTA RAMÍREZ. Pbro.',
                ]"
                label="Ministro"
                filled
                dense
              /> -->
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-3">
              <q-input
                v-model="dataBautizos.Fecha_Bautismo"
                type="text"
                label="Fecha Bautismo"
                dense
              />
            </div>

            <div class="col-3">
              <q-input
                v-model="dataBautizos.Lugar_Nacimiento"
                type="text"
                label="Lugar de Nacimiento"
                dense
              />
            </div>

            <div class="col-3">
              <q-input
                v-model="dataBautizos.Fecha_Nacimiento"
                type="text"
                label="Fecha de Nacimiento"
                dense
              />
            </div>
          </div>

          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <q-input
                v-model="dataBautizos.Padres"
                type="text"
                label="Nombre_Padres"
                dense
              />
            </div>

            <div class="col-5">
              <q-input
                v-model="dataBautizos.Abuelos_Paternos"
                type="text"
                label="Abuelos Paternos"
                dense
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <q-input
                v-model="dataBautizos.Abuelos_Maternos"
                type="text"
                label="Abuelos Maternos"
                dense
              />
            </div>

            <div class="col-5">
              <q-input
                v-model="dataBautizos.Padrinos"
                type="text"
                label="Padrinos"
                dense
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <q-select
                v-model="dataBautizos.Id_MinistroDoyFe"
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
                v-model="dataBautizos.Id_Ministro"
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
                v-model="dataBautizos.Cargo"
                type="text"
                label="Cargo Firmante"
                disable
                dense
              />
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-12">
              <div class="q-pa-md q-gutter-sm">
                <label for="">Nota Marginal</label>
                <q-editor
                  v-model="dataBautizos.Nota_Marginal"
                  min-height="5rem"
                />
              </div>
            </div>
          </div>
          <div class="q-pa-md">
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
    <hr />
    <section style="width: 100%">
      <Table_Component
        v-if="rows.length > 0 && (perfil == 1 || perfil == 2)"
        ref="tableComponent"
        title="Bautizos"
        tablaDirectTo="fact_bautismos"
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
  name: "Bautismos",
  components: {
    Table_Component,
  },
  mounted() {
    this.showLoading("Cargando Datos...");
    this.getDataLogin((e, data) => {
      //console.log(e, data);
      this.perfil = data.Id_Perfil;
      this.getDoyFe();
      if (this.perfil == 1 || this.perfil == 2) this.getBautismos();
      else this.hideLoading();
    });
  },
  computed: {},
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
      rows: ref([]),
      columns: ref([]),
      visibleColumns: ref([]),
      getDataLogin,
      perfil: ref(null),
    };
  },
  methods: {
    getBautismos() {
      window.ApiList.loadDataTables("Bautismos").then((e) => {
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
    },
    getDoyFe() {
      window.myAPI.loadMinistros().then((e) => {
        this.ListDoyFe = e[0];
        this.ListMinistros = e[1];
      });
    },
    setrecord(data) {
      //console.log("Recogido desde el compoentn padre", data);
      this.Id = data.Id;
      this.Codigo_Partida = data.Codigo_Partida;
      this.Libro = data.Libro;
      this.Folio = data.Folio;
      this.Numero = data.Numero;
      for (const key in this.dataBautizos) {
        this.dataBautizos[key] = data[key];
      }
      this.setCargoFirm();
    },

    invtrecord(Id) {
      this.showLoading("Realizando Eliminacion, Espera un momento...");
      let data = { Id: Id, Sp: "BD_Invt_Bautismo" };
      window.myAPI.InvtRecord(data).then((e) => {
        //console.log(e);
        if (e[0][""]) {
          if (e[0][""].includes("Error"))
            this.showMessage(e[0][""], "red", "error");
          else {
            this.showMessage(e[0][""], "positive", "check");
            this.$refs.tableComponent.cleanSelectedRow();
            this.getBautismos();
          }
        }
      });
    },
    saveBautismo() {
      this.makeValidation((result) => {
        if (result === "OK") {
          let DatosIns = this.dataBautizos;
          DatosIns.Libro = this.Libro;
          DatosIns.Folio = this.Folio;
          DatosIns.Numero = this.Numero;
          if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;

          if (this.Id != null && this.Id != "") {
            window.myAPI
              .updRecord(JSON.stringify(DatosIns), "Bautismo")
              .then((e) => {
                // console.log(e);
                if (e.indexOf("Error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.resetValues();
                  this.$refs.tableComponent.cleanSelectedRow();
                  this.getBautismos();
                }
              });
          } else {
            window.myAPI
              .insRecord(JSON.stringify(DatosIns), "Bautismo")
              .then((e) => {
                console.log(e);
                if (e.indexOf("Error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.getBautismos();
                  this.resetValues();
                }
              });
          }
        } else this.showMessage(result, "negative", "danger");
      });
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
      this.$refs.tableComponent.cleanSelectedRow();
    },
    makeValidation(res) {
      if (this.Codigo_Partida != this.Libro + this.Folio + this.Numero)
        return res("Error - El codigo de partida no coincide");

      let msj = "";
      Object.keys(this.dataBautizos).map((elem) => {
        if (elem != "Nota_Marginal") {
          if (this.dataBautizos[elem] == null || this.dataBautizos[elem] == "")
            msj += !msj.includes("Error")
              ? "Error - Completa los siguientes campos : " + elem
              : " - " + elem;
        }
      });
      if (msj == "") res("OK");
      else res(msj);
    },

    setCargoFirm() {
      this.dataBautizos.Cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataBautizos.Id_Ministro
      )?.Cargo;
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
