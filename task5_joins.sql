-- ================================================================
--   E-COMMERCE DATABASE — SQL JOINS
--   Task 5: INNER, LEFT, RIGHT, FULL OUTER JOIN + extras
--   SQL Developer Internship — ElevateLabs
--
--   Run AFTER task1_schema.sql + task2_dml.sql
--   Concepts: INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN,
--             CROSS JOIN, SELF JOIN, Multi-table JOIN, Nested JOIN
-- ================================================================

USE ecommerce_db;

-- ================================================================
-- QUICK VISUAL REFERENCE (as comments)
-- ================================================================
/*
  TABLE A          TABLE B
  ┌────────┐       ┌────────┐
  │ 1      │       │ 1      │
  │ 2      │       │ 2      │
  │ 3      │       │ 4      │
  └────────┘       └────────┘

  INNER JOIN  → rows that exist in BOTH  A ∩ B  → {1, 2}
  LEFT JOIN   → all of A + matching B    A ⊇ ∩  → {1,2,3}  (3 has NULL for B cols)
  RIGHT JOIN  → all of B + matching A    B ⊇ ∩  → {1,2,4}  (4 has NULL for A cols)
  FULL OUTER  → all of A + all of B     A ∪ B  → {1,2,3,4} (NULLs where no match)
  CROSS JOIN  → every A row × every B row (Cartesian product)
*/

-- ================================================================
-- SECTION 1 — INNER JOIN
-- Returns ONLY rows that have a match in BOTH tables.
-- Rows without a match in either table are excluded.
-- Most commonly used join type.
-- ================================================================

-- 1A. Basic INNER JOIN — customers with their orders
--     Customers who have NEVER ordered are NOT shown
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.status,
    o.total_amount
FROM customers  c
INNER JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;

-- 1B. INNER JOIN — products with their category names
--     Products without a matching category are excluded
SELECT
    p.product_id,
    p.name          AS product_name,
    p.price,
    p.stock_qty,
    c.name          AS category
FROM products   p
INNER JOIN categories c ON p.category_id = c.category_id
ORDER BY c.name, p.price;

-- 1C. INNER JOIN — orders with payment details
SELECT
    o.order_id,
    o.status            AS order_status,
    o.total_amount,
    py.method           AS payment_method,
    py.status           AS payment_status,
    COALESCE(CAST(py.paid_at AS CHAR), 'Pending') AS paid_at
FROM orders   o
INNER JOIN payments py ON o.order_id = py.order_id
ORDER BY o.order_id;

-- 1D. INNER JOIN with WHERE — delivered orders only
SELECT
    CONCAT(c.first_name,' ',c.last_name)  AS customer,
    o.order_id,
    o.total_amount,
    py.method
FROM customers  c
INNER JOIN orders   o  ON c.customer_id = o.customer_id
INNER JOIN payments py ON o.order_id    = py.order_id
WHERE o.status = 'delivered';

-- ================================================================
-- SECTION 2 — LEFT JOIN (LEFT OUTER JOIN)
-- Returns ALL rows from the LEFT table.
-- Matching rows from the RIGHT table are included.
-- If NO match in right table → right table columns are NULL.
-- Key use: find rows in A that DON'T exist in B.
-- ================================================================

-- 2A. LEFT JOIN — ALL customers, even those with no orders
--     Customers with no orders will show NULL for order columns
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name)  AS customer_name,
    c.email,
    o.order_id,                           -- NULL if no order
    o.status,                             -- NULL if no order
    o.total_amount                        -- NULL if no order
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- 2B. LEFT JOIN — find customers who have NEVER placed an order
--     Classic pattern: LEFT JOIN + WHERE right_table_id IS NULL
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name)  AS customer_name,
    c.email
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL              -- no matching order row
ORDER BY c.customer_id;

-- 2C. LEFT JOIN — all categories including those with no products
SELECT
    c.category_id,
    c.name                  AS category,
    COUNT(p.product_id)     AS product_count,   -- 0 for empty categories
    COALESCE(ROUND(AVG(p.price),2), 0) AS avg_price
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_id, c.name
ORDER BY product_count DESC;

-- 2D. LEFT JOIN — all products, showing their reviews (if any)
SELECT
    p.product_id,
    p.name                                      AS product,
    r.rating,
    COALESCE(r.comment, '(no review)')         AS review_comment,
    CONCAT(c.first_name,' ',c.last_name)        AS reviewer
