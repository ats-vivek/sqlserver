
# ✅ Intermediate SQL Lab – Solutions (Separate File)

## 🔹 Solution 1 – Maintenance Cost per Well

```sql
SELECT 
    WellID,
    SUM(CostOMR) AS TotalMaintenanceCost
FROM WellMaintenance
GROUP BY WellID
ORDER BY TotalMaintenanceCost DESC;
```

### ⭐ Bonus
```sql
SELECT 
    WellID,
    SUM(CostOMR) AS TotalMaintenanceCost
FROM WellMaintenance
GROUP BY WellID
HAVING SUM(CostOMR) > 50000
ORDER BY TotalMaintenanceCost DESC;
```

---

## 🔹 Solution 2 – Inventory Usage Tracking

```sql
SELECT 
    ProductID,
    SUM(Quantity) AS TotalIssuedQuantity
FROM InventoryTransactions
WHERE TransactionType = 'Issue'
GROUP BY ProductID
ORDER BY TotalIssuedQuantity DESC;
```

### ⭐ Bonus
```sql
SELECT TOP 10 
    ProductID,
    SUM(Quantity) AS TotalIssuedQuantity
FROM InventoryTransactions
WHERE TransactionType = 'Issue'
GROUP BY ProductID
ORDER BY TotalIssuedQuantity DESC;
```

---

## 🔹 Solution 3 – HSE Incident Breakdown

```sql
SELECT 
    Severity,
    IncidentType,
    COUNT(*) AS IncidentCount
FROM HSEIncidents
GROUP BY Severity, IncidentType
ORDER BY Severity;
```

### ⭐ Bonus
```sql
SELECT 
    Severity,
    IncidentType,
    COUNT(*) AS IncidentCount
FROM HSEIncidents
WHERE Severity IN ('High', 'Critical')
GROUP BY Severity, IncidentType;
```

---

## 🔹 Solution 4 – Maintenance Performance Analysis

```sql
SELECT 
    Status,
    COUNT(*) AS WorkOrderCount
FROM WellMaintenance
GROUP BY Status;
```

### ⭐ Bonus (Completion Percentage)
```sql
SELECT 
    CAST(
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
    AS DECIMAL(5,2)) AS CompletionPercentage
FROM WellMaintenance;
```

---

# 📌 Notes for Trainer

- Share this file only **after lab completion**
- Use queries for live walkthrough
- Encourage participants to improve queries (joins, filters, visuals)
