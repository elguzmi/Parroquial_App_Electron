/*
  Product SP: BD_Upd_MinistroDoyFe
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_MinistroDoyFe]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Santiago Guzman
-- Create date: 19/05/2023
-- Description:	Procedimiento que permite actualizar los SHORTCUTS
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_MinistroDoyFe]
@Id int ,
@Nombre_DoyFe varchar(200)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;


		--create table prueba (valores varchar(200))
		insert into prueba (valores) values(convert(varchar, @Id ) )
		update a
		set 
		Nombre_DoyFe = @Nombre_DoyFe
		from Dim_Ministros_DoyFe a		
		WHERE Id_MinistroDoyFe = @Id


		select 'SE HA ACTUALIZADO CORRECTAMENTE EL REGISTRO'
		
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
