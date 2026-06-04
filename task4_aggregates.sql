-- ================================================================
--   E-COMMERCE DATABASE — AGGREGATE FUNCTIONS & GROUPING
--   Task 4: Aggregate Functions and Grouping
--   SQL Developer Internship — ElevateLabs
--
--   Run AFTER task1_schema.sql + task2_dml.sql
--   Concepts: COUNT, SUM, AVG, MIN, MAX, GROUP BY,
--             HAVING, ROUND, DISTINCT, Multiple Grouping
-- ================================================================

USE ecommerce_db;

-- ================================================================
-- SECTION 1 — AGGREGATE FUNCTIONS (without grouping)
-- An aggregate function runs on ALL rows and returns ONE value.
-- ================================================================

-- 1A. COUNT(*) — counts every row including NULLs
--     COUNT(column) — counts only non-NULL values in that column
SELECT
    COUNT(*)              AS total_rows,          -- all rows
    COUNT(phone)          AS rows_with_phone,     -- non-NULL only
    COUNT(*) - COUNT(phone) AS rows_without_phone -- NULL count trick
FROM customers;

-- 1B. SUM — total of all values in a column
SELECT
    SUM(total_amount)           AS total_revenue,
    SUM(stock_qty)              AS total_stock_units
FROM orders o, products p;
-- simpler version:
SELECT SUM(total_amount) AS total_revenue FROM orders;
SELECT SUM(stock_qty)    AS total_stock   FROM products;

-- 1C. AVG — arithmetic mean (ignores NULLs automatically)
SELECT
    ROUND(AVG(price),        2) AS avg_product_price,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    ROUND(AVG(rating),       1) AS avg_review_rating
FROM products, orders, reviews;
-- cleaner per-table:
SELECT ROUND(AVG(price),        2) AS avg_product_price  FROM products;
SELECT ROUND(AVG(total_amount), 2) AS avg_order_value    FROM orders;
SELECT ROUND(AVG(rating),       1) AS avg_review_rating  FROM reviews;

-- 1D. MIN and MAX
SELECT
    MIN(price)         AS cheapest_product,
    MAX(price)         AS most_expensive_product,
    MAX(price) - MIN(price) AS price_range
FROM products;

SELECT
    MIN(order_date)    AS first_order_date,
    MAX(order_date)    AS latest_order_date,
    MIN(total_amount)  AS smallest_order,
    MAX(total_amount)  AS largest_order
FROM orders;

-- 1E. COUNT DISTINCT — count unique values only
--     Concept: How to count distinct values?
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers_who_ordered,
    COUNT(DISTINCT status)      AS distinct_order_statuses,
    COUNT(DISTINCT category_id) AS categories_with_products
FROM orders, products;
-- cleaner:
SELECT COUNT(DISTINCT customer_id) AS unique_buyers      FROM orders;
SELECT COUNT(DISTINCT status)      AS distinct_statuses  FROM orders;

-- ================================================================
-- SECTION 2 — GROUP BY
-- Splits rows into groups and applies aggregate per group.
-- Every column in SELECT must be either:
--   a) in GROUP BY clause, OR
--   b) inside an aggregate function
-- ================================================================

-- 2A. Count orders per status (most common GROUP BY pattern)
SELECT
    status,
    COUNT(*)           AS order_count,
    SUM(total_amount)  AS revenue_by_status
FROM orders
GROUP BY status;

-- 2B. Revenue and product count per category
SELECT
    c.name                          AS category,
    COUNT(p.product_id)             AS product_count,
    ROUND(AVG(p.price),   2)        AS avg_price,
    MIN(p.price)                    AS min_price,
    MAX(p.price)                    AS max_price,
    SUM(p.stock_qty)                AS total_stock
FROM categories c
JOIN products    p ON c.category_id = p.category_id
GROUP BY c.category_id, c.name;

-- 2C. Orders per customer — how many orders each customer placed
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    COUNT(o.order_id)                        AS total_orders,
    ROUND(SUM(o.total_amount), 2)            AS total_spent,
    ROUND(AVG(o.total_amount), 2)            AS avg_order_value
FROM customers   c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- 2D. Payment method distribution
SELECT
    method                           AS payment_method,
    COUNT(*)                         AS usage_count,
    ROUND(SUM(amount), 2)            AS total_amount_collected,
    ROUND(AVG(amount), 2)            AS avg_payment_amount
FROM payments
GROUP BY method
ORDER BY usage_count DESC;

-- 2E. Stock value per category
--     SUM(price * stock_qty) = total inventory value
SELECT
    c.name                              AS category,
    COUNT(p.product_id)                 AS products,
    ROUND(SUM(p.price * p.stock_qty), 2) AS inventory_value
