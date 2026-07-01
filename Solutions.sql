

# SQL Lab Solutions

-- Solution 1
SELECT TOP 10 WellID, SUM(OilBarrels) AS TotalOil
FROM ProductionDaily
WHERE ProductionDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY WellID
ORDER BY TotalOil DESC;

-- Solution 2
SELECT BatchID,(OutputVolumeBBL/InputVolumeBBL)*100 AS YieldPercent
FROM RefineryBatches;

-- Solution 3
SELECT WellID, SUM(CostOMR)
FROM WellMaintenance
GROUP BY WellID;

-- Solution 4
SELECT Severity, COUNT(*)
FROM HSEIncidents
GROUP BY Severity;

-- Solution 5
SELECT ProductID, SUM(Quantity)
FROM InventoryTransactions
WHERE TransactionType='Issue'
GROUP BY ProductID;

-- Solution 6
SELECT TOP 5 CustomerID, SUM(Quantity*UnitPriceOMR) Revenue
FROM Shipments
GROUP BY CustomerID
ORDER BY Revenue DESC;

-- Solution 7
SELECT * FROM Suppliers WHERE RiskRating='High';

-- Solution 8
SELECT SiteID, COUNT(*) FROM Employees GROUP BY SiteID;

-- Solution 9
SELECT TOP 10 WellID, SUM(DowntimeHours)
FROM ProductionDaily
GROUP BY WellID
ORDER BY SUM(DowntimeHours) DESC;

-- Solution 10pro
SELECT ProductCategory, AVG(LengthKM)
FROM Pipelines
GROUP BY ProductCategory;
