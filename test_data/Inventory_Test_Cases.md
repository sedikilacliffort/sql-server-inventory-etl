# Inventory Validation Test Cases

## Purpose

This document describes the test scenarios included in `Inventory_Test_Batch001.csv`.

| Test Case | Scenario | Expected Result |
|---|---|---|
| TC001 | Valid item and location | Pass validation |
| TC002 | Valid item and location | Pass validation |
| TC003 | ItemCode ITM999 does not exist in Item master | Reject |
| TC004 | LocationCode XYZ01 is invalid | Reject |
| TC005 | Quantity is negative | Reject |
| TC006 | Item category does not match master data | Reject |
| TC007 | Duplicate ItemCode and LocationCode combination | Reject both duplicate records |
| TC008 | Valid item and location | Pass validation |

## Data Quality Checks

The validation procedure checks:
- Quantity must be greater than zero.
- Location must be one of the approved locations.
- ItemCode must exist in the Item master.
- ItemCategory must match the Item master.
- Duplicate item-location combinations are flagged.

## Expected Outcome

The dataset is designed to demonstrate both successful and rejected records during the inventory validation process.
