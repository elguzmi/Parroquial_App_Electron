# Despliegue y release

## Entornos

| Entorno | Comando | Notas |
|---------|---------|--------|
| Desarrollo | `npm run dev` | Electron + hot reload; migraciones desde `src-electron/db/migrations` |
| Build local | `npm run build` | Genera instalador Electron |
| Release publicado | `npm run release` | Build + publish a GitHub Releases (`electron-updater`) |

Configuración de publish: `quasar.conf.js` → `electron.builder.publish` (repo GitHub del proyecto).

## Qué viaja en el instalador (extraResources)

- `templates/` — plantillas Word por defecto
- `db/migrations/` — scripts de esquema

UserData en el PC de la parroquia:

```
%APPDATA%/parroquia_app/
  config.json
  assets/
  templates/     ← personalizadas; no se pisan en update
  exports/
```

## Alta de una parroquia nueva

1. Instalar la app en el PC de la parroquia.
2. Tener SQL Server con la base (restore de plantilla / backup maestro del producto).
3. Abrir la app → wizard **Setup**:
   - Probar conexión SQL
   - Nombre, color, logos
4. Guardar → se escribe `config.json` y se corren migraciones pendientes.
5. Login con usuario de la DB parroquial.

No hace falta recrear todo el esquema histórico con migraciones: el baseline asume DB ya operativa; las migraciones cubren cambios **desde** celebrantes en adelante.

## Actualizar una parroquia ya instalada

1. Publicar nueva versión (bump en `package.json` + `npm run release`).
2. La app detecta update (`ApiUpdate` / `electron-updater`).
3. Tras instalar/reiniciar, al conectar SQL aplica migraciones nuevas si las hay.

Checklist de release con cambio de DB:

- [ ] Nuevo archivo en `src-electron/db/migrations/` (nombre correcto, idempotente)
- [ ] Probar en DB limpia de migraciones y en DB que ya tenía el cambio a mano
- [ ] Bump de versión app
- [ ] Build/release
- [ ] Verificar en Configuración → Esquema DB que aparece aplicada

## Credenciales y seguridad

- `config.json` contiene usuario/clave SQL en claro en AppData (modelo actual desktop local).
- No commitear `config.json` real ni contraseñas de parroquias.
- En desarrollo y producción, la conexión SQL sale del wizard (`config.example.json` es solo una plantilla).

## Soporte post-instalación

Si una feature nueva “no aparece” (ej. celebrantes vacíos):

1. Configuración → Esquema DB → ¿hay pendientes? → **Actualizar esquema**
2. Revisar consola Electron: logs `[db-migrations]`
3. En SSMS: tabla `__DbMigrations` y existencia de SPs/tablas de la migración
