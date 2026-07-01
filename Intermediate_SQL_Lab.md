
# 📘 Intermediate Level Lab Exercises (Analysis)

## 🔹 Exercise 1 – Maintenance Cost per Well

### 🎯 Business Scenario
Operations team wants to identify **high-cost wells** to optimise maintenance budget.

### ✅ Task
- Calculate total maintenance cost per well
- Show Well ID and total cost
- Sort by highest cost first

### ⭐ Bonus
- Show wells where cost > 50,000

---

## 🔹 Exercise 2 – Inventory Usage Tracking

### 🎯 Business Scenario
Supply chain team wants to analyse product consumption trends.

### ✅ Task
- Calculate total issued quantity per product
- Filter for TransactionType = 'Issue'
- Sort from highest to lowest

### ⭐ Bonus
- Show top 10 products

---

## 🔹 Exercise 3 – HSE Incident Breakdown

### 🎯 Business Scenario
HSE team wants visibility on incident severity trends.

### ✅ Task
- Count incidents by Severity and Incident Type

### ⭐ Bonus
- Filter only High and Critical incidents

---

## 🔹 Exercise 4 – Maintenance Performance Analysis

### 🎯 Business Scenario
Management wants to track maintenance efficiency.

### ✅ Task
- Count work orders by Status

### ⭐ Bonus
- Calculate completion percentage

---

# ✅ Solutions

## Solution 1
```sql
SELECT WellID, SUM(CostOMR) AS TotalMaintenanceCost
FROM WellMaintenance
GROUP BY WellID
ORDER BY TotalMaintenanceCost DESC;
```

---

## Solution 2
```sql
SELECT ProductID, SUM(Quantity)
FROM InventoryTransactions
WHERE TransactionType='Issue'
GROUP BY ProductID
ORDER BY SUM(Quantity) DESC;
```

---

## Solution 3
```sql
SELECT Severity, IncidentType, COUNT(*)
FROM HSEIncidents
GROUP BY Severity, IncidentType;
```

---

## Solution 4
```sql
SELECT Status, COUNT(*)
FROM WellMaintenance
GROUP BY Status;
```
