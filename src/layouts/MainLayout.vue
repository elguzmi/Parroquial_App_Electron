<template>
  <q-layout view="hHh LpR fFf" class="bg-grey-3">
    <q-header class="bg-grey-3 text-grey-9" reveal height-hint="60">
      <q-toolbar class="GPLAY__toolbar text-dark bg-primary">
        <q-btn
          v-if="$q.platform.is.mobile || !leftDrawerOpen"
          flat
          dense
          round
          @click="toggleLeftDrawer"
          aria-label="Menu"
          icon="menu"
          class="q-mr-sm"
        />
        <div class="q-pr-lg text-h6" v-if="$q.screen.gt.xs">
          Parroquia Jesús Eucaristía
        </div>

        <q-space />
        <div class="q-pr-lg text-h5 text-weight-bold" v-if="$q.screen.gt.xs">
          Modulo {{ selectedModule }}
        </div>

        <q-space />
        <div class="q-pl-md q-gutter-sm row no-wrap items-center">
          <!-- <q-btn round dense flat color="grey-8" icon="notifications">
            <q-badge color="red" text-color="white" floating> 2 </q-badge>
            <q-tooltip>Notifications</q-tooltip>
          </q-btn> -->
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      show-if-above
      bordered
      class="bg-grey-3 text-grey-7"
      :width="200"
    >
      <q-list>
        <q-item
          v-for="(modul, index) in modules"
          :key="index"
          clickable
          :class="modul.Clase_Principal"
          @click="setMenuActive(modul.Modulo)"
        >
          <q-item-section avatar :class="modul.Clase">
            <q-icon :name="modul.Icono" />
          </q-item-section>
          <q-item-section class="books-text">
            <q-item-label>{{ modul.Nombre_Modulo }}</q-item-label>
          </q-item-section>
        </q-item>
        <q-item
          clickable
          class="GPLAY__drawer-link GPLAY__drawer-link--logout"
          @click="closeSession()"
        >
          <q-item-section
            avatar
            class="books-icon bg-light-7 text-dark-1 text-center"
          >
            <q-icon name="logout" />
          </q-item-section>
          <q-item-section class="books-text">
            <q-item-label>Cerrar Sesion</q-item-label>
          </q-item-section>
        </q-item>
      </q-list>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import { ref } from "vue";
import { useQuasar } from "quasar";

export default {
  name: "GooglePlayLayout",

  setup() {
    const $q = useQuasar();
    const leftDrawerOpen = ref(false);
    const search = ref("");
    const storage = ref(0.26);

    function toggleLeftDrawer() {
      leftDrawerOpen.value = !leftDrawerOpen.value;
    }

    function showLoading(msj) {
      $q.loading.show({
        message: msj,
      });
    }
    const hideLoading = () => $q.loading.hide();

    const getDataLogin = (cll) => {
      if ($q.localStorage.has("SK"))
        cll(true, JSON.parse($q.localStorage.getItem("SK")));
      else cll(false, {});
    };

    const saveModules = (obj) => {
      $q.localStorage.set("KeyMod", JSON.stringify(obj));
    };
    const removeLocal = () => $q.localStorage.clear();

    return {
      leftDrawerOpen,
      search,
      storage,
      selectedModule: ref(""),
      toggleLeftDrawer,
      modules: ref([]),
      getDataLogin,
      removeLocal,
      showLoading,
      hideLoading,
      saveModules,
    };
  },
  created() {
    this.getModules();
  },
  methods: {
    getModules() {
      this.showLoading("Cargando Modulos... Por favor espera");
      this.getDataLogin((val, data) => {
        if (!val) this.$router.push("/");
        else {
          window.ApiLogin.loadModules(data.Id_Perfil).then((e) => {
            this.modules = e;
            this.saveModules(e);
            this.$router.push("/Inicio");
            this.hideLoading();
          });
        }
      });
    },

    setMenuActive(moduleName) {
      this.selectedModule = moduleName;
      this.$router.push("/" + moduleName);
    },
    closeSession() {
      this.removeLocal();
      this.$router.push("/");
    },
  },
};
</script>

<style lang="sass">
.GPLAY
  &__toolbar
    height: 60px

  &__logo
    width: 183px
    height: 39px

  &__toolbar-input-containerbooks-text
    min-width: 100px
    width: 55%

  &__toolbar-input-btn
    border-radius: 0
    max-width: 60px
    width: 100%

  &__drawer-link

    .q-item__section--avatar
      margin: -8px 0 -8px -16px
      padding: 8px 0 8px 16px

    .q-item__section--main
      margin: -8px -16px -8px 16px
      padding: 8px 16px 8px 2px
      font-size: 18px
      font-weight: 300

    &--apps, &--movies, &--music, &--books, &--devices ,&--defunciones
      background: #f5f5f5!important
      &:hover
        color: #eee !important

    &--apps:hover
      background: #43a047!important

    &--movies:hover
      background: #e53935!important

    &--music:hover
      background: #fb8c00!important

    &--books:hover
      background: #1e88e5!important

    &--devices:hover
      background: #546e7a!important

    &--defunciones:hover
      background: var(--q-dark) !important

    &--logout:hover
      background: #d7d5e7!important

  &__drawer-item
    padding: 6px 12px 6px 23px

  &__sticky
    min-height: 49px
    border-bottom: 1px solid rgba(0,0,0,0.12)

  &__sticky-help
    border: 1px solid #ccc
    padding-left: 8px
    padding-right: 8px

  &__sticky-settings
    padding-left: 17px
    padding-right: 17px
    border: 1px solid #ccc
</style>
