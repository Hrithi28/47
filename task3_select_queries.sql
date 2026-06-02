-- ================================================================
--   E-COMMERCE DATABASE — BASIC SELECT QUERIES
--   Task 3: Writing Basic SELECT Queries
--   SQL Developer Internship — ElevateLabs
--
--   Run AFTER task1_schema.sql + task2_dml.sql
--   Concepts: SELECT, WHERE, AND/OR, LIKE, BETWEEN,
--             ORDER BY, LIMIT, DISTINCT, IN, Aliases
-- ================================================================

USE ecommerce_db;

-- ================================================================
-- SECTION 1 — SELECT * vs SPECIFIC COLUMNS
-- ================================================================

-- 1A. SELECT * — retrieves ALL columns from a table
--     Use sparingly; fetches more data than often needed
SELECT * FROM customers;

-- 1B. SELECT specific columns — "Projection"
--     Only fetch what you actually need (faster, cleaner)
SELECT first_name, last_name, email
FROM   customers;

-- 1C. SELECT with computed column
SELECT
    product_id,
    name,
    price,
    stock_qty,
    price * stock_qty  AS inventory_value   -- computed, aliased
FROM products;

-- ================================================================
-- SECTION 2 — ALIASES (AS)
-- Concept: Give columns or tables a temporary display name
-- ================================================================

-- 2A. Column alias with AS
SELECT
    first_name  AS "First Name",
    last_name   AS "Last Name",
    email       AS "Email Address",
    phone       AS "Phone Number"
FROM customers;

-- 2B. Table alias (shorthand for long table names)
SELECT
    c.first_name,
    c.last_name,
    c.email
FROM customers AS c;        -- 'c' is now the alias for customers

-- 2C. Alias on expression
SELECT
    name                            AS product_name,
    price                           AS original_price,
    ROUND(price * 0.90, 2)          AS discounted_10pct,
    ROUND(price * 0.80, 2)          AS discounted_20pct
FROM products;

-- ================================================================
-- SECTION 3 — WHERE CLAUSE (Filtering rows)
-- ================================================================

-- 3A. Simple equality filter
SELECT * FROM products
WHERE  category_id = 1;            -- only Electronics

-- 3B. Greater than / Less than
SELECT name, price, stock_qty
FROM   products
WHERE  price > 1000;               -- products costing more than ₹1000

-- 3C. Less than or equal to
SELECT name, price
FROM   products
WHERE  price <= 500;               -- budget products

-- 3D. Not equal (both syntaxes work in MySQL)
SELECT * FROM orders
WHERE  status != 'cancelled';      -- exclude cancelled orders
-- same as: WHERE status <> 'cancelled'

-- 3E. Filter on NULL (cannot use = NULL!)
SELECT customer_id, first_name, last_name
FROM   customers
WHERE  phone IS NULL;              -- customers with no phone

-- 3F. Filter NOT NULL
SELECT product_id, name, description
FROM   products
WHERE  description IS NOT NULL;    -- products that have a description

-- ================================================================
-- SECTION 4 — AND / OR / NOT
-- ================================================================

-- 4A. AND — both conditions must be true
SELECT name, price, stock_qty
FROM   products
WHERE  price > 500
  AND  stock_qty > 40;            -- expensive AND well-stocked

-- 4B. OR — either condition can be true
SELECT * FROM orders
WHERE  status = 'pending'
   OR  status = 'processing';     -- open orders

-- 4C. AND + OR with parentheses (brackets control precedence)
SELECT name, price
FROM   products
WHERE  (category_id = 1 OR category_id = 2)
  AND   price < 2000;             -- Electronics or Clothing under ₹2000

-- 4D. NOT — negates a condition
SELECT * FROM orders
WHERE  NOT status = 'delivered';

-- ================================================================
-- SECTION 5 — IN  (vs  =)
-- Concept: IN checks membership in a list — cleaner than many ORs
--   = matches one value exactly
--   IN matches any value in the given list
-- ================================================================

-- 5A. IN operator
SELECT * FROM orders
WHERE  status IN ('pending', 'processing', 'shipped');

-- 5B. Equivalent using OR (verbose — same result as 5A)
SELECT * FROM orders
WHERE  status = 'pending'
   OR  status = 'processing'
   OR  status = 'shipped';

-- 5C. NOT IN
SELECT name, category_id
FROM   products
WHERE  category_id NOT IN (1, 2);   -- exclude Electronics & Clothing

