<template>
  <q-page class="flex flex-center">
    <div class="q-pa-md">
      <h1>Acerca de</h1>
      <div>
        <q-table
          flat
          bordered
          title="Treats"
          :rows="rows"
          :columns="columns"
          row-key="name"
          :visible-columns="visibleColumns"
        >
          <template v-slot:top="props">
            <div class="col-2 q-table__title">Treats</div>

            <q-space />

            <div v-if="$q.screen.gt.xs" class="col">
              <q-toggle
                v-model="visibleColumns"
                val="calories"
                label="Calories"
              />
              <q-toggle v-model="visibleColumns" val="fat" label="Fat" />
              <q-toggle v-model="visibleColumns" val="carbs" label="Carbs" />
              <q-toggle
                v-model="visibleColumns"
                val="protein"
                label="Protein"
              />
              <q-toggle v-model="visibleColumns" val="sodium" label="Sodium" />
              <q-toggle
                v-model="visibleColumns"
                val="calcium"
                label="Calcium"
              />
              <q-toggle v-model="visibleColumns" val="iron" label="Iron" />
            </div>
            <q-select
              v-else
              v-model="visibleColumns"
              multiple
              borderless
              dense
              options-dense
              :display-value="$q.lang.table.columns"
              emit-value
              map-options
              :options="columns"
              option-value="name"
              style="min-width: 150px"
            />

            <q-btn
              flat
              round
              dense
              :icon="props.inFullscreen ? 'fullscreen_exit' : 'fullscreen'"
              @click="props.toggleFullscreen"
              class="q-ml-md"
            />
          </template>
        </q-table>
      </div>
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
