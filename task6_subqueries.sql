-- ================================================================
--   E-COMMERCE DATABASE — SUBQUERIES AND NESTED QUERIES
--   Task 6: Subqueries in SELECT, WHERE, FROM
--   SQL Developer Internship — ElevateLabs
--
--   Run AFTER task1_schema.sql + task2_dml.sql
--   Concepts: Scalar subquery, Correlated subquery, IN, NOT IN,
--             EXISTS, NOT EXISTS, ANY, ALL, Derived table (FROM),
--             Subquery in SELECT, Nested subqueries
-- ================================================================

USE ecommerce_db;

-- ================================================================
-- SECTION 1 — WHAT IS A SUBQUERY?
-- A subquery is a SELECT statement nested inside another query.
-- The inner query runs first; its result is used by the outer query.
-- ================================================================

/*
  TYPES OF SUBQUERIES:
  ┌─────────────────────────────────────────────────────┐
  │ 1. SCALAR    → returns exactly ONE value (1 row, 1 col) │
  │ 2. ROW       → returns ONE row, multiple columns       │
  │ 3. COLUMN    → returns ONE column, multiple rows       │
  │ 4. TABLE     → returns multiple rows & columns         │
  │ 5. CORRELATED→ references outer query (runs per row)   │
  └─────────────────────────────────────────────────────┘

  WHERE subqueries can appear:
  · SELECT clause  (scalar only)
  · WHERE  clause  (scalar, column, table via IN/EXISTS)
  · FROM   clause  (table subquery → "derived table")
  · HAVING clause  (scalar or column)
*/

-- ================================================================
-- SECTION 2 — SCALAR SUBQUERY
-- Returns exactly ONE value (one row, one column).
-- Can be used anywhere a single value is valid.
-- ================================================================

-- 2A. Scalar subquery in WHERE — find products above average price
SELECT
    name,
    price,
    price - (SELECT AVG(price) FROM products) AS above_avg_by
FROM  products
WHERE price > (SELECT AVG(price) FROM products)   -- scalar: single value
ORDER BY price DESC;

-- 2B. Scalar subquery in SELECT column — compare each price to avg
--     The subquery runs ONCE and its result appears in every row
SELECT
    name,
    price,
    ROUND((SELECT AVG(price) FROM products), 2)     AS avg_all_products,
    ROUND(price - (SELECT AVG(price) FROM products), 2) AS diff_from_avg,
    CASE
        WHEN price > (SELECT AVG(price) FROM products) THEN '↑ Above avg'
        WHEN price < (SELECT AVG(price) FROM products) THEN '↓ Below avg'
        ELSE '= At avg'
    END AS position
FROM  products
ORDER BY price DESC;

-- 2C. Scalar subquery in HAVING
SELECT
    category_id,
    ROUND(AVG(price), 2) AS avg_price
FROM  products
GROUP BY category_id
HAVING AVG(price) > (SELECT AVG(price) FROM products)  -- vs global avg
ORDER BY avg_price DESC;

-- 2D. Multiple scalar subqueries — mini dashboard
SELECT
    (SELECT COUNT(*) FROM customers)                          AS total_customers,
    (SELECT COUNT(*) FROM orders)                             AS total_orders,
    (SELECT COUNT(*) FROM orders WHERE status = 'delivered')  AS delivered_orders,
    (SELECT ROUND(SUM(total_amount), 2) FROM orders)          AS total_revenue,
    (SELECT ROUND(AVG(total_amount), 2) FROM orders)          AS avg_order_value,
    (SELECT MAX(price) FROM products)                         AS most_expensive_product;

-- ================================================================
-- SECTION 3 — SUBQUERY IN WHERE WITH IN / NOT IN
-- Use when you need a list of values to filter against.
-- IN  → match any value in the subquery result
-- NOT IN → exclude all values in the subquery result
-- ================================================================

-- 3A. IN — customers who have placed at least one order
SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM  customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id      -- subquery returns a column of values
    FROM orders
);

-- 3B. NOT IN — customers who have NEVER placed an order
SELECT
    customer_id,
    first_name,
    last_name,
    email
FROM  customers
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE customer_id IS NOT NULL    -- ⚠ always exclude NULLs with NOT IN!
);

-- 3C. IN — products that have been ordered at least once
SELECT
    product_id,
    name,
    price,
    stock_qty
