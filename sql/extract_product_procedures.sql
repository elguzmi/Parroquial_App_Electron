/*
  Listado para extraer los SP del producto desde la DB plantilla.

  1) Ejecuta este SELECT.
  2) Para cada nombre, en SSMS: Generate Scripts
     o: Script Stored Procedure as → CREATE To.
  3) Guarda el cuerpo en:
     src-electron/db/repeatable/R__<Nombre>.sql
  4) Sustituye CREATE PROCEDURE por CREATE OR ALTER PROCEDURE.
*/

SELECT
    SCHEMA_NAME(p.schema_id) AS [Schema],
    p.name AS Procedimiento,
    N'R__' + p.name + N'.sql' AS NombreArchivo,
    p.modify_date AS Modificado
FROM sys.procedures p
WHERE p.is_ms_shipped = 0
  AND p.name LIKE N'BD[_]%'
ORDER BY p.name;
