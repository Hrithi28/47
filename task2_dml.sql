-- ================================================================
--   E-COMMERCE DATABASE — DATA INSERTION & NULL HANDLING
--   Task 2: DML Operations (INSERT / UPDATE / DELETE)
--   SQL Developer Internship — ElevateLabs
--
--   Run AFTER task1_schema.sql  (requires ecommerce_db to exist)
-- ================================================================

USE ecommerce_db;

-- ----------------------------------------------------------------
-- SAFETY: disable FK checks temporarily so we can truncate freely
--         (useful when re-running this file during development)
-- ----------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE reviews;
TRUNCATE TABLE payments;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE addresses;
TRUNCATE TABLE products;
TRUNCATE TABLE categories;
TRUNCATE TABLE customers;
SET FOREIGN_KEY_CHECKS = 1;

-- ================================================================
-- SECTION 1 — INSERT INTO (full row, all columns specified)
-- ================================================================

-- ── 1A. Categories (no NULLs expected) ─────────────────────────
INSERT INTO categories (name, description) VALUES
  ('Electronics',    'Gadgets, phones, laptops and accessories'),
  ('Clothing',       'Men and women fashion apparel'),
  ('Books',          'Academic and recreational reading material'),
  ('Home & Kitchen', 'Appliances and household essentials'),
  ('Sports',         'Fitness equipment and outdoor gear');

-- ── 1B. Customers — full data ───────────────────────────────────
-- Concept: INSERT INTO with all column values provided
INSERT INTO customers (first_name, last_name, email, phone, created_at) VALUES
  ('Arjun',    'Sharma',    'arjun.sharma@email.com',    '9876543210', '2024-01-10 09:00:00'),
  ('Priya',    'Nair',      'priya.nair@email.com',      '9123456780', '2024-01-12 11:30:00'),
  ('Rahul',    'Verma',     'rahul.verma@email.com',     '9001234567', '2024-02-05 14:00:00'),
  ('Sneha',    'Iyer',      'sneha.iyer@email.com',      '9988776655', '2024-02-20 10:15:00'),
  ('Karthik',  'Rajan',     'karthik.rajan@email.com',   '9345678901', '2024-03-01 08:45:00');

-- ── 1C. Customers — INSERT INTO SPECIFIC COLUMNS ONLY ──────────
-- Concept: Can we insert values into specific columns only?
--   YES — omitted columns get their DEFAULT value or NULL.
--   Here `phone` is omitted → stored as NULL (column allows NULL).
--   `created_at` is omitted → DEFAULT CURRENT_TIMESTAMP is used.
INSERT INTO customers (first_name, last_name, email) VALUES
  ('Divya',   'Menon',   'divya.menon@email.com'),    -- phone = NULL
  ('Arun',    'Kumar',   'arun.kumar@email.com'),     -- phone = NULL
  ('Meera',   'Pillai',  'meera.pillai@email.com');   -- phone = NULL

-- ── 1D. Products — some with NULL description (optional field) ──
INSERT INTO products (category_id, name, description, price, stock_qty) VALUES
  (1, 'Wireless Bluetooth Headphones', 'Over-ear, 30h battery, ANC',        1999.00, 50),
  (1, 'USB-C Fast Charger 65W',        '3-port GaN charger, wide compat.',    799.00, 120),
  (1, 'Mechanical Keyboard TKL',        NULL,                                 3499.00, 25),  -- NULL description
  (2, 'Cotton Crew-Neck T-Shirt',      'Unisex, available S–XXL',             499.00, 200),
  (2, 'Slim Fit Chinos',               NULL,                                 1299.00, 80),   -- NULL description
  (3, 'MySQL in a Nutshell',           'Comprehensive MySQL reference guide',  649.00, 30),
  (3, 'Clean Code by Robert Martin',   NULL,                                   799.00, 15),   -- NULL description
  (4, 'Stainless Steel Water Bottle',  '1L, leak-proof, keeps cold 24h',      349.00, 80),
  (4, 'Non-stick Frying Pan',          'Induction compatible, 26cm',          899.00, 40),
  (5, 'Yoga Mat 6mm',                  'Non-slip, eco-friendly PVC',          599.00, 60);

-- ── 1E. Addresses ───────────────────────────────────────────────
INSERT INTO addresses (customer_id, street, city, state, postal_code, country, is_default) VALUES
  (1, '12 MG Road',           'Bengaluru', 'Karnataka',  '560001', 'India', 1),
  (1, '7 Brigade Road',       'Bengaluru', 'Karnataka',  '560025', 'India', 0),  -- 2nd address
  (2, '45 Anna Salai',        'Chennai',   'Tamil Nadu', '600002', 'India', 1),
  (3, '8 Connaught Place',    'New Delhi', 'Delhi',      '110001', 'India', 1),
  (4, '22 Park Street',       'Kolkata',   'West Bengal','700016', 'India', 1),
  (5, '3 Marine Drive',       'Mumbai',    'Maharashtra','400020', 'India', 1),
  (6, '9 Jubilee Hills',      'Hyderabad', 'Telangana',  '500033', 'India', 1);

