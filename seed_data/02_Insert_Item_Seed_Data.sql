```sql
USE InventoryManagementDB;
GO

INSERT INTO dbo.Item
(
    ItemCode,
    ItemDescription,
    ItemCategory,
    Active
)
VALUES
    ('ITM001', 'Industrial Pump', 1, 1),
    ('ITM002', 'Hydraulic Hose', 2, 1),
    ('ITM003', 'Bearing Assembly', 3, 1),
    ('ITM004', 'Steel Bolt', 4, 1),
    ('ITM005', 'Electric Motor', 5, 1),
    ('ITM006', 'Valve Assembly', 4, 1),
    ('ITM007', 'Pressure Gauge', 3, 1),
    ('ITM008', 'Filter Cartridge', 2, 1),
    ('ITM009', 'Drive Belt', 1, 1),
    ('ITM010', 'Gearbox', 5, 1);
GO
```
