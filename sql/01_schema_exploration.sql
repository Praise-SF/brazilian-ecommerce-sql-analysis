/*
Purpose:
Explore and validate the structure and relationships
of the Olist Brazilian E-Commerce dataset.
*/

USE olist_ecommerce;


-- ==================================================
-- 1. TABLE ROW COUNTS
-- ==================================================
-- Result: customers=99,441 | orders=99,441 | order_items=112,650
-- order_payments=103,886 | order_reviews=99,223 | products=32,951 | sellers=3,095


SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers;


-- ==================================================
-- 2. TABLE STRUCTURE
-- ==================================================

DESCRIBE customers;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE order_payments;
DESCRIBE order_reviews;
DESCRIBE products;
DESCRIBE sellers;


-- ==================================================
-- 3. RELATIONSHIP VALIDATION
-- ==================================================
-- Result: all unmatched counts = 0 across every relationship
-- (customers, orders, order_items, products, sellers, payments, reviews)
-- Confirms referential integrity holds cleanly

-- Orders → Customers
SELECT COUNT(*) AS unmatched_customers
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order Items → Orders
SELECT COUNT(*) AS unmatched_orders
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order Items → Products
SELECT COUNT(*) AS unmatched_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order Items → Sellers
SELECT COUNT(*) AS unmatched_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Payments → Orders
SELECT COUNT(*) AS unmatched_payments
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Reviews → Orders
SELECT COUNT(*) AS unmatched_reviews
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;