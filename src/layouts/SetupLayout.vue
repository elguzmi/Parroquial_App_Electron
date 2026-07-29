<template>
  <q-layout view="hHh Lpr lFf" class="setup-shell">
    <div class="setup-shell__glow setup-shell__glow--a" />
    <div class="setup-shell__glow setup-shell__glow--b" />

    <q-page-container>
      <q-page class="setup-frame">
        <aside class="setup-aside">
          <div>
            <div class="setup-brand">
              <span class="setup-brand__eyebrow">Sistema parroquial</span>
              <h1 class="setup-brand__title">Configuración inicial</h1>
              <p class="setup-brand__copy">
                Un solo instalador para todas las parroquias. Define la base de
                datos y la identidad visual una sola vez.
              </p>
            </div>

            <div class="setup-progress-mobile" aria-hidden="true">
              <div
                class="setup-progress-mobile__dot"
                :class="{
                  'is-active': currentStep === 1,
                  'is-done': currentStep > 1,
                }"
              />
              <div
                class="setup-progress-mobile__dot"
                :class="{ 'is-active': currentStep === 2 }"
              />
            </div>

            <nav class="setup-steps" aria-label="Progreso del asistente">
              <div
                class="setup-step"
                :class="{
                  'is-active': currentStep === 1,
                  'is-done': currentStep > 1,
                }"
              >
                <div class="setup-step__index">
                  {{ currentStep > 1 ? "✓" : "1" }}
                </div>
                <div>
                  <div class="setup-step__label">Paso 1</div>
                  <p class="setup-step__title">Base de datos</p>
                  <p class="setup-step__hint">
                    Servidor SQL Server, credenciales y prueba de conexión.
                  </p>
                </div>
              </div>

              <div
                class="setup-step"
                :class="{ 'is-active': currentStep === 2 }"
              >
                <div class="setup-step__index">2</div>
                <div>
                  <div class="setup-step__label">Paso 2</div>
                  <p class="setup-step__title">Identidad parroquial</p>
                  <p class="setup-step__hint">
                    Nombre, color institucional y assets visuales.
                  </p>
                </div>
              </div>
            </nav>
          </div>

          <div class="setup-aside__footer">Kapri Technology · Setup Wizard</div>
        </aside>

        <main class="setup-main">
          <router-view />
        </main>
      </q-page>
    </q-page-container>
  </q-layout>
</template>

<script>
import { computed, defineComponent } from "vue";
import { useRoute } from "vue-router";

export default defineComponent({
  name: "SetupLayout",
  setup() {
    const route = useRoute();
    const currentStep = computed(() => {
      if (route.path.includes("parroquia")) return 2;
      return 1;
    });

    return { currentStep };
  },
});
</script>

<style lang="scss">
@import "src/css/setup.scss";
</style>
