# Database Design

## 1. Project Overview

The SQL Server Inventory ETL project is designed to process inventory data received from external sources such as warehouses, suppliers, or inventory management systems.

The solution uses a staging area to validate inventory records before importing valid records into the main inventory table.

## 2. Database

**Database Name:** InventoryManagementDB

## 3. Database Tables

### 3.1 Item
Stores the master data for inventory items.

| Column | Data Type | Description |
|---|---|---|
| ItemID | INT | Primary key |
| ItemCode | VARCHAR(20) | Unique item identifier |
| ItemDescription | VARCHAR(100) | Item description |
| ItemCategory | INT | Item category |
| Active | BIT | Indicates whether the item is active |

### 3.2 Inventory
Stores inventory quantities by item and warehouse location.

| Column | Data Type | Description |
|---|---|---|
| InventoryID | INT | Primary key |
| ItemCode | VARCHAR(20) | Item identifier |
| LocationCode | VARCHAR(20) | Warehouse location |
| Quantity | INT | Inventory quantity |
| LastUpdated | DATETIME | Last update timestamp |

A unique constraint on ItemCode and LocationCode prevents duplicate inventory combinations.

### 3.3 INV_Validation_Test
Staging table used to store incoming inventory records before validation and import.

| Column | Data Type | Description |
|---|---|---|
| ValidationID | INT | Primary key |
| ItemCode | VARCHAR(20) | Item identifier |
| LocationCode | VARCHAR(20) | Warehouse location |
| Quantity | INT | Inventory quantity |
| ItemCategory | INT | Item category |
| MultiItem | VARCHAR(20) | Additional item attribute |
| MaxSlots | INT | Maximum slot attribute |
| DataValidation | VARCHAR(500) | Validation warning |
| DataError | VARCHAR(500) | Validation error |
| ProcessFlag | VARCHAR(3) | Indicates whether record can be processed |
| ImportBatchID | INT | Reference to import batch |

### 3.4 InventoryImportBatch
Tracks inventory import batches.

| Column | Data Type | Description |
|---|---|---|
| ImportBatchID | INT | Primary key |
| SourceFileName | VARCHAR(255) | Source file name |
| CreatedAt | DATETIME2 | Batch creation timestamp |
| BatchStatus | VARCHAR(20) | Current batch status |

### 3.5 InventoryImportAudit
Records the results of inventory import attempts.

| Column | Data Type | Description |
|---|---|---|
| AuditID | BIGINT | Primary key |
| StartedAt | DATETIME2 | Import start time |
| CompletedAt | DATETIME2 | Import completion time |
| InsertedRows | INT | Number of inserted records |
| ImportStatus | VARCHAR(20) | Import outcome |
| ErrorMessage | NVARCHAR(4000) | Error details |
| ImportBatchID | INT | Associated batch |

### 3.6 InventoryBatchReconciliation
Stores reconciliation snapshots for inventory import batches.

| Column | Data Type | Description |
|---|---|---|
| ReconciliationID | INT | Primary key |
| ImportBatchID | INT | Associated batch |
| SnapshotAt | DATETIME2 | Snapshot timestamp |
| TotalRecords | INT | Total records received |
| ValidatedRecords | INT | Records validated |
| PassedRecords | INT | Records that passed validation |
| RejectedRecords | INT | Records rejected |
| DuplicateRecords | INT | Duplicate records identified |
| ExistingInventoryRecords | INT | Records already present in inventory |
| ReadyForImportRecords | INT | Records ready for import |
| TotalImportAttempts | INT | Total import attempts |
| SuccessfulAttempts | INT | Successful import attempts |
| FailedAttempts | INT | Failed import attempts |
| TotalImportedRows | INT | Total successfully imported rows |

## 4. Stored Procedures

The project includes the following stored procedures:

- dbo.usp_ValidateInventory` - validates incoming inventory records.
- dbo.usp_ImportInventory` - imports valid records into the Inventory table.
- dbo.usp_ReconcileInventoryBatch` - generates batch reconciliation snapshots.

## 5. ETL Workflow

1. Inventory data is received as a CSV file.
2. SSIS loads the CSV data into the staging table.
3. A batch validation procedure checks data quality.
4. Valid records are imported into the Inventory table.
5. Import attempts are recorded in the audit table.
6. Reconciliation snapshots are generated for reporting and monitoring.

## 6. Data Quality Controls

The solution includes the following controls:

- Quantity must be greater than zero.
- Location codes must be valid.
- Item codes must exist in the Item master table.
- Item categories must match the master data.
- Duplicate item-location combinations are flagged.
- Existing inventory combinations are identified.
- Successfully processed batches cannot be imported again.
