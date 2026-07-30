import { boot } from "quasar/wrappers";
import { Notify, Dialog } from "quasar";

export default boot(() => {
  if (typeof window === "undefined" || !window.ApiUpdate) {
    return;
  }

  let installDialogOpen = false;

  window.ApiUpdate.onStatus((payload) => {
    if (!payload || !payload.type) return;

    if (payload.type === "available") {
      const version = payload.info?.version || "";
      Notify.create({
        type: "info",
        message: version
          ? `Nueva versión ${version} disponible. Descargando...`
          : "Nueva versión disponible. Descargando...",
        timeout: 4500,
        position: "top",
      });
      return;
    }

    if (payload.type === "progress" && payload.progress?.percent != null) {
      const percent = Math.round(payload.progress.percent);
      if (percent === 0 || percent === 50 || percent >= 99) {
        Notify.create({
          type: "ongoing",
          message: `Descargando actualización: ${percent}%`,
          timeout: 2000,
          position: "top",
          group: "update-progress",
        });
      }
      return;
    }

    if (payload.type === "downloaded" && !installDialogOpen) {
      installDialogOpen = true;
      const version = payload.info?.version || "";
      Dialog.create({
        title: "Actualización lista",
        message: version
          ? `La versión ${version} se descargó correctamente. ¿Reiniciar ahora para instalarla?`
          : "La actualización se descargó correctamente. ¿Reiniciar ahora para instalarla?",
        persistent: true,
        ok: { label: "Reiniciar ahora", color: "primary" },
        cancel: { label: "Más tarde", flat: true },
      })
        .onOk(() => {
          window.ApiUpdate.install();
        })
        .onCancel(() => {
          installDialogOpen = false;
          Notify.create({
            type: "info",
            message:
              "La actualización se instalará al cerrar la aplicación.",
            timeout: 5000,
            position: "top",
          });
        });
      return;
    }

    if (payload.type === "error") {
      Notify.create({
        type: "negative",
        message: `Error al buscar actualizaciones: ${
          payload.message || "desconocido"
        }`,
        timeout: 7000,
        position: "top",
      });
    }
  });
});
