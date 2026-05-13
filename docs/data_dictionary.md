# Data Dictionary

## Dataset Overview

This project uses the Olist Brazilian E-Commerce Public Dataset from Kaggle. The dataset contains customer, order, payment, product, seller, review, and location-level data from a Brazilian e-commerce marketplace.

## Tables

### 1. olist_customers_dataset

Purpose:
Contains customer identifiers and customer location information.

Key fields:
- customer_id
- customer_unique_id
- customer_zip_code_prefix
- customer_city
- customer_state

Business use:
Used to analyse customer geography, repeat purchase behaviour, and customer-level retention.

---

### 2. olist_orders_dataset

Purpose:
Contains order-level journey and status information.

Key fields:
- order_id
- customer_id
- order_status
- order_purchase_timestamp
- order_approved_at
- order_delivered_carrier_date
- order_delivered_customer_date
- order_estimated_delivery_date

Business use:
Used to analyse order funnel, delivery performance, fulfilment delays, and customer journey timelines.

---

### 3. olist_order_items_dataset

Purpose:
Contains product-level items within each order.

Key fields:
- order_id
- order_item_id
- product_id
- seller_id
- shipping_limit_date
- price
- freight_value

Business use:
Used to analyse revenue, product/category performance, seller performance, and order item economics.

---

### 4. olist_order_payments_dataset

Purpose:
Contains payment information for each order.

Key fields:
- order_id
- payment_sequential
- payment_type
- payment_installments
- payment_value

Business use:
Used to analyse payment behaviour, total payment value, payment methods, and revenue patterns.

---

### 5. olist_order_reviews_dataset

Purpose:
Contains customer review scores and review timestamps.

Key fields:
- review_id
- order_id
- review_score
- review_comment_title
- review_comment_message
- review_creation_date
- review_answer_timestamp

Business use:
Used to analyse customer satisfaction and the relationship between delivery performance and review scores.

---

### 6. olist_products_dataset

Purpose:
Contains product attributes and product category information.

Key fields:
- product_id
- product_category_name
- product_name_lenght
- product_description_lenght
- product_photos_qty
- product_weight_g
- product_length_cm
- product_height_cm
- product_width_cm

Business use:
Used to analyse product category performance, physical product characteristics, and catalogue quality.

---

### 7. olist_sellers_dataset

Purpose:
Contains seller identifiers and seller location information.

Key fields:
- seller_id
- seller_zip_code_prefix
- seller_city
- seller_state

Business use:
Used to analyse seller performance, regional fulfilment patterns, and marketplace operations.

---

### 8. olist_geolocation_dataset

Purpose:
Contains zip-code-level location coordinates.

Key fields:
- geolocation_zip_code_prefix
- geolocation_lat
- geolocation_lng
- geolocation_city
- geolocation_state

Business use:
Used for optional geographic analysis and mapping.

---

### 9. product_category_name_translation

Purpose:
Maps Portuguese product category names to English names.

Key fields:
- product_category_name
- product_category_name_english

Business use:
Used to make dashboard and analysis outputs readable for English-speaking stakeholders.

# Insight Log

## Data Quality Findings

### Missing order journey dates

Initial missing-value checks showed no missing dates, but improved checks detected blank or placeholder date values.

Findings:
- 160 orders are missing approval timestamps.
- 1,783 orders are missing carrier handoff dates.
- 2,965 orders are missing customer delivery dates.
- 0 orders are missing estimated delivery dates.

Business meaning:
Some orders do not fully progress through the order journey. These records need to be handled carefully in funnel and delivery analysis. Estimated delivery dates are available for all orders, which supports late-delivery analysis.

Recommendation:
Use order status filters when analysing delivery performance. Delivered-order analysis should only include orders with actual customer delivery dates. Funnel analysis should include all statuses to show drop-off across the order journey.

### Relationship integrity checks

Most key relationships passed integrity checks:
- 0 orders without customer matches.
- 0 order items without order matches.
- 0 payments without order matches.
- 0 reviews without order matches.
- 0 order items without seller matches.

However, 1,604 order item rows have product IDs that do not match the products table.

Business meaning:
Revenue analysis can still include these rows because price and freight values exist in the order_items table. However, product/category analysis must treat these rows carefully because category information may be missing.

Recommendation:
Use LEFT JOIN instead of INNER JOIN when joining order_items to products. Label missing categories as "unknown" using COALESCE so revenue is not accidentally excluded from analysis.
