/*
  20260730_001_dim_ministros_celebrantes
  Baseline: tabla + seed de ministros celebrantes (Ministro / Presidió).
  Idempotente: seguro si ya se ejecutó a mano en alguna parroquia.
*/

IF OBJECT_ID(N'dbo.Dim_MinistrosCelebrantes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Dim_MinistrosCelebrantes
    (
        Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Dim_MinistrosCelebrantes PRIMARY KEY,
        Nombre NVARCHAR(200) NOT NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Dim_MinistrosCelebrantes_Activo DEFAULT (1),
        Orden INT NOT NULL CONSTRAINT DF_Dim_MinistrosCelebrantes_Orden DEFAULT (0),
        Fecha_Creacion DATETIME NOT NULL CONSTRAINT DF_Dim_MinistrosCelebrantes_Fecha DEFAULT (GETDATE())
    );

    CREATE UNIQUE INDEX UX_Dim_MinistrosCelebrantes_Nombre
        ON dbo.Dim_MinistrosCelebrantes (Nombre)
        WHERE Activo = 1;
END
GO

;WITH Seed AS (
    SELECT *
    FROM (VALUES
        (N'LUIS HERNANDO RÍOS ALDANA. PBRO.', 1),
        (N'LUIS FERNANDO LEÓN ROBAYO. PBRO', 2),
        (N'CÉSAR AUGUSTO ALMONACID RUBIO. PBRO', 3),
        (N'HUMBERTO RENGIFO. PBRO.', 4),
        (N'JOSÉ CARLOS MANZANO ASCANIO. PBRO.', 5),
        (N'JOSÉ AQUILINO SABOGAL MORA. PBRO.', 6),
        (N'OMAR JAVIER OJEDA TEUTA. PBRO.', 7),
        (N'YOEL GÓMEZ RAMÍREZ. PBRO.', 8)
    ) AS V(Nombre, Orden)
)
INSERT INTO dbo.Dim_MinistrosCelebrantes (Nombre, Activo, Orden)
SELECT S.Nombre, 1, S.Orden
FROM Seed S
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Dim_MinistrosCelebrantes T
    WHERE T.Nombre = S.Nombre
);
GO
