/*
  Product SP: BD_Upd_User
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_User]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Santiago Guzman
-- Create date: 01/04/2023
-- Description:	Procedimiento que permite actualizar un usuario
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_User]
@Id_User int,
@UserName varchar(20),
@Clave varchar(20),
@UserType int
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		IF(len(@UserName)< 4)begin
			select 'El usuario debe al menos contener 4 caracteres'
			return
		end
		IF(len(@Clave)< 4)begin
			select 'La clave debe al menos contener 4 caracteres'
			return
		end

		IF( @UserType not in (select Id_Perfil from Dim_Perfiles))begin
			select 'Selecciona un valor adecuado al tipo de usuario'
			return
		end

		UPDATE A
		set UserName = @UserName
		,Clave = @Clave
		,Id_Perfil = @UserType
		from Dim_Usuarios A
		WHERE A.Id_User = @Id_User
		
		select 'Se ha actualizado Correctamente el Usuario'
		
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
