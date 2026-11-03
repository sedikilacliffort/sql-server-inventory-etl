
USE [InventoryManagementDB]
GO

/****** Object:  StoredProcedure [dbo].[usp_ImportInventory]    Script Date: 03/11/2026 21:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[usp_ImportInventory]
    @ImportBatchID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @InsertedRows INT = 0;
    DECLARE @AuditID BIGINT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ImportTransactionStarted BIT = 0;

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
    -- 2. Create audit record for this attempt
    --------------------------------------------------

    INSERT INTO dbo.InventoryImportAudit
    (
        ImportBatchID,
        StartedAt,
        ImportStatus
    )
    VALUES
    (
        @ImportBatchID,
        SYSDATETIME(),
        'Running'
    );

    SET @AuditID = SCOPE_IDENTITY();


    BEGIN TRY

        --------------------------------------------------
        -- 3. Confirm that the batch has been validated
        --------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.InventoryImportBatch
            WHERE ImportBatchID = @ImportBatchID
              AND BatchStatus = 'Validated'
        )
        BEGIN
            THROW 50003,
                  'Batch must be validated before importing.',
                  1;
        END;


        --------------------------------------------------
        -- 4. Check whether the batch contains records
        --------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.INV_Validation_Test
            WHERE ImportBatchID = @ImportBatchID
        )
        BEGIN
            THROW 50004,
                  'Batch contains no records to import.',
                  1;
        END;


        --------------------------------------------------
        -- 5. Confirm that all records were validated
        --------------------------------------------------

        IF EXISTS
        (
            SELECT 1
            FROM dbo.INV_Validation_Test
            WHERE ImportBatchID = @ImportBatchID
              AND ProcessFlag IS NULL
        )
        BEGIN
            THROW 50002,
                  'Batch contains records that have not been validated.',
                  1;
        END;


        --------------------------------------------------
        -- 6. Start import transaction
        --------------------------------------------------

        BEGIN TRANSACTION;

        SET @ImportTransactionStarted = 1;


        --------------------------------------------------
        -- 7. Identify eligible records
        --------------------------------------------------

        ;WITH EligibleRecords AS
        (
            SELECT
                ValidationID,
                ItemCode,
                LocationCode,
                Quantity
            FROM dbo.INV_Validation_Test
            WHERE ImportBatchID = @ImportBatchID
              AND ProcessFlag = 'Yes'
              AND DataError IS NULL
        ),

        --------------------------------------------------
        -- 8. Identify duplicate combinations
        --------------------------------------------------

        DuplicateCombinations AS
        (
            SELECT
                ItemCode,
                LocationCode
            FROM EligibleRecords
            GROUP BY
                ItemCode,
                LocationCode
            HAVING COUNT(*) > 1
        ),

        --------------------------------------------------
        -- 9. Select import candidates
        --------------------------------------------------

        ImportCandidates AS
        (
            SELECT
                a.ItemCode,
                a.LocationCode,
                a.Quantity
            FROM EligibleRecords a

            LEFT JOIN DuplicateCombinations d
                ON a.ItemCode = d.ItemCode
                AND a.LocationCode = d.LocationCode

            WHERE d.ItemCode IS NULL
        )

        --------------------------------------------------
        -- 10. Insert eligible records
        --------------------------------------------------

        INSERT INTO dbo.Inventory
        (
            ItemCode,
            LocationCode,
            Quantity,
            LastUpdated
        )
        SELECT
            a.ItemCode,
            a.LocationCode,
            a.Quantity,
            SYSDATETIME()
        FROM ImportCandidates a
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM dbo.Inventory b WITH (UPDLOCK, HOLDLOCK)
            WHERE b.ItemCode = a.ItemCode
              AND b.LocationCode = a.LocationCode
        );

        SET @InsertedRows = @@ROWCOUNT;


        --------------------------------------------------
        -- 11. Update audit record
        --------------------------------------------------

        UPDATE dbo.InventoryImportAudit
        SET
            CompletedAt = SYSDATETIME(),
            InsertedRows = @InsertedRows,
            ImportStatus = 'Succeeded',
            ErrorMessage = NULL
        WHERE AuditID = @AuditID;


        --------------------------------------------------
        -- 12. Update batch status
        --------------------------------------------------

        UPDATE dbo.InventoryImportBatch
        SET BatchStatus = 'Processed'
        WHERE ImportBatchID = @ImportBatchID;


        --------------------------------------------------
        -- 13. Commit transaction
        --------------------------------------------------

        COMMIT TRANSACTION;

        -- Transaction completed successfully
        SET @ImportTransactionStarted = 0;


        --------------------------------------------------
        -- 14. Return successful import result
        --------------------------------------------------

        SELECT
            @AuditID AS AuditID,
            @ImportBatchID AS ImportBatchID,
            @InsertedRows AS InsertedRows,
            'Succeeded' AS ImportStatus;


    END TRY

    BEGIN CATCH

        --------------------------------------------------
        -- 15. Roll back failed transaction
        --------------------------------------------------

        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;


        SET @ErrorMessage = ERROR_MESSAGE();


        --------------------------------------------------
        -- 16. Record failed attempt
        --------------------------------------------------

        UPDATE dbo.InventoryImportAudit
        SET
            CompletedAt = SYSDATETIME(),
            InsertedRows = 0,
            ImportStatus = 'Failed',
            ErrorMessage = @ErrorMessage
        WHERE AuditID = @AuditID;


        --------------------------------------------------
        -- 17. Mark batch failed only if the actual
        --     import transaction failed
        --------------------------------------------------

        IF @ImportTransactionStarted = 1
        BEGIN
            UPDATE dbo.InventoryImportBatch
            SET BatchStatus = 'Failed'
            WHERE ImportBatchID = @ImportBatchID;
        END;


        THROW;

    END CATCH;

END;
GO