-- ── 1F. Orders ──────────────────────────────────────────────────
INSERT INTO orders (customer_id, address_id, order_date, status, total_amount) VALUES
  (1, 1, '2024-03-10 10:00:00', 'delivered',   2798.00),
  (2, 3, '2024-03-12 14:30:00', 'processing',   649.00),
  (3, 4, '2024-04-01 09:15:00', 'pending',     1148.00),
  (4, 5, '2024-04-05 16:00:00', 'shipped',     2598.00),
  (5, 6, '2024-04-10 11:45:00', 'cancelled',    599.00),
  (1, 2, '2024-04-15 13:00:00', 'pending',      799.00);

-- ── 1G. Order Items (composite PK: order_id + product_id) ───────
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 1999.00),
  (1, 2, 1,  799.00),
  (2, 6, 1,  649.00),
  (3, 4, 1,  499.00),
  (3, 8, 1,  349.00),
  (3, 2, 1,  799.00),  -- note: 349+499+799 = 1647 ≠ 1148; intentional for UPDATE demo below
  (4, 3, 1, 3499.00),
  (4, 5, 1, 1299.00),  -- 3499+1299=4798, UPDATE will fix total_amount
  (5, 10,1,  599.00),
  (6, 2, 1,  799.00);

-- ── 1H. Payments ────────────────────────────────────────────────
-- paid_at is NULL for pending/processing payments
INSERT INTO payments (order_id, method, status, paid_at, amount) VALUES
  (1, 'upi',         'completed', '2024-03-10 10:05:00', 2798.00),
  (2, 'credit_card', 'pending',    NULL,                   649.00),  -- NULL paid_at
  (3, 'cod',         'pending',    NULL,                  1148.00),  -- NULL paid_at
  (4, 'net_banking', 'completed', '2024-04-05 16:10:00', 2598.00),
  (5, 'upi',         'refunded',  '2024-04-11 09:00:00',  599.00),
  (6, 'debit_card',  'pending',    NULL,                   799.00);  -- NULL paid_at

-- ── 1I. Reviews ─────────────────────────────────────────────────
-- comment is optional → some are NULL
INSERT INTO reviews (product_id, customer_id, rating, comment, reviewed_at) VALUES
  (1, 1, 5, 'Excellent sound quality, very comfortable!',  '2024-03-20 08:00:00'),
  (6, 2, 4, 'Great reference book for SQL beginners.',     '2024-03-25 12:00:00'),
  (4, 3, 3,  NULL,                                         '2024-04-08 10:00:00'),  -- NULL comment
  (3, 4, 5, 'Solid build, satisfying keystrokes!',         '2024-04-15 09:30:00'),
  (10,5, 4,  NULL,                                         '2024-04-18 14:00:00'); -- NULL comment

-- ================================================================
-- SECTION 2 — INSERT USING SELECT
-- Concept: "How to insert values using SELECT?"
-- Create a summary table first, then populate it from live data.
-- ================================================================

-- Create a small audit/summary table (if it doesn't already exist)
CREATE TABLE IF NOT EXISTS order_summary (
    summary_id    INT          NOT NULL AUTO_INCREMENT,
    customer_id   INT          NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    order_count   INT          NOT NULL DEFAULT 0,
    total_spent   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    generated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_summary PRIMARY KEY (summary_id)
);

TRUNCATE TABLE order_summary;

-- Populate order_summary using INSERT … SELECT
INSERT INTO order_summary (customer_id, full_name, order_count, total_spent)
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS full_name,
    COUNT(o.order_id)                        AS order_count,
    COALESCE(SUM(o.total_amount), 0)         AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- ================================================================
-- SECTION 3 — NULL HANDLING QUERIES
-- ================================================================

-- 3A. Find customers with no phone number (IS NULL)
-- Concept: How does IS NULL work?
SELECT customer_id, first_name, last_name, email,
       COALESCE(phone, 'Not provided') AS phone_display
FROM   customers
WHERE  phone IS NULL;

-- 3B. Find products with no description
SELECT product_id, name,
       CASE
           WHEN description IS NULL THEN '⚠ Description missing'
           ELSE description
       END AS description_status
FROM   products;

-- 3C. Find payments not yet completed (paid_at IS NULL)
SELECT p.payment_id, o.order_id, p.method, p.status, p.amount,
       IFNULL(CAST(p.paid_at AS CHAR), 'Not yet paid') AS payment_date
FROM   payments p
JOIN   orders   o ON p.order_id = o.order_id
WHERE  p.paid_at IS NULL;

-- 3D. Find reviews with no comment
SELECT r.review_id, c.first_name, pr.name AS product, r.rating,
       COALESCE(r.comment, '— No comment left —') AS review_text
FROM   reviews   r
JOIN   customers c  ON r.customer_id = c.customer_id
JOIN   products  pr ON r.product_id  = pr.product_id
WHERE  r.comment IS NULL;

-- ================================================================
-- SECTION 4 — UPDATE STATEMENTS
-- ================================================================

-- 4A. Update a single row — add phone for a customer who had NULL
-- Concept: UPDATE with WHERE condition
UPDATE customers
SET    phone = '9111222333'
WHERE  customer_id = 6;   -- Divya Menon had NULL phone

-- 4B. Update multiple rows at once
-- Concept: How do you update multiple rows?
-- Add description to all products where it is NULL
UPDATE products
SET    description = 'No description provided yet.'
WHERE  description IS NULL;

-- 4C. Update order total to match actual order_items total
-- (corrects the intentional mismatch in order 3)
UPDATE orders o
SET    total_amount = (
           SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0)
           FROM   order_items oi
           WHERE  oi.order_id = o.order_id
       );

