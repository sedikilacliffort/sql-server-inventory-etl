# Deployment Guide

## 1. Project Overview

This guide describes the deployment and execution sequence for the SQL Server Inventory ETL project.

The project uses SQL Server, stored procedures, and SQL Server Integration Services (SSIS) to load, validate, import, and reconcile inventory data.

The project uses synthetic data for demonstration purposes.

## 2. Prerequisites

The following tools are required:

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services (SSIS)
- Visual Studio with the SSIS extension
- A CSV file containing inventory records

## 3. Deployment Sequence

### Step 1: Create the Database

Create the database:

```sql
CREATE DATABASE InventoryManagementDB;
GO
```

### Step 2: Create Database Tables

Execute the table creation scripts in the following order:

1. `01_Create_Item_Table.sql`
2. `02_Create_Inventory_Table.sql`
3. `03_Create_InventoryImportBatch_Table.sql`
4. `04_Create_INV_Validation_Test_Table.sql`
5. `05_Create_InventoryImportAudit_Table.sql`
6. `06_Create_InventoryBatchReconciliation_Table.sql`

These scripts are located in the `sql/tables` folder.

### Step 3: Insert Item Seed Data

Execute:

`sql/seed_data/01_Insert_Item_Seed_Data.sql`

This script inserts synthetic item master data into `dbo.Item`.

### Step 4: Create Stored Procedures

Execute the stored procedure scripts in this order:

1. `01_usp_ValidateInventory.sql`
2. `02_usp_ImportInventory.sql`
3. `03_usp_ReconcileInventoryBatch.sql`

These scripts are located in `sql/stored_procedures`.

## 4. SSIS Package Deployment

The SSIS package is named:

`LoadInventoryCSV.dtsx`

The package loads inventory data from a CSV file into the staging table `dbo.INV_Validation_Test`.

The package includes:

- An Execute SQL Task that checks whether the batch has already been loaded.
- A Data Flow Task that loads the CSV records into the staging table.

The Data Flow Task runs only after the pre-load check succeeds.

Refer to `ssis/SSIS_Package_Overview.md` for further details.

## 5. Batch Processing Workflow

After loading the CSV file into staging, execute the following procedures for the relevant `ImportBatchID`.

### Step 1: Validate the Batch

```sql
EXEC dbo.usp_ValidateInventory
    @ImportBatchID = 4;
```

The validation procedure identifies data quality issues and determines which records are eligible for import.

### Step 2: Import Eligible Records

```sql
EXEC dbo.usp_ImportInventory
    @ImportBatchID = 4;
```

The import procedure inserts eligible inventory records and records the processing outcome in the audit table.

### Step 3: Reconcile the Batch

```sql
EXEC dbo.usp_ReconcileInventoryBatch
    @ImportBatchID = 4;
```

The reconciliation procedure records batch processing statistics and import audit results.

> Note: The value `4` is an example ImportBatchID. Replace it with the actual batch ID being processed.

## 6. Monitoring and Reconciliation

The following tables support monitoring and audit:

- `dbo.InventoryImportBatch` — tracks batch status.
- `dbo.InventoryImportAudit` — records import attempts and outcomes.
- `dbo.InventoryBatchReconciliation` — stores reconciliation snapshots.
- `dbo.INV_Validation_Test` — stores staging records and validation results.

## 7. Expected Batch Lifecycle

The expected batch lifecycle is:

`Received → Validated → Processed`

A batch is validated before import. Successfully processed batches are marked as `Processed`.

## 8. Important Notes

- Use synthetic data only.
- Ensure the item master data exists before validating inventory records.
- Do not import batches that have not passed validation.
- Re-running reconciliation creates an additional snapshot.
- The SSIS package pre-load check is designed to prevent the same batch from being loaded into staging more than once.
