/*
  Product SP: BD_Upd_Confirmacion
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_Confirmacion]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 30/04/2023
-- Description:	Procedimiento que permite realiza la actualizacion de una conrfimacion con el ID
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_Confirmacion]
@Id int
,@Libro varchar(5)
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

		UPDATE A 
		SET Codigo_Partida = @Libro + @Folio + @Numero
		,libro = @Libro 
		,Folio = @Folio
		,Numero = @Numero
		,Fecha_Confirmacion = @Fecha_Confirmacion
		,Nombre_Confirmado  = @Nombre_Confirmado 
		,Lugar_Nacimiento = @Lugar_Nacimiento
		,Fecha_Nacimiento = @Fecha_Nacimiento
		,Nombre_Padres = @Nombre_Padres 
		,Parroquia_Bautizo = @Parroquia_Bautizo 
		,Diocesis = @Diocesis 
		,Fecha_Bautismo = @Fecha_Bautismo 
		,Libro_B = @Libro_B 
		,Folio_B = @Folio_B 
		,Numero_B = @Numero_B 
		,Padrinos = @Padrinos 
		,Ministro = @Ministro 
		,Id_DoyFe = @Id_MinistroDoyFe 
		,Notas_Correcciones = @Notas_Correcciones 
		,Id_Firmante = @Id_Ministro 
		FROM Fact_Confirmaciones A
		WHERE Id = @Id

		SELECT 'SE HA EDITADO CORRECTAMENTE EL REGISTRO'
		COMMIT TRANSACTION T1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
