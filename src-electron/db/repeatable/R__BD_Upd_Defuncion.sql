/*
  Product SP: BD_Upd_Defuncion
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_Defuncion]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 30/04/2023
-- Description:	Procedimiento que permite realiza el actualizacion de una Defuncion con el ID
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_Defuncion]
@Id int
,@Libro varchar(5)
,@Folio varchar(5)
,@Numero varchar(5)
,@Fecha_Sepelio varchar(80)
,@Nombre_Difunto varchar(150)
,@Ciudad_Origen varchar(100)
,@Edad varchar(15)
,@Padres varchar(200)
,@Estado_Civil varchar(50)
,@Ocacion_Muerte varchar(200)
,@Id_DoyFe int
,@Id_Firmante int 
,@NotaMarginal varchar(max)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		if @NotaMarginal is null or @NotaMarginal = '' 
			set @NotaMarginal = 'SIN NOTAS MARGINALES HASTA LA FECHA'

		UPDATE a
		SET No_Defuncion = @Libro + @Folio + @Numero
		,Libro = @Libro
		,Folio = @Folio
		,Numero = @Numero
		,Fecha_Sepelio = @Fecha_Sepelio
		,Nombre_Difunto = @Nombre_Difunto
		,Ciudad_Origen = @Ciudad_Origen
		,Edad = @Edad
		,Padres = @Padres
		,Estado_Civil = @Estado_Civil
		,Ocacion_Muerte = @Ocacion_Muerte
		,Id_DoyFe = @Id_DoyFe
		,Id_Firmante = @Id_Firmante
		,NotaMarginal = @NotaMarginal
		FROM Fact_Defunciones a
		WHERE Id = @Id

		SELECT 'SE HA EDITADO CORRECTAMENTE EL REGISTRO'
		COMMIT TRANSACTION T1

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION T1
		SELECT 'ERROR : '+ ERROR_MESSAGE()
	END CATCH
END
GO
