<template>
  <q-page class="flex" padding>
    <section style="width: 100%">
      <div class="form">
        <q-form
          @submit="saveMatrimonio()"
          @reset="resetValues()"
          class="q-gutter-md"
        >
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-2">
              <q-input
                type="text"
                label="Codigo de Partida"
                readonly
                v-model="Codigo_Partida"
                dense
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
            <div class="col-6">
              <q-select
                v-model="dataMatrimonio.Presencio"
                :options="[
                  'YOEL GÓMEZ RAMÍREZ. Pbro.',
                  'LORENZO ALZATE ARBOLEDA. Pbro',
                  'MARIO DE JESÚS ACOSTA RAMÍREZ. Pbro.',
                ]"
                label="Presencio"
                filled
                dense
              />
            </div>

            <div class="col-5">
              <q-input
                v-model="dataMatrimonio.Fecha_Matrimonio"
                type="text"
                label="Fecha Matrimonio"
                :dense="isDense"
              />
            </div>
          </div>

          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-5">
              <CardNovios
                title="Información Novio"
                card="Novio"
                :dataForm="dataMatrimonio"
                ref="cards1"
                prefijo="o"
                @SetInfo="SetearInfoCards"
              ></CardNovios>
            </div>

            <div class="col-5">
              <CardNovios
                title="Información Novia"
                card="Novia"
                :dataForm="dataMatrimonio"
                ref="cards"
                prefijo="a"
                @SetInfo="SetearInfoCards"
              ></CardNovios>
            </div>
          </div>
          <div
            class="full-width row no-wrap justify-around items-start content-around"
          >
            <div class="col-7">
              <div class="q-pa-sm q-gutter-sm">
                <label for="">Nota Marginal</label>
                <q-editor
                  v-model="dataMatrimonio.Nota_Marginal"
                  min-height="5rem"
                />
              </div>
            </div>
            <div class="col-4">
              <q-input
                v-model="dataMatrimonio.Testigos"
                type="text"
                label="Testigos"
                dense
              />
              <q-select
                v-model="dataMatrimonio.Id_MinistroDoyFe"
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
              <q-select
                v-model="dataMatrimonio.Id_Ministro"
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
              >
              </q-select>
              <q-input
                v-model="dataMatrimonio.Cargo"
                type="text"
                label="Cargo Firmante"
                disable
                dense
              />
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
        v-if="rows.length > 0"
        title="Matrimonios"
        tablaDirectTo="fact_Matrimonios"
        :columns="columns"
        :rows="rows"
        :visibleColumns="visibleColumns"
        @eventedited="setrecord"
        @eventinvt="invtrecord"
        @loadingShow="showLoading"
        @loadingHide="hideLoading"
      ></Table_Component>
    </section>
    <Previsualizacion
      title="Matrimonio"
      :Doc="Documento"
      v-if="showDialog"
      :openDialog="showDialog"
    ></Previsualizacion>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import Table_Component from "components/Table_Component.vue";
import CardNovios from "components/CardNovios.vue";
import Previsualizacion from "components/Previsualizacion.vue";
import { useQuasar } from "quasar";

