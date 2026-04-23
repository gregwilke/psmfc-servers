-- ============================================================================
-- KBFishC_Dev: Remove all data for a specific OrganizationID
-- Purpose: Prepare database for technical training exercises
-- Usage: Set @OrgID below, then run against KBFishC_Dev
-- ============================================================================

USE KBFishC_Dev;
GO

-- *** SET THE ORGANIZATION ID HERE ***
DECLARE @OrgID VARCHAR(50) = 'USGSW';

IF @OrgID = ''
BEGIN
    RAISERROR('Please set @OrgID to a valid OrganizationID before running this script.', 16, 1);
    RETURN;
END

-- Show what we're about to delete
PRINT '================================================================';
PRINT 'Cleanup for OrganizationID: ' + @OrgID;
PRINT '================================================================';

-- Preview counts before deletion
PRINT '';
PRINT 'Records to be deleted:';

DECLARE @cnt INT;

SELECT @cnt = COUNT(*) FROM Media m
    INNER JOIN Effort e ON m.EffortID = e.ID
    WHERE e.OrganizationID = @OrgID;
PRINT '  Media (via Effort):            ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM Media m
    INNER JOIN DSiteDeployment d ON m.SiteDeploymentID = d.ID
    WHERE d.OrganizationID = @OrgID;
PRINT '  Media (via Deployment):        ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM MRRCaptures mc
    INNER JOIN Effort e ON mc.EffortID = e.ID
    WHERE e.OrganizationID = @OrgID;
PRINT '  MRRCaptures:                   ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM Detection dt
    INNER JOIN DSiteDeployment d ON dt.SiteDeploymentID = d.ID
    WHERE d.OrganizationID = @OrgID;
PRINT '  Detection:                     ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM EventLog el
    INNER JOIN DSiteDeployment d ON el.SiteDeploymentID = d.ID
    WHERE d.OrganizationID = @OrgID;
PRINT '  EventLog:                      ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM DSiteConfiguration dc
    INNER JOIN DSiteDeployment d ON dc.SiteDeploymentID = d.ID
    WHERE d.OrganizationID = @OrgID;
PRINT '  DSiteConfiguration:            ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM Effort WHERE OrganizationID = @OrgID;
PRINT '  Effort:                        ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM DSiteDeployment WHERE OrganizationID = @OrgID;
PRINT '  DSiteDeployment:               ' + CAST(@cnt AS VARCHAR(10));

SELECT @cnt = COUNT(*) FROM DataFiles WHERE OrganizationID = @OrgID;
PRINT '  DataFiles:                     ' + CAST(@cnt AS VARCHAR(10));

PRINT '';
PRINT 'Starting deletion in transaction...';

BEGIN TRY
    BEGIN TRANSACTION;

    -- ---------------------------------------------------------------
    -- 1-2. Media (leaf table - references MRRCaptures, Effort, DSiteDeployment)
    -- ---------------------------------------------------------------
    DELETE m FROM Media m
        INNER JOIN Effort e ON m.EffortID = e.ID
        WHERE e.OrganizationID = @OrgID;
    PRINT '  [1/9] Media (via Effort):            ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    DELETE m FROM Media m
        INNER JOIN DSiteDeployment d ON m.SiteDeploymentID = d.ID
        WHERE d.OrganizationID = @OrgID;
    PRINT '  [2/9] Media (via Deployment):        ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    -- ---------------------------------------------------------------
    -- 3. MRRCaptures (references Effort, DataFiles)
    -- ---------------------------------------------------------------
    DELETE mc FROM MRRCaptures mc
        INNER JOIN Effort e ON mc.EffortID = e.ID
        WHERE e.OrganizationID = @OrgID;
    PRINT '  [3/9] MRRCaptures:                   ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    -- ---------------------------------------------------------------
    -- 4. Detection (references DSiteDeployment, DataFiles)
    -- ---------------------------------------------------------------
    DELETE dt FROM Detection dt
        INNER JOIN DSiteDeployment d ON dt.SiteDeploymentID = d.ID
        WHERE d.OrganizationID = @OrgID;
    PRINT '  [4/9] Detection:                     ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    -- ---------------------------------------------------------------
    -- 5. EventLog (references DSiteDeployment, DataFiles)
    -- ---------------------------------------------------------------
    DELETE el FROM EventLog el
        INNER JOIN DSiteDeployment d ON el.SiteDeploymentID = d.ID
        WHERE d.OrganizationID = @OrgID;
    PRINT '  [5/9] EventLog:                      ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    -- ---------------------------------------------------------------
    -- 6. DSiteConfiguration (references DSiteDeployment)
    -- ---------------------------------------------------------------
    DELETE dc FROM DSiteConfiguration dc
        INNER JOIN DSiteDeployment d ON dc.SiteDeploymentID = d.ID
        WHERE d.OrganizationID = @OrgID;
    PRINT '  [6/9] DSiteConfiguration:            ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    -- ---------------------------------------------------------------
    -- 7. Effort (has OrganizationID directly)
    -- ---------------------------------------------------------------
    DELETE FROM Effort WHERE OrganizationID = @OrgID;
    PRINT '  [7/9] Effort:                        ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    -- ---------------------------------------------------------------
    -- 8. DSiteDeployment (has OrganizationID directly)
    -- ---------------------------------------------------------------
    DELETE FROM DSiteDeployment WHERE OrganizationID = @OrgID;
    PRINT '  [8/9] DSiteDeployment:               ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    -- ---------------------------------------------------------------
    -- 9. DataFiles (has OrganizationID directly)
    -- ---------------------------------------------------------------
    DELETE FROM DataFiles WHERE OrganizationID = @OrgID;
    PRINT '  [9/9] DataFiles:                     ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' deleted';

    COMMIT TRANSACTION;
    PRINT '';
    PRINT 'Cleanup completed successfully.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '';
    PRINT 'ERROR - Transaction rolled back. No data was deleted.';
    PRINT 'Error: ' + ERROR_MESSAGE();
    PRINT 'Line:  ' + CAST(ERROR_LINE() AS VARCHAR(10));
END CATCH
GO
