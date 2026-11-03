```sql
USE InventoryManagementDB;
GO

INSERT INTO dbo.InventoryImportBatch
(
    SourceFileName,
    BatchStatus
)
VALUES
(
    'Inventory_Seed_Batch001.csv',
    'Received'
);
GO

SELECT
    ImportBatchID,
    SourceFileName,
    CreatedAt,
    BatchStatus
FROM dbo.InventoryImportBatch;
GO
```
