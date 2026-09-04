/*
  Product SP: BD_Inactivate_User
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Inactivate_User]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Santiago Guzman
-- Create date: 01/04/2023
-- Description:	Procedimiento que permite inactivar un usuario
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Inactivate_User]
@Id_User int
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		UPDATE A
		set Is_Active = 0
		from Dim_Usuarios A
		WHERE A.Id_User = @Id_User
		
		select 'Se ha eliminado Correctamente el Usuario'
		
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
