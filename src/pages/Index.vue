<template>
  <q-page class="flex flex-center">
    <q-card
      class="my-card"
      flat
      bordered
      v-for="(item, index) in modulesCards"
      :key="index"
    >
      <q-img :srcset="require('../assets/img/' + item.Nombre_Imagen)" />

      <q-card-section>
        <q-btn
          fab
          color="primary"
          :icon="item.Icono"
          class="absolute"
          style="top: 0; right: 12px; transform: translateY(-50%)"
        />

        <div class="row no-wrap items-center">
          <div class="col text-h6 ellipsis">{{ item.Nombre_Modulo }}</div>
          <div
            class="col-auto text-grey text-caption q-pt-md row no-wrap items-center"
          >
            <q-icon :name="item.Icono" />
          </div>
        </div>

        <!-- <q-rating v-model="stars" :max="5" size="32px" /> -->
      </q-card-section>

      <q-card-section class="q-pt-none">
        <div class="text-subtitle1"></div>
        <div class="text-caption text-grey">
          {{ item.Descripcion }}
        </div>
      </q-card-section>
      <q-separator />
      <q-card-actions>
        <q-btn flat color="primary" @click="redirect(item.Modulo)">
          Ir al modulo
        </q-btn>
      </q-card-actions>
    </q-card>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
// import * as echarts from "echarts";
import { useQuasar } from "quasar";

//import { ipcRenderer } from "electron";
//const { ipcRenderer } = require("electron");
export default defineComponent({
  name: "PageIndex",
  setup() {
    const $q = useQuasar();

    const getKeyModules = () => {
      return $q.localStorage.getItem("KeyMod");
    };
    return {
      getKeyModules,
      modulesCards: ref([]),
    };
  },
  mounted() {
    console.log("Holi");
    this.loadModuleCards();
  },
  methods: {
    loadModuleCards() {
      let dataModule = JSON.parse(this.getKeyModules());
      this.modulesCards = dataModule.filter((e) => e.Mostrar_Inicio == true);
    },

    redirect(nameModule) {
      this.$router.push("/" + nameModule);
    },
  },
});
</script>
