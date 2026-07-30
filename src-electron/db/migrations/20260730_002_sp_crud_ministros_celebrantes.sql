/*
  20260730_002_sp_crud_ministros_celebrantes
  SPs de alta / edición / baja lógica para Configuración.
  Payload FE: { Nombre } | { Id, Nombre } | { Id }
*/

IF OBJECT_ID(N'dbo.BD_Ins_NewMinistroCelebrante', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Ins_NewMinistroCelebrante;
GO

CREATE PROCEDURE dbo.BD_Ins_NewMinistroCelebrante
    @Nombre NVARCHAR(200)
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

    DECLARE @Orden INT =
        ISNULL((SELECT MAX(Orden) FROM dbo.Dim_MinistrosCelebrantes), 0) + 1;

    INSERT INTO dbo.Dim_MinistrosCelebrantes (Nombre, Activo, Orden)
    VALUES (@Nombre, 1, @Orden);

    SELECT N'Ministro celebrante creado correctamente';
END
GO

IF OBJECT_ID(N'dbo.BD_Upd_MinistroCelebrante', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Upd_MinistroCelebrante;
GO

CREATE PROCEDURE dbo.BD_Upd_MinistroCelebrante
    @Id INT,
    @Nombre NVARCHAR(200)
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

    UPDATE dbo.Dim_MinistrosCelebrantes
    SET Nombre = @Nombre
    WHERE Id = @Id;

    SELECT N'Ministro celebrante actualizado correctamente';
END
GO

IF OBJECT_ID(N'dbo.BD_Invt_MinistroCelebrante', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Invt_MinistroCelebrante;
GO

CREATE PROCEDURE dbo.BD_Invt_MinistroCelebrante
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR @Id <= 0
    BEGIN
        SELECT N'Error - Id inválido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Dim_MinistrosCelebrantes WHERE Id = @Id AND Activo = 1
    )
    BEGIN
        SELECT N'Error - El ministro celebrante no existe o ya fue eliminado';
        RETURN;
    END

    UPDATE dbo.Dim_MinistrosCelebrantes
    SET Activo = 0
    WHERE Id = @Id;

    SELECT N'Ministro celebrante eliminado correctamente';
END
GO
