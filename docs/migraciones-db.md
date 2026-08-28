# Migraciones de base de datos

## Problema que resuelve

La app se actualiza sola (`electron-updater`), pero cada parroquia tiene SQL local. Sin migraciones, un cambio de tabla/SP habría que correrlo a mano en cada iglesia.

## Cómo funciona (idea simple)

1. En la app hay una carpeta de scripts: `src-electron/db/migrations/`
2. Cada archivo se llama `YYYYMMDD_NNN_descripcion.sql`
3. En cada DB existe la tabla `dbo.__DbMigrations`
4. Al conectar, la app compara **nombres de archivo** vs **MigrationId** en la tabla
5. Lo que falta se ejecuta en orden y se registra

**No se usa `AppVersion` para decidir.** `AppVersion` solo es auditoría (“qué versión de app aplicó este script”).

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

Los scripts en `sql/` son **referencia manual**. El flujo oficial es solo `src-electron/db/migrations/`.

## Cuándo corren

- Primera conexión SQL válida (`getConnection`)
- Tras guardar config en el setup
- En Login (`ApiDb.ensureMigrations`)
- Botón **Actualizar esquema** en Configuración

## Empaquetado

En `quasar.conf.js` → `extraResources`:

- Origen: `src-electron/db/migrations`
- Destino en instalado: `resources/db/migrations`

En desarrollo se leen desde el fuente del proyecto.

## Reglas de oro para desarrollo

1. **Nunca editar** una migración ya publicada.
2. Si hay un error o falta un cambio: crear un archivo **nuevo** con fecha/número siguiente.
3. Preferir scripts **idempotentes** (`IF OBJECT_ID ... IS NULL`, `IF COL_LENGTH ...`, `WHERE NOT EXISTS`).
4. Separar lotes con `GO` cuando haga falta (CREATE PROCEDURE, etc.). El migrator parte por `GO`.
5. Mensajes de SP para `executeSp_St`: `SELECT N'mensaje'` **sin** `AS ''` (SQL Server no permite alias vacío).

## Cómo agregar un cambio nuevo (ejemplo)

Necesitas una columna `Telefono` en una tabla:

1. Crear  
   `src-electron/db/migrations/20260827_001_add_telefono_xxx.sql`
2. Contenido idempotente con `IF COL_LENGTH(...) IS NULL ALTER TABLE ...`
3. Subir versión de app en `package.json` y publicar release
4. Al abrir la app en cada parroquia, esa migración se aplica sola

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
