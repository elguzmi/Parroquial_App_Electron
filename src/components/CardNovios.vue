<template>
  <q-card flat bordered class="my-card rounded-borders">
    <q-card-section>
      <div class="text-h6 text-center">{{ title }}</div>
    </q-card-section>

    <q-card-section class="q-pt-none q-gutter-y-xs">
      <q-input
        v-model="dataCard.Nombre_"
        type="text"
        label="Nombre"
        :dense="isDense"
      />
      <q-input
        v-model="dataCard.Padres_"
        type="text"
        label="Padres"
        :dense="isDense"
      />
      <q-input
        v-model="dataCard.Parroquia_"
        type="text"
        label="Parroquia"
        :dense="isDense"
      />
      <q-input
        v-model="dataCard.Fecha_Bautismo_"
        type="text"
        label="Fecha Bautismo"
        dense
      />
    </q-card-section>

    <q-separator inset />

    <q-card-section class="full-width row no-wrap justify-around items-start">
      <div class="col-3">
        <q-input
          v-model="dataCard.Libro_"
          type="text"
          label="Libro"
          :dense="isDense"
        />
      </div>
      <div class="col-3">
        <q-input
          v-model="dataCard.Folio_"
          type="text"
          label="Folio"
          :dense="isDense"
        />
      </div>
      <div class="col-3">
        <q-input
          v-model="dataCard.Numero_"
          type="text"
          label="Numero"
          :dense="isDense"
        />
      </div>
    </q-card-section>
  </q-card>
</template>

<script>
import { defineComponent, ref } from "vue";

export default defineComponent({
  name: "CardNovios",
  props: {
    title: { type: String },
    card: { type: String },
    dataForm: { type: Object },
    prefijo: { type: String },
  },
  setup() {
    return {
      isDense: true,
      dataCard: ref({
        Nombre_: ref(null),
        Padres_: ref(null),
        Parroquia_: ref(null),
        Fecha_Bautismo_: ref(null),
        Libro_: ref(null),
        Folio_: ref(null),
        Numero_: ref(null),
      }),
    };
  },

  updated() {
    //console.log("Se actualizo");
  },
  mounted() {
    //console.log("Montado cards");
  },
  methods: {
    updateData() {
      //console.log("Actualizando..");
      this.dataCard.Nombre_ = this.dataForm["Novi" + this.prefijo];
      this.dataCard.Padres_ = this.dataForm["Padres_Novi" + this.prefijo];
      this.dataCard.Parroquia_ = this.dataForm["Parroquia_Novi" + this.prefijo];
      this.dataCard.Fecha_Bautismo_ =
        this.dataForm["Fecha_Bautismo_Novi" + this.prefijo];
      this.dataCard.Libro_ = this.dataForm["Libro_Novi" + this.prefijo];
      this.dataCard.Folio_ = this.dataForm["Folio_Novi" + this.prefijo];
      this.dataCard.Numero_ = this.dataForm["Acta_Novi" + this.prefijo];
    },
    cleanData() {
      //console.log(this.dataCard);
      Object.keys(this.dataCard).map((e) => {
        this.dataCard[e] = null;
      });
    },
    getData() {
      this.$emit("SetInfo", this.dataCard, this.prefijo);
    },
  },
});
</script>
