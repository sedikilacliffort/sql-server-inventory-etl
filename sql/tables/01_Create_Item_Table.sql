USE InventoryManagementDB;
GO

CREATE TABLE dbo.Item
(
    ItemID INT IDENTITY(1,1) PRIMARY KEY,
    ItemCode VARCHAR(20) NOT NULL UNIQUE,
    ItemDescription VARCHAR(100) NOT NULL,
    ItemCategory INT NOT NULL,
    Active BIT NOT NULL DEFAULT 1
);
GO
