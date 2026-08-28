<template>
  <q-layout view="hHh LpR lFf" class="app-layout">
    <q-header class="app-header" elevated height-hint="64">
      <q-toolbar class="app-toolbar">
        <q-btn
          flat
          dense
          round
          class="app-toolbar__menu"
          icon="menu"
          aria-label="Abrir o cerrar menú"
          @click="toggleLeftDrawer"
        />

        <div class="app-toolbar__brand">
          <div class="app-toolbar__parish ellipsis">
            {{ parishName }}
          </div>
          <div v-if="$q.screen.gt.xs" class="app-toolbar__module ellipsis">
            {{ moduleTitle }}
          </div>
        </div>

        <q-space />

        <div class="app-toolbar__actions">
          <div v-if="$q.screen.gt.sm" class="app-toolbar__user">
            <div class="app-toolbar__avatar" aria-hidden="true">
              <q-icon name="person" size="18px" />
            </div>
            <div class="app-toolbar__user-text">
              <span class="app-toolbar__user-name ellipsis">{{ userDisplayName }}</span>
              <span class="app-toolbar__user-role">Sesión activa</span>
            </div>
          </div>

          <q-btn
            flat
            dense
            no-caps
            class="app-toolbar__logout"
            icon="logout"
            :label="$q.screen.gt.xs ? 'Salir' : undefined"
            aria-label="Cerrar sesión"
            @click="closeSession"
          />
        </div>
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="leftDrawerOpen"
      bordered
      :mini="isMini"
      :width="264"
      :mini-width="72"
      :breakpoint="1023"
      :overlay="$q.screen.lt.md"
      :behavior="$q.screen.lt.md ? 'mobile' : 'desktop'"
      class="app-drawer"
      :class="{ 'app-drawer--mini': isMini }"
      content-class="app-drawer__content"
    >
      <div class="app-drawer__inner">
        <div class="app-drawer__head" :class="{ 'app-drawer__head--mini': isMini }">
          <div class="app-drawer__brand">
            <div class="app-drawer__logo" aria-hidden="true">
              <q-icon name="account_balance" size="20px" />
            </div>
            <div v-show="!isMini" class="app-drawer__head-text">
              <div class="app-drawer__product">Parroquia App</div>
              <div class="app-drawer__tag">Gestión sacramental</div>
            </div>
          </div>

          <button
            v-if="$q.screen.gt.sm"
            type="button"
            class="app-drawer__rail-toggle"
            :class="{ 'app-drawer__rail-toggle--mini': isMini }"
            :aria-label="drawerExpanded ? 'Colapsar menú' : 'Expandir menú'"
            :title="drawerExpanded ? 'Colapsar' : 'Expandir'"
            @click="toggleDrawerExpanded"
          >
            <q-icon
              :name="drawerExpanded ? 'chevron_left' : 'chevron_right'"
              size="18px"
            />
          </button>
        </div>

        <div class="app-drawer__scroll">
          <q-list class="app-nav">
            <q-item
              v-for="modul in modules"
              :key="modul.Modulo || modul.Nombre_Modulo"
              v-ripple
              clickable
              :active="isModuleActive(modul.Modulo)"
              active-class="app-nav__item--active"
              class="app-nav__item"
              @click="setMenuActive(modul.Modulo)"
            >
              <q-item-section avatar class="app-nav__avatar">
                <div class="app-nav__icon">
                  <q-icon :name="modul.Icono || 'folder'" size="20px" />
                </div>
              </q-item-section>
              <q-item-section>
                <q-item-label class="app-nav__label">
                  {{ modul.Nombre_Modulo }}
                </q-item-label>
              </q-item-section>
              <q-tooltip
                v-if="isMini"
                anchor="center right"
                self="center left"
                :offset="[12, 0]"
              >
                {{ modul.Nombre_Modulo }}
              </q-tooltip>
            </q-item>
          </q-list>
        </div>

        <div class="app-drawer__footer" :class="{ 'app-drawer__footer--mini': isMini }">
          <q-btn
            class="app-drawer__logout"
            flat
            no-caps
            dense
            icon="logout"
            :label="isMini ? undefined : 'Cerrar sesión'"
            aria-label="Cerrar sesión"
            @click="closeSession"
          >
            <q-tooltip v-if="isMini" anchor="center right" self="center left" :offset="[12, 0]">
              Cerrar sesión
            </q-tooltip>
          </q-btn>
        </div>
      </div>
    </q-drawer>

    <q-page-container class="app-page-container">
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import { ref, computed, watch, onMounted, onBeforeUnmount } from "vue";
import { useQuasar } from "quasar";
import { useStore } from "vuex";
import { useRouter, useRoute } from "vue-router";
import { dialogBtnCancel, dialogBtnPrimary } from "src/utils/appDialog";

