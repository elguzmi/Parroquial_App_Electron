/**
 * Presets for Quasar Dialog.create / $q.dialog —
 * aligned with navy/Outfit UI (cfg-dialog, sac-btn).
 *
 * Note: DialogPlugin defaults button color to Quasar $primary (gold).
 * These presets override that so Cancel ≠ gold and OK matches the app.
 */

export const dialogBtnCancel = (label = "Cancelar") => ({
  label,
  flat: true,
  unelevated: true,
  noCaps: true,
  color: "grey-8",
  class: "app-dialog__btn app-dialog__btn--cancel",
});

export const dialogBtnDanger = (label = "Eliminar") => ({
  label,
  unelevated: true,
  noCaps: true,
  color: "negative",
  class: "app-dialog__btn app-dialog__btn--danger",
});

export const dialogBtnPrimary = (label = "Aceptar") => ({
  label,
  unelevated: true,
  noCaps: true,
  // color stays plugin-default primary → CSS remaps bg to navy
  class: "app-dialog__btn app-dialog__btn--primary",
});
