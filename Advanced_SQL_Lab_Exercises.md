# Advanced SQL Server Lab Exercises – Oil & Gas Database

## Audience
This lab is designed for participants who already understand `SELECT`, `JOIN`, `GROUP BY`, filtering, and basic SQL Server table relationships.

## Database
Use the `OmanOilGasDB` database created earlier.

```sql
USE OmanOilGasDB;
GO
```

---

# Lab 1 – Functions: Scalar Function and Table-Valued Function

## Business Scenario
The operations and refinery teams need reusable database logic so that calculations are consistent across reports.

## Exercise 1A – Create a Scalar Function for Refinery Yield

Create a scalar function named:

```sql
dbo.fn_CalculateYieldPercent
```

The function should:

- Accept two input values:
  - `@InputVolumeBBL`
  - `@OutputVolumeBBL`
- Return the refinery yield percentage
- Return `0` if input volume is `0` or `NULL`
- Return value as `DECIMAL(10,2)`

### Expected Usage

```sql
SELECT TOP 10
    BatchID,
    InputVolumeBBL,
    OutputVolumeBBL,
    dbo.fn_CalculateYieldPercent(InputVolumeBBL, OutputVolumeBBL) AS YieldPercent
FROM dbo.RefineryBatches;
```

---

## Exercise 1B – Create a Table-Valued Function for Well Production

Create an inline table-valued function named:

```sql
dbo.tvf_GetWellProductionSummary
```

The function should accept:

- `@StartDate`
- `@EndDate`

The function should return:

- `WellID`
- Total oil produced
- Total gas produced
- Total water produced
- Total downtime hours

### Expected Usage

```sql
SELECT *
FROM dbo.tvf_GetWellProductionSummary('2026-01-01', '2026-06-30');
```

---

# Lab 2 – Stored Procedures

## Business Scenario
The operations manager wants a reusable stored procedure to retrieve high-level production performance for a date range.

## Exercise 2 – Create a Stored Procedure for Site Production Summary

Create a stored procedure named:

```sql
dbo.usp_GetSiteProductionSummary
```

The stored procedure should:

- Accept `@StartDate` and `@EndDate`
- Return production summary by site
- Include:
  - Site ID
  - Site name
  - Total oil barrels
  - Total gas volume
  - Total water barrels
  - Total downtime hours
- Sort by highest oil production first

### Expected Usage

```sql
EXEC dbo.usp_GetSiteProductionSummary
    @StartDate = '2026-01-01',
    @EndDate = '2026-06-30';
```

---

# Lab 3 – Triggers: Insert, Update and Delete

## Business Scenario
The HSE team wants an audit trail whenever incident data is inserted, updated, or deleted.

## Exercise 3A – Create an Audit Table

Create a table named:

```sql
dbo.HSEIncidentAudit
```

The audit table should capture:

- Audit ID
- Incident ID
- Action type: `INSERT`, `UPDATE`, or `DELETE`
- Old severity
- New severity
- Old closure status
- New closure status
- Audit date
- Login name

---

## Exercise 3B – Create an INSERT Trigger

Create a trigger named:

```sql
dbo.trg_HSEIncidents_Insert_Audit
```

The trigger should insert one audit row whenever a new HSE incident is added.

---

## Exercise 3C – Create an UPDATE Trigger

Create a trigger named:

```sql
dbo.trg_HSEIncidents_Update_Audit
```

The trigger should insert an audit row whenever an existing incident is updated.

---

## Exercise 3D – Create a DELETE Trigger

Create a trigger named:

```sql
dbo.trg_HSEIncidents_Delete_Audit
```

The trigger should insert an audit row whenever an incident is deleted.

---

# Lab 4 – Transaction Management

## Business Scenario
A shipment dispatch must be recorded safely. If shipment creation fails, inventory movement should not be saved. If inventory movement fails, shipment should not be saved.

## Exercise 4 – Create a Stored Procedure with Transaction Handling

Create a stored procedure named:

```sql
dbo.usp_CreateShipmentWithInventoryIssue
```

The procedure should:

- Accept customer, product, site, quantity, unit price and employee details
- Insert a record into `dbo.Shipments`
- Insert a matching `Issue` record into `dbo.InventoryTransactions`
- Use transaction handling
- Use `TRY...CATCH`
- Commit transaction if both inserts succeed
- Roll back transaction if any insert fails
- Return the newly created shipment ID

---

# Lab 5 – Table Variables

## Business Scenario
Management wants to quickly identify high downtime wells without creating permanent tables.

## Exercise 5 – Use a Table Variable for Temporary Analysis

Write a query that:

- Declares a table variable named `@HighDowntimeWells`
- Inserts wells where total downtime is greater than 20 hours
- Stores:
  - Well ID
  - Total downtime hours
  - Total oil barrels
- Returns the top 10 wells by downtime

---

# Optional Challenge – Combine Concepts

Create a stored procedure that:

- Uses a table variable
- Calls the table-valued function from Lab 1B
- Returns wells with high downtime for a given date range

Suggested name:

```sql
dbo.usp_GetHighDowntimeWells
```