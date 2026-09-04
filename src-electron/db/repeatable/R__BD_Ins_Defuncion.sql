/*
  Product SP: BD_Ins_Defuncion
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Ins_Defuncion]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 18/04/2023
-- Description:	Procedimiento que permite realiza el ingreso de un Defuncion
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Ins_Defuncion]
@Libro varchar(5)
,@Folio varchar(5)
,@Numero varchar(5)
,@Fecha_Sepelio varchar(80)
,@Nombre_Difunto varchar(150)
,@Ciudad_Origen varchar(100)
,@Edad varchar(10)
,@Padres varchar(200)
,@Estado_Civil varchar(50)
,@Ocacion_Muerte varchar(200)
,@NotaMarginal varchar(max)
,@Id_DoyFe int
,@Id_Firmante int 
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		if @NotaMarginal is null or @NotaMarginal = '' 
			set @NotaMarginal = 'SIN NOTAS MARGINALES HASTA LA FECHA'

		INSERT INTO Fact_Defunciones(
		No_Defuncion
		,Libro
		,Folio
		,Numero
		,Fecha_Sepelio
		,Nombre_Difunto
		,Ciudad_Origen
		,Edad
		,Padres
		,Estado_Civil
		,Ocacion_Muerte
		,Id_DoyFe
		,NotaMarginal
		,Id_Firmante
		)
		Values(
		@Libro + @Folio + @Numero
		,@Libro
		,@Folio
		,@Numero
		,@Fecha_Sepelio
		,@Nombre_Difunto
		,@Ciudad_Origen
		,@Edad
		,@Padres
		,@Estado_Civil
		,@Ocacion_Muerte
		,iif( @Id_DoyFe = 0 , null ,@Id_DoyFe) 
		,@NotaMarginal
		,iif( @Id_Firmante = 0 , null , @Id_Firmante)
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
