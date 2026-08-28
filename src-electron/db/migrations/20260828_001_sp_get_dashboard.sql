/*
  20260828_001_sp_get_dashboard
  Home / dashboard: KPIs de totales por módulo + actividad reciente.

  Result sets de BD_Get_Dashboard:
    [0] KPIs          — un row por módulo activo en Dim_DashboardKpis
    [1] Actividad     — últimos eventos de Fact_Auditoria (vacío si aún no existe)

  Contrato futuro de auditoría (se creará en otra migración):
    dbo.Fact_Auditoria (
      Id INT, Titulo NVARCHAR, Detalle NVARCHAR, Fecha DATETIME2,
      Modulo NVARCHAR, Accion NVARCHAR, Usuario NVARCHAR
    )
*/

IF OBJECT_ID(N'dbo.Dim_DashboardKpis', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_DashboardKpis
    (
        Id INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_Dim_DashboardKpis PRIMARY KEY,
        ModuleKey NVARCHAR(50) NOT NULL,
        SourceTable NVARCHAR(128) NOT NULL,
        DateColumn NVARCHAR(128) NULL,
        Label NVARCHAR(120) NOT NULL,
        SortOrder INT NOT NULL
            CONSTRAINT DF_Dim_DashboardKpis_Sort DEFAULT (0),
        Activo BIT NOT NULL
            CONSTRAINT DF_Dim_DashboardKpis_Activo DEFAULT (1),
        CONSTRAINT UQ_Dim_DashboardKpis_ModuleKey UNIQUE (ModuleKey)
    );
END
GO

;WITH Seed AS (
    SELECT *
    FROM (VALUES
        (N'Bautismos',      N'fact_bautismos',      N'Fecha_Bautismo',      N'Total de bautizos',         10),
        (N'Confirmaciones', N'fact_Confirmaciones', N'Fecha_Confirmacion',  N'Total de confirmaciones',   20),
        (N'Matrimonios',    N'fact_Matrimonios',    N'Fecha_Matrimonio',    N'Total de matrimonios',      30),
        (N'Defunciones',    N'fact_Defunciones',    N'Fecha_Sepelio',       N'Total de defunciones',      40)
    ) AS V(ModuleKey, SourceTable, DateColumn, Label, SortOrder)
)
INSERT INTO dbo.Dim_DashboardKpis (ModuleKey, SourceTable, DateColumn, Label, SortOrder, Activo)
SELECT S.ModuleKey, S.SourceTable, S.DateColumn, S.Label, S.SortOrder, 1
FROM Seed S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Dim_DashboardKpis T
    WHERE T.ModuleKey = S.ModuleKey
);
GO

IF OBJECT_ID(N'dbo.BD_Get_Dashboard', N'P') IS NOT NULL
    DROP PROCEDURE dbo.BD_Get_Dashboard;
GO

CREATE PROCEDURE dbo.BD_Get_Dashboard
    @TopActividad INT = 8
AS
BEGIN
    SET NOCOUNT ON;

    SET @TopActividad = ISNULL(@TopActividad, 8);
    IF @TopActividad < 1 SET @TopActividad = 8;
    IF @TopActividad > 50 SET @TopActividad = 50;

    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

    CREATE TABLE #Kpis
    (
        ModuleKey NVARCHAR(50) NOT NULL,
        Label NVARCHAR(120) NOT NULL,
        TotalCount INT NOT NULL,
        MonthCount INT NOT NULL,
        SourceAvailable BIT NOT NULL,
        SortOrder INT NOT NULL
    );

    DECLARE
        @Id INT,
        @ModuleKey NVARCHAR(50),
        @SourceTable NVARCHAR(128),
        @DateColumn NVARCHAR(128),
        @Label NVARCHAR(120),
        @SortOrder INT,
        @ObjectName NVARCHAR(300),
        @Sql NVARCHAR(MAX),
        @Total INT,
        @Month INT,
        @Available BIT;

    DECLARE kpi_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT Id, ModuleKey, SourceTable, DateColumn, Label, SortOrder
        FROM dbo.Dim_DashboardKpis
        WHERE Activo = 1
        ORDER BY SortOrder ASC, Id ASC;

    OPEN kpi_cursor;
    FETCH NEXT FROM kpi_cursor INTO
        @Id, @ModuleKey, @SourceTable, @DateColumn, @Label, @SortOrder;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Total = 0;
        SET @Month = 0;
        SET @Available = 0;
        SET @Sql = NULL;
        SET @ObjectName = NULL;

        IF @SourceTable IS NOT NULL
           AND @SourceTable NOT LIKE N'%[^A-Za-z0-9_]%'
           AND OBJECT_ID(N'dbo.' + @SourceTable, N'U') IS NOT NULL
        BEGIN
            SET @Available = 1;
            SET @ObjectName = N'dbo.' + QUOTENAME(@SourceTable);

            IF @DateColumn IS NOT NULL
               AND @DateColumn NOT LIKE N'%[^A-Za-z0-9_]%'
               AND COL_LENGTH(N'dbo.' + @SourceTable, @DateColumn) IS NOT NULL
            BEGIN
                SET @Sql = N'
