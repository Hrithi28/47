# 📊 SQL Developer Internship — Task 4: Aggregate Functions & Grouping

## 📌 Objective
Use aggregate functions and grouping to summarize and analyze e-commerce data.

---

## 📁 Files

| File | Run order | Description |
|---|---|---|
| `task1_schema.sql` | 1st | Database schema |
| `task2_dml.sql` | 2nd | Data population |
| `task4_aggregates.sql` | 3rd | Aggregate queries |

---

## 🧠 Concepts Covered

### Aggregate Functions
| Function | What it does | NULL behaviour |
|---|---|---|
| `COUNT(*)` | Counts all rows | Includes NULLs |
| `COUNT(col)` | Counts non-NULL values | Ignores NULLs |
| `COUNT(DISTINCT col)` | Counts unique values | Ignores NULLs |
| `SUM(col)` | Total of all values | Ignores NULLs |
| `AVG(col)` | Arithmetic mean | Ignores NULLs |
| `MIN(col)` | Smallest value | Ignores NULLs |
| `MAX(col)` | Largest value | Ignores NULLs |
| `ROUND(val, n)` | Round to n decimals | — |

### GROUP BY
```sql
-- One result row per unique status value
SELECT status, COUNT(*), SUM(total_amount)
FROM   orders
GROUP  BY status;

-- Group by multiple columns → one row per unique combination
SELECT method, status, COUNT(*)
FROM   payments
GROUP  BY method, status;
```

### WHERE vs HAVING
```sql
-- WHERE: filters individual rows BEFORE grouping
-- HAVING: filters groups AFTER aggregation

SELECT category_id, COUNT(*), AVG(price)
FROM   products
WHERE  stock_qty > 0          -- ← row filter (before GROUP BY)
GROUP  BY category_id
HAVING AVG(price) > 500;      -- ← group filter (after GROUP BY)
```

### SQL Execution Order
```
FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
```

---

## 📋 Query Index

| # | Query description | Key concept |
|---|---|---|
| 1A | COUNT(*) vs COUNT(col) | NULL counting |
| 1B | SUM of revenue and stock | SUM |
| 1C | AVG price, order value, rating | AVG + ROUND |
| 1D | MIN/MAX price and date | MIN, MAX |
| 1E | COUNT DISTINCT customers | COUNT DISTINCT |
| 2A | Orders by status | Basic GROUP BY |
| 2B | Products per category with stats | GROUP BY + JOIN |
| 2C | Orders per customer | LEFT JOIN + GROUP BY |
| 2D | Payment method distribution | GROUP BY + ORDER BY |
| 2E | Inventory value per category | SUM expression |
| 3A | Orders by status + month | Multi-column GROUP BY |
| 3B | Reviews by product + rating | Multi-column GROUP BY |
| 4A | Categories with >1 product | HAVING COUNT |
| 4B | Customers who spent >₹1000 | HAVING SUM |
| 4C | Products rated >3.5 | HAVING AVG |
| 4E | WHERE + HAVING together | Combined filtering |
| 6A | Sales dashboard by status | Business report |
| 6B | Best-selling products | Joined aggregation |
| 6C | Customer leaderboard | LEFT JOIN + GROUP BY |
| 6D | Highest price per category | MAX per group |
| 6E | Monthly revenue trend | DATE_FORMAT + GROUP BY |
| 6F | Product review summary | CASE inside SUM |

---

## 💡 Interview Q&A

**1. What is GROUP BY?**
Groups rows sharing the same value(s) in specified columns into summary rows. Each group produces one output row with aggregate values.

**2. Difference between WHERE and HAVING?**
WHERE filters individual rows before grouping. HAVING filters groups after aggregation. Rule: if you need an aggregate function in the condition → HAVING; otherwise → WHERE.

**3. COUNT(*) vs COUNT(column)?**
`COUNT(*)` counts every row including NULLs. `COUNT(col)` counts only rows where `col` is not NULL. Use `COUNT(*) - COUNT(col)` to count NULLs.

**4. Can you GROUP BY multiple columns?**
Yes: `GROUP BY col1, col2` creates one output row per unique *combination* of col1 and col2.

**5. What is ROUND() used for?**
`ROUND(value, n)` rounds a number to `n` decimal places. `ROUND(AVG(price), 2)` ensures money values show exactly 2 decimal places.

**6. How do you find the highest value by group?**
`SELECT department, MAX(salary) FROM employees GROUP BY department` — MAX applies per group, not globally.

**7. Default behavior of GROUP BY?**
MySQL sorts results by the grouped column(s) by default (implementation-specific). Always add explicit `ORDER BY` for guaranteed ordering.

**8. Explain AVG and SUM.**
`SUM` adds all values in a column. `AVG` divides that sum by the count of non-NULL rows. Both ignore NULLs.

**9. How to count distinct values?**
`SELECT COUNT(DISTINCT customer_id) FROM orders` — counts each unique customer_id only once regardless of how many orders they placed.

**10. What is an aggregate function?**
A function that takes a set of rows and returns a single summary value: COUNT, SUM, AVG, MIN, MAX. They collapse multiple rows into one per group.
