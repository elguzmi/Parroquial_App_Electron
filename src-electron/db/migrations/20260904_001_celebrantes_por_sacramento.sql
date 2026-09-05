/*
  20260904_001_celebrantes_por_sacramento
  Catálogo de sacramentos + visibilidad de cada celebrante por módulo.
  Migración idempotente: los celebrantes actuales quedan activos en todos.
*/

IF OBJECT_ID(N'dbo.Dim_SacramentosCelebrantes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_SacramentosCelebrantes
    (
        Codigo NVARCHAR(30) NOT NULL
            CONSTRAINT PK_Dim_SacramentosCelebrantes PRIMARY KEY,
        Nombre NVARCHAR(80) NOT NULL,
        Orden INT NOT NULL
            CONSTRAINT DF_Dim_SacramentosCelebrantes_Orden DEFAULT (0),
        Activo BIT NOT NULL
            CONSTRAINT DF_Dim_SacramentosCelebrantes_Activo DEFAULT (1)
    );
END
GO

;WITH Seed AS (
    SELECT *
    FROM (VALUES
        (N'BAUTISMO', N'Bautismo', 1),
        (N'CONFIRMACION', N'Confirmación', 2),
        (N'MATRIMONIO', N'Matrimonio', 3)
    ) AS V(Codigo, Nombre, Orden)
)
INSERT INTO dbo.Dim_SacramentosCelebrantes (Codigo, Nombre, Orden, Activo)
SELECT S.Codigo, S.Nombre, S.Orden, 1
FROM Seed S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Dim_SacramentosCelebrantes T
    WHERE T.Codigo = S.Codigo
);
GO

IF OBJECT_ID(N'dbo.Dim_MinistrosCelebrantes_Sacramentos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_MinistrosCelebrantes_Sacramentos
    (
        Id_MinistroCelebrante INT NOT NULL,
        CodigoSacramento NVARCHAR(30) NOT NULL,
        Activo BIT NOT NULL
            CONSTRAINT DF_Dim_MinistrosCelebrantes_Sacramentos_Activo DEFAULT (1),
        CONSTRAINT PK_Dim_MinistrosCelebrantes_Sacramentos
            PRIMARY KEY (Id_MinistroCelebrante, CodigoSacramento),
        CONSTRAINT FK_CelebranteSacramento_Celebrante
            FOREIGN KEY (Id_MinistroCelebrante)
            REFERENCES dbo.Dim_MinistrosCelebrantes (Id),
        CONSTRAINT FK_CelebranteSacramento_Sacramento
            FOREIGN KEY (CodigoSacramento)
            REFERENCES dbo.Dim_SacramentosCelebrantes (Codigo)
    );

    CREATE INDEX IX_CelebranteSacramento_Codigo
        ON dbo.Dim_MinistrosCelebrantes_Sacramentos (CodigoSacramento, Activo)
        INCLUDE (Id_MinistroCelebrante);
END
GO

INSERT INTO dbo.Dim_MinistrosCelebrantes_Sacramentos
    (Id_MinistroCelebrante, CodigoSacramento, Activo)
SELECT
    C.Id,
    S.Codigo,
    1
FROM dbo.Dim_MinistrosCelebrantes C
CROSS JOIN dbo.Dim_SacramentosCelebrantes S
WHERE S.Activo = 1
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.Dim_MinistrosCelebrantes_Sacramentos J
      WHERE J.Id_MinistroCelebrante = C.Id
        AND J.CodigoSacramento = S.Codigo
  );
GO
