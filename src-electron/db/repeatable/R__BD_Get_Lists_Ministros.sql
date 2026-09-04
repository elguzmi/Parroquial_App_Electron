/*
  Product SP: BD_Get_Lists_Ministros
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Lists_Ministros]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 07/04/2023
-- Description:	Procedimiento que permite conseguir la lista de firmantes y ministros
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Lists_Ministros]
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		-----------**** Lista de ministros Doy Fe
		SELECT 
		'0' AS Id
		,'SIN SELECCIONAR' as Nombre
		UNION 
		SELECT
		Id_MinistroDoyFe as Id
		,Nombre_DoyFe as Nombre
		FROM Dim_Ministros_DoyFe
		WHERE Is_Active = 1

		-----------**** Lista de ministros Firmantes  
		SELECT 
		'0' AS Id
		,'SIN SELECCIONAR' as Nombre
		,'Sin Cargo' AS Cargo
		,0 as isCurrent
		UNION
		SELECT 
		Id_Ministro as Id 
		,Nombre_Firmante as Nombre
		,Cargo
		,isCurrent
		FROM Dim_Ministros_Firmantes
		WHERE Is_Active = 1

		SELECT
			Id,
			Nombre
		FROM dbo.Dim_MinistrosCelebrantes
		WHERE Activo = 1
		ORDER BY Orden ASC, Nombre ASC;

	END TRY
	BEGIN CATCH
		SELECT 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
