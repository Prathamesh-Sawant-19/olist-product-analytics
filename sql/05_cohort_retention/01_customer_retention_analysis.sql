USE olist_product_analytics;

-- 1. Repeat vs one-time customers using customer_unique_id

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    COUNT(*) AS customer_count,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS percentage_of_customers

FROM customer_orders
GROUP BY customer_type;

-- 2. Customer order frequency distribution

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    total_orders,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage_of_customers
FROM customer_orders
GROUP BY total_orders
ORDER BY total_orders;

-- 3. Monthly customer acquisition based on first purchase month

WITH customer_first_order AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_purchase_timestamp
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    DATE_FORMAT(first_purchase_timestamp, '%Y-%m') AS acquisition_month,
    COUNT(*) AS new_customers
FROM customer_first_order
GROUP BY acquisition_month
ORDER BY acquisition_month;

-- 4. Monthly repeat purchase behaviour

WITH customer_monthly_orders AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(DISTINCT o.order_id) AS orders_in_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id, DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

customer_order_sequence AS (
    SELECT
        customer_unique_id,
        order_month,
        orders_in_month,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_month
        ) AS customer_month_sequence
    FROM customer_monthly_orders
)

SELECT
    order_month,
    COUNT(DISTINCT CASE WHEN customer_month_sequence = 1 THEN customer_unique_id END) AS new_customers,
    COUNT(DISTINCT CASE WHEN customer_month_sequence > 1 THEN customer_unique_id END) AS returning_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN customer_month_sequence > 1 THEN customer_unique_id END) * 100.0 /
        COUNT(DISTINCT customer_unique_id),
        2
    ) AS returning_customer_rate
FROM customer_order_sequence
GROUP BY order_month
ORDER BY order_month;

-- 5. Monthly customer cohort retention

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS order_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
),

customer_cohorts AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),

cohort_activity AS (
    SELECT
        co.customer_unique_id,
        cc.cohort_month,
        co.order_month,
        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(cc.cohort_month, '%Y-%m-%d'),
            STR_TO_DATE(co.order_month, '%Y-%m-%d')
        ) AS months_since_first_purchase
    FROM customer_orders co
    JOIN customer_cohorts cc
        ON co.customer_unique_id = cc.customer_unique_id
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    ca.months_since_first_purchase,
    cs.cohort_size,
    COUNT(DISTINCT ca.customer_unique_id) AS active_customers,
    ROUND(
        COUNT(DISTINCT ca.customer_unique_id) * 100.0 / cs.cohort_size,
        2
    ) AS retention_rate
FROM cohort_activity ca
JOIN cohort_sizes cs
    ON ca.cohort_month = cs.cohort_month
GROUP BY
    ca.cohort_month,
    ca.months_since_first_purchase,
    cs.cohort_size
ORDER BY
    ca.cohort_month,
    ca.months_since_first_purchase;

    -- 6. Cohort retention focused on first 6 months

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS order_month
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
),

customer_cohorts AS (
    SELECT
        customer_unique_id,
        MIN(order_month) AS cohort_month
    FROM customer_orders
    GROUP BY customer_unique_id
),

cohort_activity AS (
    SELECT
        co.customer_unique_id,
        cc.cohort_month,
        co.order_month,
        TIMESTAMPDIFF(
            MONTH,
            STR_TO_DATE(cc.cohort_month, '%Y-%m-%d'),
            STR_TO_DATE(co.order_month, '%Y-%m-%d')
        ) AS months_since_first_purchase
    FROM customer_orders co
    JOIN customer_cohorts cc
        ON co.customer_unique_id = cc.customer_unique_id
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
)

SELECT
    ca.cohort_month,
    cs.cohort_size,

    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 0 THEN ca.customer_unique_id END) * 100.0 / cs.cohort_size, 2) AS month_0,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 1 THEN ca.customer_unique_id END) * 100.0 / cs.cohort_size, 2) AS month_1,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 2 THEN ca.customer_unique_id END) * 100.0 / cs.cohort_size, 2) AS month_2,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 3 THEN ca.customer_unique_id END) * 100.0 / cs.cohort_size, 2) AS month_3,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 4 THEN ca.customer_unique_id END) * 100.0 / cs.cohort_size, 2) AS month_4,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 5 THEN ca.customer_unique_id END) * 100.0 / cs.cohort_size, 2) AS month_5,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_purchase = 6 THEN ca.customer_unique_id END) * 100.0 / cs.cohort_size, 2) AS month_6

FROM cohort_activity ca
JOIN cohort_sizes cs
    ON ca.cohort_month = cs.cohort_month
GROUP BY ca.cohort_month, cs.cohort_size
ORDER BY ca.cohort_month;

-- 7. Product categories associated with repeat customers

WITH customer_order_counts AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
),

customer_category_orders AS (
    SELECT
        c.customer_unique_id,
        COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown') AS product_category,
        COUNT(DISTINCT o.order_id) AS category_orders
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    LEFT JOIN products p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct
        ON p.product_category_name = ct.product_category_name
    GROUP BY
        c.customer_unique_id,
        COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown')
)

SELECT
    cco.product_category,
    COUNT(DISTINCT cco.customer_unique_id) AS customers,
    COUNT(DISTINCT CASE WHEN coc.total_orders > 1 THEN cco.customer_unique_id END) AS repeat_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN coc.total_orders > 1 THEN cco.customer_unique_id END) * 100.0 /
        COUNT(DISTINCT cco.customer_unique_id),
        2
    ) AS repeat_customer_rate
FROM customer_category_orders cco
JOIN customer_order_counts coc
    ON cco.customer_unique_id = coc.customer_unique_id
GROUP BY cco.product_category
HAVING customers >= 500
ORDER BY repeat_customer_rate DESC;