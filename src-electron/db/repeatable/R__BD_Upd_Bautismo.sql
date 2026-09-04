/*
  Product SP: BD_Upd_Bautismo
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_Bautismo]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 30/04/2023
-- Description:	Procedimiento que permite realiza la actualizacion de un bautismo
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_Bautismo]
@Id int,
@Libro varchar(5),
@Folio varchar(5),
@Numero varchar(5),
@Nombre varchar(150),
@Ministro VARCHAR(80),
@Fecha_Bautismo varchar(80),
@Lugar_Nacimiento varchar(100),
@Fecha_Nacimiento varchar(60),
@Padres varchar(200),
@Abuelos_Paternos varchar(200),
@Abuelos_Maternos varchar(200),
@Padrinos varchar(200),
@Id_MinistroDoyFe int,
@Id_Ministro int,
@Nota_Marginal nvarchar(max) = null
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		if @Nota_Marginal is null or @Nota_Marginal = '' 
			set @Nota_Marginal = 'SIN NOTAS MARGINALES HASTA LA FECHA'

		UPDATE A
		 SET Codigo_Partida = @Libro + @Folio + @Numero
		,Libro = @Libro
		,Folio = @Folio
		,Numero = @Numero
		,Nombre = @Nombre
		,Fecha_Bautismo = @Fecha_Bautismo
		,Ministro = @Ministro
		,Lugar_Nacimiento = @Lugar_Nacimiento
		,Fecha_Nacimiento = @Fecha_Nacimiento
		,Padres = @Padres
		,Abuelos_Paternos = @Abuelos_Paternos
		,Abuelos_Maternos = @Abuelos_Maternos
		,Padrinos = @Padrinos
		,Id_DoyFe = @Id_MinistroDoyFe
		,Nota_Marginal = @Nota_Marginal
		,Id_Firmante = @Id_Ministro
		FROM Fact_Bautismos A 
		where Id= @Id

		SELECT 'SE HA EDITADO CORRECTAMENTE EL REGISTRO'
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
