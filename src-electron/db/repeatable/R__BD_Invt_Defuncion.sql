/*
  Product SP: BD_Invt_Defuncion
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Invt_Defuncion]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cesar Santiago Guzman Prada
-- Create date: 01/05/2023
-- Description:	Procedimiento que permite realiza la inactivacion o actualizar el estado  de una defuncion
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Invt_Defuncion]
@Id int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		UPDATE A
		 SET Is_Active = 0
		FROM Fact_Defunciones A 
		where Id = @Id

		SELECT 'SE HA ELIMINADO CORRECTAMENTE EL REGISTRO'
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
