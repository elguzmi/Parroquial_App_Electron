/*
  Product SP: BD_Upd_Matrimonio
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Upd_Matrimonio]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 30/04/2023
-- Description:	Procedimiento que permite realiza la actualizacion de un Matrimonio con el ID
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Upd_Matrimonio]
 @Id int
,@Libro varchar(5)
,@Folio varchar(5)
,@Numero varchar(5)
,@Fecha_Matrimonio varchar(80)
,@Presencio varchar(150)
,@Novio varchar(150)
,@Padres_Novio varchar(200)
,@Parroquia_Novio varchar(100)
,@Fecha_Bautismo_Novio varchar(80)
,@Lib_Novio varchar(5)
,@Fol_Novio varchar(5)
,@Acta_Novio varchar(5)
,@Novia varchar(150)
,@Padres_Novia varchar(200)
,@Parroquia_Novia varchar(150)
,@Fecha_Bautismo_Novia varchar(80)
,@Lib_Novia varchar(5)
,@Fol_Novia varchar(5)
,@Acta_Novia varchar(5)
,@Testigos varchar(200)
,@Id_MinistroDoyFe  int 
,@Nota_Marginal varchar(max)
,@Id_Ministro int 
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION T1
		SET NOCOUNT ON;

		if @Nota_Marginal is null or @Nota_Marginal = '' set @Nota_Marginal = 'SIN NOTAS MARGINALES HASTA LA FECHA'

		UPDATE A
			SET Codigo_Partida = @Libro + @Folio + @Numero
			,Libro = @Libro 
			,Folio = @Folio 
			,Numero = @Numero
			,Fecha_Matrimonio = @Fecha_Matrimonio
			,Presencio = @Presencio
			,Novio = @Novio
			,Padres_Novio = @Padres_Novio
			,Parroquia_Novio = @Parroquia_Novio
			,Fecha_Bautismo_Novio = @Fecha_Bautismo_Novio
			,Lib_Novio = @Lib_Novio
			,Fol_Novio = @Fol_Novio
			,Acta_Novio = @Acta_Novio
			,Novia = @Novia
			,Padres_Novia = @Padres_Novia
			,Parroquia_Novia = @Parroquia_Novia
			,Fecha_Bautismo_Novia = @Fecha_Bautismo_Novia
			,Lib_Novia = @Lib_Novia
			,Fol_Novia = @Fol_Novia
			,Acta_Novia = @Acta_Novia
			,Testigos = @Testigos
			,Id_DoyFe = @Id_MinistroDoyFe
			,Nota_Marginal = @Nota_Marginal
			,Id_Firmante = @Id_Ministro
		FROM Fact_Matrimonios A
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
