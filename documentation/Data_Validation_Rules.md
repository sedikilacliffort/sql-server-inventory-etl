# Data Validation Rules

## 1. Purpose

This document describes the data quality checks applied to inventory records before they are imported into the Inventory table.

The validation process helps ensure that inventory data is accurate, consistent, and suitable for processing.

## 2. Validation Rules

| Rule ID | Validation Rule | Condition | Expected Outcome |
|---|---|---|---|
| VR001 | Quantity Validation | Quantity must be greater than zero | Invalid quantities are rejected |
| VR002 | Location Validation | Location must be JHB01, PTA01, CPT01, or DBN01 | Invalid locations are rejected |
| VR003 | Item Master Validation | ItemCode must exist in dbo.Item | Unknown items are rejected |
| VR004 | Item Category Validation | ItemCategory must match the item master | Incorrect categories are rejected |
| VR005 | Duplicate Validation | ItemCode and LocationCode must be unique within an import batch | Both duplicate records are rejected |
| VR006 | Existing Inventory Check | ItemCode and LocationCode already exist in dbo.Inventory | Record receives a warning |
| VR007 | Batch Status Validation | Batch must be in an eligible status before validation or import | Invalid batch processing is prevented |

## 3. Validation Outcomes

### 3.1 Passed Records

Records that satisfy all validation rules are assigned:

`ProcessFlag = 'Yes'`

These records may proceed to the import stage.

### 3.2 Rejected Records

Records that fail one or more validation rules are assigned:

`ProcessFlag = 'No'`

The reason for rejection is recorded in the DataError column.

### 3.3 Warning Records

Records that already exist in inventory may receive the warning:

`Item already exists in inventory`

These records are identified for review and are not inserted as duplicate inventory combinations.

## 4. Duplicate Handling

Duplicate ItemCode and LocationCode combinations within the same import batch are flagged.

Both records involved in the duplicate combination are rejected until the issue is reviewed and corrected.

## 5. Batch Processing Controls

The validation procedure checks that:

- The specified ImportBatchID exists.
- The batch contains staging records.
- The batch status permits validation.
- Successfully processed batches cannot be validated or imported again under the implemented controls.

## 6. Error Tracking

Validation errors are stored in the DataError column.

Validation warnings are stored in the DataValidation column.

The ProcessFlag indicates whether the record passed or failed validation.

These fields support data quality reporting, troubleshooting, and reconciliation.
