```sql
USE InventoryManagementDB;
GO

INSERT INTO dbo.Inventory
(
    ItemCode,
    LocationCode,
    Quantity,
    LastUpdated
)
VALUES
    ('ITM001', 'JHB01', 100, GETDATE()),
    ('ITM002', 'PTA01', 50, GETDATE()),
    ('ITM003', 'CPT01', 75, GETDATE()),
    ('ITM004', 'DBN01', 200, GETDATE()),
    ('ITM005', 'JHB01', 30, GETDATE()),
    ('ITM006', 'PTA01', 45, GETDATE()),
    ('ITM007', 'CPT01', 60, GETDATE()),
    ('ITM010', 'DBN01', 25, GETDATE());
GO
```
