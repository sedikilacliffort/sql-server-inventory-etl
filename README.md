# SQL Server Inventory ETL Project

## Project Overview

This project demonstrates an end-to-end inventory data ETL workflow using Microsoft SQL Server and SQL Server Integration Services (SSIS).

The solution loads inventory data from CSV files into a SQL Server staging table, applies data quality validation rules, imports eligible records into the inventory table, and reconciles the processing results.

The project uses synthetic data for demonstration and portfolio purposes.

## Business Problem

Inventory data received from external source files may contain invalid quantities, incorrect locations, missing item master records, category mismatches, or duplicate item-location combinations.

Without proper validation and processing controls, these data quality issues can affect inventory accuracy and reporting.

This project implements a controlled ETL process to identify data issues and import only eligible inventory records.

## Solution Architecture

CSV Source File  
↓  
SSIS Package - `LoadInventoryCSV.dtsx`  
↓  
SQL Server Staging Table - `dbo.INV_Validation_Test`  
↓  
Data Validation - `dbo.usp_ValidateInventory`  
↓  
Inventory Import - `dbo.usp_ImportInventory`  
↓  
Inventory Table - `dbo.Inventory`  
↓  
Batch Reconciliation - `dbo.usp_ReconcileInventoryBatch`

## Technologies Used

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services (SSIS)
- T-SQL
- CSV files

## Database Components

### Tables

| Table | Purpose |
|---|---|
| `dbo.Item` | Stores item master data |
| `dbo.Inventory` | Stores inventory quantities by item and location |
| `dbo.INV_Validation_Test` | Staging and validation table |
| `dbo.InventoryImportBatch` | Tracks import batches and their statuses |
| `dbo.InventoryImportAudit` | Records inventory import attempts |
| `dbo.InventoryBatchReconciliation` | Stores batch reconciliation snapshots |

### Stored Procedures

| Stored Procedure | Purpose |
|---|---|
| `dbo.usp_ValidateInventory` | Validates staged inventory records |
| `dbo.usp_ImportInventory` | Imports eligible inventory records |
| `dbo.usp_ReconcileInventoryBatch` | Reconciles batch processing results |

## Data Validation Rules

The ETL workflow validates:

- Inventory quantity must be greater than zero.
- Location code must be valid.
- Item code must exist in the item master.
- Item category must match the item master.
- Duplicate item-location combinations are flagged.
- Existing inventory combinations are identified.

Duplicate records are flagged for review rather than imported.

## ETL Workflow

1. Prepare the CSV source file.
2. Execute the SSIS package.
3. Check whether the batch has already been loaded.
4. Load the CSV records into the staging table.
5. Validate the staged records.
6. Import eligible inventory records.
7. Record import audit information.
8. Reconcile the batch results.

## Audit and Reconciliation

The project includes batch-level audit and reconciliation controls to track:

- Total records received.
- Validated and rejected records.
- Duplicate records.
- Records eligible for import.
- Import attempts and outcomes.
- Total imported rows.

## Project Documentation

Additional documentation is available in the `documentation` folder:

- `Database_Design.md`
- `Data_Validation_Rules.md`
- `ETL_Workflow.md`

## Disclaimer

This project uses synthetic data and is intended for learning, demonstration, and portfolio purposes. It does not contain confidential company data.

## Author

Cliffort Sedikila

## Project Structure

```text
sql-server-inventory-etl/
│
├── documentation/
│   ├── Database_Design.md
│   ├── Data_Validation_Rules.md
│   ├── ETL_Workflow.md
│   └── Deployment_Guide.md
│
├── seed_data/
│   └── 01_Insert_Item_Seed_Data.sql
│
├── sql/
│   ├── tables/
│   │   ├── 01_Create_Item_Table.sql
│   │   ├── 02_Create_Inventory_Table.sql
│   │   ├── 03_Create_InventoryImportBatch_Table.sql
│   │   ├── 04_Create_INV_Validation_Test_Table.sql
│   │   ├── 05_Create_InventoryImportAudit_Table.sql
│   │   └── 06_Create_InventoryBatchReconciliation_Table.sql
│   │
│   └── stored_procedures/
│       ├── 01_usp_ValidateInventory.sql
│       ├── 02_usp_ImportInventory.sql
│       └── 03_usp_ReconcileInventoryBatch.sql
│
└── ssis/
    └── SSIS_Package_Overview.md
```

