# Arquitectura

## Resumen

Parroquia App es una aplicación **desktop** (Electron) con UI en **Quasar/Vue 3**. La lógica de negocio sacramental vive en **SQL Server** (stored procedures). El proceso (Electron main) conecta a la DB, ejecuta SPs, gestiona config local, plantillas Word, auto-update y **migraciones de esquema**.

```
┌─────────────────────┐     IPC      ┌──────────────────────┐
│  Vue / Quasar (UI)  │ ◄──────────► │  Electron main       │
│  pages / components │              │  mssql · migrator    │
└─────────────────────┘              │  config · templates  │
                                     └──────────┬───────────┘
                                                │
                                                ▼
                                     ┌──────────────────────┐
                                     │  SQL Server (local)  │
                                     │  1 DB por parroquia  │
                                     └──────────────────────┘
```

## Multi-parroquia

No hay un servidor central de datos. Cada instalación apunta a **su** SQL:

- Credenciales y branding en `%APPDATA%/parroquia_app/config.json`
- Wizard de setup si aún no hay config

## Capas relevantes

| Capa | Ubicación | Responsabilidad |
|------|-----------|-----------------|
| UI | `src/pages`, `src/components` | Formularios sacramentales, config, login |
| Estilos sacramentos | `src/css/sacrament.scss` | Look & feel unificado de módulos |
| Estado | `src/store` | Usuario y config pública |
| Preload / IPC | `src-electron/electron-preload.js` | `myAPI`, `ApiLogin`, `ApiSetup`, `ApiDb`, `ApiUpdate` |
| Main | `src-electron/electron-main.js` | Conexión SQL, SPs, setup, migraciones |
| Config local | `src-electron/configStore.js` | Leer/escribir `config.json` y assets |
| Plantillas | `src-electron/templateStore.js` | Seed de `Template*.docx` en AppData |
| Migraciones | `src-electron/db/migrations` | Cambios de esquema de un solo disparo |
| SP de producto | `src-electron/db/repeatable` | `R__*.sql` con `CREATE OR ALTER`; se reaplican si cambia el archivo |
| Auto-update | `src-electron/autoUpdate.js` | `electron-updater` + versión de app |

## Ejecución de procedimientos

La UI no arma SQL ad-hoc para CRUD de negocio. Usa:

| API | Uso |
|-----|-----|
| `executeSp_St` | SP que devuelve un mensaje (string, columna sin nombre) |
| `executeSp_Dt` | SP que devuelve un registro / objeto |
| `executeSp_Ds` | SP que devuelve varios result sets (arrays) |

Los parámetros del SP deben llamarse **igual** que las keys del JSON enviado. Electron lee los parámetros con `BD_Get_Lists_Parameters` y hace `request.input(...)`.

## Sacramentos y ministros

En bautizos, confirmaciones y matrimonios, el campo **Ministro / Presidió** guarda el **nombre (texto)**, no el Id. El catálogo viene de:

1. Result set `[2]` de `BD_Get_Lists_Ministros` (si existe), o
2. SP `BD_Get_MinistrosCelebrantes` (creado por migración automática)

Helper FE: `src/utils/celebrantes.js`.

## Branding / UX

Dirección visual institucional (navy/gold, Fraunces + Outfit) aplicada en login, acerca de, configuración, layout y módulos sacramentales. La idea es producto comercial multi-parroquia con la misma base de código.
