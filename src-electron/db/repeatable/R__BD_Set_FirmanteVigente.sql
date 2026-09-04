/*
  Product SP: BD_Set_FirmanteVigente
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Marca un firmante como vigente (isCurrent = 1) y deja los demás en 0.
CREATE OR ALTER PROCEDURE [dbo].[BD_Set_FirmanteVigente]
@Id int
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		IF NOT EXISTS (
			SELECT 1
			FROM dbo.Dim_Ministros_Firmantes
			WHERE Id_Ministro = @Id
			  AND Is_Active = 1
		)
		BEGIN
			SELECT N'Error - El firmante no existe o está inactivo'
			RETURN
		END

		UPDATE dbo.Dim_Ministros_Firmantes
		SET isCurrent = CASE WHEN Id_Ministro = @Id THEN 1 ELSE 0 END

		SELECT N'SE HA MARCADO EL FIRMANTE VIGENTE PARA LOS CERTIFICADOS'
	END TRY
	BEGIN CATCH
		SELECT N'ERROR : ' + ERROR_MESSAGE()
	END CATCH
END
GO
