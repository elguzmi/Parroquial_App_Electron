/*
  Product SP: BD_Upd_MinistroFirmante
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_MinistroFirmante]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Santiago Guzman
-- Create date: 19/05/2023
-- Description:	Procedimiento que permite actualizar los SHORTCUTS
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_MinistroFirmante]
@Id int,
@Cargo varchar(200),
@Nombre_Firmante varchar(200)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		update a
		set 
		Nombre_Firmante = @Nombre_Firmante,
		Cargo = @Cargo
		from Dim_Ministros_Firmantes a		
		WHERE Id_Ministro = @Id

		select 'SE HA ACTUALIZADO CORRECTAMENTE EL REGISTRO'
		
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