FROM categories c
JOIN products    p ON c.category_id = p.category_id
GROUP BY c.category_id, c.name
ORDER BY inventory_value DESC;

-- ================================================================
-- SECTION 3 — MULTIPLE COLUMN GROUP BY
-- Concept: Can you group by multiple columns? YES.
-- Creates one row per unique combination of the grouped columns.
-- ================================================================

-- 3A. Orders grouped by status AND month
SELECT
    status,
    DATE_FORMAT(order_date, '%Y-%m')   AS order_month,
    COUNT(*)                           AS orders_in_month,
    ROUND(SUM(total_amount), 2)        AS monthly_revenue
FROM orders
GROUP BY status, DATE_FORMAT(order_date, '%Y-%m')
ORDER BY order_month, status;

-- 3B. Reviews grouped by product AND rating
SELECT
    p.name                         AS product_name,
    r.rating,
    COUNT(*)                       AS review_count
FROM reviews  r
JOIN products p ON r.product_id = p.product_id
GROUP BY r.product_id, p.name, r.rating
ORDER BY p.name, r.rating DESC;

-- 3C. Payment method + status combination counts
SELECT
    method,
    status                         AS payment_status,
    COUNT(*)                       AS count,
    ROUND(SUM(amount), 2)          AS total
FROM payments
GROUP BY method, status
ORDER BY method, status;

-- ================================================================
-- SECTION 4 — HAVING
-- Concept: WHERE filters ROWS before grouping.
--           HAVING filters GROUPS after aggregation.
-- ================================================================

-- 4A. Categories with more than 1 product
--     (cannot use WHERE COUNT(*) > 1 — must use HAVING)
SELECT
    c.name              AS category,
    COUNT(p.product_id) AS product_count
FROM categories c
JOIN products    p ON c.category_id = p.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(p.product_id) > 1        -- filter groups, not rows
ORDER BY product_count DESC;

-- 4B. Customers who have spent more than ₹1000 total
SELECT
    CONCAT(c.first_name,' ',c.last_name)  AS customer,
    COUNT(o.order_id)                     AS total_orders,
    ROUND(SUM(o.total_amount), 2)         AS total_spent
FROM customers  c
JOIN orders     o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(o.total_amount) > 1000
ORDER BY total_spent DESC;

-- 4C. Products with average rating above 3.5
SELECT
    p.name                          AS product,
    COUNT(r.review_id)              AS review_count,
    ROUND(AVG(r.rating), 1)         AS avg_rating
FROM products p
JOIN reviews  r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name
HAVING AVG(r.rating) > 3.5
ORDER BY avg_rating DESC;

-- 4D. Payment methods used more than once
SELECT
    method,
    COUNT(*)   AS times_used
FROM payments
GROUP BY method
HAVING COUNT(*) > 1;

-- 4E. WHERE + HAVING together
--     WHERE filters individual rows FIRST,
--     then GROUP BY + HAVING act on the remaining rows
SELECT
    c.name                           AS category,
    COUNT(p.product_id)              AS products_in_range,
    ROUND(AVG(p.price), 2)           AS avg_price
FROM categories c
JOIN products    p ON c.category_id = p.category_id
WHERE  p.price BETWEEN 400 AND 2000   -- filter rows first (WHERE)
GROUP BY c.category_id, c.name
HAVING COUNT(p.product_id) >= 1       -- filter groups (HAVING)
ORDER BY avg_price DESC;

-- ================================================================
-- SECTION 5 — ROUND() and number formatting
-- ================================================================

-- 5A. ROUND(value, decimal_places)
SELECT
    name,
    price,
    ROUND(price, 0)           AS rounded_to_whole,
    ROUND(price * 1.18, 2)    AS price_with_gst,      -- 18% GST
    ROUND(price * 0.90, 2)    AS price_after_10pct_off
FROM products
ORDER BY price;

-- 5B. ROUND with aggregate
SELECT
    ROUND(AVG(price),      0) AS avg_price_rounded,
    ROUND(SUM(price),     -2) AS total_rounded_to_hundreds,
    ROUND(SUM(stock_qty * price), 2) AS total_inventory_value
FROM products;

-- ================================================================
-- SECTION 6 — PRACTICAL BUSINESS REPORTS
-- (Combining everything: GROUP BY + HAVING + ORDER BY + ROUND)
-- ================================================================

-- 6A. Sales dashboard — revenue by order status
SELECT
    status                              AS order_status,
    COUNT(*)                            AS order_count,
    ROUND(SUM(total_amount),    2)      AS total_revenue,
    ROUND(AVG(total_amount),    2)      AS avg_order_value,
    ROUND(MIN(total_amount),    2)      AS min_order,
    ROUND(MAX(total_amount),    2)      AS max_order
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

