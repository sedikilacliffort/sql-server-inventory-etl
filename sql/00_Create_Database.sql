```sql
/*
    Project: SQL Server Inventory ETL
    Script: Create Database
    Purpose: Create the database required for the Inventory ETL project.
*/

IF DB_ID('InventoryManagementDB') IS NULL
BEGIN
    CREATE DATABASE InventoryManagementDB;
END;
GO
```
