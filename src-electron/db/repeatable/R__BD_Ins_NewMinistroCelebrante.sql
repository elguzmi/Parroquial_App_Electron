/*
  Product SP: BD_Ins_NewMinistroCelebrante
  Repeatable migrator: CREATE OR ALTER (checksum)
  Payload: { Nombre, CodigosSacramento }  -- CSV; NULL = todos los del catálogo
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_NewMinistroCelebrante]    Script Date: 9/4/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_NewMinistroCelebrante]
    @Nombre NVARCHAR(200),
    @CodigosSacramento NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = N''
    BEGIN
        SELECT N'Error - El nombre del ministro es obligatorio';
        RETURN;
    END

    SET @Nombre = LTRIM(RTRIM(@Nombre));

    IF EXISTS (
        SELECT 1
        FROM dbo.Dim_MinistrosCelebrantes
        WHERE Activo = 1 AND Nombre = @Nombre
    )
    BEGIN
        SELECT N'Error - Ya existe un ministro celebrante con ese nombre';
        RETURN;
    END

    DECLARE @Sel TABLE (Codigo NVARCHAR(30) NOT NULL PRIMARY KEY);

    IF @CodigosSacramento IS NULL OR LTRIM(RTRIM(@CodigosSacramento)) = N''
    BEGIN
        INSERT INTO @Sel (Codigo)
        SELECT Codigo
        FROM dbo.Dim_SacramentosCelebrantes
        WHERE Activo = 1;
    END
    ELSE
    BEGIN
        INSERT INTO @Sel (Codigo)
        SELECT DISTINCT UPPER(LTRIM(RTRIM(S.value)))
        FROM STRING_SPLIT(@CodigosSacramento, N',') S
        WHERE LTRIM(RTRIM(S.value)) <> N'';
    END

    IF NOT EXISTS (SELECT 1 FROM @Sel)
    BEGIN
        SELECT N'Error - Seleccione al menos un sacramento';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM @Sel X
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.Dim_SacramentosCelebrantes D
            WHERE D.Codigo = X.Codigo AND D.Activo = 1
        )
    )
    BEGIN
        SELECT N'Error - Hay un sacramento no válido en la selección';
        RETURN;
    END

    DECLARE @Orden INT =
        ISNULL((SELECT MAX(Orden) FROM dbo.Dim_MinistrosCelebrantes), 0) + 1;

    INSERT INTO dbo.Dim_MinistrosCelebrantes (Nombre, Activo, Orden)
    VALUES (@Nombre, 1, @Orden);

    DECLARE @Id INT = SCOPE_IDENTITY();

    INSERT INTO dbo.Dim_MinistrosCelebrantes_Sacramentos
        (Id_MinistroCelebrante, CodigoSacramento, Activo)
    SELECT
        @Id,
        S.Codigo,
        CASE WHEN X.Codigo IS NULL THEN 0 ELSE 1 END
    FROM dbo.Dim_SacramentosCelebrantes S
    LEFT JOIN @Sel X ON X.Codigo = S.Codigo
    WHERE S.Activo = 1;

    SELECT N'Ministro celebrante creado correctamente';
END
GO
