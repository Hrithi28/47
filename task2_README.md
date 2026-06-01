# 🗄️ SQL Developer Internship — Task 2: Data Insertion & NULL Handling

## 📌 Objective
Practice inserting, updating, and deleting data in a relational database while correctly handling NULL values.

---

## 📁 Files

| File | Description |
|---|---|
| `task1_schema.sql` | Database schema from Task 1 (run this first) |
| `task2_dml.sql`    | All DML operations — INSERT, UPDATE, DELETE, NULL handling |

---

## ▶️ How to Run

```sql
-- Step 1: Run schema (Task 1)
source task1_schema.sql;

-- Step 2: Run DML operations (Task 2)
source task2_dml.sql;
```

Or paste contents into **DB Fiddle**, **SQLiteStudio**, or **MySQL Workbench** and execute.

---

## 🧠 Key Concepts Demonstrated

### 1. INSERT INTO

| Type | Example in file |
|---|---|
| Full row insert | `INSERT INTO customers (...all cols...) VALUES (...)` |
| Partial insert (specific columns only) | `INSERT INTO customers (first_name, last_name, email)` — phone omitted → NULL |
| INSERT using SELECT | `INSERT INTO order_summary (...) SELECT ... FROM customers JOIN orders ...` |
| Bulk insert (multiple rows) | Single `INSERT INTO` with multiple `VALUES (...)` rows |

### 2. NULL Handling

| Technique | Used for |
|---|---|
| Omitting optional column → `NULL` | `phone`, `description`, `comment`, `paid_at` |
| `IS NULL` filter | Find unpaid orders, customers without phones |
| `COALESCE(col, fallback)` | Display friendly label when value is NULL |
| `IFNULL(col, fallback)` | Alternate MySQL shorthand |
| `CASE WHEN ... IS NULL THEN ...` | Conditional NULL display in results |
| `DEFAULT` constraint | `created_at DEFAULT CURRENT_TIMESTAMP`, `country DEFAULT 'India'` |

### 3. UPDATE

| Scenario | Description |
|---|---|
| Single row | Add phone to one customer |
| Multiple rows | Fill NULL descriptions for all matching products |
| Subquery UPDATE | Recalculate `total_amount` from `order_items` |
| JOIN UPDATE | Deduct stock for all products in a given order |
| Conditional batch | Mark old pending orders as cancelled |

### 4. DELETE

| Scenario | Description |
|---|---|
| Delete with WHERE | Remove a specific review by ID |
| Conditional batch delete | Remove order_items for cancelled orders, then orders |
| ON DELETE CASCADE | Deleting an order auto-deletes its payment row |
| Safe orphan delete | Remove customers who never placed an order |

### 5. ROLLBACK (Transaction Safety)

```sql
START TRANSACTION;
    DELETE FROM products WHERE stock_qty < 30;
ROLLBACK;
-- All deleted rows are fully restored
```

---

## 💡 Interview Q&A

**1. Difference between NULL and 0?**
NULL means the value is unknown or missing. 0 is an actual integer value. `WHERE phone = 0` and `WHERE phone IS NULL` return completely different result sets.

**2. What is a DEFAULT constraint?**
A value automatically assigned to a column when no value is provided during INSERT. Example: `created_at DATETIME DEFAULT CURRENT_TIMESTAMP`.

**3. How does IS NULL work?**
`IS NULL` is the correct operator to test for NULL. `= NULL` always returns false because NULL is not equal to anything, including itself.

**4. How do you update multiple rows?**
Use `UPDATE table SET col = value WHERE condition` — any rows matching the WHERE clause are updated simultaneously.

**5. Can we insert partial values?**
Yes — specify only the columns you want to fill. Omitted columns receive their DEFAULT value or NULL (if the column allows it).

**6. What happens if a NOT NULL field is left empty?**
MySQL throws `ERROR 1364: Field 'x' doesn't have a default value` and the INSERT fails.

**7. How do you rollback a deletion?**
Wrap the DELETE in a transaction: `START TRANSACTION; DELETE ...; ROLLBACK;`. The data is fully restored as long as COMMIT hasn't been called.

**8. Can we insert into specific columns only?**
Yes: `INSERT INTO customers (first_name, last_name, email) VALUES ('A','B','c@d.com')` — phone gets NULL, created_at gets DEFAULT.

**9. How to insert values using SELECT?**
`INSERT INTO target_table (col1, col2) SELECT expr1, expr2 FROM source_table WHERE ...`

**10. What is ON DELETE CASCADE?**
A foreign key option that automatically deletes child rows when the parent row is deleted. In our schema, `payments.order_id` has `ON DELETE CASCADE` — deleting an order removes its payment automatically.

---

## 🔍 NULL Audit Query

```sql
SELECT 'customers.phone' AS column_name, COUNT(*)-COUNT(phone) AS null_count FROM customers
UNION ALL
SELECT 'products.description',            COUNT(*)-COUNT(description)           FROM products
UNION ALL
SELECT 'payments.paid_at',                COUNT(*)-COUNT(paid_at)               FROM payments
UNION ALL
SELECT 'reviews.comment',                 COUNT(*)-COUNT(comment)               FROM reviews;
```
