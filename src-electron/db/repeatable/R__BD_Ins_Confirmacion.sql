/*
  Product SP: BD_Ins_Confirmacion
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_Confirmacion]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 18/04/2023
-- Description:	Procedimiento que permite realiza el ingreso de una confirmacion
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_Confirmacion]
 @Libro varchar(5)
,@Folio varchar(5)
,@Numero varchar(5)
,@Fecha_Confirmacion varchar(60)
,@Nombre_Confirmado varchar(200)
,@Lugar_Nacimiento varchar(60)
,@Fecha_Nacimiento varchar(80)
,@Nombre_Padres varchar(200)
,@Parroquia_Bautizo varchar(80)
,@Diocesis varchar(80)
,@Fecha_Bautismo varchar(80)
,@Libro_B varchar(5)
,@Folio_B varchar(5)
,@Numero_B varchar(5)
,@Padrinos varchar(200)
,@Ministro varchar(100)
,@Id_MinistroDoyFe int
,@Notas_Correcciones varchar(max)
,@Id_Ministro int
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		if @Notas_Correcciones is null or @Notas_Correcciones = '' 
			set @Notas_Correcciones = 'SIN NOTAS MARGINALES HASTA LA FECHA'

		INSERT INTO Fact_Confirmaciones(
			Codigo_Partida
			,libro
			,Folio
			,Numero
			,Fecha_Confirmacion
			,Nombre_Confirmado
			,Lugar_Nacimiento
			,Fecha_Nacimiento
			,Nombre_Padres
			,Parroquia_Bautizo
			,Diocesis
			,Fecha_Bautismo
			,Libro_B
			,Folio_B
			,Numero_B
			,Padrinos
			,Ministro
			,Id_DoyFe
			,Notas_Correcciones
			,Id_Firmante
		)
		Values(
			@Libro + @Folio + @Numero
			,@Libro 
			,@Folio 
			,@Numero
			,@Fecha_Confirmacion
			,@Nombre_Confirmado 
			,@Lugar_Nacimiento
			,@Fecha_Nacimiento
			,@Nombre_Padres 
			,@Parroquia_Bautizo 
			,@Diocesis 
			,@Fecha_Bautismo 
			,@Libro_B 
			,@Folio_B 
			,@Numero_B 
			,@Padrinos 
			,@Ministro 
			,iif( @Id_MinistroDoyFe = 0 , null ,@Id_MinistroDoyFe)
			,@Notas_Correcciones 
			,iif( @Id_Ministro = 0 , null , @Id_Ministro) 
		)

		SELECT 'SE HA GUARDADO EL REGISTRO CORRECTAMENTE' 
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
