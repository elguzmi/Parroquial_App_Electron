export function printPdf(payload, timeoutMs = 25000) {
  if (!window.myAPI?.printToPdf) {
    return Promise.reject(
      new Error("La función de PDF no está disponible. Reinicie la aplicación.")
    );
  }

  return Promise.race([
    window.myAPI.printToPdf(payload),
    new Promise((_, reject) => {
      setTimeout(() => {
        reject(
          new Error(
            "La generación del PDF tardó demasiado. Cierre el aviso e intente de nuevo."
          )
        );
      }, timeoutMs);
    }),
  ]);
}
