USE InventoryManagementDB;
GO

CREATE TABLE dbo.InventoryImportAudit
(
    AuditID BIGINT IDENTITY(1,1) PRIMARY KEY,
    StartedAt DATETIME NOT NULL DEFAULT SYSDATETIME(),
    CompletedAt DATETIME NULL,
    InsertedRows INT NOT NULL DEFAULT 0,
    ImportStatus VARCHAR(20) NOT NULL,
    ErrorMessage VARCHAR(1000) NULL,
    ImportBatchID INT NULL,

    CONSTRAINT FK_InventoryImportAudit_InventoryImportBatch
        FOREIGN KEY (ImportBatchID)
        REFERENCES dbo.InventoryImportBatch (ImportBatchID)
);
GO
