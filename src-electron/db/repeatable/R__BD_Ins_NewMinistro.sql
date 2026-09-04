/*
  Product SP: BD_Ins_NewMinistro
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_NewMinistro]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 18/04/2023
-- Description:	Procedimiento que permite realizar la insercion de un nuevo ministro y su cargo
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_NewMinistro]
	@Nombre_Ministro varchar(50),
	@Cargo varchar(30)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		INSERT INTO Dim_Ministros_Firmantes(Nombre_Firmante,Cargo)
		values(@Nombre_Ministro,@Cargo)

		SELECT 'SE HA AGREGADO EL REGISTRO CORRECTAMENTE' 
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
