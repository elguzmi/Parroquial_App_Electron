/*
  Product SP: BD_GetData_FromTable
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_GetData_FromTable]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 27/05/2023
-- Description:	Procedimiento que permite conseguir todos los datos la correspondiente tabla para exportarlos en excel
-- =============================================
-- [dbo].[BD_GetData_FromTable] 'Matrimonios'
CREATE OR ALTER PROCEDURE [dbo].[BD_GetData_FromTable]
@Tabla varchar(20)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

		DECLARE @Query nvarchar(max) = ''
		set @Tabla = 'Fact_'+@Tabla
		--declare @Tabla varchar(50) = 'Fact_'+@tab

		declare @columnas varchar(1000)= (select replace(Columnas_Visibles,'|',',') from Dim_Config_Listas where Nombre_Tabla =  @Tabla)
		print @columnas

		set @Query = '
			SELECT '+@columnas+'
			into ##Tmp_table
			FROM '+@Tabla + ' A
			LEFT JOIN Dim_Ministros_DoyFe B ON A.Id_DoyFe = B.Id_MinistroDoyFe
			LEFT JOIN Dim_Ministros_Firmantes C ON A.Id_Firmante = C.Id_Ministro
			WHERE A.Is_Active = 1
		'
		if object_id('tempdb..##Tmp_table', 'U') is not null drop table ##Tmp_table;
		if object_id('tempdb..#tmp_Record', 'U') is not null drop table #tmp_Record;
		exec sp_executesql @Query

		select * from ##Tmp_table

	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
