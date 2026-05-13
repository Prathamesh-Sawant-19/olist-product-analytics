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
