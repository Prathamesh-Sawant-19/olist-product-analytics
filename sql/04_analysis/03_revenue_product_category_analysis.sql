USE olist_product_analytics;

-- 1. Total item revenue, freight revenue, and total order item value
SELECT
    ROUND(SUM(price), 2) AS total_item_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight_value,
    ROUND(SUM(price + freight_value), 2) AS total_item_plus_freight_value,
    COUNT(*) AS total_order_items,
    COUNT(DISTINCT order_id) AS total_orders_with_items
FROM order_items;


-- 2. Revenue by product category, preserving unknown product matches
SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
    COUNT(*) AS order_items,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_value,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY product_category
ORDER BY item_revenue DESC;


-- 3. Top 15 product categories by item revenue
SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS order_items,
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY product_category
ORDER BY item_revenue DESC
LIMIT 15;


-- 4. Revenue concentration by seller
SELECT
    oi.seller_id,
    s.seller_state,
    s.seller_city,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS order_items,
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_value,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
GROUP BY oi.seller_id, s.seller_state, s.seller_city
ORDER BY item_revenue DESC
LIMIT 20;


-- 5. Revenue by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(*) AS order_items,
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(SUM(oi.freight_value), 2) AS freight_value,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_value,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY item_revenue DESC;


-- 6. Payment value by payment type
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS avg_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 7. Compare item + freight value with payment value at order level
WITH item_totals AS (
    SELECT
        order_id,
        ROUND(SUM(price + freight_value), 2) AS item_plus_freight_value
    FROM order_items
    GROUP BY order_id
),

payment_totals AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value), 2) AS payment_value
    FROM order_payments
    GROUP BY order_id
)

SELECT
    COUNT(*) AS matched_orders,
    ROUND(SUM(item_plus_freight_value), 2) AS total_item_plus_freight_value,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(SUM(payment_value - item_plus_freight_value), 2) AS total_difference,
    ROUND(AVG(payment_value - item_plus_freight_value), 2) AS avg_difference_per_order
FROM item_totals i
JOIN payment_totals p
    ON i.order_id = p.order_id;


-- 8. Revenue by product category with review score
SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS item_revenue,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY product_category
HAVING orders >= 100
ORDER BY item_revenue DESC;
