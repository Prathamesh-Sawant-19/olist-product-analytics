USE olist_product_analytics;

-- 1. Order status funnel
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_total_orders
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;


-- 2. Simplified completed vs not completed view
SELECT
    CASE 
        WHEN order_status = 'delivered' THEN 'completed'
        ELSE 'not_completed'
    END AS completion_group,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage_of_total_orders
FROM orders
GROUP BY completion_group;


-- 3. Order journey date availability
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_purchase_timestamp IS NOT NULL AND order_purchase_timestamp <> '' THEN 1 ELSE 0 END) AS purchase_step_available,
    SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at <> '' THEN 1 ELSE 0 END) AS approval_step_available,
    SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date <> '' THEN 1 ELSE 0 END) AS carrier_step_available,
    SUM(CASE WHEN order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date <> '' THEN 1 ELSE 0 END) AS customer_delivery_step_available
FROM orders;


-- 4. Funnel conversion based on journey timestamps
SELECT 
    'purchase_to_approval' AS funnel_step,
    COUNT(*) AS base_orders,
    SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at <> '' THEN 1 ELSE 0 END) AS converted_orders,
    ROUND(SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at <> '' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS conversion_rate
FROM orders

UNION ALL

SELECT 
    'approval_to_carrier',
    SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at <> '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at <> ''
              AND order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date <> ''
        THEN 1 ELSE 0 END),
    ROUND(
        SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at <> ''
                  AND order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date <> ''
            THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at <> '' THEN 1 ELSE 0 END),
        2
    )
FROM orders

UNION ALL

SELECT 
    'carrier_to_customer_delivery',
    SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date <> '' THEN 1 ELSE 0 END),
    SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date <> ''
              AND order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date <> ''
        THEN 1 ELSE 0 END),
    ROUND(
        SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date <> ''
                  AND order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date <> ''
            THEN 1 ELSE 0 END) * 100.0 /
        SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date <> '' THEN 1 ELSE 0 END),
        2
    )
FROM orders;


-- 5. Average journey duration for delivered orders
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_approved_at)), 2) AS avg_hours_purchase_to_approval,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_approved_at, order_delivered_carrier_date)), 2) AS avg_hours_approval_to_carrier,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_delivered_carrier_date, order_delivered_customer_date)), 2) AS avg_hours_carrier_to_customer,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_delivered_customer_date)), 2) AS avg_hours_purchase_to_delivery,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 2) AS avg_days_purchase_to_delivery
FROM orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_approved_at IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;


-- 6. Late delivery analysis for delivered orders
SELECT
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_deliveries,
    ROUND(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_rate
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
  