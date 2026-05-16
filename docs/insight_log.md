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

# Insight Log

## Order Funnel Analysis
- 97.02% of orders completed successfully
- Main operational bottleneck identified in carrier-to-customer delivery stage
- Average purchase-to-delivery time: 12.09 days
- Late deliveries account for 8.11% of delivered orders

## Delivery Performance Analysis
- 93.22% deliveries arrive on time or early
- Severe late deliveries (>7 days) account for ~3%
- Delivery efficiency improved significantly over time despite order growth
- Late deliveries strongly impact review score (2.57 vs 4.29)

## Revenue and Product Category Analysis

- Total item revenue was approximately 13.59M, with freight contributing approximately 2.25M. Combined item + freight value was approximately 15.84M across 112,650 order items and 98,666 orders with items.
- Health & beauty was the highest-revenue product category, generating approximately 1.26M in item revenue from 9,670 order items and 8,836 orders, with an average item price of 130.16.
- Watches/gifts and bed/bath/table were also major revenue-driving categories, showing that revenue is concentrated in a few high-volume consumer categories.
- Seller revenue is highly concentrated, with several top sellers based in São Paulo (SP). The highest-revenue seller generated approximately 229.47K in item revenue and 249.64K total value despite not having the highest order count, suggesting higher average order/item value.
- Customer demand is strongly concentrated in SP, which generated approximately 5.20M in item revenue and 5.92M total value, far ahead of other states.
- Credit card is the dominant payment method, accounting for approximately 12.54M in payment value across 76,795 payment records.
- Payment totals are highly consistent with item + freight totals, with only a 2,870.39 total difference across 98,665 matched orders, averaging around 0.03 difference per order. This validates payment data reliability for revenue analysis.
- High-revenue categories generally maintain strong review scores. Health & beauty had an average review score of 4.14, while watches/gifts had 4.02 and bed/bath/table had 3.90.