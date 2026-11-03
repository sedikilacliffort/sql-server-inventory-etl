# SSIS Package Overview

## Package Name

`LoadInventoryCSV.dtsx`

## Purpose

The SSIS package loads inventory records from a CSV source file into the SQL Server staging table `dbo.INV_Validation_Test`.

## Control Flow

The package contains the following tasks:

1. `SQL_CheckBatchNotLoaded` – checks whether the batch has already been loaded into staging.
2. `DFT_LoadInventoryCSV_ToStaging` – loads the CSV data into the staging table.

The Data Flow Task runs after the pre-load check succeeds.

## Data Flow

The data flow contains:

- **Flat File Source:** Reads the inventory CSV file using `CM_InventoryCSV`.
- **Derived Column:** Adds the `ImportBatchID` to each incoming row.
- **OLE DB Destination:** Inserts the records into `dbo.INV_Validation_Test`.

## Destination Table

`dbo.INV_Validation_Test`

## Package Control

The pre-load check helps prevent the same batch from being loaded into staging more than once.

## ETL Sequence

CSV File → SSIS Package → SQL Server Staging Table → Data Validation → Inventory Import → Batch Reconciliation
