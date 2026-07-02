USE OmanOilGasDB;
GO

/* ============================================================
   Advanced SQL Server Lab Solutions – Oil & Gas Database
   Topics:
   1. Functions: Scalar and Table-Valued Function
   2. Stored Procedures
   3. Triggers: Insert, Update and Delete
   4. Transaction Management
   5. Table Variables
   ============================================================ */

/* ============================================================
   Lab 1A – Scalar Function: Calculate Refinery Yield Percent
   ============================================================ */
CREATE OR ALTER FUNCTION dbo.fn_CalculateYieldPercent
(
    @InputVolumeBBL DECIMAL(18,2),
    @OutputVolumeBBL DECIMAL(18,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @YieldPercent DECIMAL(10,2);

    IF @InputVolumeBBL IS NULL OR @InputVolumeBBL = 0
        SET @YieldPercent = 0;
    ELSE
        SET @YieldPercent = CAST((@OutputVolumeBBL / @InputVolumeBBL) * 100 AS DECIMAL(10,2));

    RETURN @YieldPercent;
END;
GO

-- Test scalar function
SELECT TOP 10
    BatchID,
    InputVolumeBBL,
    OutputVolumeBBL,
    dbo.fn_CalculateYieldPercent(InputVolumeBBL, OutputVolumeBBL) AS YieldPercent
FROM dbo.RefineryBatches;
GO

/* ============================================================
   Lab 1B – Inline Table-Valued Function: Well Production Summary
   ============================================================ */
CREATE OR ALTER FUNCTION dbo.tvf_GetWellProductionSummary
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        pd.WellID,
        SUM(pd.OilBarrels) AS TotalOilBarrels,
        SUM(pd.GasMMscf) AS TotalGasMMscf,
        SUM(pd.WaterBarrels) AS TotalWaterBarrels,
        SUM(pd.DowntimeHours) AS TotalDowntimeHours
    FROM dbo.ProductionDaily pd
    WHERE pd.ProductionDate BETWEEN @StartDate AND @EndDate
    GROUP BY pd.WellID
);
GO

-- Test table-valued function
SELECT TOP 20 *
FROM dbo.tvf_GetWellProductionSummary('2026-01-01', '2026-06-30')
ORDER BY TotalOilBarrels DESC;
GO

/* ============================================================
   Lab 2 – Stored Procedure: Site Production Summary
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.usp_GetSiteProductionSummary
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.SiteID,
        s.SiteName,
        SUM(pd.OilBarrels) AS TotalOilBarrels,
        SUM(pd.GasMMscf) AS TotalGasMMscf,
        SUM(pd.WaterBarrels) AS TotalWaterBarrels,
        SUM(pd.DowntimeHours) AS TotalDowntimeHours
    FROM dbo.ProductionDaily pd
    INNER JOIN dbo.Sites s
        ON pd.SiteID = s.SiteID
    WHERE pd.ProductionDate BETWEEN @StartDate AND @EndDate
    GROUP BY
        s.SiteID,
        s.SiteName
    ORDER BY TotalOilBarrels DESC;
END;
GO

-- Test stored procedure
EXEC dbo.usp_GetSiteProductionSummary
    @StartDate = '2026-01-01',
    @EndDate = '2026-06-30';
GO

/* ============================================================
   Lab 3A – Audit Table for HSE Incident Triggers
   ============================================================ */
IF OBJECT_ID('dbo.HSEIncidentAudit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HSEIncidentAudit
    (
        AuditID BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_HSEIncidentAudit PRIMARY KEY,
        IncidentID BIGINT NULL,
        ActionType NVARCHAR(10) NOT NULL,
        OldSeverity NVARCHAR(20) NULL,
        NewSeverity NVARCHAR(20) NULL,
        OldClosureStatus NVARCHAR(30) NULL,
        NewClosureStatus NVARCHAR(30) NULL,
        AuditDate DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        LoginName NVARCHAR(128) NOT NULL DEFAULT SUSER_SNAME()
    );
END;
GO

/* ============================================================
   Lab 3B – INSERT Trigger
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.trg_HSEIncidents_Insert_Audit
ON dbo.HSEIncidents
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.HSEIncidentAudit
    (
        IncidentID,
        ActionType,
        OldSeverity,
        NewSeverity,
        OldClosureStatus,
        NewClosureStatus,
        AuditDate,
        LoginName
    )
    SELECT
        i.IncidentID,
        'INSERT',
        NULL,
        i.Severity,
        NULL,
        i.ClosureStatus,
        SYSUTCDATETIME(),
        SUSER_SNAME()
    FROM inserted i;
END;
GO

/* ============================================================
   Lab 3C – UPDATE Trigger
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.trg_HSEIncidents_Update_Audit
ON dbo.HSEIncidents
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.HSEIncidentAudit
    (
        IncidentID,
        ActionType,
        OldSeverity,
        NewSeverity,
        OldClosureStatus,
        NewClosureStatus,
        AuditDate,
        LoginName
    )
    SELECT
        i.IncidentID,
        'UPDATE',
        d.Severity,
        i.Severity,
        d.ClosureStatus,
        i.ClosureStatus,
        SYSUTCDATETIME(),
        SUSER_SNAME()
    FROM inserted i
    INNER JOIN deleted d
        ON i.IncidentID = d.IncidentID;
END;
GO

/* ============================================================
   Lab 3D – DELETE Trigger
   ============================================================ */
CREATE OR ALTER TRIGGER dbo.trg_HSEIncidents_Delete_Audit
ON dbo.HSEIncidents
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.HSEIncidentAudit
    (
        IncidentID,
        ActionType,
        OldSeverity,
        NewSeverity,
        OldClosureStatus,
        NewClosureStatus,
        AuditDate,
        LoginName
    )
    SELECT
        d.IncidentID,
        'DELETE',
        d.Severity,
        NULL,
        d.ClosureStatus,
        NULL,
        SYSUTCDATETIME(),
        SUSER_SNAME()
    FROM deleted d;
END;
GO

/* ============================================================
   Lab 3 – Trigger Test Script
   Note: This test inserts, updates and deletes one dummy HSE row.
   ============================================================ */
DECLARE @TestIncidentID BIGINT;

INSERT INTO dbo.HSEIncidents
(
    IncidentDate,
    SiteID,
    DepartmentID,
    IncidentType,
    Severity,
    ReportedByEmployeeID,
    Description,
    CorrectiveAction,
    ClosureStatus
)
VALUES
(
    CAST(GETDATE() AS DATE),
    1,
    1,
    'Near Miss',
    'Low',
    1,
    'Trigger test incident',
    'Initial corrective action',
    'Open'
);

SET @TestIncidentID = SCOPE_IDENTITY();

UPDATE dbo.HSEIncidents
SET Severity = 'High',
    ClosureStatus = 'Under Investigation'
WHERE IncidentID = @TestIncidentID;

DELETE FROM dbo.HSEIncidents
WHERE IncidentID = @TestIncidentID;

SELECT TOP 10 *
FROM dbo.HSEIncidentAudit
ORDER BY AuditID DESC;
GO

/* ============================================================
   Lab 4 – Transaction Management Stored Procedure
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.usp_CreateShipmentWithInventoryIssue
    @CustomerID INT,
    @ProductID INT,
    @FromSiteID INT,
    @Quantity DECIMAL(18,3),
    @UnitPriceOMR DECIMAL(18,3),
    @CreatedByEmployeeID INT,
    @NewShipmentID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Shipments
        (
            ShipmentDate,
            CustomerID,
            ProductID,
            FromSiteID,
            TransportMode,
            Quantity,
            UnitPriceOMR,
            CurrencyCode,
            DeliveryStatus
        )
        VALUES
        (
            CAST(GETDATE() AS DATE),
            @CustomerID,
            @ProductID,
            @FromSiteID,
            'Road Tanker',
            @Quantity,
            @UnitPriceOMR,
            'OMR',
            'Dispatched'
        );

        SET @NewShipmentID = SCOPE_IDENTITY();

        INSERT INTO dbo.InventoryTransactions
        (
            TransactionDate,
            SiteID,
            ProductID,
            TransactionType,
            Quantity,
            UnitOfMeasure,
            ReferenceDocument,
            CreatedByEmployeeID
        )
        VALUES
        (
            SYSUTCDATETIME(),
            @FromSiteID,
            @ProductID,
            'Issue',
            @Quantity,
            'BBL',
            CONCAT('SHIPMENT-', @NewShipmentID),
            @CreatedByEmployeeID
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Test successful transaction
DECLARE @ShipmentID BIGINT;

EXEC dbo.usp_CreateShipmentWithInventoryIssue
    @CustomerID = 1,
    @ProductID = 1,
    @FromSiteID = 1,
    @Quantity = 100.000,
    @UnitPriceOMR = 35.500,
    @CreatedByEmployeeID = 1,
    @NewShipmentID = @ShipmentID OUTPUT;

SELECT @ShipmentID AS NewShipmentID;
GO

/* ============================================================
   Lab 5 – Table Variable for High Downtime Wells
   ============================================================ */
DECLARE @HighDowntimeWells TABLE
(
    WellID INT NOT NULL,
    TotalDowntimeHours DECIMAL(18,2) NOT NULL,
    TotalOilBarrels DECIMAL(18,2) NOT NULL
);

INSERT INTO @HighDowntimeWells
(
    WellID,
    TotalDowntimeHours,
    TotalOilBarrels
)
SELECT
    WellID,
    SUM(DowntimeHours) AS TotalDowntimeHours,
    SUM(OilBarrels) AS TotalOilBarrels
FROM dbo.ProductionDaily
GROUP BY WellID
HAVING SUM(DowntimeHours) > 20;

SELECT TOP 10
    WellID,
    TotalDowntimeHours,
    TotalOilBarrels
FROM @HighDowntimeWells
ORDER BY TotalDowntimeHours DESC;
GO

/* ============================================================
   Optional Challenge Solution – Stored Procedure using TVF + Table Variable
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.usp_GetHighDowntimeWells
    @StartDate DATE,
    @EndDate DATE,
    @MinimumDowntimeHours DECIMAL(18,2) = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @HighDowntimeWells TABLE
    (
        WellID INT NOT NULL,
        TotalOilBarrels DECIMAL(18,2) NOT NULL,
        TotalGasMMscf DECIMAL(18,3) NOT NULL,
        TotalWaterBarrels DECIMAL(18,2) NOT NULL,
        TotalDowntimeHours DECIMAL(18,2) NOT NULL
    );

    INSERT INTO @HighDowntimeWells
    (
        WellID,
        TotalOilBarrels,
        TotalGasMMscf,
        TotalWaterBarrels,
        TotalDowntimeHours
    )
    SELECT
        WellID,
        TotalOilBarrels,
        TotalGasMMscf,
        TotalWaterBarrels,
        TotalDowntimeHours
    FROM dbo.tvf_GetWellProductionSummary(@StartDate, @EndDate)
    WHERE TotalDowntimeHours > @MinimumDowntimeHours;

    SELECT
        h.WellID,
        w.WellName,
        h.TotalOilBarrels,
        h.TotalGasMMscf,
        h.TotalWaterBarrels,
        h.TotalDowntimeHours
    FROM @HighDowntimeWells h
    INNER JOIN dbo.Wells w
        ON h.WellID = w.WellID
    ORDER BY h.TotalDowntimeHours DESC;
END;
GO

-- Test optional challenge procedure
EXEC dbo.usp_GetHighDowntimeWells
    @StartDate = '2026-01-01',
    @EndDate = '2026-06-30',
    @MinimumDowntimeHours = 20;
GO