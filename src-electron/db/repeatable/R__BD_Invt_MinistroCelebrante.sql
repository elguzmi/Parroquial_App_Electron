/*
  Product SP: BD_Invt_MinistroCelebrante
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Invt_MinistroCelebrante]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[BD_Invt_MinistroCelebrante]
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
