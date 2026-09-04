/*
  Product SP: BD_Get_Lists_Parameters
  Repeatable migrator: CREATE OR ALTER (checksum)
*/
/****** Object:  StoredProcedure [dbo].[BD_Get_Lists_Parameters]    Script Date: 9/3/2026 5:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Santiago Guzman
-- Create date: 11/05/2023
-- Description:	Procedimiento que trae los parametros del procedimiento a ejecutar
-- =============================================
-- [dbo].[BD_Get_Lists_Parameters] 'BD_Ins_Bautismo'
CREATE OR ALTER PROCEDURE [dbo].[BD_Get_Lists_Parameters]
@Sp varchar(40)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;

	SELECT 
    p.name AS Parameter,        
    REPLACE(p.name,'@','') AS ParameterN,        
    t.name AS [Type],
	p.max_length
	FROM sys.procedures sp
	JOIN sys.parameters p 
		ON sp.object_id = p.object_id
	JOIN sys.types t
		ON p.system_type_id = t.system_type_id
	WHERE sp.name = @Sp 
	and t.name not in ('sysname')

	END TRY
	BEGIN CATCH
		select 'ERROR : '+ ERROR_MESSAGE()
	END CATCH

END
GO
