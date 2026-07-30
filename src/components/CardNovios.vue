<template>
  <q-card flat class="sac-novio-card">
    <q-card-section>
      <h3 class="sac-novio-card__title">{{ title }}</h3>
    </q-card-section>

    <q-card-section class="q-pt-none q-gutter-y-sm">
      <div class="sac-field">
        <label class="sac-label" :for="uid('nombre')">Nombre</label>
        <q-input
          :id="uid('nombre')"
          v-model="dataCard.Nombre_"
          class="sac-input"
          type="text"
          dense
          outlined
          hide-bottom-space
        />
      </div>
      <div class="sac-field">
        <label class="sac-label" :for="uid('padres')">Padres</label>
        <q-input
          :id="uid('padres')"
          v-model="dataCard.Padres_"
          class="sac-input"
          type="text"
          dense
          outlined
          hide-bottom-space
        />
      </div>
      <div class="sac-field">
        <label class="sac-label" :for="uid('parroquia')">Parroquia</label>
        <q-input
          :id="uid('parroquia')"
          v-model="dataCard.Parroquia_"
          class="sac-input"
          type="text"
          dense
          outlined
          hide-bottom-space
        />
      </div>
      <div class="sac-field">
        <label class="sac-label" :for="uid('fecha')">Fecha de bautismo</label>
        <q-input
          :id="uid('fecha')"
          v-model="dataCard.Fecha_Bautismo_"
          class="sac-input"
          type="text"
          dense
          outlined
          hide-bottom-space
        />
      </div>
    </q-card-section>

    <q-separator />

    <q-card-section>
      <div class="sac-novio-card__grid">
        <div class="sac-field">
          <label class="sac-label" :for="uid('libro')">Libro</label>
          <q-input
            :id="uid('libro')"
            v-model="dataCard.Lib_"
            class="sac-input"
            type="text"
            dense
            outlined
            hide-bottom-space
          />
        </div>
        <div class="sac-field">
          <label class="sac-label" :for="uid('folio')">Folio</label>
          <q-input
            :id="uid('folio')"
            v-model="dataCard.Fol_"
            class="sac-input"
            type="text"
            dense
            outlined
            hide-bottom-space
          />
        </div>
        <div class="sac-field">
          <label class="sac-label" :for="uid('numero')">Número</label>
          <q-input
            :id="uid('numero')"
            v-model="dataCard.Numero_"
            class="sac-input"
            type="text"
            dense
            outlined
            hide-bottom-space
          />
        </div>
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
  setup(props) {
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
      uid(suffix) {
        return `novio-${props.prefijo || "x"}-${suffix}`;
      },
    };
  },
  methods: {
    updateData() {
      this.dataCard.Nombre_ = this.dataForm["Novi" + this.prefijo];
      this.dataCard.Padres_ = this.dataForm["Padres_Novi" + this.prefijo];
      this.dataCard.Parroquia_ = this.dataForm["Parroquia_Novi" + this.prefijo];
      this.dataCard.Fecha_Bautismo_ =
        this.dataForm["Fecha_Bautismo_Novi" + this.prefijo];
      this.dataCard.Lib_ = this.dataForm["Lib_Novi" + this.prefijo];
      this.dataCard.Fol_ = this.dataForm["Fol_Novi" + this.prefijo];
      this.dataCard.Numero_ = this.dataForm["Acta_Novi" + this.prefijo];
    },
    cleanData() {
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
