# Manual operativo — Parroquia App

Documento orientado a **administración parroquial y soporte**.  
Puede copiarse a Microsoft Word o exportarse a PDF sin cambios de fondo.

**Producto:** Parroquia App (Kapritecnology)  
**Plataforma:** Windows · escritorio  
**Datos:** Microsoft SQL Server en el equipo / red local de la parroquia

---

## 1. Qué es la aplicación

Sistema para registrar y documentar sacramentos:

- Bautismos  
- Confirmaciones  
- Matrimonios  
- Defunciones  

También permite configurar ministros, plantillas de certificados, datos de la parroquia y exportar información a Excel.

Cada parroquia tiene **su propia instalación** y **su propia base de datos**. Los datos no se mezclan entre iglesias.

---

## 2. Primer uso (instalación)

1. Instalar el programa con el instalador entregado por Kapritecnology.
2. Al abrir, si es la primera vez, aparece la configuración inicial:
   - Servidor SQL, base de datos, usuario y contraseña → **Probar conexión**
   - Nombre de la parroquia, color y logos
3. Guardar. El sistema prepara plantillas y actualiza el esquema de base de datos si hace falta.
4. Iniciar sesión con el usuario proporcionado.

La configuración queda guardada en el equipo (carpeta de datos de la aplicación). No es necesario repetir el wizard salvo reinstalación o “Reconfigurar” desde el login.

---

## 3. Pantallas principales

| Pantalla | Para qué sirve |
|----------|----------------|
| Inicio | Resumen y accesos rápidos |
| Bautismos / Confirmaciones / Matrimonios / Defunciones | Captura y consulta de registros |
| Configuración | Ministros, plantillas, datos parroquia, esquema DB |
| Acerca de | Versión del software, guía, licencia, contacto |

---

## 4. Ministros (Configuración)

En **Configuración → Ministros y firmantes** hay tres listas:

### 4.1 Ministros celebrantes

Aparecen en el campo **Ministro** o **Presidió** de bautizos, confirmaciones y matrimonios.

- Puede **añadir**, **editar** o **eliminar** (baja lógica).
- En el registro sacramental se guarda el **nombre escrito**, no un código interno.

### 4.2 Ministros firmantes

Personas autorizadas para firmar documentos (con cargo: párroco, diácono, etc.).

### 4.3 Ministros “Doy fe”

Personas que dan fe en actas y certificados.

---

## 5. Plantillas y documentos

En **Configuración → Plantillas de documentos**:

- Abrir la carpeta de plantillas Word (`TemplateBautismo.docx`, etc.).
- Editar en Word, guardar y cerrar. No cambie el nombre del archivo.
- Las plantillas personalizadas **se conservan** al actualizar el programa.
- Atajos: textos cortos que se reemplazan al generar documentos.
- Pie de página PDF: texto del pie al exportar en PDF.

---

## 6. Datos de la parroquia

- Variables usadas en encabezados / documentos.
- Exportar a Excel una tabla sacramental completa.
- **Esquema de base de datos:**
  - Indica si la base está **al día** con la versión del programa.
  - **Verificar estado:** solo consulta.
  - **Actualizar esquema:** aplica cambios pendientes (si los hay).

Si tras una actualización del programa falta una función nueva, use **Actualizar esquema** o contacte a soporte indicando lo que muestra “Última migración”.

---

## 7. Actualizaciones del programa

La aplicación puede detectar versiones nuevas y ofrecer instalarlas.

Después de actualizar:

1. Abra de nuevo el programa e inicie sesión (o espere el aviso en el login).
2. Si el esquema necesitaba cambios, se aplican solos en la mayoría de los casos.
3. Confirme en Configuración → Esquema de base de datos que el estado sea **Al día**.

---

## 8. Buenas prácticas

- No borre ni renombre archivos `Template*.docx` de la carpeta de plantillas.
- Antes de cambios grandes, conviene un respaldo de la base SQL (coordinar con quien administra el servidor).
- Al editar un celebrante ya usado en actas antiguas, los registros viejos mantienen el nombre anterior (histórico).
- No comparta la contraseña de SQL ni el archivo de configuración del equipo.

---

## 9. Problemas frecuentes

| Síntoma | Qué revisar |
|---------|-------------|
| No abre / pide configurar otra vez | Existe `config.json`; probar conexión SQL |
| Lista de celebrantes vacía | Configuración → Esquema DB → Actualizar esquema |
| Error al guardar un ministro | Nombre vacío o duplicado; mensaje en pantalla |
| Certificado con datos viejos de parroquia | Variables globales / plantilla Word |
| Versión rara en Acerca de (ej. 23.x) | En desarrollo puede confundirse; en instalado debe coincidir con el producto |

---

## 10. Contacto Kapritecnology

Soporte del producto: **Kapritecnology** (datos de contacto también en la pantalla de Login / Acerca de).

Al reportar un incidente, indique:

- Nombre de la parroquia  
- Versión del software (Acerca de)  
- Texto de “Esquema DB” / última migración  
- Captura del mensaje de error  

---

*Documento generado a partir de la documentación del repositorio. Mantener alineado con `docs/` al cambiar el producto.*
