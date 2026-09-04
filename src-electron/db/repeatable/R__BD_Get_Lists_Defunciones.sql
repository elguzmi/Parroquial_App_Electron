/*
  Product SP: BD_Get_Lists_Defunciones
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Lists_Defunciones]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 07/04/2023
-- Description:	Procedimiento que permite conseguir la lista defunciones general
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Lists_Defunciones]
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON;
	
		SELECT 
		a.Id
		,a.No_Defuncion
		,a.Libro
		,a.Folio
		,a.Numero
		,a.Fecha_Sepelio
		,a.Nombre_Difunto
		,a.Ciudad_Origen
		,a.Edad
		,a.Padres
		,a.Estado_Civil
		,a.Ocacion_Muerte
		,b.Id_MinistroDoyFe as Id_DoyFe
		,b.Nombre_DoyFe
		,a.NotaMarginal
		,c.Id_Ministro as Id_Firmante
		,c.Nombre_Firmante
		FROM Fact_Defunciones A
		LEFT JOIN Dim_Ministros_DoyFe b on a.Id_DoyFe = b.Id_MinistroDoyFe
		LEFT JOIN Dim_Ministros_Firmantes c on a.Id_Firmante = c.Id_Ministro
		WHERE A.Is_Active = 1
		ORDER BY 1 DESC

		SELECT 
		Columnas
		,Columnas_Visibles
		,Columnas_Label
		FROM Dim_Config_Listas
		WHERE Nombre_Tabla = 'Fact_Defunciones'

	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
