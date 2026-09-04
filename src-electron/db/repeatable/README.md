# Procedimientos almacenados del producto

Cada archivo `R__NombreDelSp.sql` viaja en el instalador y se aplica en **todas** las parroquias.

- Primera vez: se ejecuta y se registra en `dbo.__DbMigrations`.
- Si cambias el archivo y publicas una versión nueva: se vuelve a ejecutar porque cambió el checksum (SHA-256).
- Las migraciones `YYYYMMDD_NNN_*.sql` de `../migrations/` **no** se reeditan; los SP de producto sí se actualizan aquí.

## Cómo extraer desde SQL Server

1. En SSMS, sobre la **DB plantilla del producto**, Tasks → Generate Scripts.
2. Solo **Stored Procedures** (`BD_*` y los que use la app).
3. En cada script generado:
   - Cambia `CREATE PROCEDURE` por `CREATE OR ALTER PROCEDURE`.
   - Quita `DROP PROCEDURE` si el asistente lo añadió.
   - Deja `GO` entre lotes (el migrator lo parte).
4. Guarda aquí como `R__` + nombre exacto del objeto + `.sql`.

Ejemplos:

- `R__BD_Get_Lists_Confirmaciones.sql`
- `R__BD_Ins_Confirmacion.sql`
- `R__BD_Get_Documento.sql`

Hay un listado de ayuda en `sql/extract_product_procedures.sql`.

Para volver a partir un dump de SSMS (todos los SP en un solo `.sql`):

```
node src-electron/db/splitSsmsDump.js "C:\ruta\sps.sql"
```

Eso genera/sobrescribe `R__*.sql` aquí, quita `USE [base]`, y cambia `CREATE` por `CREATE OR ALTER`.

## Reglas

- Un archivo = un SP (cuerpo **completo**, no un parche).
- No pongas datos de parroquia ni `USE [OtraBase]`.
- No edites un SP “a mano” solo en una iglesia: el siguiente update lo pisa. El arreglo va en git y sale en el release.
