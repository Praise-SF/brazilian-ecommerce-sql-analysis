==================================================
## CHECK 7A — Customer delivery cannot occur before purchase

**Query used:**
```sql
SELECT COUNT(*) AS invalid_delivery_orders
FROM orders
WHERE NULLIF(TRIM(order_delivered_customer_date), '') IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;
```

**Result:**

| invalid_delivery_orders |
|---|
| 0 |

**Confirmed:** No orders were found where the customer delivery date occurred before the purchase timestamp. This check passed.

==================================================
## CHECK 7B — Carrier delivery cannot occur before purchase

**Query used:**
```sql
SELECT COUNT(*) AS invalid_carrier_orders
FROM orders
WHERE NULLIF(TRIM(order_delivered_carrier_date), '') IS NOT NULL
  AND order_delivered_carrier_date < order_purchase_timestamp;
```

**Result:**

| invalid_carrier_orders |
|---|
| 166 |

**Confirmed:** 166 orders show a carrier delivery date occurring *before* the purchase timestamp — logically impossible, since an item can't be handed to a carrier before it was purchased. This indicates either a data entry error in the source system or a timestamp logging issue upstream. Flagged as a data quality limitation rather than corrected, since the true intended values can't be recovered from the data alone.

==================================================
## CHECK 7C — Customer delivery should not occur before carrier delivery

**Query used:**
```sql
SELECT COUNT(*) AS invalid_delivery_sequence
FROM orders
WHERE NULLIF(TRIM(order_delivered_carrier_date), '') IS NOT NULL
  AND NULLIF(TRIM(order_delivered_customer_date), '') IS NOT NULL
  AND order_delivered_customer_date < order_delivered_carrier_date;
```

**Result:**

| invalid_delivery_sequence |
|---|
| 23 |

**Confirmed:** 23 orders show the customer receiving delivery *before* the carrier delivery date was logged — another timestamp sequencing inconsistency. Combined with Check 7B, this suggests a small but non-trivial number of orders (189 total across both checks) have unreliable carrier-date logging. This should be kept in mind when using `order_delivered_carrier_date` in later analysis — it's less reliable than `order_purchase_timestamp` or `order_delivered_customer_date`, both of which passed their consistency checks cleanly.

==================================================
## CHECK 8 — Review score range and average

**Query used:**
```sql
SELECT
    MIN(review_score) AS minimum_score,
    MAX(review_score) AS maximum_score,
    AVG(review_score) AS average_score
FROM order_reviews;
```

**Result:**

| minimum_score | maximum_score | average_score |
|---|---|---|
| 1 | 5 | 4.0864 |

**Confirmed:** Review scores fall entirely within the expected 1-5 range (no invalid values), with an average of 4.09 — indicating generally positive customer sentiment across the platform.

==================================================
## CHECK 9 — Review score distribution

**Query used:**
```sql
SELECT
    review_score,
    COUNT(*) AS review_count
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;
```

**Result:**

| review_score | review_count |
|---|---|
| 1 | 11,424 |
| 2 | 3,151 |
| 3 | 8,179 |
| 4 | 19,142 |
| 5 | 57,327 |

**Confirmed:** The distribution is heavily skewed toward 5-star reviews (57,327 — roughly 58% of all reviews), but 1-star reviews (11,424) are notably more common than 2-star or 3-star reviews — a "polarized" pattern rather than a smooth curve. This is a common review-platform phenomenon (people are more likely to leave a review when very happy or very unhappy) and is worth keeping in mind for the delivery/review correlation analysis: the 1-star group is large enough to be statistically meaningful when segmenting by delivery lateness later.

==================================================
## Updated Summary of Findings

13. Carrier delivery date occurs before purchase timestamp in 166 orders — a data quality issue, not corrected in place.
14. Customer delivery occurs before carrier delivery in 23 orders — a secondary timestamp sequencing issue.
15. `order_delivered_carrier_date` is less reliable than other timestamp fields and should be used cautiously in later analysis.
16. Review scores range cleanly from 1-5 with an average of 4.09.
17. Review score distribution is polarized: 5-star reviews dominate (57,327), but 1-star reviews (11,424) are the second-largest group — more common than 2-star or 3-star.
18. Date/timestamp columns were converted from TEXT to DATETIME to support date arithmetic required for delivery analysis.
