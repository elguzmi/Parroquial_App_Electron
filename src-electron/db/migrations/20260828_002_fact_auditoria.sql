/*
  20260828_002_fact_auditoria
  Bitácora del home: tabla de hechos + catálogo de eventos + SP de inserción.

  Contrato leído por BD_Get_Dashboard [1]:
    Id, Titulo, Detalle, Fecha, Modulo, Accion, Usuario

  Electron escribe vía BD_Ins_Auditoria (nunca desde cada página Vue).
*/

IF OBJECT_ID(N'dbo.Fact_Auditoria', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Fact_Auditoria
    (
        Id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Fact_Auditoria PRIMARY KEY,
        Fecha DATETIME2 NOT NULL
            CONSTRAINT DF_Fact_Auditoria_Fecha DEFAULT (GETDATE()),
        Modulo NVARCHAR(50) NOT NULL,
        Accion NVARCHAR(50) NOT NULL,
        Titulo NVARCHAR(200) NOT NULL,
        Detalle NVARCHAR(400) NULL,
        Usuario NVARCHAR(120) NULL,
        IdRegistro INT NULL,
        Tabla NVARCHAR(128) NULL
    );

    CREATE INDEX IX_Fact_Auditoria_Fecha
        ON dbo.Fact_Auditoria (Fecha DESC, Id DESC);
END
GO

IF OBJECT_ID(N'dbo.Dim_AuditoriaAcciones', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_AuditoriaAcciones
    (
        Id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Dim_AuditoriaAcciones PRIMARY KEY,
        EventKey NVARCHAR(80) NOT NULL,
        SourceSp NVARCHAR(80) NULL,
        Accion NVARCHAR(50) NOT NULL,
        Modulo NVARCHAR(50) NOT NULL,
        Tabla NVARCHAR(128) NULL,
        TitleTemplate NVARCHAR(200) NOT NULL,
        DetailTemplate NVARCHAR(400) NULL,
        Activo BIT NOT NULL
            CONSTRAINT DF_Dim_AuditoriaAcciones_Activo DEFAULT (1),
        CONSTRAINT UQ_Dim_AuditoriaAcciones_EventKey UNIQUE (EventKey)
    );
END
GO

;WITH Seed AS (
    SELECT *
    FROM (VALUES
        -- Bautizos
        (N'BD_Ins_Bautismo',  N'BD_Ins_Bautismo',  N'CREAR',    N'Bautismos',      N'fact_bautismos',      N'Bautizo registrado: {Nombre}',            N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Upd_Bautismo',  N'BD_Upd_Bautismo',  N'EDITAR',   N'Bautismos',      N'fact_bautismos',      N'Bautizo actualizado: {Nombre}',            N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Invt_Bautismo', N'BD_Invt_Bautismo', N'ELIMINAR', N'Bautismos',      N'fact_bautismos',      N'Bautizo eliminado',                         N'Id {Id}'),
        -- Confirmaciones
        (N'BD_Ins_Confirmacion',  N'BD_Ins_Confirmacion',  N'CREAR',    N'Confirmaciones', N'fact_Confirmaciones', N'Confirmación registrada: {Nombre_Confirmado}', N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Upd_Confirmacion',  N'BD_Upd_Confirmacion',  N'EDITAR',   N'Confirmaciones', N'fact_Confirmaciones', N'Confirmación actualizada: {Nombre_Confirmado}', N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Invt_Confirmacion', N'BD_Invt_Confirmacion', N'ELIMINAR', N'Confirmaciones', N'fact_Confirmaciones', N'Confirmación eliminada',                       N'Id {Id}'),
        -- Matrimonios
        (N'BD_Ins_Matrimonio',  N'BD_Ins_Matrimonio',  N'CREAR',    N'Matrimonios', N'fact_Matrimonios', N'Matrimonio registrado: {Novio} y {Novia}',  N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Upd_Matrimonio',  N'BD_Upd_Matrimonio',  N'EDITAR',   N'Matrimonios', N'fact_Matrimonios', N'Matrimonio actualizado: {Novio} y {Novia}', N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Invt_Matrimonio', N'BD_Invt_Matrimonio', N'ELIMINAR', N'Matrimonios', N'fact_Matrimonios', N'Matrimonio eliminado',                      N'Id {Id}'),
        -- Defunciones
        (N'BD_Ins_Defuncion',  N'BD_Ins_Defuncion',  N'CREAR',    N'Defunciones', N'fact_Defunciones', N'Defunción registrada: {Nombre_Difunto}',  N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Upd_Defuncion',  N'BD_Upd_Defuncion',  N'EDITAR',   N'Defunciones', N'fact_Defunciones', N'Defunción actualizada: {Nombre_Difunto}', N'Libro {Libro} · Folio {Folio} · N° {Numero}'),
        (N'BD_Invt_Defuncion', N'BD_Invt_Defuncion', N'ELIMINAR', N'Defunciones', N'fact_Defunciones', N'Defunción eliminada',                     N'Id {Id}'),
        -- Certificados
        (N'WORD:fact_bautismos',      NULL, N'WORD', N'Bautismos',      N'fact_bautismos',      N'Certificado Word de bautizo',      N'Id {Id}'),
        (N'PDF:fact_bautismos',       NULL, N'PDF',  N'Bautismos',      N'fact_bautismos',      N'Certificado PDF de bautizo',       N'Id {Id}'),
        (N'WORD:fact_Confirmaciones', NULL, N'WORD', N'Confirmaciones', N'fact_Confirmaciones', N'Certificado Word de confirmación', N'Id {Id}'),
        (N'PDF:fact_Confirmaciones',  NULL, N'PDF',  N'Confirmaciones', N'fact_Confirmaciones', N'Certificado PDF de confirmación',  N'Id {Id}'),
        (N'WORD:fact_Matrimonios',    NULL, N'WORD', N'Matrimonios',    N'fact_Matrimonios',    N'Certificado Word de matrimonio',   N'Id {Id}'),
        (N'PDF:fact_Matrimonios',     NULL, N'PDF',  N'Matrimonios',    N'fact_Matrimonios',    N'Certificado PDF de matrimonio',    N'Id {Id}'),
        (N'WORD:fact_Defunciones',    NULL, N'WORD', N'Defunciones',    N'fact_Defunciones',    N'Certificado Word de defunción',    N'Id {Id}'),
        (N'PDF:fact_Defunciones',     NULL, N'PDF',  N'Defunciones',    N'fact_Defunciones',    N'Certificado PDF de defunción',     N'Id {Id}')
    ) AS V(EventKey, SourceSp, Accion, Modulo, Tabla, TitleTemplate, DetailTemplate)
)
INSERT INTO dbo.Dim_AuditoriaAcciones
    (EventKey, SourceSp, Accion, Modulo, Tabla, TitleTemplate, DetailTemplate, Activo)
SELECT
    S.EventKey, S.SourceSp, S.Accion, S.Modulo, S.Tabla, S.TitleTemplate, S.DetailTemplate, 1
FROM Seed S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Dim_AuditoriaAcciones T
    WHERE T.EventKey = S.EventKey
);
GO

IF OBJECT_ID(N'dbo.BD_Ins_Auditoria', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Ins_Auditoria;
GO

CREATE PROCEDURE dbo.BD_Ins_Auditoria
    @Modulo NVARCHAR(50),
    @Accion NVARCHAR(50),
    @Titulo NVARCHAR(200),
    @Detalle NVARCHAR(400) = NULL,
    @Usuario NVARCHAR(120) = NULL,
    @IdRegistro INT = NULL,
    @Tabla NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Titulo IS NULL OR LTRIM(RTRIM(@Titulo)) = N''
    BEGIN
        SELECT N'Error - El título de auditoría es obligatorio';
        RETURN;
    END

    IF @Modulo IS NULL OR LTRIM(RTRIM(@Modulo)) = N''
        SET @Modulo = N'General';

    IF @Accion IS NULL OR LTRIM(RTRIM(@Accion)) = N''
        SET @Accion = N'OTRO';

    INSERT INTO dbo.Fact_Auditoria
        (Modulo, Accion, Titulo, Detalle, Usuario, IdRegistro, Tabla)
    VALUES
        (
            LEFT(LTRIM(RTRIM(@Modulo)), 50),
            LEFT(LTRIM(RTRIM(@Accion)), 50),
            LEFT(LTRIM(RTRIM(@Titulo)), 200),
            LEFT(NULLIF(LTRIM(RTRIM(@Detalle)), N''), 400),
            LEFT(NULLIF(LTRIM(RTRIM(@Usuario)), N''), 120),
            @IdRegistro,
            LEFT(NULLIF(LTRIM(RTRIM(@Tabla)), N''), 128)
        );

    SELECT N'OK';
END
GO

IF OBJECT_ID(N'dbo.BD_Get_AuditoriaAcciones', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Get_AuditoriaAcciones;
GO

CREATE PROCEDURE dbo.BD_Get_AuditoriaAcciones
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        EventKey,
        SourceSp,
        Accion,
        Modulo,
        Tabla,
        TitleTemplate,
        DetailTemplate
    FROM dbo.Dim_AuditoriaAcciones
    WHERE Activo = 1;
END
GO