FROM  products
WHERE product_id IN (
    SELECT DISTINCT product_id
    FROM order_items
)
ORDER BY name;

-- 3D. NOT IN — products that have NEVER been ordered
SELECT
    product_id,
    name,
    price,
    stock_qty
FROM  products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM order_items
    WHERE product_id IS NOT NULL
)
ORDER BY name;

-- 3E. IN with aggregated subquery — orders above average amount
SELECT
    order_id,
    customer_id,
    total_amount,
    status
FROM  orders
WHERE total_amount IN (
    SELECT total_amount
    FROM   orders
    WHERE  total_amount > (SELECT AVG(total_amount) FROM orders)
)
ORDER BY total_amount DESC;

-- 3F. Nested IN — customers who ordered Technology products
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS customer_name
FROM  customers
WHERE customer_id IN (
    SELECT DISTINCT o.customer_id
    FROM   orders      o
    JOIN   order_items oi ON o.order_id    = oi.order_id
    JOIN   products    p  ON oi.product_id = p.product_id
    WHERE  p.category_id IN (
        SELECT category_id           -- nested subquery (2 levels deep)
        FROM   categories
        WHERE  name = 'Electronics'
    )
)
ORDER BY customer_id;

-- ================================================================
-- SECTION 4 — SUBQUERY WITH = / > / < (single value comparison)
-- When you know the subquery returns exactly ONE row, ONE column
-- you can use comparison operators directly.
-- ================================================================

-- 4A. = — find the most expensive product
SELECT name, price
FROM  products
WHERE price = (SELECT MAX(price) FROM products);

-- 4B. = — find the order with the highest total
SELECT order_id, customer_id, total_amount, status
FROM  orders
WHERE total_amount = (SELECT MAX(total_amount) FROM orders);

-- 4C. > — products more expensive than the cheapest product
SELECT name, price
FROM  products
WHERE price > (SELECT MIN(price) FROM products)
ORDER BY price;

-- 4D. Find customer(s) who placed the most orders
SELECT
    customer_id,
    CONCAT(first_name,' ',last_name) AS customer_name,
    COUNT(*) AS order_count
FROM  customers
JOIN  orders USING (customer_id)
GROUP BY customer_id, first_name, last_name
HAVING COUNT(*) = (
    SELECT MAX(order_count)
    FROM  (
        SELECT customer_id, COUNT(*) AS order_count
        FROM   orders
        GROUP  BY customer_id
    ) AS counts                      -- derived table (used in HAVING)
);

-- ================================================================
-- SECTION 5 — EXISTS / NOT EXISTS
-- EXISTS checks if the subquery returns ANY rows (true/false).
-- More efficient than IN for large datasets —
-- stops scanning as soon as ONE match is found.
-- The correlated subquery runs ONCE PER OUTER ROW.
-- ================================================================

-- 5A. EXISTS — customers who have at least one order
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    c.email
FROM  customers c
WHERE EXISTS (
    SELECT 1                        -- SELECT 1 is convention; value doesn't matter
    FROM   orders o
    WHERE  o.customer_id = c.customer_id   -- correlated: references outer 'c'
);

-- 5B. NOT EXISTS — customers with NO orders
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name
FROM  customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM   orders o
    WHERE  o.customer_id = c.customer_id
);

-- 5C. EXISTS — products that have received at least one review
SELECT
    p.product_id,
    p.name,
    p.price
FROM  products p
WHERE EXISTS (
    SELECT 1
    FROM   reviews r
    WHERE  r.product_id = p.product_id
)
ORDER BY p.product_id;

-- 5D. NOT EXISTS — products with NO reviews
SELECT
    p.product_id,
    p.name,
    p.price
FROM  products p
WHERE NOT EXISTS (
    SELECT 1
    FROM   reviews r
    WHERE  r.product_id = p.product_id
);

-- 5E. EXISTS — orders that have a completed payment
SELECT
    o.order_id,
    o.status,
    o.total_amount
FROM  orders o
WHERE EXISTS (
    SELECT 1
    FROM   payments py
    WHERE  py.order_id = o.order_id
      AND  py.status   = 'completed'
);

-- ================================================================
-- SECTION 6 — CORRELATED SUBQUERY
-- A subquery that references columns from the OUTER query.
-- Runs ONCE FOR EVERY ROW of the outer query (can be slow on
-- large tables — consider rewriting as JOIN if performance matters).
-- ================================================================

