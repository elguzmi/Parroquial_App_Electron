/*
  Product SP: BD_Ins_NewDoyFe
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_NewDoyFe]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 18/04/2023
-- Description:	Procedimiento que permite realiza el ingreso de un Defuncion
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_NewDoyFe]
	@Nombre_DoyFe varchar(20)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		INSERT INTO Dim_Ministros_DoyFe(Nombre_DoyFe)
		values(@Nombre_DoyFe)

		SELECT 'SE HA AGREGADO EL REGISTRO CORRECTAMENTE' 
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
