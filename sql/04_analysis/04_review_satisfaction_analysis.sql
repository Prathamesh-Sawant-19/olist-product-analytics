USE olist_product_analytics;

-- 1. Overall review score distribution

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM order_reviews),
        2
    ) AS percentage_of_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- 2. Average review score by product category

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown') AS product_category,

    COUNT(DISTINCT r.review_id) AS total_reviews,

    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM order_reviews r

JOIN orders o
    ON r.order_id = o.order_id

JOIN order_items oi
    ON o.order_id = oi.order_id

LEFT JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

GROUP BY product_category

HAVING total_reviews >= 100

ORDER BY avg_review_score DESC;


-- 3. Lowest-rated high-volume categories

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name, 'unknown') AS product_category,

    COUNT(DISTINCT r.review_id) AS total_reviews,

    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM order_reviews r

JOIN orders o
    ON r.order_id = o.order_id

JOIN order_items oi
    ON o.order_id = oi.order_id

LEFT JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

GROUP BY product_category

HAVING total_reviews >= 500

ORDER BY avg_review_score ASC
LIMIT 15;


-- 4. Seller review performance

SELECT
    oi.seller_id,
    s.seller_state,
    s.seller_city,

    COUNT(DISTINCT r.review_id) AS total_reviews,

    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM order_reviews r

JOIN orders o
    ON r.order_id = o.order_id

JOIN order_items oi
    ON o.order_id = oi.order_id

LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    oi.seller_id,
    s.seller_state,
    s.seller_city

HAVING total_reviews >= 50

ORDER BY avg_review_score DESC
LIMIT 20;


-- 5. Review score by delivery speed bucket

SELECT
    CASE
        WHEN TIMESTAMPDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) <= 7
            THEN '0-7 Days'

        WHEN TIMESTAMPDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) <= 14
            THEN '8-14 Days'

        WHEN TIMESTAMPDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) <= 21
            THEN '15-21 Days'

        ELSE '22+ Days'
    END AS delivery_speed_bucket,

    COUNT(DISTINCT r.review_id) AS total_reviews,

    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM order_reviews r

JOIN orders o
    ON r.order_id = o.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY delivery_speed_bucket

ORDER BY avg_review_score DESC;


-- 6. Review score distribution for late deliveries

SELECT
    r.review_score,

    COUNT(*) AS review_count,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS percentage_of_reviews

FROM order_reviews r

JOIN orders o
    ON r.order_id = o.order_id

WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date

GROUP BY r.review_score
ORDER BY r.review_score;


-- 7. Review score distribution for on-time deliveries

SELECT
    r.review_score,

    COUNT(*) AS review_count,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS percentage_of_reviews

FROM order_reviews r

JOIN orders o
    ON r.order_id = o.order_id

WHERE o.order_delivered_customer_date <= o.order_estimated_delivery_date

GROUP BY r.review_score
ORDER BY r.review_score;