export default {
  name: "MainLayout",

  setup() {
    const $q = useQuasar();
    const store = useStore();
    const router = useRouter();
    const route = useRoute();

    const leftDrawerOpen = ref($q.screen.gt.sm);
    const drawerExpanded = ref(true);
    const selectedModule = ref("");
    const modules = ref([]);

    const isMini = computed(
      () => $q.screen.gt.sm && leftDrawerOpen.value && !drawerExpanded.value
    );

    const userInfo = computed(
      () => store.getters["userInfo/getUserInfo"] || {}
    );

    const parishName = computed(
      () =>
        userInfo.value.Parroquia ||
        store.state.appConfig?.appConfig?.parroquia ||
        "Parroquia"
    );

    const userDisplayName = computed(() => {
      return (
        userInfo.value.Nombre ||
        userInfo.value.Usuario ||
        userInfo.value.User ||
        "Usuario"
      );
    });

    const moduleTitle = computed(() => {
      const current = modules.value.find(
        (m) => m.Modulo === selectedModule.value
      );
      if (current?.Nombre_Modulo) return current.Nombre_Modulo;
      if (!selectedModule.value || selectedModule.value === "Home") {
        return "Inicio";
      }
      return selectedModule.value;
    });

    function toggleLeftDrawer() {
      leftDrawerOpen.value = !leftDrawerOpen.value;
    }

    function toggleDrawerExpanded() {
      if ($q.screen.lt.md) return;
      if (!leftDrawerOpen.value) {
        leftDrawerOpen.value = true;
        drawerExpanded.value = true;
        return;
      }
      drawerExpanded.value = !drawerExpanded.value;
    }

    function showLoading(msj) {
      $q.loading.show({ message: msj });
    }

    const hideLoading = () => $q.loading.hide();

    const showMessage = (msj, color, icon) => {
      $q.loading.hide();
      $q.notify({
        progress: true,
        message: msj,
        icon: icon || "info",
        color: color || "primary",
        textColor: "white",
      });
    };

    const getDataLogin = (cll) => {
      if ($q.localStorage.has("SK")) {
        cll(true, JSON.parse($q.localStorage.getItem("SK")));
      } else {
        cll(false, {});
      }
    };

    const saveModules = (obj) => {
      $q.localStorage.set("KeyMod", JSON.stringify(obj));
    };

    const removeLocal = () => $q.localStorage.clear();

    function syncModuleFromRoute(path) {
      const clean = String(path || "").replace(/^\//, "");
      selectedModule.value = clean || "Inicio";
    }

    function onResize() {
      if ($q.screen.lt.md) {
        drawerExpanded.value = true;
      }
    }

    watch(
      () => route.path,
      (path) => syncModuleFromRoute(path),
      { immediate: true }
    );

    onMounted(() => {
      window.addEventListener("resize", onResize);
    });

    onBeforeUnmount(() => {
      window.removeEventListener("resize", onResize);
    });

    return {
      store,
      leftDrawerOpen,
      drawerExpanded,
      isMini,
      selectedModule,
      modules,
      parishName,
      userDisplayName,
      moduleTitle,
      toggleLeftDrawer,
      toggleDrawerExpanded,
      getDataLogin,
      removeLocal,
      showLoading,
      hideLoading,
      showMessage,
      saveModules,
      syncModuleFromRoute,
      router,
      route,
    };
  },

  created() {
    this.getModules();
  },

  methods: {
    isModuleActive(moduleName) {
      return this.selectedModule === moduleName;
    },

    getModules() {
      this.showLoading("Cargando módulos…");
      this.getDataLogin((val, data) => {
        if (!val) {
          this.hideLoading();
          this.$router.push("/");
          return;
        }

        // Restaurar sesión en Vuex tras refresh
        if (data && Object.keys(data).length) {
          this.store.commit("userInfo/setUserInfo", data);
        }

        window.ApiLogin.loadModules(data.Id_Perfil)
          .then((e) => {
            if (e.success === false) {
              this.showMessage(
                "Error -" + (e.message || "No se pudieron cargar los módulos"),
                "negative",
                "error"
              );
              return;
            }

            this.modules = Array.isArray(e.data) ? e.data : [];
            this.saveModules(this.modules);

            const path = this.$route.path;
            const onShellOnly = path === "/Home" || path === "/";
            if (onShellOnly) {
              this.$router.push("/Inicio");
            } else {
              this.syncModuleFromRoute(path);
            }
          })
          .catch((err) => {
            this.showMessage(
              err?.message || "Error al cargar módulos",
              "negative",
              "error"
            );
          })
          .finally(() => {
            this.hideLoading();
          });
      });
    },

    setMenuActive(moduleName) {
      if (!moduleName) return;
      this.selectedModule = moduleName;
      this.$router.push("/" + moduleName);

      // En móvil, cerrar el drawer tras navegar
      if (this.$q.screen.lt.md) {
        this.leftDrawerOpen = false;
      }
    },

    closeSession() {
      this.$q
        .dialog({
          title: "Cerrar sesión",
          message: "¿Desea salir de la aplicación?",
          cancel: dialogBtnCancel(),
          ok: dialogBtnPrimary("Salir"),
          persistent: true,
        })
        .onOk(() => {
          if (window.ApiLogin?.logout) {
            window.ApiLogin.logout();
          }
          this.removeLocal();
          this.$router.push("/");
        });
    },
  },
};
</script>

<style lang="scss">
@import url("https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,650;9..144,700&family=Outfit:wght@300;400;500;600;700&display=swap");

.app-layout {
  --app-navy: #0b2431;
  --app-navy-mid: #16303c;
  --app-navy-soft: #1a3a4a;
  --app-gold: #c9a227;
  --app-gold-soft: #b8922a;
  --app-muted: #5b7380;
  --app-line: rgba(11, 36, 49, 0.1);
  --app-fog: #f3f5f7;
  --app-surface: #ffffff;

  background: var(--app-fog);
  font-family: "Outfit", sans-serif;
  color: var(--app-navy-mid);
  min-height: 100vh;
}

.app-header {
  background: var(--app-surface) !important;
  color: var(--app-navy) !important;
  box-shadow: 0 1px 0 var(--app-line), 0 8px 24px rgba(11, 36, 49, 0.04) !important;
}

.app-toolbar {
  min-height: 64px;
  padding: 0 0.75rem 0 0.5rem;
  gap: 0.35rem;
}

.app-toolbar__menu {
  color: var(--app-navy) !important;
}

.app-toolbar__brand {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 0.05rem;
  padding-left: 0.15rem;
}

.app-toolbar__parish {
  font-family: "Fraunces", serif;
  font-weight: 650;
  font-size: 1.05rem;
  line-height: 1.2;
  color: var(--app-navy);
  max-width: min(42vw, 360px);
}

.app-toolbar__module {
  font-size: 0.78rem;
  color: var(--app-muted);
  font-weight: 500;
  max-width: min(42vw, 360px);
}

.app-toolbar__actions {
  display: flex;
  align-items: center;
  gap: 0.55rem;
}

.app-toolbar__user {
  display: flex;
  align-items: center;
  gap: 0.55rem;
  padding: 0.35rem 0.65rem 0.35rem 0.35rem;
  border-radius: 999px;
  background: rgba(11, 36, 49, 0.04);
  border: 1px solid var(--app-line);
  max-width: 220px;
}

.app-toolbar__avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  background: var(--app-navy);
  color: var(--app-gold);
  flex-shrink: 0;
}

