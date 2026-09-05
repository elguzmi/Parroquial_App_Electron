/*
  Product SP: BD_Upd_MinistroCelebrante
  Repeatable migrator: CREATE OR ALTER (checksum)
  Payload: { Id, Nombre, CodigosSacramento }
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_MinistroCelebrante]    Script Date: 9/4/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_MinistroCelebrante]
    @Id INT,
    @Nombre NVARCHAR(200),
    @CodigosSacramento NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR @Id <= 0
    BEGIN
        SELECT N'Error - Id inválido';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = N''
    BEGIN
        SELECT N'Error - El nombre del ministro es obligatorio';
        RETURN;
    END

    SET @Nombre = LTRIM(RTRIM(@Nombre));

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Dim_MinistrosCelebrantes WHERE Id = @Id AND Activo = 1
    )
    BEGIN
        SELECT N'Error - El ministro celebrante no existe o está inactivo';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM dbo.Dim_MinistrosCelebrantes
        WHERE Activo = 1 AND Nombre = @Nombre AND Id <> @Id
    )
    BEGIN
        SELECT N'Error - Ya existe otro ministro celebrante con ese nombre';
        RETURN;
    END

    DECLARE @Sel TABLE (Codigo NVARCHAR(30) NOT NULL PRIMARY KEY);

    IF @CodigosSacramento IS NULL OR LTRIM(RTRIM(@CodigosSacramento)) = N''
    BEGIN
        SELECT N'Error - Seleccione al menos un sacramento';
        RETURN;
    END

    INSERT INTO @Sel (Codigo)
    SELECT DISTINCT UPPER(LTRIM(RTRIM(S.value)))
    FROM STRING_SPLIT(@CodigosSacramento, N',') S
    WHERE LTRIM(RTRIM(S.value)) <> N'';

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

    UPDATE dbo.Dim_MinistrosCelebrantes
    SET Nombre = @Nombre
    WHERE Id = @Id;

    MERGE dbo.Dim_MinistrosCelebrantes_Sacramentos AS T
    USING (
        SELECT
            @Id AS Id_MinistroCelebrante,
            S.Codigo AS CodigoSacramento,
            CASE WHEN X.Codigo IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS Activo
        FROM dbo.Dim_SacramentosCelebrantes S
        LEFT JOIN @Sel X ON X.Codigo = S.Codigo
        WHERE S.Activo = 1
    ) AS SRC
    ON T.Id_MinistroCelebrante = SRC.Id_MinistroCelebrante
       AND T.CodigoSacramento = SRC.CodigoSacramento
    WHEN MATCHED THEN
        UPDATE SET Activo = SRC.Activo
    WHEN NOT MATCHED THEN
        INSERT (Id_MinistroCelebrante, CodigoSacramento, Activo)
        VALUES (SRC.Id_MinistroCelebrante, SRC.CodigoSacramento, SRC.Activo);

    SELECT N'Ministro celebrante actualizado correctamente';
END
GO
