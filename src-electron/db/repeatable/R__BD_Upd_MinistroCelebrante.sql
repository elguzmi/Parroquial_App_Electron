/*
  Product SP: BD_Upd_MinistroCelebrante
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_MinistroCelebrante]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_MinistroCelebrante]
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