//import { ipcRenderer } from "electron";
//const { ipcRenderer } = require("electron");
export default defineComponent({
  name: "Matrimonios",
  components: {
    Table_Component,
    CardNovios,
    Previsualizacion,
  },
  mounted() {
    this.getMatrimonios();
    this.getDoyFe();
  },
  setup() {
    const $q = useQuasar();

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

      dataMatrimonio: ref({
        Fecha_Matrimonio: ref(null),
        Presencio: ref(null),

        // data Novio
        Novio: ref(null),
        Padres_Novio: ref(null),
        Parroquia_Novio: ref(null),
        Fecha_Bautismo_Novio: ref(null),
        Libro_Novio: ref(null),
        Folio_Novio: ref(null),
        Acta_Novio: ref(null),

        // data Novia
        Novia: ref(null),
        Padres_Novia: ref(null),
        Parroquia_Novia: ref(null),
        Fecha_Bautismo_Novia: ref(null),
        Libro_Novia: ref(null),
        Folio_Novia: ref(null),
        Acta_Novia: ref(null),

        Testigos: ref(null),
        Id_MinistroDoyFe: ref(0),
        Nota_Marginal: ref(null),
        Id_Ministro: ref(0),
        Cargo: ref(null),
      }),

      isDense: true,
      ListDoyFe: ref(null),
      ListMinistros: ref(null),
      // *** data de la tabla
      rows: ref([]),
      columns: ref([]),
      visibleColumns: ref([]),
    };
  },
  methods: {
    getMatrimonios() {
      window.myAPI.loadDataTables("Matrimonios").then((e) => {
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
      });
    },
    getDoyFe() {
      window.myAPI.loadMinistros().then((e) => {
        //console.log("Ministros juntos ", e);
        this.ListDoyFe = e[0];
        this.ListMinistros = e[1];
      });
    },

    saveMatrimonio() {
      this.$refs.cards1.getData();
      this.$refs.cards.getData();
      //console.log(this.dataMatrimonio);
      this.makeValidation((result) => {
        if (result === "OK") {
          let DatosIns = this.dataMatrimonio;
          DatosIns.Libro = this.Libro;
          DatosIns.Folio = this.Folio;
          DatosIns.Numero = this.Numero;
          if (this.Id != null && this.Id != "") DatosIns.Id = this.Id;
          if (this.Id != null && this.Id != "") {
            window.myAPI
              .updRecord(JSON.stringify(DatosIns), "Matrimonio")
              .then((e) => {
                console.log(e);
                if (e.indexOf("Error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.resetValues();
                  this.getMatrimonios();
                }
              });
          } else {
            window.myAPI
              .insRecord(JSON.stringify(DatosIns), "Matrimonio")
              .then((e) => {
                console.log(e);
                if (e.indexOf("Error") >= 0)
                  this.showMessage(e, "red", "error");
                else {
                  this.showMessage(e, "positive", "check");
                  this.resetValues();
                  this.getMatrimonios();
                }
              });
          }
        } else console.log(result);
      });
    },
    makeValidation(res) {
      console.log(this.dataMatrimonio);
      if (this.Codigo_Partida != this.Libro + this.Folio + this.Numero)
        return res("Error - El codigo de partida no coincide");

      let msj = "";
      Object.keys(this.dataMatrimonio).map((elem) => {
        if (
          this.dataMatrimonio[elem] == null ||
          this.dataMatrimonio[elem] == ""
        )
          msj += "Error - Completa el campo " + elem;
      });
      if (msj == "") res("OK");
      else res(msj);
    },
    setrecord(data) {
      console.log("Recogido desde el compoentn padre", data);
      this.Id = data.Id;
      this.Codigo_Partida = data.Codigo_Partida;
      this.Libro = data.Libro;
      this.Folio = data.Folio;
      this.Numero = data.Numero;

      for (const key in data) {
        this.dataMatrimonio[key] = data[key];
      }
      this.setCargoFirm();
      this.$refs.cards.updateData();
      this.$refs.cards1.updateData();
    },

    SetearInfoCards(data, prefijo) {
      console.log("Dta set info", data, prefijo);
      this.dataMatrimonio["Novi" + prefijo] = data.Nombre_;
      this.dataMatrimonio["Padres_Novi" + prefijo] = data.Padres_;
      this.dataMatrimonio["Parroquia_Novi" + prefijo] = data.Parroquia_;
      this.dataMatrimonio["Fecha_Bautismo_Novi" + prefijo] =
        data.Fecha_Bautismo_;
      this.dataMatrimonio["Libro_Novi" + prefijo] = data.Libro_;
      this.dataMatrimonio["Folio_Novi" + prefijo] = data.Folio_;
      this.dataMatrimonio["Acta_Novi" + prefijo] = data.Numero_;
    },

    invtrecord(Id) {
      this.showLoading("Realizando Eliminacion, Espera un momento...");
      console.log("Id de inactivacion", Id);
      let data = { Id: Id, Sp: "BD_Invt_Matrimonio" };
      window.myAPI.InvtRecord(data).then((e) => {
        console.log(e);
        if (e[0][""]) {
          if (e[0][""].includes("Error"))
            this.showMessage(e[0][""], "red", "error");
          else {
            this.showMessage(e[0][""], "positive", "check");
            this.getMatrimonios();
          }
        }
      });
    },

    setCargoFirm() {
      this.dataMatrimonio.Cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataMatrimonio.Id_Ministro
      ).Cargo;
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
      this.dataMatrimonio.Libro_Novio = null;
      this.dataMatrimonio.Folio_Novio = null;
      this.dataMatrimonio.Acta_Novio = null;
      this.dataMatrimonio.Novia = null;
      this.dataMatrimonio.Padres_Novia = null;
      this.dataMatrimonio.Parroquia_Novia = null;
      this.dataMatrimonio.Fecha_Bautismo_Novia = null;
      this.dataMatrimonio.Libro_Novia = null;
      this.dataMatrimonio.Folio_Novia = null;
      this.dataMatrimonio.Acta_Novia = null;
      this.dataMatrimonio.Testigos = null;
      this.dataMatrimonio.Id_MinistroDoyFe = 0;
      this.dataMatrimonio.Nota_Marginal = null;
      this.dataMatrimonio.Id_Ministro = 0;
      this.dataMatrimonio.Cargo = null;
      this.$refs.cards.cleanData();
      this.$refs.cards1.cleanData();
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
