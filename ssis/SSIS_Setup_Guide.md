# SSIS Setup Guide

## Purpose

This guide describes the setup and execution of the `LoadInventoryCSV.dtsx` SSIS package.

## Prerequisites

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services
- Visual Studio with SQL Server Integration Services Projects extension
- `InventoryManagementDB` database

## Package

Package name: `LoadInventoryCSV.dtsx`

## Control Flow

The package contains:

1. `SQL_CheckBatchNotLoaded`
   - Checks whether the batch has already been loaded into the staging table.
2. `DFT_LoadInventoryCSV_ToStaging`
   - Loads the inventory CSV file into `dbo.INV_Validation_Test`.

The Data Flow Task executes only when the pre-load check succeeds.

## Data Flow

The Data Flow contains:

- Flat File Source (`CM_InventoryCSV`)
- Derived Column (adds `ImportBatchID`)
- OLE DB Destination (`dbo.INV_Validation_Test`)

## Execution Workflow

1. Prepare the inventory CSV file.
2. Ensure the corresponding import batch exists in `dbo.InventoryImportBatch`.
3. Configure the CSV file connection manager.
4. Set the appropriate `ImportBatchID`.
5. Execute the SSIS package.
6. Verify that the records were loaded into `dbo.INV_Validation_Test`.
7. Run the inventory validation procedure.

## Important Note

The package's batch pre-check currently uses a hardcoded batch ID. This should be parameterized in a future enhancement to support reusable execution across multiple batches.