-- 6A. Correlated subquery — each product's price vs its category avg
SELECT
    p.name,
    p.price,
    ROUND(
        (SELECT AVG(p2.price)
         FROM   products p2
         WHERE  p2.category_id = p.category_id),  -- references outer p
        2
    ) AS category_avg_price,
    ROUND(
        p.price - (SELECT AVG(p2.price)
                   FROM products p2
                   WHERE p2.category_id = p.category_id),
        2
    ) AS diff_from_category_avg
FROM  products p
ORDER BY p.category_id, p.price DESC;

-- 6B. Correlated subquery — each customer's total spend
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer,
    (
        SELECT COALESCE(ROUND(SUM(o.total_amount), 2), 0)
        FROM   orders o
        WHERE  o.customer_id = c.customer_id   -- correlated reference
    ) AS total_spent,
    (
        SELECT COUNT(*)
        FROM   orders o
        WHERE  o.customer_id = c.customer_id
    ) AS order_count
FROM  customers c
ORDER BY total_spent DESC;

-- 6C. Correlated subquery — find products priced above their category average
SELECT
    p.name,
    p.price,
    c.name AS category
FROM  products  p
JOIN  categories c ON p.category_id = c.category_id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM   products p2
    WHERE  p2.category_id = p.category_id   -- correlated: same category
)
ORDER BY c.name, p.price DESC;

-- ================================================================
-- SECTION 7 — SUBQUERY IN FROM CLAUSE (Derived Table)
-- A subquery in FROM acts as a temporary "virtual table".
-- Must be given an alias. The outer query treats it like a real table.
-- ================================================================

