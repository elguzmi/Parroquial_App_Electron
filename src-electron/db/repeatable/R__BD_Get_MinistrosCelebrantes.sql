/*
  Product SP: BD_Get_MinistrosCelebrantes
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_MinistrosCelebrantes]    Script Date: 9/4/2026 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_MinistrosCelebrantes]
    @CodigoSacramento NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CodigoSacramento IS NOT NULL
        SET @CodigoSacramento = UPPER(LTRIM(RTRIM(@CodigoSacramento)));

    IF @CodigoSacramento = N''
        SET @CodigoSacramento = NULL;

    SELECT
        C.Id,
        C.Nombre,
        C.Orden,
        ISNULL(STUFF((
            SELECT N',' + J.CodigoSacramento
            FROM dbo.Dim_MinistrosCelebrantes_Sacramentos J
            WHERE J.Id_MinistroCelebrante = C.Id
              AND J.Activo = 1
            ORDER BY J.CodigoSacramento
            FOR XML PATH(N''), TYPE
        ).value(N'.', N'nvarchar(400)'), 1, 1, N''), N'') AS CodigosSacramento
    FROM dbo.Dim_MinistrosCelebrantes C
    WHERE C.Activo = 1
      AND (
            @CodigoSacramento IS NULL
            OR EXISTS (
                SELECT 1
                FROM dbo.Dim_MinistrosCelebrantes_Sacramentos J
                WHERE J.Id_MinistroCelebrante = C.Id
                  AND J.CodigoSacramento = @CodigoSacramento
                  AND J.Activo = 1
            )
          )
    ORDER BY C.Orden ASC, C.Nombre ASC;
END
GO