.app-toolbar__user-text {
  min-width: 0;
  display: flex;
  flex-direction: column;
  line-height: 1.15;
}

.app-toolbar__user-name {
  font-size: 0.82rem;
  font-weight: 600;
  color: var(--app-navy);
}

.app-toolbar__user-role {
  font-size: 0.7rem;
  color: var(--app-muted);
}

.app-toolbar__logout {
  color: var(--app-navy-mid) !important;
  font-weight: 600;
  border-radius: 10px;
}

.app-toolbar__logout:hover {
  background: rgba(193, 0, 21, 0.08) !important;
  color: #b42318 !important;
}

.app-drawer {
  background: linear-gradient(180deg, #0b2431 0%, #123848 58%, #0f3340 100%) !important;
  border-right: 1px solid rgba(255, 255, 255, 0.06) !important;
  color: #f4f7f8;
}

.app-drawer__content {
  background: transparent !important;
  overflow-x: hidden !important;
  overflow-y: hidden !important;
}

.app-drawer__inner {
  height: 100%;
  width: 100%;
  max-width: 100%;
  display: flex;
  flex-direction: column;
  min-height: 0;
  overflow-x: hidden;
  overflow-y: hidden;
  box-sizing: border-box;
}

.app-drawer__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.4rem;
  padding: 0.85rem 0.7rem 0.8rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  min-height: 64px;
  box-sizing: border-box;
  overflow: hidden;
}

.app-drawer__head--mini {
  flex-direction: column;
  justify-content: center;
  gap: 0.45rem;
  padding: 0.75rem 0.3rem 0.7rem;
}

.app-drawer__brand {
  display: flex;
  align-items: center;
  gap: 0.55rem;
  min-width: 0;
  flex: 1;
  overflow: hidden;
}

