USE olist_product_analytics;

-- 1. Check row counts again
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
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
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation;


-- 2. Check uniqueness of expected key fields
SELECT 
    COUNT(*) AS total_customer_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_ids
FROM customers;

SELECT 
    COUNT(*) AS total_order_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNT(DISTINCT customer_id) AS unique_customer_ids_in_orders
FROM orders;

SELECT 
    COUNT(*) AS total_product_rows,
    COUNT(DISTINCT product_id) AS unique_product_ids
FROM products;

SELECT 
    COUNT(*) AS total_seller_rows,
    COUNT(DISTINCT seller_id) AS unique_seller_ids
FROM sellers;


-- 3. Check order status distribution
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- 4. Check missing values in important order dates
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_timestamp,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approved_at,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS missing_carrier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_customer_delivery_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS missing_estimated_delivery_date
FROM orders;


-- 5. Check missing product category names
SELECT
    COUNT(*) AS total_products,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS missing_product_category
FROM products;


-- 6. Check review score distribution
SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_reviews), 2) AS percentage_of_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- 7. Check payment type distribution
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM order_payments), 2) AS percentage_of_payments
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;


-- 8. Check if every order has a customer match
SELECT 
    COUNT(*) AS orders_without_customer_match
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 9. Check if order_items have matching orders
SELECT 
    COUNT(*) AS order_items_without_order_match
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 10. Check if payments have matching orders
SELECT 
    COUNT(*) AS payments_without_order_match
FROM order_payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 11. Check if reviews have matching orders
SELECT 
    COUNT(*) AS reviews_without_order_match
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 12. Check if order items have matching products
SELECT 
    COUNT(*) AS order_items_without_product_match
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- 13. Check if order items have matching sellers
SELECT 
    COUNT(*) AS order_items_without_seller_match
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Improved missing date check to catch blank strings or zero-date placeholders

SELECT
    COUNT(*) AS total_orders,

    SUM(CASE 
        WHEN order_approved_at IS NULL 
          OR order_approved_at = '' 
          OR order_approved_at = '0000-00-00 00:00:00'
        THEN 1 ELSE 0 END) AS missing_approved_at,

    SUM(CASE 
        WHEN order_delivered_carrier_date IS NULL 
          OR order_delivered_carrier_date = '' 
          OR order_delivered_carrier_date = '0000-00-00 00:00:00'
        THEN 1 ELSE 0 END) AS missing_carrier_date,

    SUM(CASE 
        WHEN order_delivered_customer_date IS NULL 
          OR order_delivered_customer_date = '' 
          OR order_delivered_customer_date = '0000-00-00 00:00:00'
        THEN 1 ELSE 0 END) AS missing_customer_delivery_date,

    SUM(CASE 
        WHEN order_estimated_delivery_date IS NULL 
          OR order_estimated_delivery_date = '' 
          OR order_estimated_delivery_date = '0000-00-00 00:00:00'
        THEN 1 ELSE 0 END) AS missing_estimated_delivery_date
FROM orders;

-- The combined relationship check query
USE olist_product_analytics;

SELECT 'orders_without_customer_match' AS check_name,
       COUNT(*) AS issue_count
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'order_items_without_order_match',
       COUNT(*)
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'payments_without_order_match',
       COUNT(*)
FROM order_payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE p.order_id IS NULL

UNION ALL

SELECT 'reviews_without_order_match',
       COUNT(*)
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order_items_without_product_match',
       COUNT(*)
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'order_items_without_seller_match',
       COUNT(*)
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;
