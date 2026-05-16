USE olist_product_analytics;

-- Data cleaning note:
-- During import, category_translation had a malformed first column name caused by CSV encoding/BOM characters.
-- The malformed column appeared as `ï»¿product_category_name`.
-- This prevented joins between products.product_category_name and category_translation.product_category_name.

-- Inspect imported column names
DESCRIBE category_translation;

-- Manual cleaning step applied:
-- ALTER TABLE category_translation
-- CHANGE COLUMN `ï»¿product_category_name` product_category_name TEXT;

-- Expected final columns:
-- product_category_name
-- product_category_name_english

DESCRIBE category_translation;
