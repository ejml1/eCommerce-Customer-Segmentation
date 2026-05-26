SELECT *
FROM rfm_analysis
LIMIT 10;

-- 234,474 Total Users
SELECT COUNT(*)
FROM rfm_analysis;

-- 5,400 (2.3%) users score 5,5,5 on the RFM model
SELECT COUNT(*)
FROM rfm_analysis
WHERE recency_percentile = 5
  AND frequency_percentile = 5
  AND monetary_percentile = 5;

/*
 Analysis of most recent buyers
 MIN: 2020-10-26
 MAX: 2020-11-21
 */
SELECT MIN(STRFTIME('%Y-%m-%d', last_purchase)) AS min_latest_purchase,
       MAX(STRFTIME('%Y-%m-%d', last_purchase)) AS max_latest_purchases
FROM rfm_analysis
WHERE recency_percentile = 5;

/*
 Analysis of highest frequency of buyers
 MIN: 2
 MAX: 178
 AVG: 4

 The spread of buyers is extremely large, and the MIN number of purchases
 in the highest frequency of buyers category is 2. Splitting by percentiles
 may not be the most appropriate for 'frequency' as 1-2 frequency is split amongst
 buyers are split across 4 segments.
 */
SELECT MIN(num_purchases) AS min_num_purchases,
       MAX(num_purchases) AS max_num_purchase,
       ROUND(AVG(num_purchases),1) AS avg_num_purchases
FROM rfm_analysis
WHERE frequency_percentile = 5;

/*
 Analysis of customers with the largest monetary value
 MIN: $740.49
 MAX: $68,035.60
 AVG: $1718.66
 */
SELECT MIN(total_spend) AS min_total_spent,
       MAX(total_spend) AS max_total_spent,
       ROUND(AVG(total_spend),2) AS avg_total_spent
FROM rfm_analysis
WHERE monetary_percentile = 5;

SELECT COUNT(user)
FROM rfm_analysis
WHERE ROUND((monetary_percentile + frequency_percentile) / 2 , 0) >= 4
  AND recency_percentile = 5;