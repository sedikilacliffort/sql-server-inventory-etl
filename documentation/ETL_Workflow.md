# ETL Workflow - SQL Server Inventory Management Project

## 1. Overview

This project implements an ETL workflow to load inventory data from CSV files into a SQL Server staging table, validate the data, import eligible records into the inventory table, and reconcile the results.

The workflow uses SQL Server Integration Services (SSIS) and SQL Server stored procedures.

## 2. ETL Process Flow

The workflow follows these steps:

1. Prepare the inventory CSV source file.
2. Execute the SSIS package `LoadInventoryCSV.dtsx`.
3. Check whether the batch has already been loaded into staging.
4. Load CSV records into `dbo.INV_Validation_Test`.
5. Execute `dbo.usp_ValidateInventory`.
6. Review validation results and rejected records.
7. Execute `dbo.usp_ImportInventory` for validated batches.
8. Execute `dbo.usp_ReconcileInventoryBatch`.
9. Review audit and reconciliation results.

## 3. SSIS Package

### Package Name
`LoadInventoryCSV.dtsx`

### Control Flow

The package contains the following tasks:

- **Execute SQL Task:** `SQL_CheckBatchNotLoaded`
- **Data Flow Task:** `DFT_LoadInventoryCSV_ToStaging`

The Data Flow Task executes only when the pre-load check succeeds.

### Data Flow

The data flow consists of:

1. Flat File Source - reads the inventory CSV file.
2. Derived Column - adds the `ImportBatchID`.
3. OLE DB Destination - loads the data into `dbo.INV_Validation_Test`.

## 4. Staging Process

The staging table is:

`dbo.INV_Validation_Test`

The table temporarily stores imported CSV records before validation and processing.

The `ImportBatchID` identifies which batch each staging record belongs to.

## 5. Data Validation

The stored procedure:

`dbo.usp_ValidateInventory`

Validates the staged records against the inventory business rules, including:

- Positive inventory quantity.
- Valid inventory location.
- Item existence in the item master.
- Correct item category.
- Duplicate item and location combinations.
- Existing inventory combinations.

The procedure updates the validation results and batch status.

## 6. Inventory Import

The stored procedure:

`dbo.usp_ImportInventory`

Imports eligible records into:

`dbo.Inventory`

The procedure also records the import attempt in:

`dbo.InventoryImportAudit`

Only batches with the appropriate validated status can be imported.

## 7. Batch Reconciliation

The stored procedure:

`dbo.usp_ReconcileInventoryBatch`

Produces reconciliation snapshots in:

`dbo.InventoryBatchReconciliation`

The reconciliation includes:

- Total records.
- Validated records.
- Passed records.
- Rejected records.
- Duplicate records.
- Existing inventory records.
- Records ready for import.
- Import attempts.
- Successful and failed attempts.
- Total imported rows.

## 8. Error Handling and Controls

The workflow includes controls to:

- Prevent a batch from being loaded into staging more than once.
- Validate data before importing.
- Prevent ordinary repeat imports of processed batches.
- Record import attempts and their outcomes.
- Reconcile batch processing results.

## 9. Technology Stack

- SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services (SSIS)
- T-SQL
- CSV source files

## 10. Project Objective

The objective is to demonstrate a structured inventory ETL process with staging, data quality validation, controlled importing, audit logging, and batch reconciliation using Microsoft SQL Server technologies.