-- 5D. IN with a subquery
SELECT first_name, last_name, email
FROM   customers
WHERE  customer_id IN (
    SELECT DISTINCT customer_id
    FROM   orders
    WHERE  status = 'delivered'     -- customers who got a delivery
);

-- ================================================================
-- SECTION 6 — LIKE (Pattern Matching)
-- Concept: LIKE 'pattern' — % = any number of chars, _ = one char
-- ================================================================

-- 6A. Starts with 'W'
SELECT name FROM products
WHERE  name LIKE 'W%';

-- 6B. Contains 'a' anywhere
SELECT name FROM products
WHERE  name LIKE '%a%';            -- 'a' anywhere in the name

-- 6C. Ends with 'n'
SELECT first_name FROM customers
WHERE  first_name LIKE '%n';       -- names ending in 'n'

-- 6D. Single character wildcard _
--     _ matches exactly ONE character
SELECT * FROM customers
WHERE  first_name LIKE '_____';    -- exactly 5-character first names

-- 6E. Email pattern match
SELECT first_name, last_name, email
FROM   customers
WHERE  email LIKE '%@email.com';   -- all @email.com addresses

-- 6F. LIKE with AND
SELECT name, price
FROM   products
WHERE  name LIKE '%Steel%'
   OR  name LIKE '%Wireless%';

-- ================================================================
-- SECTION 7 — BETWEEN (Range filtering)
-- Concept: BETWEEN low AND high — inclusive on both ends
-- ================================================================

-- 7A. BETWEEN on numbers
SELECT name, price
FROM   products
WHERE  price BETWEEN 500 AND 1500;   -- ₹500 to ₹1500 inclusive

-- 7B. NOT BETWEEN
SELECT name, price
FROM   products
WHERE  price NOT BETWEEN 500 AND 1500;

-- 7C. BETWEEN on dates
SELECT order_id, customer_id, order_date, total_amount
FROM   orders
WHERE  order_date BETWEEN '2024-03-01' AND '2024-04-30';

-- 7D. BETWEEN on strings (alphabetical range)
SELECT first_name, last_name
FROM   customers
WHERE  first_name BETWEEN 'A' AND 'M';   -- names starting A–M

-- ================================================================
-- SECTION 8 — ORDER BY (Sorting)
-- Concept: Default sort is ASC (ascending). Use DESC for reverse.
-- ================================================================

-- 8A. Ascending (default — cheapest first)
SELECT name, price
FROM   products
ORDER  BY price;                   -- same as ORDER BY price ASC

-- 8B. Descending (most expensive first)
SELECT name, price
FROM   products
ORDER  BY price DESC;

-- 8C. Sort by multiple columns
SELECT first_name, last_name, email
FROM   customers
ORDER  BY last_name ASC, first_name ASC;   -- surname first, then first name

-- 8D. Sort by alias
SELECT name, price * stock_qty AS inventory_value
FROM   products
ORDER  BY inventory_value DESC;    -- highest stock value first

-- 8E. Sort orders by date (newest first)
SELECT order_id, customer_id, order_date, total_amount, status
FROM   orders
ORDER  BY order_date DESC;

-- ================================================================
-- SECTION 9 — LIMIT (Restrict number of rows)
-- ================================================================

-- 9A. Top 3 most expensive products
SELECT name, price
FROM   products
ORDER  BY price DESC
LIMIT  3;

-- 9B. Top 5 most recent orders
SELECT order_id, customer_id, order_date, total_amount
FROM   orders
ORDER  BY order_date DESC
LIMIT  5;

-- 9C. LIMIT with OFFSET — pagination
--     LIMIT 3 OFFSET 3 → skip first 3, return next 3 (page 2)
SELECT name, price
FROM   products
ORDER  BY price DESC
LIMIT  3 OFFSET 3;

-- 9D. Cheapest product in each category (just the single cheapest overall)
SELECT name, category_id, price
FROM   products
ORDER  BY price ASC
LIMIT  1;

-- ================================================================
-- SECTION 10 — DISTINCT (Remove duplicates)
-- Concept: Returns only unique values for the selected column(s)
-- ================================================================

-- 10A. Distinct statuses in orders
SELECT DISTINCT status
FROM   orders;

-- 10B. Distinct categories used in products
SELECT DISTINCT category_id
FROM   products
ORDER  BY category_id;

-- 10C. Distinct countries in addresses
SELECT DISTINCT country
FROM   addresses;

