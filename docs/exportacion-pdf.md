# Exportación PDF de certificados

Este documento explica cómo se generan los certificados PDF, cómo cada parroquia los personaliza y qué cambió respecto a la implementación anterior.

## Por qué se cambió el motor

La exportación anterior usaba `jsPDF` con `doc.html()`. Ese método rasteriza el HTML (lo convierte en imagen) y tiene soporte limitado de CSS. En la práctica:

- se perdían estilos del encabezado, tablas y negritas
- el pie se convertía a texto plano (se eliminaban `<br>`, `<center>` y el resto de HTML)
- las coordenadas del pie estaban fijas (`600 / 2`), independientes del tamaño oficio
- el resultado se veía borroso al imprimir

En una aplicación Electron, el motor correcto es el de Chromium: `webContents.printToPDF()`. Es el mismo motor de “Imprimir a PDF” de Chrome: texto vectorial, CSS real y calidad de impresión profesional. No hace falta Puppeteer ni otra copia de Chromium.

## Cómo funciona ahora

```
Registro seleccionado
        │
        ▼
BD_Get_Documento          ← header, cuerpo y pie ya resueltos
        │                   (@NombreLocal, @Parroquia, datos del sacramento…)
        ▼
myAPI.printToPdf
        │
        ▼
src-electron/pdfExport.js
  1. Arma un HTML de impresión (oficio / legal)
  2. Lo carga en una ventana oculta
  3. Chromium genera el PDF
  4. Lo guarda y lo abre en el visor del sistema
```

El botón **PDF** de bautizos, confirmaciones, matrimonios y defunciones sigue igual: seleccione un registro y el certificado se abre. Ya no se usa una URL temporal del navegador; el archivo queda en el Escritorio (o en `AppData/exports` si no hay Escritorio), igual que Word.

Nombre típico: `Certificado_fact_bautismos_123.pdf`.

## Qué puede cambiar cada parroquia (sin programar)

| Pieza | Dónde se edita | Efecto |
| --- | --- | --- |
| Nombre, dirección, ciudad, correo, teléfono | Configuración → **Datos de la parroquia** → Variables del encabezado | Se insertan en el cabezal de todos los PDF |
| Pie de autenticación / curia | Configuración → **Plantillas de documentos** → Pie de página | Negrita, alineación, saltos de línea; exclusivo de PDF |
| Vista previa del diseño | Mismo panel → **Vista previa PDF** | Abre un PDF de ejemplo con el encabezado y el pie actuales |
| Cuerpo del sacramento | Plantilla HTML en base de datos (`Dim_Documentos`) | Lo resuelve `BD_Get_Documento` con los datos del registro |

Flujo recomendado para la secretaría:

1. Actualice las variables institucionales si cambió el nombre, la dirección o el teléfono.
2. Edite el pie (horario de la curia, validez, etc.) y use **Vista previa PDF**.
3. Si el diseño es correcto, pulse **Guardar pie de página**.
4. Exporte un registro real desde el listado del sacramento.

La vista previa usa el texto que está en el editor, aunque aún no lo haya guardado. Los certificados del listado usan el pie **guardado** en base de datos.

## Piezas técnicas

- `src-electron/pdfExport.js`: ensambla el HTML y llama a `printToPDF` (página oficio, márgenes por CSS `@page`).
- `src-electron/electron-main.js` / `electron-preload.js`: IPC `myAPI.printToPdf`.
- `src/components/Table_Component.vue`: botón PDF de los listados.
- `src/components/Previsualizacion.vue`: misma API si se reutiliza la previsualización.
- `src/pages/Configuracion.vue`: editor de pie, vista del encabezado y vista previa.

El HTML de encabezado y cuerpo **no se reescribe**: se respeta el que ya genera la base de datos. El motor solo añade una hoja de estilos de impresión (tipografía Arial, pie al pie de página, colores exactos al imprimir). El `line-height: 8px` que existía en algunos cabezales (ajuste para jsPDF) se normaliza para que el texto no se solape.

## Impacto

- **Funcionalidad:** se mantiene “seleccionar registro → PDF → abrir documento”.
- **Calidad:** texto nítido, tablas y estilos del HTML de cada sacramento.
- **Multiparroquia:** cada instalación sigue usando su SQL y sus variables; el pie se edita en Configuración sin tocar código.
- **Dependencias:** el PDF ya no usa `jspdf`; se genera con el motor de impresión de Chromium.
- **Riesgo bajo:** no hay migración SQL. Si `BD_Get_Documento` o `BD_Get_Setting_Pdf` fallan, el comportamiento es el mismo: se muestra el error y no se genera archivo.
- **Compatibilidad:** requiere Electron (ya es el runtime de la app). No aplica en un build web puro.

## Pruebas sugeridas

- Exportar un bautizo, una confirmación, un matrimonio y una defunción.
- Cambiar una variable del encabezado y comprobar que el PDF nuevo la refleja.
- Editar el pie, generar vista previa, guardar y exportar un registro.
- Comprobar que Word sigue abriéndose como antes.
- Verificar que el archivo PDF aparece en el Escritorio y se puede imprimir en hoja oficio.
