USE [InventoryManagementDB]
GO

/****** Object:  StoredProcedure [dbo].[usp_ValidateInventory]    Script Date: 03/11/2026 21:48:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[usp_ValidateInventory]
    @ImportBatchID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        --------------------------------------------------
        -- 1. Check whether the batch exists
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
        -- 2. Check whether the batch can be validated
        --------------------------------------------------

        IF EXISTS
        (
            SELECT 1
            FROM dbo.InventoryImportBatch
            WHERE ImportBatchID = @ImportBatchID
              AND BatchStatus NOT IN
                  ('Received', 'Validated', 'Failed')
        )
        BEGIN
            THROW 50002,
                  'Batch cannot be validated in its current status.',
                  1;
        END;


        --------------------------------------------------
        -- 3. Check whether the batch contains records
        --------------------------------------------------

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.INV_Validation_Test
            WHERE ImportBatchID = @ImportBatchID
        )
        BEGIN
            THROW 50003,
                  'Batch contains no records to validate.',
                  1;
        END;


        --------------------------------------------------
        -- 4. Perform validation
        --------------------------------------------------

        BEGIN TRANSACTION;

        ;WITH DuplicateItems AS
        (
            SELECT
                ItemCode,
                LocationCode
            FROM dbo.INV_Validation_Test
            WHERE ImportBatchID = @ImportBatchID
            GROUP BY
                ItemCode,
                LocationCode
            HAVING COUNT(*) > 1
        ),

        ValidationResults AS
        (
            SELECT
                a.ValidationID,

                NULLIF(
                    CONCAT_WS('; ',

                        CASE
                            WHEN a.Quantity IS NULL
                                 OR a.Quantity <= 0
                                THEN 'Invalid quantity'
                        END,

                        CASE
                            WHEN a.LocationCode IS NULL
                                 OR a.LocationCode NOT IN
                                    ('JHB01', 'PTA01', 'CPT01', 'DBN01')
                                THEN 'Invalid location'
                        END,

                        CASE
                            WHEN b.ItemCode IS NULL
                                THEN 'Item does not exist'
                        END,

                        CASE
                            WHEN b.ItemCode IS NOT NULL
                                 AND
                                 (
                                     a.ItemCategory IS NULL
                                     OR a.ItemCategory <> b.ItemCategory
                                 )
                                THEN 'Incorrect item category'
                        END,

                        CASE
                            WHEN d.ItemCode IS NOT NULL
                                THEN 'Duplicate item and location in import batch'
                        END

                    ),
                    ''
                ) AS DataError,

                CASE
                    WHEN i.ItemCode IS NOT NULL
                        THEN 'Item already exists in inventory'
                    ELSE NULL
                END AS DataValidation

            FROM dbo.INV_Validation_Test a

            LEFT JOIN dbo.Item b
                ON a.ItemCode = b.ItemCode

            LEFT JOIN dbo.Inventory i
                ON a.ItemCode = i.ItemCode
                AND a.LocationCode = i.LocationCode

            LEFT JOIN DuplicateItems d
                ON a.ItemCode = d.ItemCode
                AND a.LocationCode = d.LocationCode

            WHERE a.ImportBatchID = @ImportBatchID
        )

        --------------------------------------------------
        -- 5. Update validation results
        --------------------------------------------------

        UPDATE a
        SET
            a.DataError = v.DataError,
            a.DataValidation = v.DataValidation,
            a.ProcessFlag =
                CASE
                    WHEN v.DataError IS NOT NULL THEN 'No'
                    ELSE 'Yes'
                END

        FROM dbo.INV_Validation_Test a

        INNER JOIN ValidationResults v
            ON a.ValidationID = v.ValidationID;


        --------------------------------------------------
        -- 6. Update batch status
        --------------------------------------------------

        UPDATE dbo.InventoryImportBatch
        SET BatchStatus = 'Validated'
        WHERE ImportBatchID = @ImportBatchID;

        COMMIT TRANSACTION;


        --------------------------------------------------
        -- 7. Return detailed validation results
        --------------------------------------------------

        SELECT
            ValidationID,
            ImportBatchID,
            ItemCode,
            LocationCode,
            DataError,
            DataValidation,
            ProcessFlag

        FROM dbo.INV_Validation_Test

        WHERE ImportBatchID = @ImportBatchID

        ORDER BY ValidationID;


        --------------------------------------------------
        -- 8. Return validation summary
        --------------------------------------------------

        SELECT
            COUNT(*) AS TotalRecords,

            SUM(CASE
                WHEN ProcessFlag = 'Yes'
                    THEN 1 ELSE 0
            END) AS PassedRecords,

            SUM(CASE
                WHEN ProcessFlag = 'No'
                    THEN 1 ELSE 0
            END) AS RejectedRecords,

            SUM(CASE
                WHEN DataValidation IS NOT NULL
                    THEN 1 ELSE 0
            END) AS WarningRecords,

            SUM(CASE
                WHEN DataError LIKE '%Duplicate item and location%'
                    THEN 1 ELSE 0
            END) AS DuplicateRecords

        FROM dbo.INV_Validation_Test

        WHERE ImportBatchID = @ImportBatchID;


        --------------------------------------------------
        -- 9. Return batch status
        --------------------------------------------------

        SELECT
            ImportBatchID,
            SourceFileName,
            BatchStatus

        FROM dbo.InventoryImportBatch

        WHERE ImportBatchID = @ImportBatchID;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;
GO
