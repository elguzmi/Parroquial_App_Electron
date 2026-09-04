/*
  Product SP: BD_Upd_VariablesGlobales
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_VariablesGlobales]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Santiago Guzman
-- Create date: 19/05/2023
-- Description:	Procedimiento que permite actualizar las variables globales
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_VariablesGlobales]
@Id int,
@Valor varchar(200)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		update a
		set Valor = @Valor
		from Dim_Variables_Globales a		
		WHERE Id_Variable = @Id

		select 'Se ha actualizado correctamente'
		
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