SELECT
    @Total = COUNT(1),
    @Month = SUM(
        CASE
            WHEN COALESCE(
                    TRY_CONVERT(date, ' + QUOTENAME(@DateColumn) + N', 103),
                    TRY_CONVERT(date, ' + QUOTENAME(@DateColumn) + N', 23),
                    TRY_CONVERT(date, ' + QUOTENAME(@DateColumn) + N')
                 ) >= @MonthStart
            THEN 1 ELSE 0
        END
    )
FROM ' + @ObjectName + N';';
            END
            ELSE
            BEGIN
                SET @Sql = N'
SELECT
    @Total = COUNT(1),
    @Month = 0
FROM ' + @ObjectName + N';';
            END

            BEGIN TRY
                EXEC sys.sp_executesql
                    @Sql,
                    N'@Total INT OUTPUT, @Month INT OUTPUT, @MonthStart DATE',
                    @Total = @Total OUTPUT,
                    @Month = @Month OUTPUT,
                    @MonthStart = @MonthStart;
            END TRY
            BEGIN CATCH
                SET @Available = 0;
                SET @Total = 0;
                SET @Month = 0;
            END CATCH
        END

        INSERT INTO #Kpis (ModuleKey, Label, TotalCount, MonthCount, SourceAvailable, SortOrder)
        VALUES (
            @ModuleKey,
            @Label,
            ISNULL(@Total, 0),
            ISNULL(@Month, 0),
            @Available,
            @SortOrder
        );

        FETCH NEXT FROM kpi_cursor INTO
            @Id, @ModuleKey, @SourceTable, @DateColumn, @Label, @SortOrder;
    END

    CLOSE kpi_cursor;
    DEALLOCATE kpi_cursor;

    SELECT
        ModuleKey,
        Label,
        TotalCount,
        MonthCount,
        SourceAvailable
    FROM #Kpis
    ORDER BY SortOrder ASC, ModuleKey ASC;

    IF OBJECT_ID(N'dbo.Fact_Auditoria', N'U') IS NOT NULL
       AND COL_LENGTH(N'dbo.Fact_Auditoria', N'Id') IS NOT NULL
       AND COL_LENGTH(N'dbo.Fact_Auditoria', N'Titulo') IS NOT NULL
       AND COL_LENGTH(N'dbo.Fact_Auditoria', N'Fecha') IS NOT NULL
    BEGIN
        BEGIN TRY
            SET @Sql = N'
SELECT TOP (@TopActividad)
    Id,
    Titulo,
    ISNULL(Detalle, N'''') AS Detalle,
    Fecha,
    ISNULL(Modulo, N'''') AS Modulo,
    ISNULL(Accion, N'''') AS Accion,
    ISNULL(Usuario, N'''') AS Usuario
FROM dbo.Fact_Auditoria
ORDER BY Fecha DESC, Id DESC;';

            EXEC sys.sp_executesql
                @Sql,
                N'@TopActividad INT',
                @TopActividad = @TopActividad;
        END TRY
        BEGIN CATCH
            SELECT
                CAST(NULL AS INT) AS Id,
                CAST(NULL AS NVARCHAR(200)) AS Titulo,
                CAST(NULL AS NVARCHAR(400)) AS Detalle,
                CAST(NULL AS DATETIME2) AS Fecha,
                CAST(NULL AS NVARCHAR(50)) AS Modulo,
                CAST(NULL AS NVARCHAR(50)) AS Accion,
                CAST(NULL AS NVARCHAR(120)) AS Usuario
            WHERE 1 = 0;
        END CATCH
    END
    ELSE
    BEGIN
        SELECT
            CAST(NULL AS INT) AS Id,
            CAST(NULL AS NVARCHAR(200)) AS Titulo,
            CAST(NULL AS NVARCHAR(400)) AS Detalle,
            CAST(NULL AS DATETIME2) AS Fecha,
            CAST(NULL AS NVARCHAR(50)) AS Modulo,
            CAST(NULL AS NVARCHAR(50)) AS Accion,
            CAST(NULL AS NVARCHAR(120)) AS Usuario
        WHERE 1 = 0;
    END

    DROP TABLE #Kpis;
END
GO
