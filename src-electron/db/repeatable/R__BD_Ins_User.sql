/*
  Product SP: BD_Ins_User
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_User]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Santiago Guzman
-- Create date: 01/04/2023
-- Description:	Procedimiento que permite insertar un nuevo usuario
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_User]
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

		IF( @UserType not in (select Id_Tipo from Dim_TiposUsuarios))begin
			select 'Selecciona un valor adecuado al tipo de usuario'
			return
		end

		INSERT INTO Dim_Usuarios(
		UserName
		,Clave
		,User_Type
		)
		VALUES(@UserName,@Clave,@UserType)

		select 'Se ha Creado Correctamente el Usuario'
		
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
