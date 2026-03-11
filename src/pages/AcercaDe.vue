<template>
  <q-page class="flex flex-center" style="background-color: black">
    <div class="q-pa-md">
      <q-card class="my-card">
        <img src="../assets/img/logo_kapri.jpg" style="width:40%; margin: 0 auto;" />

        <q-card-section>
          <div class="text-h6">Kapri Technology</div>
          <div class="text-subtitle2">Kamilo Prieto // Santiago Guzmán</div>
        </q-card-section>

        <q-card-section>
          <p>
            <strong>Kapri Technology</strong> es una iniciativa enfocada en el desarrollo
            de soluciones tecnológicas modernas y escalables. Nos especializamos en la
            creación de software confiable, eficiente y adaptable, diseñado para apoyar
            el crecimiento y la transformación digital de empresas, instituciones y
            organizaciones.
          </p>

          <p>
            Nuestro enfoque se centra en el desarrollo de aplicaciones web, móviles y
            de escritorio, utilizando tecnologías modernas que permiten construir
            sistemas robustos, seguros y preparados para escalar conforme evolucionan
            las necesidades de cada proyecto. Buscamos crear herramientas digitales
            que optimicen procesos, mejoren la productividad y faciliten la gestión
            de la información.
          </p>

          <p>
            En Kapri Technology trabajamos con un compromiso constante hacia la
            calidad del software, la innovación tecnológica y la creación de
            soluciones intuitivas y eficientes, capaces de adaptarse a distintos
            entornos y sectores, brindando a nuestros clientes plataformas
            tecnológicas confiables y preparadas para el futuro.
          </p>

          <p>
            <strong>Contacto:</strong><br>
            📧 kapritecnology@gmail.com<br>
            📱 320 410 2229
          </p>
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref } from "vue";
export default defineComponent({
  name: "AcercaDe",
  setup() {
    const columns = [
      {
        name: "name",
        required: true,
        label: "Dessert (100g serving)",
        align: "left",
        field: (row) => row.name,
        format: (val) => `${val}`,
        sortable: true,
      },
      {
        name: "calories",
        align: "center",
        label: "Calories",
        field: "calories",
        sortable: true,
      },
      { name: "fat", label: "Fat (g)", field: "fat", sortable: true },
      { name: "carbs", label: "Carbs (g)", field: "carbs" },
      { name: "protein", label: "Protein (g)", field: "protein" },
      { name: "sodium", label: "Sodium (mg)", field: "sodium" },
      {
        name: "calcium",
        label: "Calcium (%)",
        field: "calcium",
        sortable: true,
        sort: (a, b) => parseInt(a, 10) - parseInt(b, 10),
      },
      {
        name: "iron",
        label: "Iron (%)",
        field: "iron",
        sortable: true,
        sort: (a, b) => parseInt(a, 10) - parseInt(b, 10),
      },
    ];

    const rows = [
      {
        name: "Frozen Yogurt",
        calories: 159,
        fat: 6.0,
        carbs: 24,
        protein: 4.0,
        sodium: 87,
        calcium: "14%",
        iron: "1%",
      },
      {
        name: "Ice cream sandwich",
        calories: 237,
        fat: 9.0,
        carbs: 37,
        protein: 4.3,
        sodium: 129,
        calcium: "8%",
        iron: "1%",
      },
      {
        name: "Eclair",
        calories: 262,
        fat: 16.0,
        carbs: 23,
        protein: 6.0,
        sodium: 337,
        calcium: "6%",
        iron: "7%",
      },
    ];
    return {
      visibleColumns: ref([
        "calories",
        "desc",
        "fat",
        "carbs",
        "protein",
        "sodium",
        "calcium1",
        "iron",
      ]),
      columns,
      rows,
    };
  },
  mounted() {},
  methods: {},
});
</script>
