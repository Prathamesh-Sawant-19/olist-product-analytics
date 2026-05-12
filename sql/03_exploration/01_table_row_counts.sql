USE olist_product_analytics;

SHOW TABLES;

SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;
SELECT COUNT(*) AS payments_count FROM order_payments;
SELECT COUNT(*) AS reviews_count FROM order_reviews;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS sellers_count FROM sellers;
SELECT COUNT(*) AS category_translation_count FROM category_translation;
SELECT COUNT(*) AS geolocation_count FROM geolocation;
