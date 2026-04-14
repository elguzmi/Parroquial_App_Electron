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
                label="Ministro"
                filled
                fill-input
                hide-selected
                input-debounce="0"
                use-input
                dense
                :options="[
                  'JAIRO ALBERTO AGUILAR GONZÁLEZ. Pbro.',	
                  'YOEL GÓMEZ RAMÍREZ. Pbro.',
                  'LORENZO ALZATE ARBOLEDA. Pbro',
                  'MARIO DE JESÚS ACOSTA RAMÍREZ. Pbro.',
                  'MONSEÑOR ENRIQUE SARMIENTO ANGULO',
                  'MONSEÑOR JUAN VICENTE CÓRDOBA VILLOTA. SJ.',
                ]"
                @input-value="setModel"
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
                :options="[...ListMinistros, ...ListMinistrosNoActive]"
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
        title="Confirmaciones"
        tablaDirectTo="fact_Confirmaciones"
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
        this.ListId_MinistroDoyFe = e[0];
        this.ListMinistros = e[1];
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
          this.$refs.tableComponent.cleanSelectedRow();
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
      this.setFirmanteFav();
      this.setCargoFirm();
    },

    addMinistroToList(id , name) {
      const verify = this.ListMinistros.some((e) => e.Id == id) || this.ListMinistrosNoActive.some((e) => e.Id == id);
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
      this.$refs.tableComponent.cleanSelectedRow();
      this.ListMinistrosNoActive = [];
      this.setFirmanteFav();
    },

    setFirmanteFav(){
      const selectDefault = this.ListMinistros.find(
        (e) => e.isCurrent == 1
      );
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
