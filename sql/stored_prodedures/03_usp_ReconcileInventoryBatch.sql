USE [InventoryManagementDB]
GO

/****** Object:  StoredProcedure [dbo].[usp_ReconcileInventoryBatch]    Script Date: 03/11/2026 21:55:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[usp_ReconcileInventoryBatch]
    @ImportBatchID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ReconciliationID INT;

    --------------------------------------------------
    -- 1. Confirm that the batch exists
    --------------------------------------------------

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.InventoryImportBatch
        WHERE ImportBatchID = @ImportBatchID
    )
    BEGIN
        THROW 50001, 'Import batch does not exist.', 1;
    END;


    --------------------------------------------------
    -- 2. Calculate validation statistics
    --------------------------------------------------

    ;WITH BatchStats AS
    (
        SELECT
            COUNT(*) AS TotalRecords,

            SUM(CASE
                WHEN ProcessFlag IS NOT NULL THEN 1
                ELSE 0
            END) AS ValidatedRecords,

            SUM(CASE
                WHEN ProcessFlag = 'Yes' THEN 1
                ELSE 0
            END) AS PassedRecords,

            SUM(CASE
                WHEN ProcessFlag = 'No' THEN 1
                ELSE 0
            END) AS RejectedRecords,

            SUM(CASE
                WHEN DataError LIKE '%Duplicate item and location%'
                    THEN 1
                ELSE 0
            END) AS DuplicateRecords,

            SUM(CASE
                WHEN DataValidation =
                    'Item already exists in inventory'
                    THEN 1
                ELSE 0
            END) AS ExistingInventoryRecords,

            SUM(CASE
                WHEN ProcessFlag = 'Yes'
                 AND DataError IS NULL
                 AND DataValidation IS NULL
                    THEN 1
                ELSE 0
            END) AS ReadyForImportRecords

        FROM dbo.INV_Validation_Test
        WHERE ImportBatchID = @ImportBatchID
    ),

    --------------------------------------------------
    -- 3. Calculate import audit statistics
    --------------------------------------------------

    AuditStats AS
    (
        SELECT
            COUNT(*) AS TotalImportAttempts,

            SUM(CASE
                WHEN ImportStatus = 'Succeeded' THEN 1
                ELSE 0
            END) AS SuccessfulAttempts,

            SUM(CASE
                WHEN ImportStatus = 'Failed' THEN 1
                ELSE 0
            END) AS FailedAttempts,

            SUM(CASE
                WHEN ImportStatus = 'Succeeded'
                    THEN InsertedRows
                ELSE 0
            END) AS TotalImportedRows

        FROM dbo.InventoryImportAudit
        WHERE ImportBatchID = @ImportBatchID
    )

    --------------------------------------------------
    -- 4. Save reconciliation snapshot
    --------------------------------------------------

    INSERT INTO dbo.InventoryBatchReconciliation
    (
        ImportBatchID,
        TotalRecords,
        ValidatedRecords,
        PassedRecords,
        RejectedRecords,
        DuplicateRecords,
        ExistingInventoryRecords,
        ReadyForImportRecords,
        TotalImportAttempts,
        SuccessfulAttempts,
        FailedAttempts,
        TotalImportedRows
    )
    SELECT
        @ImportBatchID,
        v.TotalRecords,
        COALESCE(v.ValidatedRecords, 0),
        COALESCE(v.PassedRecords, 0),
        COALESCE(v.RejectedRecords, 0),
        COALESCE(v.DuplicateRecords, 0),
        COALESCE(v.ExistingInventoryRecords, 0),
        COALESCE(v.ReadyForImportRecords, 0),
        COALESCE(a.TotalImportAttempts, 0),
        COALESCE(a.SuccessfulAttempts, 0),
        COALESCE(a.FailedAttempts, 0),
        COALESCE(a.TotalImportedRows, 0)

    FROM BatchStats v
    CROSS JOIN AuditStats a;


    --------------------------------------------------
    -- 5. Capture the new snapshot ID
    --------------------------------------------------

    SET @ReconciliationID = SCOPE_IDENTITY();


    --------------------------------------------------
    -- 6. Return the saved reconciliation report
    --------------------------------------------------

    SELECT
        r.ReconciliationID,
        r.SnapshotAt,

        b.ImportBatchID,
        b.SourceFileName,
        b.BatchStatus,

        r.TotalRecords,
        r.ValidatedRecords,
        r.PassedRecords,
        r.RejectedRecords,
        r.DuplicateRecords,
        r.ExistingInventoryRecords,
        r.ReadyForImportRecords,

        r.TotalImportAttempts,
        r.SuccessfulAttempts,
        r.FailedAttempts,
        r.TotalImportedRows

    FROM dbo.InventoryBatchReconciliation r

    INNER JOIN dbo.InventoryImportBatch b
        ON r.ImportBatchID = b.ImportBatchID

    WHERE r.ReconciliationID = @ReconciliationID;

END;
GO


