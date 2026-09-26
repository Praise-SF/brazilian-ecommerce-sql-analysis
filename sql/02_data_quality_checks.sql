/*

Purpose:
Identify missing values, inconsistent records,
invalid relationships, and suspicious timestamps
in the Olist Brazilian E-Commerce dataset.

The checks focus primarily on the orders table
because delivery performance is the main focus
of the project.
*/

USE olist_ecommerce;


-- ==================================================
-- CHECK 1: Missing customer delivery dates by status
-- ==================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
WHERE order_delivered_customer_date IS NULL
   OR order_delivered_customer_date = ''
GROUP BY order_status
ORDER BY order_count DESC;


-- ==================================================
-- CHECK 2: Delivered orders with missing
-- customer delivery dates
-- ==================================================

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_status = 'delivered'
  AND (
      order_delivered_customer_date IS NULL
      OR order_delivered_customer_date = ''
  );


-- ==================================================
-- CHECK 3: Non-delivered orders with a
-- customer delivery date
-- ==================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date <> ''
  AND order_status <> 'delivered'
GROUP BY order_status
ORDER BY order_count DESC;


-- ==================================================
-- CHECK 4: Missing important order timestamps
-- ==================================================

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN NULLIF(TRIM(order_purchase_timestamp), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_purchase_timestamp,

    SUM(
        CASE
            WHEN NULLIF(TRIM(order_approved_at), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_approved_at,

    SUM(
        CASE
            WHEN NULLIF(TRIM(order_delivered_carrier_date), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_carrier_date,

    SUM(
        CASE
            WHEN NULLIF(TRIM(order_delivered_customer_date), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_customer_delivery_date,

    SUM(
        CASE
            WHEN NULLIF(TRIM(order_estimated_delivery_date), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_estimated_delivery_date

FROM orders;


-- ==================================================
-- CHECK 5: Approval timestamp cannot occur
-- before purchase timestamp
-- ==================================================

SELECT
    COUNT(*) AS invalid_orders
FROM orders
WHERE NULLIF(TRIM(order_approved_at), '') IS NOT NULL
  AND NULLIF(TRIM(order_purchase_timestamp), '') IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;
-- CHECK 5: Result: 0 invalid orders — check passed

-- ==================================================
-- CHECK 6: Missing approval timestamps by
-- order status
-- ==================================================

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
WHERE NULLIF(TRIM(order_approved_at), '') IS NULL
GROUP BY order_status
ORDER BY order_count DESC;
-- CHECK6: Result: 160 missing approval timestamps (141 canceled, 14 delivered, 5 created)

-- ==================================================
-- CHECK 7A: Customer delivery cannot occur
-- before purchase
-- ==================================================

SELECT
    COUNT(*) AS invalid_delivery_orders
FROM orders
WHERE NULLIF(TRIM(order_delivered_customer_date), '') IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;
-- CHECK 7A: Result: 0 invalid delivery orders — check passed


-- ==================================================
-- CHECK 7B: Carrier delivery cannot occur
-- before purchase
-- ==================================================

SELECT
    COUNT(*) AS invalid_carrier_orders
FROM orders
WHERE NULLIF(TRIM(order_delivered_carrier_date), '') IS NOT NULL
  AND order_delivered_carrier_date < order_purchase_timestamp;
-- CHECK 7B: Result: 166 invalid carrier orders — carrier date before purchase date (needs investigation)

-- ==================================================
-- CHECK 7C: Customer delivery should not occur
-- before carrier delivery
-- ==================================================

SELECT
    COUNT(*) AS invalid_delivery_sequence
FROM orders
WHERE NULLIF(TRIM(order_delivered_carrier_date), '') IS NOT NULL
  AND NULLIF(TRIM(order_delivered_customer_date), '') IS NOT NULL
  AND order_delivered_customer_date < order_delivered_carrier_date;
-- CHECK 7C: Result: 23 invalid delivery sequence — customer delivery before carrier delivery (needs investigation)


-- ==================================================
-- CHECK 8: Review score range and average
-- ==================================================

SELECT
    MIN(review_score) AS minimum_score,
    MAX(review_score) AS maximum_score,
    AVG(review_score) AS average_score
FROM order_reviews;
-- CHECK 8: Result: min=1, max=5, avg=4.0864

-- ==================================================
-- CHECK 9: Review score distribution
-- ==================================================

SELECT
    review_score,
    COUNT(*) AS review_count
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;
-- CHECK 9: Result: 1★=11,424 | 2★=3,151 | 3★=8,179 | 4★=19,142 | 5★=57,327