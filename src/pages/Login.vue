<template>
  <q-layout>
    <q-page-container>
      <q-page>
        <div class="background__" v-if="store.state.appConfig.appConfig.fondo_login"
         :style="{ backgroundImage: `url(${getImg(store.state.appConfig.appConfig.fondo_login)})` }" >
          <q-card class="my-card" style="width: 50%; opacity: 0.9">
            <q-img
              v-if="store.state.appConfig.appConfig.logo_login"
              :src="require(`src/assets/img/${store.state.appConfig.appConfig.logo_login}`)"
              style="height: 150px"
              fit="contain"
            />

            <q-card-section>
              <div class="row no-wrap items-center">
                <div class="col text-h6 ellipsis">LOGIN</div>
              </div>
            </q-card-section>

            <q-form class="full-width" autofocus @submit="tryLogin()">
              <q-card-section class="q-pt-none">
                <div class="content-center inputs q-gutter-y-md">
                  <q-input
                    v-model="userName"
                    type="text"
                    class="input"
                    input-style="color:black"
                    placeholder="Usuario"
                    color="secondary"
                    label-color="primary"
                    error-message="Username es incorrecto"
                    clearable
                    required
                  />
                  <q-input
                    v-model="clave"
                    placeholder="Contraseña"
                    place
                    color="secondary"
                    label-color="primary"
                    :type="isPwd ? 'password' : 'text'"
                    required
                  >
                    <template v-slot:append>
                      <q-icon
                        :name="isPwd ? 'visibility_off' : 'visibility'"
                        class="cursor-pointer"
                        @click="isPwd = !isPwd"
                      />
                    </template>
                  </q-input>
                </div>
              </q-card-section>
              <q-separator />
              <q-card-actions>
                <div class="full-width buttons">
                  <q-btn
                    class="full-width btn"
                    label="Iniciar sesión"
                    color="secondary"
                    text-color="dark"
                    type="submit"
                  />
                </div>
              </q-card-actions>
              <q-separator />
              <q-card-section>
                <q-img
                  :srcset="require('../assets/img/logo_kapri.jpg')"
                  width="200px"
                  spinner-size="82px"
                  spinner-color="primary"
                  style="float: right"
                />
              </q-card-section>
            </q-form>
          </q-card>
        </div>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<style>
.background__ {
  height: 100vh;
  background-size: cover;
  display: flex;
  justify-content: space-around;
  align-items: center;
}
</style>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";
import { useStore } from "vuex";

export default defineComponent({
  name: "PageIndex",
  mounted() {
    window.ApiLogin.getConfigParroquia().then((e) => {
      this.store.commit('appConfig/setAppConfig', e);
    });
  },
  setup() {
    const q = useQuasar();
    const store = useStore();

    function saveLogin(data, cl) {
      store.commit('userInfo/setUserInfo', data);
      q.localStorage.set("SK", JSON.stringify(data)); // SessionKey
      if (q.localStorage.has("SK")) cl(true);
      else cl(false);
    }

    function showLoading(msj) {
      q.loading.show({
        message: msj,
      });
    }
    const hideLoading = () => q.loading.hide();
    const showMessage = (msj, color, icon) => {
      q.loading.hide();
      q.notify({
        progress: true,
        message: msj,
        icon: icon,
        color: color,
        textColor: "white",
      });
    };

    return {
      store,
      userName: ref(null),
      clave: ref(null),
      tries: ref(0),
      isPwd: ref(true),
      saveLogin,
      showLoading,
      hideLoading,
      showMessage,
    };
  },
  methods: {
    getImg(name) {
      return require(`src/assets/img/${name}`)
    },
    tryLogin() {
      let data = { user: this.userName, clave: this.clave };
      this.showLoading("Cargando.. Por favor espera");
      window.ApiLogin.loadLogin(data).then((e) => {
        if (e.success == false)
          this.showMessage("Error -" + e.errorMessage, "negative", "error");
        else {
          if (e.data.length > 0) {
            this.saveLogin(e.data[0], () => {
              this.hideLoading();
              this.showMessage(
                "Sesion Iniciada correctamente",
                "positive",
                "check"
              );
              this.$router.push("/Home");
            });
          } else {
            this.tries += 1;
            this.showMessage(
              "Usuario o contraseña incorrecta.",
              "negative",
              "error"
            );
            this.hideLoading();
          }
        }
      });
    },
  },
  watch: {
  },
});
</script>
