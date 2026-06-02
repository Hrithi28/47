# 🔍 SQL Developer Internship — Task 3: Basic SELECT Queries

## 📌 Objective
Extract and filter data from the e-commerce database using SELECT queries — covering projection, filtering, sorting, limiting, and pattern matching.

---

## 📁 Files

| File | Description |
|---|---|
| `task1_schema.sql` | Database schema (run first) |
| `task2_dml.sql` | Data population (run second) |
| `task3_select_queries.sql` | All SELECT queries for Task 3 |

---

## ▶️ How to Run

```sql
source task1_schema.sql;   -- create tables
source task2_dml.sql;      -- insert data
source task3_select_queries.sql;  -- run queries
```

Or paste into **MySQL Workbench**, **DB Browser for SQLite**, or **DB Fiddle**.

---

## 🧠 Concepts Covered

### SELECT & Projection
```sql
SELECT * FROM products;                        -- all columns
SELECT name, price FROM products;             -- specific columns
SELECT name, price * 0.9 AS sale FROM products; -- computed + alias
```

### WHERE Filtering
```sql
WHERE price > 1000                 -- comparison
WHERE phone IS NULL                -- NULL check
WHERE status != 'cancelled'        -- not equal
```

### AND / OR / NOT
```sql
WHERE price > 500 AND stock_qty > 40
WHERE status = 'pending' OR status = 'processing'
WHERE (category_id = 1 OR category_id = 2) AND price < 2000
```

### IN vs =
```sql
-- = matches one value
WHERE status = 'pending'

-- IN matches multiple — cleaner than chained ORs
WHERE status IN ('pending', 'processing', 'shipped')
```

### LIKE — Pattern Matching
| Pattern | Meaning |
|---|---|
| `LIKE 'W%'` | Starts with W |
| `LIKE '%a%'` | Contains 'a' anywhere |
| `LIKE '%com'` | Ends with 'com' |
| `LIKE '_____'` | Exactly 5 characters |

### BETWEEN
```sql
WHERE price BETWEEN 500 AND 1500           -- numbers (inclusive)
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'  -- dates
WHERE first_name BETWEEN 'A' AND 'M'       -- alphabetical
```

### ORDER BY
```sql
ORDER BY price ASC        -- ascending (default)
ORDER BY price DESC       -- descending
ORDER BY last_name, first_name  -- multi-column
```

### LIMIT + OFFSET (Pagination)
```sql
LIMIT 5                   -- top 5 rows
LIMIT 5 OFFSET 5          -- rows 6–10 (page 2)
```

### DISTINCT
```sql
SELECT DISTINCT status FROM orders;        -- unique statuses only
SELECT DISTINCT method, status FROM payments; -- unique combinations
```

---

## 📊 Query Index

| # | Query | Key Concept |
|---|---|---|
| 1A | `SELECT * FROM customers` | SELECT all |
| 1B | `SELECT first_name, email FROM customers` | Projection |
| 2A–C | Column & table aliases | AS keyword |
| 3A–F | WHERE with =, >, <, IS NULL | Basic filtering |
| 4A–D | AND, OR, NOT combinations | Logical operators |
| 5A–D | IN, NOT IN, IN with subquery | IN operator |
| 6A–F | LIKE with %, _ wildcards | Pattern matching |
| 7A–D | BETWEEN on numbers, dates, strings | Range filter |
| 8A–E | ORDER BY ASC, DESC, multi-column | Sorting |
| 9A–D | LIMIT, LIMIT + OFFSET | Pagination |
| 10A–D | DISTINCT single and multi-column | Deduplication |
| 11A–E | Combined queries using all concepts | Real-world scenarios |

---

## 💡 Interview Q&A

**1. What does SELECT * do?**
Returns every column from the table. Convenient but inefficient — always prefer listing specific columns in production.

**2. How do you filter rows?**
Use a `WHERE` clause: `WHERE price > 1000 AND category_id = 1`.

**3. What is `LIKE '%value%'`?**
A pattern match. `%` is a wildcard for any number of characters. `LIKE '%Steel%'` matches any string containing "Steel" anywhere.

**4. What is BETWEEN used for?**
Range filtering — `BETWEEN 500 AND 1500` is inclusive of both endpoints. Works on numbers, dates, and strings.

**5. How do you limit output rows?**
`LIMIT n` — returns the first `n` rows. Use with `ORDER BY` to make it meaningful. Add `OFFSET m` to skip rows (pagination).

**6. Difference between = and IN?**
`=` matches exactly one value. `IN (a, b, c)` matches any value in the list — cleaner than writing multiple OR conditions.

**7. How to sort in descending order?**
Add `DESC` after the column name: `ORDER BY price DESC`.

**8. What is aliasing?**
Giving a column or table a temporary name using `AS`: `SELECT price * 0.9 AS sale_price`. The alias only exists in that query's output.

**9. Explain DISTINCT.**
Removes duplicate rows from results. `SELECT DISTINCT status FROM orders` returns each unique status only once.

**10. What is the default sort order?**
Without `ORDER BY`, MySQL's row order is undefined (arbitrary). When `ORDER BY` is used without ASC/DESC, it defaults to **ASC** (ascending).