-- 7A. Derived table — customer order summary, then filter on result
SELECT *
FROM (
    SELECT
        c.customer_id,
        CONCAT(c.first_name,' ',c.last_name)   AS customer_name,
        COUNT(o.order_id)                       AS order_count,
        ROUND(SUM(o.total_amount), 2)           AS total_spent,
        ROUND(AVG(o.total_amount), 2)           AS avg_order
    FROM  customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS customer_summary                           -- alias required
WHERE order_count > 0                           -- filter on derived result
ORDER BY total_spent DESC;

-- 7B. Derived table — rank products by revenue, then filter top half
SELECT
    product_name,
    category,
    total_units_sold,
    product_revenue
FROM (
    SELECT
        p.name                                        AS product_name,
        c.name                                        AS category,
        SUM(oi.quantity)                              AS total_units_sold,
        ROUND(SUM(oi.quantity * oi.unit_price), 2)   AS product_revenue
    FROM order_items oi
    JOIN products    p  ON oi.product_id = p.product_id
    JOIN categories  c  ON p.category_id = c.category_id
    GROUP BY p.product_id, p.name, c.name
) AS product_revenue_summary
WHERE product_revenue > (
    SELECT AVG(product_revenue)
    FROM (
        SELECT ROUND(SUM(oi2.quantity * oi2.unit_price), 2) AS product_revenue
        FROM   order_items oi2
        GROUP  BY oi2.product_id
    ) AS avg_sub                               -- nested derived table
)
ORDER BY product_revenue DESC;

-- 7C. Derived table — payment method stats with percentage
SELECT
    method,
    usage_count,
    total_collected,
    ROUND(usage_count * 100.0 / total_methods, 1) AS pct_of_total
FROM (
    SELECT
        method,
        COUNT(*)                     AS usage_count,
        ROUND(SUM(amount), 2)        AS total_collected,
        SUM(COUNT(*)) OVER ()        AS total_methods  -- window function
    FROM  payments
    GROUP BY method
) AS payment_stats
ORDER BY usage_count DESC;

-- ================================================================
-- SECTION 8 — SUBQUERY WITH ANY / ALL
-- ANY  → true if ANY value in subquery matches the condition
-- ALL  → true if ALL values in subquery match the condition
-- ================================================================

-- 8A. ANY — products more expensive than ANY Self-Help book
SELECT name, price
FROM  products
WHERE price > ANY (
    SELECT p.price
    FROM   products p
    JOIN   categories c ON p.category_id = c.category_id
    WHERE  c.name = 'Self-Help'
)
ORDER BY price;

-- 8B. ALL — products more expensive than ALL Self-Help books
SELECT name, price
FROM  products
WHERE price > ALL (
    SELECT p.price
    FROM   products p
    JOIN   categories c ON p.category_id = c.category_id
    WHERE  c.name = 'Self-Help'
)
ORDER BY price;

-- 8C. = ANY is equivalent to IN
SELECT name FROM products
WHERE category_id = ANY (
    SELECT category_id FROM categories WHERE name IN ('Books','Sports')
);
-- Same as:
SELECT name FROM products
WHERE category_id IN (
    SELECT category_id FROM categories WHERE name IN ('Books','Sports')
);

-- ================================================================
-- SECTION 9 — PRACTICAL BUSINESS QUERIES WITH SUBQUERIES
-- ================================================================

-- 9A. Top-spending customer per city
SELECT
    city,
    customer_name,
    total_spent
FROM (
    SELECT
        a.city,
        CONCAT(c.first_name,' ',c.last_name)  AS customer_name,
        ROUND(SUM(o.total_amount), 2)          AS total_spent,
        ROW_NUMBER() OVER (
            PARTITION BY a.city ORDER BY SUM(o.total_amount) DESC
        ) AS rnk
    FROM   customers c
    JOIN   orders    o ON c.customer_id = o.customer_id
    JOIN   addresses a ON c.customer_id = a.customer_id AND a.is_default = 1
    GROUP  BY a.city, c.customer_id, c.first_name, c.last_name
) AS ranked
WHERE rnk = 1
ORDER BY total_spent DESC;

-- 9B. Products with above-average stock in their category
SELECT
    p.name,
    p.stock_qty,
    c.name AS category,
    ROUND(
        (SELECT AVG(p2.stock_qty)
         FROM products p2
         WHERE p2.category_id = p.category_id), 1
    ) AS category_avg_stock
FROM  products   p
JOIN  categories c ON p.category_id = c.category_id
WHERE p.stock_qty > (
    SELECT AVG(p2.stock_qty)
    FROM   products p2
    WHERE  p2.category_id = p.category_id
)
ORDER BY c.name, p.stock_qty DESC;

-- 9C. Orders with total above overall average (3 ways compared)
-- Way 1: Scalar subquery
SELECT order_id, total_amount FROM orders
WHERE total_amount > (SELECT AVG(total_amount) FROM orders);

-- Way 2: JOIN with derived table (often faster)
SELECT o.order_id, o.total_amount
FROM   orders o
JOIN   (SELECT ROUND(AVG(total_amount),2) AS avg_val FROM orders) AS avg_t
ON     o.total_amount > avg_t.avg_val;

-- Way 3: Window function (most modern)
SELECT order_id, total_amount
FROM (
    SELECT order_id, total_amount,
           AVG(total_amount) OVER () AS overall_avg
    FROM   orders
) AS t
WHERE total_amount > overall_avg;

-- ================================================================
-- SECTION 10 — SUBQUERY PERFORMANCE NOTE
-- ================================================================
/*
  PERFORMANCE TIPS:
  ─────────────────────────────────────────────────────────────
  · Scalar subquery in SELECT runs ONCE per row of outer query
    → Use JOIN or window functions for large tables

  · Correlated subquery runs ONCE per row → can be O(n×m)
    → Rewrite as JOIN or derived table when possible

  · IN vs EXISTS:
    - IN   materialises the full inner result first
    - EXISTS stops at the first match → faster on large tables
    - For small subquery results: IN is fine
    - For large subquery results: prefer EXISTS

  · Derived table (FROM subquery) is computed once
    → Usually efficient; can be replaced by CTE (WITH clause)

  · Use EXPLAIN SELECT … to see the query execution plan
    and identify slow subqueries.
  ─────────────────────────────────────────────────────────────

  QUICK REFERENCE:
  ─────────────────────────────────────────────────────────────
  WHERE col = (SELECT ...)          → scalar (= one value)
  WHERE col IN (SELECT ...)         → column (= list of values)
  WHERE col NOT IN (SELECT ...)     → exclude list (watch NULLs!)
  WHERE EXISTS (SELECT 1 FROM ...)  → existence check
  WHERE NOT EXISTS (SELECT 1 ...)   → non-existence check
  WHERE col > ANY (SELECT ...)      → > at least one
  WHERE col > ALL (SELECT ...)      → > every one
  SELECT (SELECT ...) AS alias      → scalar in column
  FROM (SELECT ...) AS alias        → derived table
  HAVING agg > (SELECT ...)         → scalar in HAVING
  ─────────────────────────────────────────────────────────────
*/