FROM products   p
LEFT JOIN reviews   r  ON p.product_id  = r.product_id
LEFT JOIN customers c  ON r.customer_id = c.customer_id
ORDER BY p.product_id, r.rating DESC;

-- 2E. LEFT JOIN with COALESCE — replace NULLs with meaningful labels
SELECT
    CONCAT(c.first_name,' ',c.last_name)       AS customer,
    COALESCE(CAST(o.order_id AS CHAR), 'No orders yet') AS order_info,
    COALESCE(o.status,        'N/A')           AS status,
    COALESCE(o.total_amount,  0)               AS amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;

-- ================================================================
-- SECTION 3 — RIGHT JOIN (RIGHT OUTER JOIN)
-- Returns ALL rows from the RIGHT table.
-- Matching rows from the LEFT table are included.
-- If NO match in left table → left table columns are NULL.
-- Less common than LEFT JOIN (you can always rewrite as LEFT JOIN
-- by swapping table order).
-- ================================================================

-- 3A. RIGHT JOIN — all orders, even if customer was deleted
--     (hypothetically — shows the concept)
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name)  AS customer_name,
    o.order_id,
    o.status,
    o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;

-- 3B. RIGHT JOIN — all products, even those not in any order
SELECT
    oi.order_id,
    oi.quantity,
    p.product_id,
    p.name          AS product_name,
    p.price
FROM order_items oi
RIGHT JOIN products p ON oi.product_id = p.product_id
ORDER BY p.product_id;

-- 3C. RIGHT JOIN — find products NEVER ordered
--     Pattern: RIGHT JOIN + WHERE left_table_key IS NULL
SELECT
    p.product_id,
    p.name      AS product_name,
    p.price,
    p.stock_qty
FROM order_items oi
RIGHT JOIN products p ON oi.product_id = p.product_id
WHERE oi.order_id IS NULL           -- no matching order_item row
ORDER BY p.product_id;

-- 3D. RIGHT JOIN rewritten as LEFT JOIN (equivalent)
--     These two queries return identical results:
-- RIGHT JOIN version:
SELECT c.customer_id, o.order_id, o.status
FROM   customers c RIGHT JOIN orders o ON c.customer_id = o.customer_id;

-- LEFT JOIN version (preferred — clearer to read):
SELECT c.customer_id, o.order_id, o.status
FROM   orders o LEFT JOIN customers c ON o.customer_id = c.customer_id;

-- ================================================================
-- SECTION 4 — FULL OUTER JOIN
-- Returns ALL rows from BOTH tables.
-- Where there's no match, NULL fills in for the missing side.
-- MySQL doesn't have FULL OUTER JOIN syntax directly —
-- simulate it with LEFT JOIN UNION RIGHT JOIN.
-- ================================================================

-- 4A. FULL OUTER JOIN — all customers + all orders
--     Customers with no orders show NULL order columns
--     Orders with no customer show NULL customer columns
SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name)  AS customer_name,
    o.order_id,
    o.status,
    o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id

UNION                               -- UNION removes duplicates

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name),
    o.order_id,
    o.status,
    o.total_amount
FROM customers c
RIGHT JOIN orders o ON c.customer_id = o.customer_id

ORDER BY customer_id, order_id;

-- 4B. FULL OUTER JOIN — all products + all order_items
--     Unordered products and orphan order_items both appear
SELECT
    p.product_id,
    p.name          AS product_name,
    oi.order_id,
    oi.quantity,
    oi.unit_price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id

UNION

SELECT
    p.product_id,
    p.name,
    oi.order_id,
    oi.quantity,
    oi.unit_price
FROM products p
RIGHT JOIN order_items oi ON p.product_id = oi.product_id

ORDER BY product_id, order_id;

-- ================================================================
-- SECTION 5 — MULTI-TABLE JOIN (3+ tables)
-- Concept: Can you join more than 2 tables? YES.
-- Each JOIN adds one more table to the result set.
-- ================================================================

-- 5A. 3-table JOIN — customers → orders → payments
SELECT
    CONCAT(c.first_name,' ',c.last_name)  AS customer,
    o.order_id,
    o.order_date,
    o.status            AS order_status,
    o.total_amount,
    py.method           AS payment_method,
    py.status           AS payment_status
FROM customers  c
JOIN orders     o  ON c.customer_id = o.customer_id
JOIN payments   py ON o.order_id    = py.order_id
ORDER BY o.order_date DESC;

-- 5B. 4-table JOIN — customers → orders → order_items → products
SELECT
    CONCAT(c.first_name,' ',c.last_name)  AS customer,
    o.order_id,
    p.name                                AS product,
    cat.name                              AS category,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price           AS line_total
