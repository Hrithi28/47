# 🔍 SQL Developer Internship — Task 6: Subqueries & Nested Queries

## 📌 Objective
Use subqueries in SELECT, WHERE, and FROM clauses to write advanced, nested SQL logic.

---

## 📁 Files

| File | Run order |
|---|---|
| `task1_schema.sql` | 1st |
| `task2_dml.sql` | 2nd |
| `task6_subqueries.sql` | 3rd |

---

## 🧠 Subquery Types

### Types at a glance
| Type | Returns | Used in |
|---|---|---|
| **Scalar** | 1 row, 1 col | SELECT, WHERE =, HAVING |
| **Column** | N rows, 1 col | WHERE IN / NOT IN |
| **Table** | N rows, N cols | FROM (derived table) |
| **Correlated** | varies (reruns per outer row) | WHERE EXISTS/correlated = |

---

### 1. Scalar Subquery — single value
```sql
-- Products priced above the overall average
SELECT name, price
FROM   products
WHERE  price > (SELECT AVG(price) FROM products);

-- Mini dashboard using multiple scalars
SELECT
  (SELECT COUNT(*) FROM customers)          AS customers,
  (SELECT ROUND(SUM(total_amount),2) FROM orders) AS revenue;
```

### 2. IN / NOT IN
```sql
-- Customers who HAVE ordered
WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders);

-- Customers who have NEVER ordered
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders
                          WHERE customer_id IS NOT NULL);
-- ⚠ Always add IS NOT NULL with NOT IN to avoid unexpected empty results
```

### 3. EXISTS / NOT EXISTS
```sql
-- EXISTS stops at the first match → faster than IN on large tables
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id
);

-- NOT EXISTS — no matching row found
WHERE NOT EXISTS (
  SELECT 1 FROM reviews r WHERE r.product_id = p.product_id
);
```

### 4. Correlated Subquery
```sql
-- Runs once per row of the outer query
-- References outer query columns
SELECT p.name, p.price,
  (SELECT AVG(p2.price) FROM products p2
   WHERE p2.category_id = p.category_id) AS cat_avg  -- correlated!
FROM products p;
```

### 5. Derived Table (FROM subquery)
```sql
-- Subquery in FROM = virtual table, must have alias
SELECT *
FROM (
  SELECT customer_id, COUNT(*) AS orders, SUM(total_amount) AS spent
  FROM   orders
  GROUP  BY customer_id
) AS customer_summary      -- ← alias required
WHERE orders > 1;
```

### 6. ANY / ALL
```sql
WHERE price > ANY (SELECT price FROM products WHERE category_id = 3)
-- > at least one value → > minimum

WHERE price > ALL (SELECT price FROM products WHERE category_id = 3)
-- > every value → > maximum
```

---

## 📋 Query Index

| # | Description | Concept |
|---|---|---|
| 2A | Products above average price | Scalar in WHERE |
| 2B | Price vs avg per row | Scalar in SELECT column |
| 2D | Dashboard: all stats in one row | Multiple scalars in SELECT |
| 3A | Customers who ordered | IN |
| 3B | Customers who never ordered | NOT IN + NULL guard |
| 3F | Customers who bought Electronics (2 levels) | Nested IN |
| 4A | Most expensive product | = with MAX() |
| 4D | Customer with most orders | Derived table in HAVING |
| 5A | Customers with orders (EXISTS) | EXISTS |
| 5B | Customers with no orders (NOT EXISTS) | NOT EXISTS |
| 6A | Price vs category average (correlated) | Correlated subquery |
| 6C | Products above category avg price | Correlated in WHERE |
| 7A | Customer summary then filter | Derived table (FROM) |
| 7B | Top products by revenue | Nested derived tables |
| 8A/8B | ANY vs ALL comparison | ANY / ALL |
| 9A | Top spender per city | Window + derived table |
| 9C | Same query 3 ways | Scalar vs JOIN vs window |

---

## ⚡ Performance: IN vs EXISTS vs JOIN

| Approach | Best when |
|---|---|
| `IN (SELECT ...)` | Small subquery result set |
| `EXISTS (SELECT 1 ...)` | Large tables; stops at first match |
| `JOIN` | Best performance generally; optimizer-friendly |
| Derived table | Need to filter/aggregate on summary results |

---

## 💡 Interview Q&A

**1. What is a subquery?**
A SELECT statement nested inside another SQL statement. The inner query executes first; its result is passed to the outer query.

**2. Subquery vs JOIN?**
Both combine data from multiple tables. Subqueries are often more readable for filtering logic. JOINs are generally faster because the optimizer handles them better. Correlated subqueries can be much slower — a JOIN is usually preferable.

**3. What is a correlated subquery?**
A subquery that references columns from the outer query. It re-executes for every row of the outer query, making it O(n×m) in the worst case.

**4. Can subqueries return multiple rows?**
Yes — column subqueries (used with IN/NOT IN) return one column with multiple rows. Table subqueries (used in FROM) return multiple rows and columns. Scalar subqueries must return exactly one row, one column.

**5. How does EXISTS work?**
EXISTS returns TRUE if the subquery returns at least one row, FALSE if it returns no rows. It short-circuits — stops scanning as soon as one match is found, making it efficient for existence checks.

**6. Performance effects of subqueries?**
Scalar/column subqueries run once and are fast. Correlated subqueries run once per outer row — avoid on large tables. EXISTS is faster than IN for large datasets. Derived tables are computed once and cached.

**7. What is a scalar subquery?**
A subquery that returns exactly one row and one column. Can be used anywhere a single value is expected: `WHERE price = (SELECT MAX(price) FROM products)`.

**8. Where can subqueries be used?**
SELECT clause (scalar), WHERE clause (=, IN, EXISTS, ANY, ALL), FROM clause (derived table), HAVING clause (scalar), INSERT/UPDATE/DELETE statements.

**9. Can a subquery be in the FROM clause?**
Yes — this is called a derived table or inline view. It must be given an alias: `FROM (SELECT ...) AS alias`. The outer query treats it like a regular table.

**10. What is a derived table?**
A subquery used in the FROM clause that acts as a temporary virtual table within the query. It's computed first, then the outer query runs against its result. Does not persist after the query ends.
