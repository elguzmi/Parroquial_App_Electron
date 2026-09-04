/*
  Product SP: BD_Get_Documento
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Documento]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Cesar Santiago Guzman - Ing Desarrollo
-- Create date: 26/04/2023
-- Description:	Procedimiento que permite conseguir el HTML del documento
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Documento] 
@Id int = 884,
@Tabla varchar(50) = 'Fact_Bautismos'
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		
		
		--declare @Id varchar(5) = 19
		--declare @Tabla varchar(50) = 'Fact_Confirmaciones'
		DECLARE @Query nvarchar(max), @NombreArchivo varchar(30)

		-------- Se extrae el registro que se va a mostrar ** ----
		-- Firmante del registro (fallback). El vigente se pisa después.

		set @Query = '
			SELECT A.*, ISNULL(B.Nombre_DoyFe,'''') as DoyFe, ISNULL(C.Nombre_Firmante,'''') as Firmante, ISNULL(C.Cargo ,'''') as Cargo
			into ##Tmp_table
			FROM '+@Tabla + ' A
			LEFT JOIN Dim_Ministros_DoyFe B ON A.Id_DoyFe = B.Id_MinistroDoyFe
			LEFT JOIN Dim_Ministros_Firmantes C ON A.Id_Firmante = C.Id_Ministro
			WHERE Id = '+convert(varchar,@Id)+'
		'
		if object_id('tempdb..##Tmp_table', 'U') is not null drop table ##Tmp_table;
		if object_id('tempdb..#tmp_Record', 'U') is not null drop table #tmp_Record;
		exec sp_executesql @Query

		select * into #tmp_Record from ##Tmp_table;

		-------- Firmante vigente: isCurrent = 1, aunque Id_Firmante sea NULL ----
		DECLARE @NombreVigente varchar(200), @CargoVigente varchar(200)
		DECLARE @ColCurrent SYSNAME = (
			SELECT TOP (1) name
			FROM sys.columns
			WHERE object_id = OBJECT_ID(N'dbo.Dim_Ministros_Firmantes', N'U')
			  AND LOWER(REPLACE(name, N'_', N'')) = N'iscurrent'
			ORDER BY CASE WHEN LOWER(name) = N'iscurrent' THEN 0 ELSE 1 END
		)

		IF @ColCurrent IS NOT NULL
		BEGIN
			DECLARE @SqlVigente nvarchar(max) = N'
				SELECT TOP (1)
					@NombreOut = F.Nombre_Firmante,
					@CargoOut = F.Cargo
				FROM dbo.Dim_Ministros_Firmantes AS F
				WHERE ISNULL(F.' + QUOTENAME(@ColCurrent) + N', 0) = 1
				ORDER BY CASE WHEN ISNULL(F.Is_Active, 1) = 1 THEN 0 ELSE 1 END, F.Id_Ministro
			'
			EXEC sp_executesql @SqlVigente,
				N'@NombreOut varchar(200) OUTPUT, @CargoOut varchar(200) OUTPUT',
				@NombreOut = @NombreVigente OUTPUT,
				@CargoOut = @CargoVigente OUTPUT
		END

		IF @NombreVigente IS NOT NULL AND LTRIM(RTRIM(@NombreVigente)) <> ''
		BEGIN
			UPDATE #tmp_Record
			SET Firmante = @NombreVigente,
				Cargo = COALESCE(NULLIF(LTRIM(RTRIM(@CargoVigente)), ''), Cargo)
		END

		----------**

		-- drop table #Tmp_Doc
		SELECT 
		Id_Documento
		,Nombre
		,Html_Header
		,Html_Body
		,Html_Footer
		,Parametros
		,Tabla
		--,Html_Header_Docx
		--,Html_Body_Docx
		,Html_Footer_Docx
		,Html_Header_Docx_Node
		,Html_Body_Docx_Node
		,Html_Footer_Docx_Node
		into #Tmp_Doc
		FROM Dim_Documentos a with(nolock)
		WHERE Tabla = @Tabla
		--WHERE Tabla = 'Fact_Bautismos'

		--@Folio_B
		--@Libro_B
		--@Numero_B

		-- drop table #Tmp_Parametros
		select 
		ROW_NUMBER() over(Order BY Value ) as Pos
		,value
		INTO #Tmp_Parametros
		from string_split((Select Parametros from #Tmp_Doc),'|') 
		
		declare @i int = 1
		declare @Columna nvarchar(max) = ''
		declare @Parametros nvarchar(max) = ''
		declare @Valor nvarchar(max) = ''
		--DECLARE @Query nvarchar(max)
		--DECLARE @Query nvarchar(max)
		update #Tmp_Doc set Html_Body = replace(Html_Body,'_','')
		--update #Tmp_Doc set Html_Body_Docx = replace(Html_Body_Docx,'_','')
		update #Tmp_Doc set Html_Body_Docx_Node = replace(Html_Body_Docx_Node,'_','')



		-- se creo esta condicion porque reemplazaba los valores erroneamente
		if @Tabla = 'Fact_Confirmaciones' begin
			declare @LibroB varchar(10), @FolioB varchar(10) , @NumeroB varchar(10)
			select 
			@LibroB = Libro_B,
			@FolioB = Folio_B,
			@NumeroB = Numero_B
			from #tmp_Record 
			update #Tmp_Doc set Html_Body = REPLACE(Html_Body , '@LibroB' , isnull( @LibroB ,''))
			update #Tmp_Doc set Html_Body = REPLACE(Html_Body , '@FolioB' , isnull( @FolioB ,''))
			update #Tmp_Doc set Html_Body = REPLACE(Html_Body , '@NumeroB' , isnull( @NumeroB ,''))
			--update #Tmp_Doc set Html_Body_Docx = REPLACE(Html_Body_Docx , replace(@Columna,'_','')  , isnull(@Valor,''))
			update #Tmp_Doc set Html_Body_Docx_Node = REPLACE(Html_Body_Docx_Node , '@LibroB' , isnull( @LibroB ,''))
			update #Tmp_Doc set Html_Body_Docx_Node = REPLACE(Html_Body_Docx_Node , '@FolioB' , isnull( @FolioB ,''))
			update #Tmp_Doc set Html_Body_Docx_Node = REPLACE(Html_Body_Docx_Node , '@NumeroB' , isnull( @NumeroB ,''))
		end


		WHILE @i <= (select max(Pos) from #Tmp_Parametros)BEGIN
			set @Query = '
			SELECT @RetornoOut = value
			FROM #Tmp_Parametros A
			WHERE Pos = '+CONVERT(varchar,@i) +'
			'
			set @Parametros = '@RetornoOut VARCHAR(1000) OUTPUT'
			exec  sp_executesql @Query ,@Parametros,  @RetornoOut  = @Columna OUTPUT
			print @Columna
			--print @Query
		

			set @Query = '
			SELECT @RetornoOut2 = '+ replace(convert(varchar,@Columna),'@','')+'
			FROM #tmp_Record A'
			set @Parametros = '@RetornoOut2 VARCHAR(1000) OUTPUT'
			exec sp_executesql @Query , @Parametros, @RetornoOut2  = @Valor OUTPUT
			print @Valor
			print replace(@Columna,'_','') 

			

			update #Tmp_Doc set Html_Body = REPLACE(Html_Body , replace(@Columna,'_','')  , isnull(@Valor,''))
			--update #Tmp_Doc set Html_Body_Docx = REPLACE(Html_Body_Docx , replace(@Columna,'_','')  , isnull(@Valor,''))
			update #Tmp_Doc set Html_Body_Docx_Node = REPLACE(Html_Body_Docx_Node , replace(@Columna,'_','')  , isnull(@Valor,''))

			set @i +=1

		END

		--select replace(Html_Body,'_','')from  #Tmp_Doc

		declare @ExpedidoEn varchar(100) = (select dbo.Fn_String_ExpedidoEn())
		update  #Tmp_Doc set  Html_Body = REPLACE(Html_Body,'@ExpedidoEn', @ExpedidoEn)
		--update  #Tmp_Doc set  Html_Body_Docx = REPLACE(Html_Body_Docx,'@ExpedidoEn', @ExpedidoEn)
		update  #Tmp_Doc set  Html_Body_Docx_Node = REPLACE(Html_Body_Docx_Node,'@ExpedidoEn', @ExpedidoEn)
		
		
		declare @Fimr varchar(200)= (select isnull(Firmante,'____________________') from #tmp_Record)
		update  #Tmp_Doc 
		set  Html_Body_Docx_Node = REPLACE(Html_Body_Docx_Node,'@Linea', REPLICATE('_',len(@Fimr)+8))


		

	------------------ REEMPLAZO DEL HEADER **********_-----------------------------
	set @i = 1 
	DECLARE @Nombre varchar(200)

	SELECT
	ROW_NUMBER() over(Order BY Nombre ) as Pos
	,Nombre,Valor 
	INTO #tmp_Globals
	from Dim_Variables_Globales where Is_Active = 1

	WHILE @i <= (select max(Pos) from #tmp_Globals)begin
		set @Nombre = (select Nombre from #tmp_Globals where Pos = @i)
		set @Valor =  (select Valor from #tmp_Globals where Pos = @i)

		update  #Tmp_Doc set  Html_Header = REPLACE(Html_Header,'@'+@Nombre,@Valor)
		--update  #Tmp_Doc set  Html_Header_Docx = REPLACE(Html_Header_Docx,'@'+@Nombre,@Valor)
		update  #Tmp_Doc set  Html_Header_Docx_Node = REPLACE(Html_Header_Docx_Node,'@'+@Nombre,@Valor)

		set @i +=1
	end
		
	IF @Tabla = 'Fact_Bautismos' set @NombreArchivo = 'TemplateBautismo.docx'
	ELSE IF @Tabla = 'Fact_Confirmaciones' set @NombreArchivo = 'TemplateConfirmacion.docx'
	ELSE IF @Tabla = 'Fact_Matrimonios' set @NombreArchivo = 'TemplateMatrimonio.docx'
	ELSE IF @Tabla = 'Fact_Defunciones' set @NombreArchivo = 'TemplateDefuncion.docx'


	SELECT * FROM #Tmp_Doc
	SELECT * , @ExpedidoEn as ExpendidaEn , @NombreArchivo as Nombre_Archivo FROM #tmp_Record
			
	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