FROM customers   c
JOIN orders      o   ON c.customer_id  = o.customer_id
JOIN order_items oi  ON o.order_id     = oi.order_id
JOIN products    p   ON oi.product_id  = p.product_id
JOIN categories  cat ON p.category_id  = cat.category_id
ORDER BY o.order_id, p.name;

-- 5C. 5-table JOIN — full order report with address
SELECT
    o.order_id,
    CONCAT(c.first_name,' ',c.last_name)  AS customer,
    CONCAT(a.city,', ',a.state)           AS delivery_location,
    p.name                                AS product,
    oi.quantity,
    py.method                             AS paid_via,
    py.status                             AS payment_status
FROM orders      o
JOIN customers   c   ON o.customer_id  = c.customer_id
JOIN addresses   a   ON o.address_id   = a.address_id
JOIN order_items oi  ON o.order_id     = oi.order_id
JOIN products    p   ON oi.product_id  = p.product_id
JOIN payments    py  ON o.order_id     = py.order_id
ORDER BY o.order_id;

-- ================================================================
-- SECTION 6 — CROSS JOIN
-- Every row from Table A × every row from Table B.
-- Produces Cartesian product — no ON condition.
-- m rows × n rows = m×n rows in result.
-- Use case: generate all combinations (e.g., size × color).
-- ================================================================

-- 6A. CROSS JOIN — every category × every payment method
--     Useful for building a "possibility matrix"
SELECT
    c.name      AS category,
    py_methods.method
FROM categories c
CROSS JOIN (
    SELECT DISTINCT method FROM payments
) AS py_methods
ORDER BY c.name, py_methods.method;

-- 6B. CROSS JOIN demo — small tables to show Cartesian product
--     3 categories × 5 orders = 15 rows
SELECT
    c.name      AS category,
    o.order_id,
    o.status
FROM categories c
CROSS JOIN orders o
ORDER BY c.name, o.order_id
LIMIT 15;   -- limit shown rows for clarity

-- ================================================================
-- SECTION 7 — SELF JOIN
-- A table joined to ITSELF.
-- Requires table aliases to distinguish the two "copies".
-- Use cases: employee-manager hierarchies, finding duplicates,
--            comparing rows within the same table.
-- ================================================================

-- 7A. SELF JOIN — find customers from the same city
--     (via their addresses — customers in the same city)
SELECT
    CONCAT(c1.first_name,' ',c1.last_name)  AS customer_1,
    CONCAT(c2.first_name,' ',c2.last_name)  AS customer_2,
    a1.city
FROM customers c1
JOIN customers c2 ON c1.customer_id <> c2.customer_id   -- not same customer
                  AND c1.customer_id < c2.customer_id    -- avoid duplicates (A-B & B-A)
JOIN addresses a1 ON c1.customer_id = a1.customer_id
JOIN addresses a2 ON c2.customer_id = a2.customer_id
WHERE a1.city = a2.city
ORDER BY a1.city;

-- 7B. SELF JOIN — find products in the same category with similar price
SELECT
    p1.name            AS product_1,
    p2.name            AS product_2,
    p1.price           AS price_1,
    p2.price           AS price_2,
    ABS(p1.price - p2.price)  AS price_difference
FROM products p1
JOIN products p2 ON p1.category_id = p2.category_id
                 AND p1.product_id  < p2.product_id       -- avoid duplicates
                 AND ABS(p1.price - p2.price) <= 200       -- within ₹200
ORDER BY price_difference;

-- ================================================================
-- SECTION 8 — JOIN WITHOUT FOREIGN KEY
-- Concept: Can you join tables without foreign key?
-- YES — you can join on any column with matching data types.
-- ================================================================

-- 8A. Join on matching city name (no FK defined between tables)
SELECT
    c.first_name,
    c.last_name,
    a.city,
    a.state
FROM customers c
JOIN addresses a ON c.customer_id = a.customer_id   -- PK/FK join
-- Now join to a derived table — no FK needed
JOIN (
    SELECT DISTINCT city FROM addresses WHERE state = 'Tamil Nadu'
) AS tn_cities ON a.city = tn_cities.city;           -- joining on city name

-- 8B. Non-equi join — products with price in different ranges
--     Join on a condition other than equality
SELECT
    p.name,
    p.price,
    CASE
        WHEN p.price <= 500  THEN 'Budget'
        WHEN p.price <= 1500 THEN 'Mid-range'
        ELSE                      'Premium'
    END AS price_tier
