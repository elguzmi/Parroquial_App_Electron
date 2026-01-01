<template>
  <q-page class="flex" padding>
    <section style="width: 100%">
      <div class="form">
        <q-form
          @submit="insMatrimonio()"
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
              <!-- <q-select
                v-model="dataMatrimonio.Presencio"
                :options="[
                  'YOEL GÓMEZ RAMÍREZ. Pbro.',
                  'LORENZO ALZATE ARBOLEDA. Pbro',
                  'MARIO DE JESÚS ACOSTA RAMÍREZ. Pbro.',
                ]"
                label="Presencio"
                filled
                dense
              /> -->
              <q-select
                filled
                v-model="dataMatrimonio.Presencio"
                :model-value="dataMatrimonio.Presencio"
                use-input
                label="Presencio"
                hide-selected
                fill-input
                input-debounce="0"
                :options="[
                  'JAIRO ALBERTO AGUILAR GONZÁLEZ. Pbro.',	
                  'YOEL GÓMEZ RAMÍREZ. Pbro.',
                  'LORENZO ALZATE ARBOLEDA. Pbro',
                  'MARIO DE JESÚS ACOSTA RAMÍREZ. Pbro.',
                ]"
                @input-value="setModel"
                dense
              >
              </q-select>
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
        title="Matrimonios"
        tablaDirectTo="fact_Matrimonios"
        :columns="columns"
        :rows="rows"
        :visibleColumns="visibleColumns"
        @eventedited="setrecord"
        @eventinvt="invtrecord"
        @loadingShow="showLoading"
        @loadingHide="hideLoading"
        @msjShow="showMessage"
      ></Table_Component>
    </section>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
import Table_Component from "components/Table_Component.vue";
import CardNovios from "components/CardNovios.vue";
import { useQuasar } from "quasar";

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
      ListDoyFe: ref(null),
      ListMinistros: ref(null),
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
        this.ListDoyFe = e[0];
        this.ListMinistros = e[1];
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
        this.$refs.tableComponent.cleanSelectedRow();
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

      for (const key in this.dataMatrimonio) {
        this.dataMatrimonio[key] = data[key];
      }
      this.$refs.cards.updateData();
      this.$refs.cards1.updateData();
      this.setCargoFirm();
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
      this.dataMatrimonio.Cargo = this.ListMinistros.find(
        (e) => e.Id == this.dataMatrimonio.Id_Ministro
      )?.Cargo;
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
