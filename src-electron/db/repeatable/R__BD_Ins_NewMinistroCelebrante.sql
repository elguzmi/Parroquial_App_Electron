/*
  Product SP: BD_Ins_NewMinistroCelebrante
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_NewMinistroCelebrante]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_NewMinistroCelebrante]
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
