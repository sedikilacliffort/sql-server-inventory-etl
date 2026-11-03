
USE InventoryManagementDB;
GO

CREATE TABLE dbo.InventoryBatchReconciliation
(
    ReconciliationID INT IDENTITY(1,1) PRIMARY KEY,
    ImportBatchID INT NOT NULL,
    SnapshotAt DATETIME NOT NULL DEFAULT SYSDATETIME(),
    TotalRecords INT NOT NULL DEFAULT 0,
    ValidatedRecords INT NOT NULL DEFAULT 0,
    PassedRecords INT NOT NULL DEFAULT 0,
    RejectedRecords INT NOT NULL DEFAULT 0,
    DuplicateRecords INT NOT NULL DEFAULT 0,
    ExistingInventoryRecords INT NOT NULL DEFAULT 0,
    ReadyForImportRecords INT NOT NULL DEFAULT 0,
    TotalImportAttempts INT NOT NULL DEFAULT 0,
    SuccessfulAttempts INT NOT NULL DEFAULT 0,
    FailedAttempts INT NOT NULL DEFAULT 0,
    TotalImportedRows INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_InventoryBatchReconciliation_InventoryImportBatch
        FOREIGN KEY (ImportBatchID)
        REFERENCES dbo.InventoryImportBatch (ImportBatchID)
);
GO
