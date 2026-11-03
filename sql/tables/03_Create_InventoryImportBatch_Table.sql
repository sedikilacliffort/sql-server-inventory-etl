USE InventoryManagementDB;
GO

CREATE TABLE dbo.InventoryImportBatch
(
    ImportBatchID INT IDENTITY(1,1) PRIMARY KEY,
    SourceFileName VARCHAR(255) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT SYSDATETIME(),
    BatchStatus VARCHAR(20) NOT NULL DEFAULT 'Received'
);
GO
