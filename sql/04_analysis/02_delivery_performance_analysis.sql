USE olist_product_analytics;

-- 1. Delivery delay distribution
SELECT
    CASE
        WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) <= 0
            THEN 'On Time or Early'

        WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 1 AND 3
            THEN '1-3 Days Late'

        WHEN TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) BETWEEN 4 AND 7
            THEN '4-7 Days Late'

        ELSE 'More Than 7 Days Late'
    END AS delivery_delay_group,

    COUNT(*) AS total_orders,

    ROUND(
        COUNT(*) * 100.0 /
        (
            SELECT COUNT(*)
            FROM orders
            WHERE order_status = 'delivered'
              AND order_delivered_customer_date IS NOT NULL
              AND order_estimated_delivery_date IS NOT NULL
        ),
        2
    ) AS percentage_of_delivered_orders

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_delay_group
ORDER BY total_orders DESC;


-- 2. Average delivery time by order status
SELECT
    order_status,
    COUNT(*) AS total_orders,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            )
        ),
        2
    ) AS avg_delivery_days

FROM orders

WHERE order_delivered_customer_date IS NOT NULL

GROUP BY order_status
ORDER BY avg_delivery_days;


-- 3. Monthly delivery trend
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,

    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            )
        ),
        2
    ) AS avg_delivery_days

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL

GROUP BY order_month
ORDER BY order_month;


-- 4. Fastest vs slowest delivery states
SELECT
    c.customer_state,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                o.order_purchase_timestamp,
                o.order_delivered_customer_date
            )
        ),
        2
    ) AS avg_delivery_days

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY avg_delivery_days DESC;


-- 5. Delivery delay impact on review score
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On Time'

        ELSE 'Late'
    END AS delivery_status,

    COUNT(*) AS total_reviews,

    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM orders o

JOIN order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY delivery_status;