FROM products p
JOIN (
    SELECT 0 AS min_p, 500 AS max_p, 'Budget' AS tier
    UNION ALL SELECT 501, 1500, 'Mid-range'
    UNION ALL SELECT 1501, 99999, 'Premium'
) AS tiers ON p.price BETWEEN tiers.min_p AND tiers.max_p
ORDER BY p.price;

-- ================================================================
-- SECTION 9 — PRACTICAL BUSINESS JOIN QUERIES
-- ================================================================

-- 9A. Order summary report — complete picture per order
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name,' ',c.last_name)          AS customer,
    c.email,
    CONCAT(a.city,', ',a.state)                   AS ship_to,
    o.status,
    COUNT(oi.product_id)                          AS items_in_order,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)    AS calculated_total,
    o.total_amount                                AS stored_total,
    py.method                                     AS payment,
    py.status                                     AS paid
FROM orders      o
JOIN customers   c   ON o.customer_id = c.customer_id
JOIN addresses   a   ON o.address_id  = a.address_id
JOIN order_items oi  ON o.order_id    = oi.order_id
JOIN payments    py  ON o.order_id    = py.order_id
GROUP BY o.order_id, o.order_date, c.first_name, c.last_name,
         c.email, a.city, a.state, o.status, o.total_amount,
         py.method, py.status
ORDER BY o.order_date DESC;

-- 9B. Revenue breakdown by category
SELECT
    cat.name                                      AS category,
    COUNT(DISTINCT o.order_id)                    AS orders_containing,
    SUM(oi.quantity)                              AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2)    AS category_revenue,
    ROUND(AVG(oi.unit_price), 2)                  AS avg_selling_price
FROM categories  cat
JOIN products    p   ON cat.category_id = p.category_id
JOIN order_items oi  ON p.product_id    = oi.product_id
JOIN orders      o   ON oi.order_id     = o.order_id
WHERE o.status != 'cancelled'
GROUP BY cat.category_id, cat.name
ORDER BY category_revenue DESC;

-- 9C. Customer purchase history with product details
SELECT
    CONCAT(c.first_name,' ',c.last_name)  AS customer,
    o.order_id,
    o.order_date,
    p.name                                AS product,
    cat.name                              AS category,
    oi.quantity,
    oi.unit_price,
    r.rating                              AS review_given
FROM customers   c
JOIN orders      o   ON c.customer_id  = o.customer_id
JOIN order_items oi  ON o.order_id     = oi.order_id
JOIN products    p   ON oi.product_id  = p.product_id
JOIN categories  cat ON p.category_id  = cat.category_id
LEFT JOIN reviews r  ON r.product_id   = p.product_id   -- LEFT: show even unreviewed
                     AND r.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_date;

-- ================================================================
-- SECTION 10 — JOIN QUICK REFERENCE (as comments)
-- ================================================================
/*
  JOIN TYPE SUMMARY
  ─────────────────────────────────────────────────────────────────
  INNER JOIN      → only matching rows in BOTH tables
  LEFT  JOIN      → all rows from LEFT  + matching RIGHT (NULL if no match)
  RIGHT JOIN      → all rows from RIGHT + matching LEFT  (NULL if no match)
  FULL OUTER JOIN → all rows from BOTH (MySQL: LEFT ∪ RIGHT via UNION)
  CROSS JOIN      → every row × every row (Cartesian product, no ON)
  SELF  JOIN      → table joined to itself using aliases

  SYNTAX:
  SELECT cols
  FROM   tableA a
  [INNER|LEFT|RIGHT] JOIN tableB b ON a.key = b.key;

  FINDING NON-MATCHES:
  LEFT  JOIN + WHERE b.id IS NULL  → rows in A but NOT in B
  RIGHT JOIN + WHERE a.id IS NULL  → rows in B but NOT in A
  FULL  JOIN + WHERE a.id IS NULL
             OR b.id IS NULL       → rows unique to either table

  CARTESIAN PRODUCT WARNING:
  CROSS JOIN or a missing ON clause → m × n rows (can be millions!)
  Always check you have an ON condition unless intentionally crossing.

  OPTIMIZATION TIPS:
  · Filter early with WHERE before joining
  · Join on indexed columns (PKs and FKs are auto-indexed)
  · Prefer INNER JOIN over outer joins when possible (faster)
  · Use EXPLAIN SELECT … to see the query execution plan
  ─────────────────────────────────────────────────────────────────
*/
