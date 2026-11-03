# SQL Execution Guide

## Purpose

This guide explains the recommended execution order for setting up and running the SQL Server Inventory ETL project.

## Prerequisites

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Access to execute SQL scripts

## Database Setup

Execute the database creation script:

1. `sql/00_Create_Database.sql`

## Table Creation

Execute the table creation scripts in the following order:

1. `sql/tables/01_Create_Item_Table.sql`
2. `sql/tables/02_Create_Inventory_Table.sql`
3. `sql/tables/03_Create_InventoryImportBatch_Table.sql`
4. `sql/tables/04_Create_INV_Validation_Test_Table.sql`
5. `sql/tables/05_Create_InventoryImportAudit_Table.sql`
6. `sql/tables/06_Create_InventoryBatchReconciliation_Table.sql`

## Stored Procedure Creation

Execute the stored procedures in this order:

1. `sql/stored_procedures/01_usp_ValidateInventory.sql`
2. `sql/stored_procedures/02_usp_ImportInventory.sql`
3. `sql/stored_procedures/03_usp_ReconcileInventoryBatch.sql`

## Seed Data

Execute the seed data scripts as required:

- `seed_data/01_Insert_Item_Seed_Data.sql`
- `seed_data/02_Insert_Inventory_Seed_Data.sql`
- `seed_data/03_Insert_InventoryImportBatch_Seed_Data.sql`

## ETL Workflow

1. Prepare the inventory CSV file.
2. Create an import batch.
3. Load the CSV file into the staging table using SSIS.
4. Validate the batch using `dbo.usp_ValidateInventory`.
5. Import eligible records using `dbo.usp_ImportInventory`.
6. Reconcile the batch using `dbo.usp_ReconcileInventoryBatch`.

## Important Note

Seed data scripts contain INSERT statements. Execute them only once against a fresh database unless additional records are intentionally required.
