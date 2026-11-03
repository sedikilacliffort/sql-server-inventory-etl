USE InventoryManagementDB;
GO

CREATE TABLE dbo.Inventory
(
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ItemCode VARCHAR(20) NOT NULL,
    LocationCode VARCHAR(20) NOT NULL,
    Quantity INT NOT NULL,
    LastUpdated DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Inventory_ItemCode_LocationCode
        UNIQUE (ItemCode, LocationCode)
);
GO
