/*
  20260730_003_sp_get_ministros_celebrantes
  Listado dedicado (automático vía migrador).
  La app lo usa como fuente confiable de celebrantes sin depender
  de alterar a mano BD_Get_Lists_Ministros / BD_Get_Lists_Configs.
*/

IF OBJECT_ID(N'dbo.BD_Get_MinistrosCelebrantes', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Get_MinistrosCelebrantes;
GO

CREATE PROCEDURE dbo.BD_Get_MinistrosCelebrantes
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
