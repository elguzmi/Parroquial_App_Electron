/*
  Product SP: BD_Ins_Bautismo
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_Bautismo]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 18/04/2023
-- Description:	Procedimiento que permite realiza el ingreso de un bautismo
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_Bautismo]
@Libro varchar(5),
@Folio varchar(5),
@Numero varchar(5),
@Nombre varchar(150),
@Ministro varchar(150),
@Fecha_Bautismo varchar(80),
@Lugar_Nacimiento varchar(100),
@Fecha_Nacimiento varchar(60),
@Padres varchar(200),
@Abuelos_Paternos varchar(200),
@Abuelos_Maternos varchar(200),
@Padrinos varchar(200),
@Id_MinistroDoyFe int,
@Nota_Marginal nvarchar(max) = null,
@Id_Ministro int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;
		
		if @Nota_Marginal is null or @Nota_Marginal = '' 
			set @Nota_Marginal = 'SIN NOTAS MARGINALES HASTA LA FECHA'


		INSERT INTO Fact_Bautismos(
		Codigo_Partida
		,Libro
		,Folio
		,Numero
		,Nombre
		,Fecha_Bautismo
		,Ministro
		,Lugar_Nacimiento
		,Fecha_Nacimiento
		,Padres
		,Abuelos_Paternos
		,Abuelos_Maternos
		,Padrinos
		,Id_DoyFe
		,Nota_Marginal
		,Id_Firmante
		)
		VALUES(
			@Libro + @Folio + @Numero
			,@Libro
			,@Folio
			,@Numero
			,@Nombre
			,@Fecha_Nacimiento
			,@Ministro
			,@Lugar_Nacimiento
			,@Fecha_Nacimiento
			,@Padres
			,@Abuelos_Paternos
			,@Abuelos_Maternos
			,@Padrinos
			,iif( @Id_MinistroDoyFe = 0 , null ,@Id_MinistroDoyFe)
			,@Nota_Marginal
			,iif( @Id_Ministro = 0 , null , @Id_Ministro)
		)

		SELECT 'SE HA GUARDADO EL REGISTRO CORRECTAMENTE' 
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT 'ERROR : '+ ERROR_MESSAGE() 
	END CATCH

END
GO
