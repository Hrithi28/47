# 🔗 SQL Developer Internship — Task 5: SQL Joins

## 📌 Objective
Learn to combine data from multiple tables using all SQL join types.

---

## 📁 Files

| File | Run order |
|---|---|
| `task1_schema.sql` | 1st — creates tables |
| `task2_dml.sql` | 2nd — inserts data |
| `task5_joins.sql` | 3rd — all join queries |

---

## 🧠 Join Types Covered

### Visual Reference
```
Table A: {1, 2, 3}    Table B: {1, 2, 4}

INNER JOIN  →  {1, 2}          ← only both
LEFT JOIN   →  {1, 2, 3}       ← all A + matches
RIGHT JOIN  →  {1, 2, 4}       ← all B + matches
FULL OUTER  →  {1, 2, 3, 4}    ← all from both
CROSS JOIN  →  {1×1, 1×2, ...} ← every combination
```

---

### 1. INNER JOIN
Returns only rows that match in **both** tables.
```sql
SELECT c.first_name, o.order_id, o.total_amount
FROM   customers c
INNER JOIN orders o ON c.customer_id = o.customer_id;
-- Customers with no orders are NOT shown
```

### 2. LEFT JOIN
Returns **all rows from the left table** + matching rows from right. Non-matching right rows → `NULL`.
```sql
SELECT c.first_name, o.order_id
FROM   customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;
-- Customers with no orders appear with NULL order columns

-- Find customers who NEVER ordered:
... LEFT JOIN orders o ON ...
WHERE o.order_id IS NULL;
```

### 3. RIGHT JOIN
Returns **all rows from the right table** + matching rows from left. Equivalent to LEFT JOIN with tables swapped.
```sql
SELECT p.name, oi.order_id
FROM order_items oi
RIGHT JOIN products p ON oi.product_id = p.product_id;
-- Products never ordered appear with NULL order_items columns
```

### 4. FULL OUTER JOIN
Returns **all rows from both tables**. MySQL simulates it with `LEFT JOIN UNION RIGHT JOIN`.
```sql
SELECT c.customer_id, o.order_id
FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id
UNION
SELECT c.customer_id, o.order_id
FROM customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;
```

### 5. CROSS JOIN
Every row in A × every row in B — **Cartesian product**. 3 rows × 5 rows = 15 rows.
```sql
SELECT c.name, py.method
FROM categories c CROSS JOIN (SELECT DISTINCT method FROM payments) m;
```

### 6. SELF JOIN
A table joined **to itself** using aliases — useful for hierarchies, duplicates, comparisons.
```sql
SELECT p1.name, p2.name, ABS(p1.price - p2.price) AS diff
FROM products p1
JOIN products p2 ON p1.category_id = p2.category_id
               AND p1.product_id < p2.product_id;
```

### 7. Multi-table JOIN (4–5 tables)
```sql
SELECT c.first_name, o.order_id, p.name, cat.name, oi.quantity
FROM customers   c
JOIN orders      o   ON c.customer_id = o.customer_id
JOIN order_items oi  ON o.order_id    = oi.order_id
JOIN products    p   ON oi.product_id = p.product_id
JOIN categories  cat ON p.category_id = cat.category_id;
```

---

## 📋 Query Index

| Section | Queries | Key concept |
|---|---|---|
| 1 | 1A–1D | INNER JOIN — basic, with WHERE, 3-table |
| 2 | 2A–2E | LEFT JOIN — include NULLs, find non-matches, COALESCE |
| 3 | 3A–3D | RIGHT JOIN — all right rows, find unordered products |
| 4 | 4A–4B | FULL OUTER JOIN — simulated with UNION |
| 5 | 5A–5C | Multi-table JOINs — 3, 4, 5 tables |
| 6 | 6A–6B | CROSS JOIN — Cartesian product |
| 7 | 7A–7B | SELF JOIN — same-city customers, similar-price products |
| 8 | 8A–8B | JOIN without FK — city name, non-equi join |
| 9 | 9A–9C | Business reports — order summary, revenue by category |

---

## 💡 Interview Q&A

**1. INNER vs LEFT JOIN?**
INNER JOIN returns only matching rows from both tables. LEFT JOIN returns all rows from the left table plus any matches from the right — non-matching rows get NULL for right table columns.

**2. What is FULL OUTER JOIN?**
Returns all rows from both tables with NULLs where there's no match on either side. MySQL doesn't support it natively — simulate with `LEFT JOIN UNION RIGHT JOIN`.

**3. Can joins be nested?**
Yes — you can use subqueries in the FROM clause and JOIN to them, or chain multiple JOINs. Each JOIN adds one more table to the working result set.

**4. How to join more than 2 tables?**
Chain JOIN clauses: `FROM a JOIN b ON ... JOIN c ON ... JOIN d ON ...` — each new JOIN links to any previously joined table via a shared key.

**5. What is a CROSS JOIN?**
Produces the Cartesian product — every row of table A paired with every row of table B. m rows × n rows = m×n result rows. No ON clause. Useful for generating combinations.

**6. What is a NATURAL JOIN?**
Automatically joins tables on all columns sharing the same name. Avoid in production — fragile if column names change and hard to reason about.

**7. Can you join tables without a foreign key?**
Yes — you can JOIN on any columns with compatible data types (`ON a.city = b.city`). FK constraints just enforce data integrity; they're not required for the JOIN syntax to work.

**8. What is a self-join?**
A table joined to itself using two different aliases. Used for hierarchical data (employee → manager), finding duplicates, or comparing rows within the same table.

**9. What causes a Cartesian product?**
A CROSS JOIN, or forgetting the ON clause in a regular JOIN. Two tables with 1000 rows each without a JOIN condition produce 1,000,000 rows.

**10. How to optimize joins?**
Join on indexed columns (PKs/FKs are auto-indexed). Filter with WHERE before joining. Use INNER JOIN when possible (fewer rows than outer joins). Use `EXPLAIN SELECT ...` to inspect the query execution plan.
