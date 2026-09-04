/*
  Product SP: BD_Get_ModulosPerfil
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_ModulosPerfil]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cesar Santiago Guzman - Ing Desarrollo
-- Create date: 26/04/2023
-- Description:	Procedimiento que permite conseguir la lista de los modulos
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_ModulosPerfil] 
@IdPerfil int 
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		SELECT 
		a.Id_Modulo
		,a.Nombre_Modulo
		,a.Modulo
		,a.Icono
		,a.Clase_Principal
		,a.Clase
		,a.Mostrar_Inicio
		,a.Descripcion
		,a.Nombre_Imagen
		FROM Dim_Modulos a
		JOIN Dim_Perfiles_Modulos b on a.Id_Modulo = b.Id_Modulo and (b.Is_Active =  1 and a.Is_Active = 1)
		and b.Id_Perfil = @IdPerfil
		order by 1 asc

	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
