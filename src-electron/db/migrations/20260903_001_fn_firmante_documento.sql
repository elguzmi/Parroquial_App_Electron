/*
  20260903_001_fn_firmante_documento
  Resuelve el firmante de certificados Word/PDF con una sola regla:

    1) Ministro con isCurrent = 1 (prioridad)
    2) Si no hay vigente, el Id_Firmante guardado en el sacramento

  El nombre real de la columna se lee de sys.columns (isCurrent / IsCurrent)
  para no romper collation sensible a mayúsculas.
*/

IF OBJECT_ID(N'dbo.Dim_Ministros_Firmantes', N'U') IS NULL
BEGIN
    THROW 50001, N'No existe dbo.Dim_Ministros_Firmantes.', 1;
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Dim_Ministros_Firmantes', N'U')
      AND LOWER(name) = N'iscurrent'
)
BEGIN
    ALTER TABLE dbo.Dim_Ministros_Firmantes
        ADD isCurrent BIT NOT NULL
            CONSTRAINT DF_Dim_Ministros_Firmantes_isCurrent DEFAULT (0);
END
GO

DECLARE @col SYSNAME = (
    SELECT TOP (1) name
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Dim_Ministros_Firmantes', N'U')
      AND LOWER(name) = N'iscurrent'
);

IF @col IS NULL
BEGIN
    THROW 50002, N'No se encontró la columna isCurrent en Dim_Ministros_Firmantes.', 1;
END

DECLARE @sql NVARCHAR(MAX) = N'
CREATE OR ALTER FUNCTION dbo.Fn_Get_Firmante_Documento
(
    @Id_Firmante INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        X.Id_Ministro,
        X.Nombre_Firmante,
        X.Cargo
    FROM
    (
        SELECT
            F.Id_Ministro,
            F.Nombre_Firmante,
            F.Cargo,
            0 AS Prioridad,
            CASE WHEN ISNULL(F.Is_Active, 1) = 1 THEN 0 ELSE 1 END AS Inactivo
        FROM dbo.Dim_Ministros_Firmantes AS F
        WHERE ISNULL(F.' + QUOTENAME(@col) + N', 0) = 1

        UNION ALL

        SELECT
            F.Id_Ministro,
            F.Nombre_Firmante,
            F.Cargo,
            1 AS Prioridad,
            CASE WHEN ISNULL(F.Is_Active, 1) = 1 THEN 0 ELSE 1 END AS Inactivo
        FROM dbo.Dim_Ministros_Firmantes AS F
        WHERE F.Id_Ministro = @Id_Firmante
    ) AS X
    ORDER BY X.Prioridad, X.Inactivo, X.Id_Ministro
);
';

EXEC sys.sp_executesql @sql;
GO
