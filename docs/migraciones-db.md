# Migraciones de base de datos

## Problema que resuelve

La app se actualiza sola (`electron-updater`), pero cada parroquia tiene SQL local. Sin migraciones, un cambio de tabla/SP habría que correrlo a mano en cada iglesia.

## Cómo funciona (idea simple)

Hay **dos** tipos de script. Ambos se registran en `dbo.__DbMigrations`.

### Incrementales (tablas, seeds, un solo disparo)

1. Carpeta: `src-electron/db/migrations/`
2. Nombre: `YYYYMMDD_NNN_descripcion.sql`
3. Al conectar, lo que **no** esté en `__DbMigrations` se ejecuta en orden y se registra
4. **Nunca editar** un archivo ya publicado: si hace falta un cambio, archivo nuevo

### Repetibles (procedimientos del producto)

1. Carpeta: `src-electron/db/repeatable/`
2. Nombre: `R__NombreExactoDelSp.sql` (un archivo por SP, cuerpo completo)
3. Si el `MigrationId` no existe **o** el SHA-256 del archivo cambió, se ejecuta de nuevo (`CREATE OR ALTER`) y se actualiza checksum / `AppliedAt`
4. Así un release puede actualizar el mismo SP en todas las parroquias sin entrar a SSMS

**No se usa `AppVersion` para decidir.** `AppVersion` solo es auditoría (“qué versión de app aplicó este script”).

Orden al aplicar: primero incrementales, después repetibles.

Cómo extraer los SP actuales: `sql/extract_product_procedures.sql` y `src-electron/db/repeatable/README.md`.

## Tabla de control

La crea automáticamente el migrator (`ensureMigrationsTable` en `dbMigrator.js`):

| Columna | Uso |
|---------|-----|
| `MigrationId` | Id único = nombre del archivo sin `.sql` |
| `Description` | Texto legible derivado del nombre |
| `AppVersion` | Versión de la app al aplicar |
| `Checksum` | Hash SHA-256 del script |
| `AppliedAt` | Fecha/hora UTC de aplicación |

## Archivos actuales (baseline)

| Archivo | Qué hace |
|---------|----------|
| `20260730_001_dim_ministros_celebrantes.sql` | Tabla + seed de celebrantes |
| `20260730_002_sp_crud_ministros_celebrantes.sql` | Alta / edición / baja lógica |
| `20260730_003_sp_get_ministros_celebrantes.sql` | Listado `BD_Get_MinistrosCelebrantes` |
| `20260828_001_sp_get_dashboard.sql` | Catálogo KPI + `BD_Get_Dashboard` (totales + auditoría) |
| `20260828_002_fact_auditoria.sql` | `Fact_Auditoria`, catálogo de eventos, `BD_Ins_Auditoria` |
| `20260828_003_dashboard_fecha_local.sql` | Hora de actividad en hora local (`MinutosAtras`) |
| `20260903_001_fn_firmante_documento.sql` | `Fn_Get_Firmante_Documento`: firmante vigente (`IsCurrent`) para Word/PDF |

Los SP de negocio (`BD_*`) están en `src-electron/db/repeatable/R__*.sql` (44 archivos extraídos del dump de SSMS). No están en el dump: `BD_Get_Dashboard`, `BD_Ins_Auditoria`, `BD_Get_AuditoriaAcciones` (siguen en migraciones incrementales).

Los scripts en `sql/` son **referencia manual** (salvo el listado de extracción). El flujo que se aplica solo es:

- `src-electron/db/migrations/` — incrementales
- `src-electron/db/repeatable/` — SP de producto

## Cuándo corren

- Primera conexión SQL válida (`getConnection`)
- Tras guardar config en el setup
- En Login (`ApiDb.ensureMigrations`)
- Botón **Actualizar esquema** en Configuración

## Empaquetado

En `quasar.conf.js` → `extraResources`:

- Origen: `src-electron/db/migrations`
- Destino en instalado: `resources/db/migrations`
- Origen SP: `src-electron/db/repeatable`
- Destino SP: `resources/db/repeatable`

En desarrollo se leen desde el fuente del proyecto.

## Reglas de oro para desarrollo

1. **Nunca editar** una migración incremental ya publicada.
2. Si hay un error o falta un cambio de tabla/seed: crear un archivo **nuevo** con fecha/número siguiente.
3. Preferir scripts **idempotentes** (`IF OBJECT_ID ... IS NULL`, `IF COL_LENGTH ...`, `WHERE NOT EXISTS`).
4. Separar lotes con `GO` cuando haga falta (CREATE PROCEDURE, etc.). El migrator parte por `GO`.
5. Mensajes de SP para `executeSp_St`: `SELECT N'mensaje'` **sin** `AS ''` (SQL Server no permite alias vacío).
6. SP de producto: un `R__*.sql` con `CREATE OR ALTER` y el cuerpo **entero**. Editar ese archivo y publicar versión **sí** actualiza todas las instalaciones.

## Cómo agregar un cambio nuevo (ejemplo)

Necesitas una columna `Telefono` en una tabla:

1. Crear  
   `src-electron/db/migrations/20260827_001_add_telefono_xxx.sql`
2. Contenido idempotente con `IF COL_LENGTH(...) IS NULL ALTER TABLE ...`
3. Subir versión de app en `package.json` y publicar release
4. Al abrir la app en cada parroquia, esa migración se aplica sola

Cambio de un SP ya extraído (ej. `BD_Get_Lists_Confirmaciones`):

1. Editar `src-electron/db/repeatable/R__BD_Get_Lists_Confirmaciones.sql`
2. Bump de versión + release
3. Al conectar, el migrator ve otro checksum y reaplica el SP

## UI de soporte

- **Configuración → Datos de la parroquia → Esquema de base de datos**  
  Estado, lista aplicadas/pendientes, Verificar / Actualizar
- **Acerca de → Esquema DB**  
  Resumen rápido

## Fallos

Si una migración falla a mitad:

- No se inserta el `MigrationId` (el historial solo se escribe al terminar bien el archivo)
- Los scripts deben ser idempotentes para poder reintentar con **Actualizar esquema**
- El usuario ve aviso en Login / Configuración
