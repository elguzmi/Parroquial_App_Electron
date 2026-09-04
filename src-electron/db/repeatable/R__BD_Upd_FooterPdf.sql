/*
  Product SP: BD_Upd_FooterPdf
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_FooterPdf]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 19/05/2023
-- Description:	Procedimiento que permite conseguir la lista de configuraciones del formato pdf
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_FooterPdf]
@FooterDocPdf varchar(max)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		insert into log_cambios_FooterPdf(footer)
		values(@FooterDocPdf)

		UPDATE A
		SET Html_Footer_Docx = @FooterDocPdf
		FROM Dim_Documentos A
		WHERE Is_Active = 1

		SELECT 'SE HA ACTUALIZADO EXITOSAMENTE'
	
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH
END

GO
