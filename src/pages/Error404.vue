<template>
  <div class="err404">
    <div class="err404__panel">
      <p class="err404__code" aria-hidden="true">404</p>
      <h1 class="err404__title">Página no encontrada</h1>
      <p class="err404__copy">
        La ruta solicitada no existe o ya no está disponible.
      </p>
      <q-btn
        class="err404__btn"
        unelevated
        no-caps
        label="Volver al inicio"
        to="/"
      />
    </div>
  </div>
</template>

<script>
import { defineComponent } from "vue";

export default defineComponent({
  name: "Error404",
});
</script>

<style lang="scss" scoped>
.err404 {
  --err-navy: #0b2431;
  --err-navy-mid: #16303c;
  --err-muted: #5b7380;
  --err-fog: #f3f5f7;
  --err-gold: #c9a227;

  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 2rem 1.25rem;
  font-family: "Outfit", sans-serif;
  color: var(--err-navy-mid);
  background:
    radial-gradient(
      ellipse 80% 60% at 50% -10%,
      rgba(201, 162, 39, 0.14),
      transparent 55%
    ),
    var(--err-fog);
}

.err404__panel {
  width: min(420px, 100%);
  text-align: center;
}

.err404__code {
  margin: 0;
  font-family: "Fraunces", serif;
  font-size: clamp(4.5rem, 18vw, 7rem);
  font-weight: 700;
  line-height: 0.9;
  letter-spacing: -0.04em;
  color: var(--err-navy);
  opacity: 0.92;
}

.err404__title {
  margin: 1rem 0 0.45rem;
  font-family: "Fraunces", serif;
  font-size: 1.45rem;
  font-weight: 650;
  color: var(--err-navy);
}

.err404__copy {
  margin: 0 0 1.5rem;
  font-size: 0.95rem;
  line-height: 1.5;
  color: var(--err-muted);
}

.err404__btn {
  min-height: 42px;
  padding: 0 1.25rem;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.9rem;
  background: var(--err-navy) !important;
  color: #fff !important;
}
</style>
