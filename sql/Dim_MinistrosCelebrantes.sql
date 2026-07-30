/*
================================================================================
  NOTA (julio 2026): estos scripts manuales quedaron como referencia.
  El flujo oficial de despliegue es el migrador de Electron:

    src-electron/db/migrations/
      20260730_001_dim_ministros_celebrantes.sql
      20260730_002_sp_crud_ministros_celebrantes.sql
      20260730_003_sp_get_ministros_celebrantes.sql

  La app aplica pendientes automáticamente al conectar.
================================================================================
*/

/*
================================================================================
  Ministros celebrantes (Presidió / Ministro) — multi-parroquia
================================================================================
  Contexto FE:
  - Bautismos.Ministro          → guarda el NOMBRE (texto)
  - Confirmaciones.Ministro     → guarda el NOMBRE (texto)
  - Matrimonios.Presencio       → guarda el NOMBRE (texto)

  Ya existía BD_Get_Lists_Ministros con 2 result sets:
  - [0] Doy Fe
  - [1] Firmantes (Id, Nombre, Cargo, isCurrent)

  Este script agrega un 3er result set:
  - [2] Celebrantes (Id, Nombre)  → se mapea a options string[] en FE

  Ejecutar en cada base de datos de parroquia.
================================================================================
*/

/*-----------------------------------------------------------------------------
  1) TABLA
-----------------------------------------------------------------------------*/
IF OBJECT_ID(N'dbo.Dim_MinistrosCelebrantes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_MinistrosCelebrantes
    (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Dim_MinistrosCelebrantes PRIMARY KEY,
        Nombre NVARCHAR(200) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Dim_MinistrosCelebrantes_Activo DEFAULT (1),
        Orden INT NOT NULL CONSTRAINT DF_Dim_MinistrosCelebrantes_Orden DEFAULT (0),
        Fecha_Creacion DATETIME NOT NULL CONSTRAINT DF_Dim_MinistrosCelebrantes_Fecha DEFAULT (GETDATE())
    );

    CREATE UNIQUE INDEX UX_Dim_MinistrosCelebrantes_Nombre
        ON dbo.Dim_MinistrosCelebrantes (Nombre)
        WHERE Activo = 1;
END
GO

/*-----------------------------------------------------------------------------
  2) DATOS INICIALES (lista que estaba quemada en la app)
-----------------------------------------------------------------------------*/
;WITH Seed AS (
    SELECT *
    FROM (VALUES
        (N'LUIS HERNANDO RÍOS ALDANA. PBRO.', 1),
        (N'LUIS FERNANDO LEÓN ROBAYO. PBRO', 2),
        (N'CÉSAR AUGUSTO ALMONACID RUBIO. PBRO', 3),
        (N'HUMBERTO RENGIFO. PBRO.', 4),
        (N'JOSÉ CARLOS MANZANO ASCANIO. PBRO.', 5),
        (N'JOSÉ AQUILINO SABOGAL MORA. PBRO.', 6),
        (N'OMAR JAVIER OJEDA TEUTA. PBRO.', 7),
        (N'YOEL GÓMEZ RAMÍREZ. PBRO.', 8)
    ) AS V(Nombre, Orden)
)
INSERT INTO dbo.Dim_MinistrosCelebrantes (Nombre, Activo, Orden)
SELECT S.Nombre, 1, S.Orden
FROM Seed S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Dim_MinistrosCelebrantes T
    WHERE T.Nombre = S.Nombre
);
GO

/*-----------------------------------------------------------------------------
  3) ADICIÓN AL SP EXISTENTE: BD_Get_Lists_Ministros
     - Mantener los SELECT actuales [0] Doy Fe y [1] Firmantes
     - Agregar al FINAL del SP el siguiente SELECT (result set [2])
-----------------------------------------------------------------------------*/

/*
  >>> PEGAR ESTO AL FINAL DEL CUERPO DE: dbo.BD_Get_Lists_Ministros <<<

  -- [2] Celebrantes / Presidió (nombre para selects Ministro / Presencio)
  SELECT
      Id,
      Nombre
  FROM dbo.Dim_MinistrosCelebrantes
  WHERE Activo = 1
  ORDER BY Orden ASC, Nombre ASC;
*/

/*-----------------------------------------------------------------------------
  4) ALTERNATIVA: recrear el SP completo (ajustar nombres reales de tablas
     Doy Fe / Firmantes si en tu DB difieren)
-----------------------------------------------------------------------------*/

/*
IMPORTANTE:
Reemplaza @TablaDoyFe y @TablaFirmantes por los nombres reales que ya usa tu SP.
Abajo dejo un ejemplo típico basado en el uso de la app (Configuración):
  - Doy Fe     → normalmente Dim_MinistrosDoyFe (o similar)
  - Firmantes  → normalmente Dim_MinistrosFirmantes (o similar)

Si ya tienes el SP, NO uses el bloque ALTER completo: solo agrega el SELECT [2].
*/

-- Ejemplo de referencia (comentado a propósito):
/*
ALTER PROCEDURE dbo.BD_Get_Lists_Ministros
AS
BEGIN
    SET NOCOUNT ON;

    -- [0] Doy Fe  (YA EXISTE — no cambiar)
    -- SELECT Id, Nombre FROM ... WHERE Activo = 1 ...

    -- [1] Firmantes (YA EXISTE — no cambiar)
    -- SELECT Id, Nombre, Cargo, isCurrent FROM ... WHERE ...

    -- [2] Celebrantes (NUEVO)
    SELECT
        Id,
        Nombre
    FROM dbo.Dim_MinistrosCelebrantes
    WHERE Activo = 1
    ORDER BY Orden ASC, Nombre ASC;
END
GO
*/

/*-----------------------------------------------------------------------------
  5) CRUD en Configuración
-----------------------------------------------------------------------------*/
-- Ver script completo: sql/CRUD_MinistrosCelebrantes.sql
--   BD_Ins_NewMinistroCelebrante  { Nombre }
--   BD_Upd_MinistroCelebrante     { Id, Nombre }
--   BD_Invt_MinistroCelebrante    { Id }
--
-- Además, agregar al FINAL de BD_Get_Lists_Configs el result set [4]:
/*
  SELECT Id, Nombre, Orden
  FROM dbo.Dim_MinistrosCelebrantes
  WHERE Activo = 1
  ORDER BY Orden ASC, Nombre ASC;
*/
