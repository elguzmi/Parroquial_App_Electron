/*
  Product SP: BD_Get_MinistrosCelebrantes
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_MinistrosCelebrantes]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_MinistrosCelebrantes]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Nombre,
        Orden
    FROM dbo.Dim_MinistrosCelebrantes
    WHERE Activo = 1
    ORDER BY Orden ASC, Nombre ASC;
END
GO