.app-drawer__head--mini .app-drawer__brand {
  flex: 0;
  justify-content: center;
}

.app-drawer__logo {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: grid;
  place-items: center;
  background: rgba(201, 162, 39, 0.16);
  color: var(--app-gold);
  flex-shrink: 0;
}

.app-drawer__head-text {
  min-width: 0;
  flex: 1;
  overflow: hidden;
}

.app-drawer__product {
  font-family: "Fraunces", serif;
  font-weight: 650;
  font-size: 0.98rem;
  line-height: 1.2;
  color: #fff;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.app-drawer__tag {
  font-size: 0.7rem;
  color: rgba(244, 247, 248, 0.62);
  margin-top: 0.1rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.app-drawer__rail-toggle {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  padding: 0;
  border: 1px solid rgba(201, 162, 39, 0.35);
  border-radius: 8px;
  background: rgba(201, 162, 39, 0.14);
  color: var(--app-gold);
  display: grid;
  place-items: center;
  cursor: pointer;
  transition:
    background-color 0.15s ease,
    border-color 0.15s ease,
    color 0.15s ease;
}

.app-drawer__rail-toggle:hover {
  background: rgba(201, 162, 39, 0.28);
  border-color: rgba(201, 162, 39, 0.55);
  color: #f5e6a8;
}

.app-drawer__rail-toggle:focus-visible {
  outline: 2px solid var(--app-gold);
  outline-offset: 2px;
}

.app-drawer__rail-toggle--mini {
  width: 32px;
  height: 26px;
  border-radius: 7px;
}

.app-drawer__scroll {
  flex: 1 1 auto;
  height: 0;
  min-height: 0;
  width: 100%;
  max-width: 100%;
  overflow-x: hidden;
  overflow-y: auto;
  scrollbar-width: thin;
  scrollbar-color: rgba(255, 255, 255, 0.25) transparent;
}

.app-drawer__scroll::-webkit-scrollbar {
  width: 4px;
}

.app-drawer__scroll::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.22);
  border-radius: 999px;
}

.app-nav {
  padding: 0.55rem 0.45rem !important;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

.app-drawer--mini .app-nav {
  padding: 0.55rem 0.35rem !important;
}

.app-nav__item {
  border-radius: 12px !important;
  min-height: 44px;
  min-width: 0 !important;
  margin-bottom: 0.2rem;
  padding: 4px 8px !important;
  color: rgba(244, 247, 248, 0.78) !important;
  transition: background-color 0.15s ease, color 0.15s ease;
  overflow: hidden;
}

.app-drawer--mini .app-nav__item {
  justify-content: center;
  padding: 6px 0 !important;
}

.app-nav__item:hover {
  background: rgba(255, 255, 255, 0.06) !important;
  color: #fff !important;
}

.app-nav__item--active {
  background: rgba(201, 162, 39, 0.16) !important;
  color: #fff !important;
  box-shadow: inset 3px 0 0 var(--app-gold-soft);
}

.app-drawer--mini .app-nav__item--active {
  box-shadow: none;
  background: rgba(201, 162, 39, 0.22) !important;
}

.app-nav__avatar {
  min-width: 36px !important;
  padding-right: 10px !important;
}

.app-drawer--mini .app-nav__avatar {
  min-width: 0 !important;
  padding: 0 !important;
  align-items: center;
}

.app-nav__icon {
  width: 34px;
  height: 34px;
  border-radius: 10px;
  display: grid;
  place-items: center;
  background: rgba(255, 255, 255, 0.06);
  color: inherit;
}

.app-nav__item--active .app-nav__icon {
  background: rgba(201, 162, 39, 0.22);
  color: var(--app-gold);
}

.app-nav__label {
  font-weight: 500;
  font-size: 0.9rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.app-drawer__footer {
  padding: 0.7rem 0.55rem 0.9rem;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  box-sizing: border-box;
  overflow: hidden;
}

.app-drawer__footer--mini {
  display: flex;
  justify-content: center;
  padding: 0.65rem 0.35rem 0.85rem;
}

.app-drawer__logout {
  width: 100%;
  justify-content: flex-start;
  color: rgba(244, 247, 248, 0.78) !important;
  border-radius: 12px;
  font-weight: 500;
  min-height: 40px;
}

.app-drawer__footer--mini .app-drawer__logout {
  width: 40px;
  min-width: 40px;
  padding: 0;
  justify-content: center;
}

.app-drawer__logout:hover {
  background: rgba(244, 63, 94, 0.14) !important;
  color: #fecdd3 !important;
}

.app-page-container {
  background: var(--app-fog);
}

@media (max-width: 599px) {
  .app-toolbar__parish {
    max-width: 46vw;
    font-size: 0.95rem;
  }
}
</style>
