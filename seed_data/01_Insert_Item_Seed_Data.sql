
USE InventoryManagementDB;
GO

-- Insert synthetic item master data
INSERT INTO dbo.Item
(
    ItemCode,
    ItemDescription,
    ItemCategory,
    Active
)
VALUES
    ('ITM001', 'Industrial Bearing', 1, 1),
    ('ITM002', 'Hydraulic Hose', 2, 1),
    ('ITM003', 'Steel Bolt', 3, 1),
    ('ITM004', 'Pressure Valve', 4, 1),
    ('ITM005', 'Drive Belt', 5, 1),
    ('ITM006', 'Pneumatic Cylinder', 4, 1),
    ('ITM007', 'Roller Chain', 3, 1),
    ('ITM008', 'Oil Filter', 8, 1),
    ('ITM009', 'Gear Assembly', 7, 1),
    ('ITM010', 'Electric Motor', 8, 1);
GO