-- 10D. DISTINCT on multiple columns (unique combinations)
SELECT DISTINCT method, status
FROM   payments
ORDER  BY method;

-- ================================================================
-- SECTION 11 — COMBINED QUERIES (Putting it all together)
-- ================================================================

-- 11A. All-in-one: find affordable electronics, sorted
SELECT
    p.product_id,
    p.name                         AS product_name,
    c.name                         AS category,
    p.price,
    p.stock_qty,
    ROUND(p.price * 0.90, 2)       AS sale_price   -- alias + expression
FROM   products  AS p                               -- table alias
JOIN   categories AS c ON p.category_id = c.category_id
WHERE  c.name  = 'Electronics'                      -- WHERE filter
  AND  p.price BETWEEN 500 AND 3000                 -- BETWEEN range
  AND  p.name LIKE '%USB%'                          -- LIKE pattern
   OR (c.name = 'Electronics' AND p.price < 1000)
ORDER  BY p.price ASC                               -- ORDER BY
LIMIT  5;                                           -- LIMIT

-- 11B. Recent pending/processing orders with customer names
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    o.order_date,
    o.total_amount,
    o.status
FROM   orders     AS o
JOIN   customers  AS c  ON o.customer_id = c.customer_id
WHERE  o.status  IN ('pending', 'processing')
  AND  o.order_date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER  BY o.total_amount DESC
LIMIT  10;

-- 11C. Product search — simulates a search bar
--      User types "book" or "mat" → LIKE finds matches
SELECT
    product_id,
    name                AS product_name,
    price,
    stock_qty           AS "In Stock"
FROM   products
WHERE  name LIKE '%Book%'
   OR  name LIKE '%Mat%'
   OR  name LIKE '%Bottle%'
ORDER  BY name ASC;

-- 11D. High-value delivered orders
SELECT
    o.order_id,
    CONCAT(c.first_name,' ',c.last_name)  AS customer,
    o.total_amount,
    o.order_date
FROM   orders     o
JOIN   customers  c ON o.customer_id = c.customer_id
WHERE  o.status      = 'delivered'
  AND  o.total_amount > 1000
ORDER  BY o.total_amount DESC;

-- 11E. Customers who haven't ordered (using NOT IN)
SELECT
    customer_id,
    CONCAT(first_name,' ',last_name) AS customer_name,
    email
FROM   customers
WHERE  customer_id NOT IN (
    SELECT DISTINCT customer_id FROM orders
);

-- ================================================================
-- SECTION 12 — QUICK REFERENCE CHEATSHEET (as comments)
-- ================================================================

/*
  SYNTAX QUICK REFERENCE
  ─────────────────────────────────────────────────────

  SELECT *                → all columns
  SELECT col1, col2       → specific columns (projection)
  SELECT col AS alias     → rename column in output

  FROM   table AS t       → table alias

  WHERE  col = value      → exact match
  WHERE  col != value     → not equal  (also: <>)
  WHERE  col > value      → greater than
  WHERE  col >= value     → greater than or equal
  WHERE  col < value      → less than
  WHERE  col <= value     → less than or equal

  WHERE  col IS NULL      → NULL check  (not = NULL!)
  WHERE  col IS NOT NULL  → not null check

  WHERE  cond1 AND cond2  → both must be true
  WHERE  cond1 OR  cond2  → either must be true
  WHERE  NOT cond         → negation

  WHERE  col IN (a,b,c)   → matches any listed value
  WHERE  col NOT IN (...)  → matches none of listed

  WHERE  col LIKE 'p%'    → starts with p
  WHERE  col LIKE '%p'    → ends with p
  WHERE  col LIKE '%p%'   → contains p
  WHERE  col LIKE 'p_t'   → p + 1 char + t

  WHERE  col BETWEEN x AND y  → inclusive range

  ORDER BY col ASC        → ascending  (A→Z, 0→9) — DEFAULT
  ORDER BY col DESC       → descending (Z→A, 9→0)
  ORDER BY col1, col2     → multi-column sort

  LIMIT  n                → first n rows
  LIMIT  n OFFSET m       → skip m rows, take n (pagination)

  SELECT DISTINCT col     → unique values only

  ─────────────────────────────────────────────────────
  = vs IN:
    WHERE status = 'pending'              (one value)
    WHERE status IN ('pending','shipped') (multiple values)

  Default sort order: ASC (ascending) if ORDER BY given;
    without ORDER BY, order is undefined/arbitrary.
  ─────────────────────────────────────────────────────
*/
