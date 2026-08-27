# Parroquia App

Software de escritorio para gestión sacramental parroquial, desarrollado por **Kapritecnology**.

Cada parroquia tiene su propia instalación (Electron) conectada a un **SQL Server local**. La app se actualiza por releases; el esquema de base de datos se versiona con migraciones automáticas.

| Dato | Valor |
|------|--------|
| Producto | Parroquia App |
| Stack | Quasar 2 · Vue 3 · Electron · SQL Server |
| Versión actual | Ver `package.json` |
| Repositorio | [Parroquial_App_Electron](https://github.com/elguzmi/Parroquial_App_Electron) |

---

## Documentación

La documentación vive en Markdown dentro del repo (se versiona con el código). Se puede abrir en el IDE, GitHub o exportar a Word/PDF si hace falta entregar a una parroquia.

| Documento | Para quién | Contenido |
|-----------|------------|-----------|
| [docs/README.md](docs/README.md) | Todos | Índice de la documentación |
| [docs/arquitectura.md](docs/arquitectura.md) | Desarrollo / soporte | Cómo está armada la app |
| [docs/migraciones-db.md](docs/migraciones-db.md) | Desarrollo | Versionamiento de esquema SQL |
| [docs/configuracion.md](docs/configuracion.md) | Desarrollo / admin | Módulo Configuración y catálogos |
| [docs/despliegue-y-release.md](docs/despliegue-y-release.md) | Desarrollo | Build, update y alta de parroquia |
| [docs/manual-operativo.md](docs/manual-operativo.md) | Parroquia / soporte | Guía usable (apto para Word) |

---

## Requisitos

- Node.js ≥ 12.22 (recomendado LTS actual del equipo)
- npm ≥ 6
- Quasar CLI (`@quasar/cli`)
- SQL Server / SQL Server Express accesible en red local
- Windows (instalación de producción típica)

---

## Desarrollo

```bash
npm install
npm run dev
```

Equivale a `quasar dev -m electron`.

### Otros comandos

```bash
npm run lint
npm run format
npm run build      # quasar build -m electron
npm run release    # build + publicación (electron-updater / GitHub Releases)
```

---

## Configuración en runtime

Tras el primer arranque, la parroquia se configura con el wizard (`/setup/database` → `/setup/parroquia`).

Los datos quedan en:

`%APPDATA%/parroquia_app/config.json`

Plantillas Word (no se sobrescriben en updates):

`%APPDATA%/parroquia_app/templates/`

Ver ejemplo: [`src-electron/config.example.json`](src-electron/config.example.json).

---

## Módulos principales

- **Login** y setup multi-parroquia
- **Dashboard** (Inicio)
- **Bautismos**, **Confirmaciones**, **Matrimonios**, **Defunciones**
- **Configuración**: ministros (celebrantes, firmantes, doy fe), plantillas, variables, exportación, esquema DB
- **Acerca de**: versión de app y estado de esquema

---

## Soporte Kapritecnology

Contacto institucional (también visible en la app): Kapritecnology — Kamilo Prieto.

Para dudas de esquema SQL en una instalación: **Configuración → Datos de la parroquia → Esquema de base de datos**, o **Acerca de → Esquema DB**.
