/*
================================================================================
  CRUD Ministros Celebrantes + listado en Configuración
================================================================================
  Prerrequisito: tabla dbo.Dim_MinistrosCelebrantes (ver Dim_MinistrosCelebrantes.sql)

  FE (ConfigUsers / Configuracion):
  - Alta:   BD_Ins_NewMinistroCelebrante  { Nombre }
  - Edición: BD_Upd_MinistroCelebrante    { Id, Nombre }
  - Baja:   BD_Invt_MinistroCelebrante    { Id }   -- soft delete Activo=0

  Listados:
  - BD_Get_Lists_Ministros [2]  → selects de sacramentos (ya documentado)
  - BD_Get_Lists_Configs   [4]  → grilla de Configuración (agregar SELECT abajo)

  Los parámetros del SP deben llamarse IGUAL que las keys del JSON
  (el Electron hace request.input(ParameterN, ..., arg[ParameterN])).

  Mensaje de retorno: SELECT sin alias (NO usar AS '').
  El driver mssql lo expone como recordset[0][""] → executeSp_St.
================================================================================
*/

/*-----------------------------------------------------------------------------
  1) LISTADO — agregar al FINAL de BD_Get_Lists_Configs (result set [4])
-----------------------------------------------------------------------------*/
/*
  >>> PEGAR AL FINAL DEL CUERPO DE: dbo.BD_Get_Lists_Configs <<<

  -- [4] Ministros celebrantes (Ministro / Presidió)
  SELECT
      Id,
      Nombre,
      Orden
  FROM dbo.Dim_MinistrosCelebrantes
  WHERE Activo = 1
  ORDER BY Orden ASC, Nombre ASC;
*/

/*-----------------------------------------------------------------------------
  2) INSERT
-----------------------------------------------------------------------------*/
IF OBJECT_ID(N'dbo.BD_Ins_NewMinistroCelebrante', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Ins_NewMinistroCelebrante;
GO

CREATE PROCEDURE dbo.BD_Ins_NewMinistroCelebrante
    @Nombre NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = N''
    BEGIN
        SELECT N'Error - El nombre del ministro es obligatorio';
        RETURN;
    END

    SET @Nombre = LTRIM(RTRIM(@Nombre));

    IF EXISTS (
        SELECT 1
        FROM dbo.Dim_MinistrosCelebrantes
        WHERE Activo = 1 AND Nombre = @Nombre
    )
    BEGIN
        SELECT N'Error - Ya existe un ministro celebrante con ese nombre';
        RETURN;
    END

    DECLARE @Orden INT =
        ISNULL((SELECT MAX(Orden) FROM dbo.Dim_MinistrosCelebrantes), 0) + 1;

    INSERT INTO dbo.Dim_MinistrosCelebrantes (Nombre, Activo, Orden)
    VALUES (@Nombre, 1, @Orden);

    SELECT N'Ministro celebrante creado correctamente';
END
GO

/*-----------------------------------------------------------------------------
  3) UPDATE
-----------------------------------------------------------------------------*/
IF OBJECT_ID(N'dbo.BD_Upd_MinistroCelebrante', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Upd_MinistroCelebrante;
GO

CREATE PROCEDURE dbo.BD_Upd_MinistroCelebrante
    @Id INT,
    @Nombre NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR @Id <= 0
    BEGIN
        SELECT N'Error - Id inválido';
        RETURN;
    END

    IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = N''
    BEGIN
        SELECT N'Error - El nombre del ministro es obligatorio';
        RETURN;
    END

    SET @Nombre = LTRIM(RTRIM(@Nombre));

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Dim_MinistrosCelebrantes WHERE Id = @Id AND Activo = 1
    )
    BEGIN
        SELECT N'Error - El ministro celebrante no existe o está inactivo';
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM dbo.Dim_MinistrosCelebrantes
        WHERE Activo = 1 AND Nombre = @Nombre AND Id <> @Id
    )
    BEGIN
        SELECT N'Error - Ya existe otro ministro celebrante con ese nombre';
        RETURN;
    END

    UPDATE dbo.Dim_MinistrosCelebrantes
    SET Nombre = @Nombre
    WHERE Id = @Id;

    SELECT N'Ministro celebrante actualizado correctamente';
END
GO

/*-----------------------------------------------------------------------------
  4) SOFT DELETE (Invt)
-----------------------------------------------------------------------------*/
IF OBJECT_ID(N'dbo.BD_Invt_MinistroCelebrante', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Invt_MinistroCelebrante;
GO

CREATE PROCEDURE dbo.BD_Invt_MinistroCelebrante
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id IS NULL OR @Id <= 0
    BEGIN
        SELECT N'Error - Id inválido';
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Dim_MinistrosCelebrantes WHERE Id = @Id AND Activo = 1
    )
    BEGIN
        SELECT N'Error - El ministro celebrante no existe o ya fue eliminado';
        RETURN;
    END

    UPDATE dbo.Dim_MinistrosCelebrantes
    SET Activo = 0
    WHERE Id = @Id;

    SELECT N'Ministro celebrante eliminado correctamente';
END
GO
