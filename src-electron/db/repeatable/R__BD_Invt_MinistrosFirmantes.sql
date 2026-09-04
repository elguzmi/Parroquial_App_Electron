/*
  Product SP: BD_Invt_MinistrosFirmantes
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Invt_MinistrosFirmantes]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cesar Santiago Guzman Prada
-- Create date: 21/07/2023
-- Description:	Procedimiento que permite realiza la inactivacion o actualizar el estado de un ministroi
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Invt_MinistrosFirmantes]
@Id int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		UPDATE A
		 SET Is_Active = 0
		FROM Dim_Ministros_Firmantes A 
		where Id_Ministro = @Id

		SELECT 'SE HA ELIMINADO CORRECTAMENTE EL REGISTRO'
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
