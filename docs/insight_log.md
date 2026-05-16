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

## Customer Retention and Cohort Analysis

- 96.88% of unique customers purchased only once, while only 3.12% made repeat purchases.
- Most repeat customers placed only two orders; higher-frequency customers were rare.
- Monthly customer acquisition increased strongly from 2017 onwards and remained high through most of 2018.
- Returning customer contribution improved gradually over time, reaching around 2.5–3.1% of active monthly customers in mid-2018, but the marketplace remained heavily acquisition-driven.
- Monthly cohort analysis showed very low repeat purchase behaviour. Most meaningful cohorts had Month 1 retention below 1%, with Month 2–6 retention generally below 0.5%.
- Small or incomplete cohorts, such as 2016-09, 2016-12, 2018-09, and 2018-10, should not be over-interpreted due to low customer counts or incomplete dataset coverage.

### Product categories associated with repeat customers

Although overall repeat purchase behaviour is weak, some product categories show stronger relative repeat-customer behaviour.

Findings:
- Home appliances had the highest repeat customer rate at 10.95%.
- Fashion bags/accessories followed at 9.12%.
- Furniture/decor reached 7.36%.
- Bed/bath/table reached 6.58%.
- Most other categories were between roughly 3% and 5%.

Business meaning:
The marketplace is broadly acquisition-driven, but some categories appear more capable of bringing customers back. These categories may have stronger replenishment, household need, lifestyle, or cross-sell potential.

Recommendation:
Use higher-repeat categories for targeted retention experiments, remarketing campaigns, bundle recommendations, loyalty offers, and post-purchase email/push journeys.

## Review and Customer Satisfaction Analysis

- Overall review sentiment is positive, with 57.78% of reviews rated 5-star and 19.29% rated 4-star.
- However, 11.51% of reviews are 1-star, creating a clear dissatisfaction segment that requires investigation.
- Review scores decline as delivery time increases: 0–7 day deliveries average 4.41, 8–14 days average 4.29, 15–21 days average 4.10, and 22+ days fall sharply to 3.01.
- Late deliveries have a major negative impact on satisfaction: 46.15% of late-delivery reviews are 1-star, compared with only 8.60% for on-time deliveries.
- On-time deliveries strongly support positive experience, with 60.77% receiving 5-star reviews.
- Office furniture is the lowest-rated high-volume category, with an average review score of 3.49.
- Other lower-rated high-volume categories include unknown, bed/bath/table, furniture/decor, computers/accessories, and telephony.

Business meaning:
Delivery reliability is strongly connected to customer satisfaction. Product and operations teams should prioritise late-delivery reduction, especially for categories and sellers with high volume and lower review performance.

Recommendation:
Build monitoring for late-delivery risk, investigate low-rated high-volume categories, and prioritise operational improvements for categories where poor satisfaction may affect repeat purchase and marketplace trust.