-- 4D. Mark a payment as completed and record the paid timestamp
UPDATE payments
SET    status  = 'completed',
       paid_at = '2024-04-20 10:30:00'
WHERE  order_id = 2;

-- 4E. Reduce stock when an order is placed (batch update)
-- Deduct stock for all products in order 6
UPDATE products p
JOIN   order_items oi ON oi.product_id = p.product_id
SET    p.stock_qty = p.stock_qty - oi.quantity
WHERE  oi.order_id = 6;

-- 4F. Update order status — mark all 'pending' orders older than
--     30 days as 'cancelled'
UPDATE orders
SET    status = 'cancelled'
WHERE  status = 'pending'
  AND  order_date < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- ================================================================
-- SECTION 5 — DELETE STATEMENTS
-- ================================================================

-- 5A. Delete a specific review (with WHERE — safe delete)
-- Concept: always use WHERE with DELETE to avoid wiping whole table
DELETE FROM reviews
WHERE  review_id = 5;          -- remove the review with no comment

-- 5B. Delete all cancelled orders AND their payments
--     ON DELETE CASCADE on payments means payment rows are removed
--     automatically when the parent order is deleted.
-- Concept: What is ON DELETE CASCADE?
--   → Defined on payments.order_id → orders.order_id with ON DELETE CASCADE
--   → Deleting the order automatically deletes the linked payment row.
DELETE FROM order_items
WHERE  order_id IN (SELECT order_id FROM orders WHERE status = 'cancelled');

DELETE FROM orders
WHERE  status = 'cancelled';
-- (payment for cancelled order is removed automatically via CASCADE)

-- 5C. Delete customers who have never placed an order
--     Concept: safe conditional delete
DELETE FROM customers
WHERE  customer_id NOT IN (
           SELECT DISTINCT customer_id FROM orders
       )
  AND  customer_id > 5;   -- keep seed data customers 1–5

-- ================================================================
-- SECTION 6 — ROLLBACK DEMO (using TRANSACTION)
-- Concept: How do you rollback a deletion?
-- ================================================================

START TRANSACTION;

    -- Accidental deletion of all products
    DELETE FROM products WHERE stock_qty < 30;

    -- Verify what would be deleted
    SELECT 'After DELETE (not yet committed):' AS info;
    SELECT COUNT(*) AS remaining_products FROM products;

    -- Oops! Roll it back — nothing is permanently deleted
    ROLLBACK;

SELECT 'After ROLLBACK — all products restored:' AS info;
SELECT COUNT(*) AS restored_products FROM products;

-- ================================================================
-- SECTION 7 — VERIFICATION QUERIES
-- ================================================================

-- V1. All customers — show NULL phone as label
SELECT customer_id,
       CONCAT(first_name,' ',last_name)    AS full_name,
       email,
       COALESCE(phone, '(no phone)')       AS phone
FROM   customers
ORDER  BY customer_id;

-- V2. Products with stock and description preview
SELECT product_id, name,
       CONCAT(SUBSTRING(description,1,40),'…') AS description_preview,
       price, stock_qty
FROM   products
ORDER  BY category_id, product_id;

-- V3. Order summary with payment status
SELECT o.order_id,
       CONCAT(c.first_name,' ',c.last_name) AS customer,
       o.status                             AS order_status,
       o.total_amount,
       p.method,
       p.status                             AS payment_status,
       COALESCE(CAST(p.paid_at AS CHAR),'Pending') AS paid_at
FROM   orders   o
JOIN   customers c ON o.customer_id = c.customer_id
JOIN   payments  p ON p.order_id    = o.order_id
ORDER  BY o.order_id;

-- V4. Order summary table (built from INSERT … SELECT)
SELECT * FROM order_summary ORDER BY total_spent DESC;

-- V5. NULL audit — count NULLs per sensitive column
SELECT
    'customers.phone'      AS column_name,
    COUNT(*) - COUNT(phone) AS null_count
FROM customers
UNION ALL
SELECT
    'products.description',
    COUNT(*) - COUNT(description)
FROM products
UNION ALL
SELECT
    'payments.paid_at',
    COUNT(*) - COUNT(paid_at)
FROM payments
UNION ALL
SELECT
    'reviews.comment',
    COUNT(*) - COUNT(comment)
FROM reviews;
