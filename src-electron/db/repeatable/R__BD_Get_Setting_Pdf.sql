/*
  Product SP: BD_Get_Setting_Pdf
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Setting_Pdf]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 19/05/2023
-- Description:	Procedimiento que permite conseguir la lista de configuraciones del formato pdf
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Setting_Pdf]
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		select top 1
		Html_Footer_Docx,
		Html_Header
		from Dim_Documentos
		WHERE Is_Active = 1
	
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
