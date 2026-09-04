/*
  Product SP: BD_Get_Lists_Matrimonios
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Lists_Matrimonios]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 07/04/2023
-- Description:	Procedimiento que permite conseguir la lista matrimonios general
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Lists_Matrimonios]
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON;
	
		SELECT 
		Id
		,Codigo_Partida
		,Libro
		,Folio
		,Numero
		,Fecha_Matrimonio
		,Presencio
		,Novio
		,Padres_Novio
		,Parroquia_Novio
		,Fecha_Bautismo_Novio
		,Lib_Novio
		,Fol_Novio
		,Acta_Novio
		,Novia
		,Padres_Novia
		,Parroquia_Novia
		,Fecha_Bautismo_Novia
		,Lib_Novia
		,Fol_Novia
		,Acta_Novia
		,Testigos
		,c.Id_MinistroDoyFe
		,c.Nombre_DoyFe
		,Nota_Marginal
		,b.Id_Ministro
		,b.Nombre_Firmante
		FROM Fact_Matrimonios A
		LEFT JOIN Dim_Ministros_Firmantes B ON A.Id_Firmante = b.Id_Ministro
		LEFT JOIN Dim_Ministros_DoyFe C ON A.Id_DoyFe = C.Id_MinistroDoyFe
		WHERE A.Is_Active = 1
		--ORDER BY 1 DESC

		SELECT
		 Columnas
		,Columnas_Visibles
		,Columnas_Label
		FROM  Dim_Config_Listas 
		WHERE Nombre_Tabla = 'Fact_Matrimonios' AND Is_Active = 1

		--update Dim_Config_Listas 
		--set Columnas_Visibles = 'Codigo_Partida|Libro|Folio|Numero|Fecha_Matrimonio|Presencio|Novio|Padres_Novio|Parroquia_Novio|Fecha_Bautismo_Novio|Libro_Novio|Folio_Novio|Acta_Novio|Novia|Padres_Novia|Parroquia_Novia|Fecha_Bautismo_Novia|Libro_Novia|Folio_Novia|Acta_Novia|Testigos|Nombre_DoyFe|Nota_Marginal|Nombre_Firmante'
		----select * FROM  Dim_Config_Listas 
		--WHERE Nombre_Tabla = 'Fact_Matrimonios' AND Is_Active = 1

	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
