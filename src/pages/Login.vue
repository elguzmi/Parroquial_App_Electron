<template>
  <q-layout>
    <q-page-container>
      <q-page>
        <q-select
          label="DB"
          transition-show="flip-up"
          transition-hide="flip-down"
          filled
          v-model="dbSelected"
          :options="['serverProd', 'serverDev']"
          class="hidden"
          style="width: 100px; position: absolute; opacity: 0.1"
        />
        <div class="background__">
          <q-card class="my-card" style="width: 50%; opacity: 0.9">
            <q-img
              src="../assets/img/Logo_Parroquia.jpeg"
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
  background-image: url("../assets/img/iglesia.jpg");
  background-size: cover;
  display: flex;
  justify-content: space-around;
  align-items: center;
}
</style>

<script>
import { defineComponent, ref } from "vue";
import { useQuasar } from "quasar";

export default defineComponent({
  name: "PageIndex",
  mounted() {},
  setup() {
    const $q = useQuasar();

    function saveLogin(data, cl) {
      $q.localStorage.set("SK", JSON.stringify(data)); // SessionKey
      if ($q.localStorage.has("SK")) cl(true);
      else cl(false);
    }

    function showLoading(msj) {
      $q.loading.show({
        message: msj,
      });
    }
    const hideLoading = () => $q.loading.hide();
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

    return {
      dbSelected: ref(null),

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
    tryLogin() {
      let data = { user: this.userName, clave: this.clave };
      this.showLoading("Cargando.. Por favor espera");
      window.ApiLogin.loadLogin(data).then((e) => {
        if (e.isError)
          this.showMessage("Error -" + e.errorMessage, "negative", "error");
        else {
          if (e.length > 0) {
            this.saveLogin(e[0], () => {
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
    dbSelected(newV, oldV) {
      window.ApiLogin.changeDatabase(newV);
    },
  },
});
</script>
