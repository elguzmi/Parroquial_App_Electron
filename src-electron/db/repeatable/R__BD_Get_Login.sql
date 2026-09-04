/*
  Product SP: BD_Get_Login
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Login]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cesar Santiago Guzman - Ing Desarrollo
-- Create date: 26/04/2023
-- Description:	Procedimiento que permite loguearse dentro de la aplicacion
-- =============================================
 -- [dbo].[BD_Get_Login] 'DESPACHO' ,'1480'
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Login] 
@Usuario varchar(50) ,
@Clave varchar(50) 
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		SELECT 
		Id_User
		,UserName
		,Clave
		,Id_Perfil
		,a.Is_Active
		,b.Valor as Parroquia
		FROM Dim_Usuarios a
		cross join (
			 select * from Dim_Variables_Globales where Nombre = 'Parroquia'
		)b
		WHERE UserName = @Usuario and Clave = @Clave 
		and a.Is_Active  = 1
	
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