-- 6B. Best-selling products by quantity ordered
SELECT
    p.name                              AS product,
    c.name                              AS category,
    SUM(oi.quantity)                    AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id)         AS orders_containing_this
FROM order_items oi
JOIN products    p  ON oi.product_id = p.product_id
JOIN categories  c  ON p.category_id = c.category_id
GROUP BY p.product_id, p.name, c.name
ORDER BY total_units_sold DESC;

-- 6C. Customer leaderboard — top spenders
SELECT
    CONCAT(c.first_name,' ',c.last_name)    AS customer,
    COUNT(DISTINCT o.order_id)              AS orders_placed,
    ROUND(SUM(o.total_amount), 2)           AS lifetime_value,
    ROUND(AVG(o.total_amount), 2)           AS avg_order_value,
    MAX(o.order_date)                       AS last_order_date
FROM customers  c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY lifetime_value DESC;

-- 6D. Highest-priced product per category
--     Concept: How do you find the highest value by group?
SELECT
    c.name                      AS category,
    MAX(p.price)                AS highest_price,
    MIN(p.price)                AS lowest_price,
    ROUND(AVG(p.price), 2)      AS avg_price,
    COUNT(p.product_id)         AS product_count
FROM categories c
JOIN products    p ON c.category_id = p.category_id
GROUP BY c.category_id, c.name
ORDER BY highest_price DESC;

-- 6E. Monthly order trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m')    AS month,
    COUNT(*)                            AS orders,
    ROUND(SUM(total_amount), 2)         AS monthly_revenue,
    ROUND(AVG(total_amount), 2)         AS avg_order_value
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 6F. Product review summary
SELECT
    p.name                              AS product,
    COUNT(r.review_id)                  AS review_count,
    ROUND(AVG(r.rating), 2)             AS avg_rating,
    MIN(r.rating)                       AS lowest_rating,
    MAX(r.rating)                       AS highest_rating,
    SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END) AS five_star_count
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name
ORDER BY avg_rating DESC;

-- ================================================================
-- SECTION 7 — EXECUTION ORDER (key concept)
-- SQL clauses execute in this order:
--   1. FROM / JOIN   — choose tables
--   2. WHERE         — filter rows
--   3. GROUP BY      — group remaining rows
--   4. HAVING        — filter groups
--   5. SELECT        — compute output columns
--   6. ORDER BY      — sort output
--   7. LIMIT         — restrict rows returned
-- ================================================================

-- Demonstrating full clause order in one query:
SELECT
    c.name                           AS category,      -- 5. SELECT
    COUNT(p.product_id)              AS product_count,
    ROUND(AVG(p.price), 2)           AS avg_price,
    ROUND(SUM(p.stock_qty * p.price), 2) AS stock_value
FROM   categories c                                    -- 1. FROM
JOIN   products   p ON c.category_id = p.category_id  -- 1. JOIN
WHERE  p.stock_qty > 0                                 -- 2. WHERE (rows)
GROUP  BY c.category_id, c.name                        -- 3. GROUP BY
HAVING COUNT(p.product_id) >= 1                        -- 4. HAVING (groups)
ORDER  BY stock_value DESC                             -- 6. ORDER BY
LIMIT  10;                                             -- 7. LIMIT

-- ================================================================
-- QUICK REFERENCE
-- ================================================================
/*
  AGGREGATE FUNCTIONS:
  ─────────────────────────────────────────────────────────
  COUNT(*)         → count all rows (including NULLs)
  COUNT(col)       → count non-NULL values in col
  COUNT(DISTINCT col) → count unique non-NULL values
  SUM(col)         → total of all values
  AVG(col)         → arithmetic mean (ignores NULLs)
  MIN(col)         → smallest value
  MAX(col)         → largest value
  ROUND(val, n)    → round to n decimal places

  GROUP BY:
  ─────────────────────────────────────────────────────────
  SELECT col, AGG(col2)
  FROM   table
  GROUP  BY col;             -- one row per unique `col` value

  GROUP  BY col1, col2;      -- one row per unique combination

  HAVING vs WHERE:
  ─────────────────────────────────────────────────────────
  WHERE  col > value         -- filters ROWS  (before grouping)
  HAVING AGG(col) > value    -- filters GROUPS (after grouping)

  Rule: if it involves an aggregate function → use HAVING
        if it involves a raw column value    → use WHERE

  EXECUTION ORDER:
  FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT
  ─────────────────────────────────────────────────────────
*/
