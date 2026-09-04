/*
  Product SP: BD_Get_Lists_Confirmaciones
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Lists_Confirmaciones]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 07/04/2023
-- Description:	Procedimiento que permite conseguir la lista confirmaciones general
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Lists_Confirmaciones]
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
		,Fecha_Confirmacion
		,Nombre_Confirmado
		,Lugar_Nacimiento
		,Fecha_Nacimiento
		,Nombre_Padres
		,Parroquia_Bautizo
		,Diocesis
		,Fecha_Bautismo
		,Libro_B
		,Folio_B
		,Numero_B
		,Padrinos
		,Ministro
		,b.Id_MinistroDoyFe
		,b.Nombre_DoyFe
		,Notas_Correcciones
		,c.Id_Ministro
		,c.Nombre_Firmante
		FROM Fact_Confirmaciones A
		LEFT JOIN Dim_Ministros_DoyFe b on a.Id_DoyFe = b.Id_MinistroDoyFe
		LEFT JOIN Dim_Ministros_Firmantes c on a.Id_Firmante = c.Id_Ministro
		WHERE A.Is_Active = 1-- and  Codigo_Partida like '%188263%'
		--order by 1 desc

		select 
		Columnas
		,Columnas_Visibles
		,Columnas_Label 
		from Dim_Config_Listas 
		where Nombre_Tabla = 'Fact_Confirmaciones' 
		and Is_Active = 1

	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
