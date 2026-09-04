/*
  Product SP: BD_Upd_ShortCuts
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_ShortCuts]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Santiago Guzman
-- Create date: 19/05/2023
-- Description:	Procedimiento que permite actualizar los SHORTCUTS
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_ShortCuts]
@Id int,
@Shortcut varchar(200),
@Template varchar(500)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		update a
		set Shortcut = @Shortcut,
		Template = @Template
		from Dim_ShortCuts a		
		WHERE Id_Shortcut = @Id

		select 'SE HA ACTUALIZADO CORRECTAMENTE EL REGISTRO'
		
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
