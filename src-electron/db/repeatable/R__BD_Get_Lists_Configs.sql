/*
  Product SP: BD_Get_Lists_Configs
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Lists_Configs]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 19/05/2023
-- Description:	Procedimiento que permite conseguir la lista de configuraciones
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Lists_Configs]
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		select 
		Id_MinistroDoyFe as Id
		,Nombre_DoyFe 
		from Dim_Ministros_DoyFe
		WHERE Is_Active = 1
	
		select 
		Id_Ministro as Id
		,Nombre_Firmante
		,Cargo
		,isCurrent
		from Dim_Ministros_Firmantes
		WHERE Is_Active = 1

		select 
		Id_Shortcut as Id
		,Shortcut
		,Template
		from Dim_ShortCuts
		where Is_Active = 1

		select 
		Id_Variable as Id
		,Nombre
		,Valor
		from Dim_Variables_Globales
		WHERE Is_Active = 1

		  -- [4] Ministros celebrantes (Ministro / Presidió)
	  SELECT
		  Id,
		  Nombre,
		  Orden
	  FROM dbo.Dim_MinistrosCelebrantes
	  WHERE Activo = 1
	  ORDER BY Orden ASC, Nombre ASC;


	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
