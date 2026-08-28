# Módulo de Configuración

Ruta de la app: `/Configuracion`.

Tres pestañas:

1. **Ministros y firmantes**
2. **Plantillas de documentos**
3. **Datos de la parroquia**

---

## 1. Ministros y firmantes

Componente: `src/components/ConfigUsers.vue`  
Diálogos de alta: `src/pages/Configuracion.vue` (`editedModl`)

### Tres catálogos

| Sección | Uso en la app | Alta (`editedModl`) | SPs típicos |
|---------|---------------|---------------------|-------------|
| **Celebrantes** | Ministro / Presidió en bautizos, confirmaciones, matrimonios | `4` | `BD_Ins_NewMinistroCelebrante`, `BD_Upd_MinistroCelebrante`, `BD_Invt_MinistroCelebrante` |
| **Firmantes** | Firma en documentos | `2` | `BD_Ins_NewMinistro`, `BD_Upd_MinistroFirmante`, `BD_Invt_MinistrosFirmantes` |
| **Doy fe** | Quien da fe en actas | `1` | `BD_Ins_NewDoyFe`, `BD_Upd_MinistroDoyFe`, `BD_Invt_MinistrosDoyFe` |

### Listados

- `BD_Get_Lists_Configs` → doy fe `[0]`, firmantes `[1]`, shortcuts `[2]`, variables `[3]`, (opcional) celebrantes `[4]`
- Celebrantes: helper `loadCelebranteRows` / `BD_Get_MinistrosCelebrantes` (migración)

### UX

Cards con editar / eliminar (confirmación soft-delete), botón añadir y tarjeta dashed “añadir nuevo”.

**Importante:** en sacramentos se guarda el **Nombre** del celebrante, no el Id. Si se renombra un celebrante, los registros viejos conservan el texto histórico.

---

## 2. Plantillas de documentos

- Explicación de `TemplateBautismo.docx`, `TemplateConfirmacion.docx`, `TemplateDefuncion.docx`, `TemplateMatrimonio.docx`
- Botón para abrir carpeta de plantillas en AppData
- **Atajos** (`ConfigShortCurts`): reemplazos al generar Word (`editedModl === 3`, `BD_Ins_ShortCut`, etc.)
- **Pie de página PDF** (`BD_Get_Setting_Pdf` / `BD_Upd_FooterPdf`)

Las plantillas se siembran desde el instalador la primera vez y **no se sobrescriben** en updates (personalización por parroquia).

---

## 3. Datos de la parroquia

- **Variables globales** (`ConfigVariablesGlobales`): encabezado / datos institucionales PDF
- **Exportar información**: Excel de Bautismos / Confirmaciones / Matrimonios / Defunciones
- **Esquema de base de datos**: estado de migraciones, verificar y actualizar (ver [migraciones-db.md](migraciones-db.md))

---

## Patrón técnico de CRUD en config

1. Listar con `executeSp_Ds`
2. Crear desde el diálogo padre → `executeSp_St` + refresh del hijo
3. Editar / eliminar en el componente hijo → `executeSp_St` + confirm modal
4. Mensajes de éxito/error vía notify Quasar

Payload JSON: keys = nombres de parámetros del SP (`@Nombre` → `{ Nombre: "..." }`).
