/*
  Product SP: BD_Get_Lists_Bautismos
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Lists_Bautismos]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 07/04/2023
-- Description:	Procedimiento que permite conseguir la lista de firmantes y ministros
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Lists_Bautismos]
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
	,Nombre
	,Fecha_Bautismo 
	,Ministro 
	,Lugar_Nacimiento 
	,Fecha_Nacimiento 
	,Padres 
	,Abuelos_Paternos 
	,Abuelos_Maternos 
	,Padrinos 
	,b.Id_MinistroDoyFe
	,b.Nombre_DoyFe  
	,Nota_Marginal 
	,c.Id_Ministro
	,c.Nombre_Firmante 
	FROM Fact_Bautismos a with(nolock)
	INNER JOIN Dim_Ministros_DoyFe b with(nolock) on a.Id_DoyFe = b.Id_MinistroDoyFe
	LEFT JOIN Dim_Ministros_Firmantes c with(nolock) on a.Id_Firmante = c.Id_Ministro
	WHERE A.Is_Active = 1 
	--order by 1 desc

	select 
	Columnas
	,Columnas_Visibles
	,Columnas_Label
	from Dim_Config_Listas with(nolock) 
	where Nombre_Tabla = 'Fact_Bautismos' 
	and Is_Active = 1
	

	--UPDATE Dim_Config_Listas
	--SET Columnas_Visibles = 'Codigo_Partida|Libro|Folio|Numero|Nombre|Fecha_Bautismo|Ministro|Lugar_Nacimiento|Fecha_Nacimiento|Nombre_Padres|Abuelos_Paternos|Abuelos_Maternos|Padrinos|Nombre_DoyFe|Nota_Marginal|Nombre_Firmante'
	--WHERE Nombre_Tabla = 'Fact_Bautismos'
	
	--SELECT * FROM Dim_Config_Listas WHERE Nombre_Tabla = 'Fact_Bautismos'


	--INSERT INTO Dim_Config_Listas(Nombre_Tabla,Columnas,Columnas_Visibles,Columnas_Label)
	--Values(
	--	'Fact_Bautismos'
	--	,'Id|Codigo_Partida|Libro|Folio|Numero|Nombre_Niño|Fecha_Bautismo|Ministro|Lugar_Nacimiento|Fecha_Nacimiento|Nombre_Padres|Abuelos_Paternos|Abuelos_Maternos|Padrinos|Id_MinistroDoyFe|Nombre_DoyFe|Nota_Marginal|Id_Ministro|Nombre_Firmante'
	--	,'Codigo_Partida|Libro|Folio|Numero|Nombre_Niño|Fecha_Bautismo|Ministro|Lugar_Nacimiento|Fecha_Nacimiento|Nombre_Padres|Abuelos_Paternos|Abuelos_Maternos|Padrinos|Nombre_DoyFe|Nota_Marginal|Nombre_Firmante'
	--	,'Id|Codigo_Partida|Libro|Folio|Numero|Nombre Niño|Fecha Bautismo|Ministro|Lugar Nacimiento|Fecha Nacimiento|Nombre Padres|Abuelos Paternos|Abuelos Maternos|Padrinos|Id_MinistroDoyFe|Nombre DoyFe|Nota Marginal|Id_Ministro|Nombre Firmante'
	--)


	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
