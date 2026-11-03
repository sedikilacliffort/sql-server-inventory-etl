USE InventoryManagementDB;
GO

CREATE TABLE dbo.INV_Validation_Test
(
    ValidationID INT IDENTITY(1,1) PRIMARY KEY,
    ItemCode VARCHAR(20) NOT NULL,
    LocationCode VARCHAR(20) NOT NULL,
    Quantity INT NOT NULL,
    ItemCategory INT NOT NULL,
    MultiItem VARCHAR(20) NULL,
    MaxSlots INT NULL,
    DataValidation VARCHAR(50) NULL,
    DataError VARCHAR(500) NULL,
    ProcessFlag VARCHAR(10) NULL,
    ImportBatchID INT NOT NULL,

    CONSTRAINT FK_INV_Validation_Test_InventoryImportBatch
        FOREIGN KEY (ImportBatchID)
        REFERENCES dbo.InventoryImportBatch (ImportBatchID)
);
GO
