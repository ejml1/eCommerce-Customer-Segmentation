-- EDA

-- SELECT HEAD
SELECT *
FROM ecommerce
LIMIT 10
OFFSET (SELECT COUNT(*) FROM ecommerce) - 10;

-- COUNT(*): 2633521
SELECT COUNT(*)
FROM ecommerce;

/*
 Count distinct users and orders

 Users: 233835
 Orders: 1435266
 */
SELECT
    COUNT(DISTINCT(user_id)),
    COUNT(DISTINCT(order_id))
FROM ecommerce;

/*
 Check null values:
 price_null and user_id_null = 431954 which equates to ~16% of the data
 */
SELECT COUNT(*)-COUNT(event_time) AS event_time_null,
    COUNT(*)-COUNT(order_id) AS order_id_null,
    COUNT(*)-COUNT(product_id) AS product_id_null,
    COUNT(*)-COUNT(category_id) AS category_id_null,
    COUNT(*)-COUNT(category_code) AS category_code_null,
    COUNT(*)-COUNT(brand) AS brand_null,
    COUNT(*)-COUNT(price) AS price_null,
    COUNT(*)-COUNT(user_id) AS user_id_null
FROM ecommerce;

/*
 Check empty or 0 values:

 empty_category_id = 431954
 empty_category_code = 612202
 empty_brand = 506005
 empty_price = 121
 empty_user_id = 1637398
 */
SELECT SUM(CASE WHEN event_time = '' THEN 1 ELSE 0 END) AS empty_event_time,
       SUM(CASE WHEN order_id = '' THEN 1 ELSE 0 END) AS empty_order_id,
       SUM(CASE WHEN product_id = '' THEN 1 ELSE 0 END) AS empty_product_id,
       SUM(CASE WHEN category_id = '' THEN 1 ELSE 0 END) AS empty_category_id,
       SUM(CASE WHEN category_code = '' THEN 1 ELSE 0 END) AS empty_category_code,
       SUM(CASE WHEN brand = '' THEN 1 ELSE 0 END) AS empty_brand,
       SUM(CASE WHEN price = 0 THEN 1 ELSE 0 END) AS empty_price,
       SUM(CASE WHEN user_id = '' THEN 1 ELSE 0 END) AS empty_user_id
FROM ecommerce;

/*
 Check for if there are any duplicate order ids
 Outcome: There are 1198255 duplicate orders
 */
SELECT COUNT(order_id) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM ecommerce;

/*
 Check for order_id COUNT for each record
 */
SELECT
    order_id,
    COUNT(order_id)
FROM ecommerce
GROUP BY order_id
ORDER BY COUNT(order_id) DESC;

/*
 Visualise an example where there are multiple records with the same order_id

 This example has no user_id
 */
SELECT *
FROM ecommerce
WHERE order_id = '2388440981134393883';

/*
 Check for order_id count for each record with a non-null/empty user_id
 */
SELECT
    order_id,
    COUNT(order_id)
FROM ecommerce
WHERE user_id IS NOT NULL AND user_id != ''
GROUP BY order_id
ORDER BY COUNT(order_id) DESC;

/*
 Visualise an example where there are multiple records with the same order_id and a valid user

 This example contains records where price and user_id is null. However, for these records,
 category_code and brand contain a float and integer. This integer corresponds to the same user_id,
 highlighting errors in the data formatting.
 */
SELECT *
FROM ecommerce
WHERE order_id = '2388440981134689974';

SELECT *
FROM ecommerce
WHERE order_id = '2319266497744077025';

/*
 Check if all null prices overlap with all null users
 Outcome: All null prices overlap with all null users
 */
SELECT COUNT(*)
FROM ecommerce
WHERE price IS NULL AND user_id IS NULL;

/*
 HEAD to visualise records that have null prices and user_id

 Similar to the "Visualise an example where there are multiple records with the same order_id and a valid user",
 category_code and brand contain a float and integer. The brand is formatted in way similar to a user_id,
 highlighting errors in the data formatting.

 TODO: Need to think of a strategy to correct these values
 */
SELECT *
FROM ecommerce
WHERE price IS NULL AND user_id IS NULL
LIMIT 10;

/*
Max values:
Last Purchase: 2020-11-21
Largest Single Order: $50925.9
*/
SELECT
    MAX(STRFTIME('%Y-%m-%d', SUBSTR(event_time,1,10))) AS last_purchase,
    MAX(price) AS largest_single_order
FROM ecommerce;

/*
 Min values:
 Earliest: 1970-01-01
 Largest Single Order: $0

 1970 is the earliest purchase. However as this is an e-commerce store, this data does not look correct
 Orders of $0 also signifies that data is missing from these orders
 */
SELECT
    MIN(STRFTIME('%Y-%m-%d', SUBSTR(event_time,1,10))) AS first_purchase,
    MIN(price) AS smallest_single_order
FROM ecommerce;

/*
 Average Values
 Average Spent on Single Order: $154.09
 */
SELECT
    ROUND(AVG(price),2) AS average_spent_single_order
FROM ecommerce;

/*
 Check the DISTINCT years

 The distinct years are 2020 and 1970. As this is an ecommerce site, it is unlikely that 1970 is a valid value.
 This will skew the recency section of the RFM model, therefore these records will not be used in the analysis
 */
SELECT DISTINCT(STRFTIME('%Y', SUBSTR(event_time,1,10))) AS unique_years
FROM ecommerce
ORDER BY unique_years DESC
LIMIT 10;

WITH cte_imputed AS(
    SELECT
        order_id,
        event_time,
        COALESCE(price, category_code) AS price,
        COALESCE(user_id, brand) AS user
    FROM ecommerce
    WHERE event_time NOT LIKE '1970%'
),
cte_grouped AS(
    SELECT
        order_id,
        event_time,
        user,
        ROUND(SUM(price),2) AS single_order_purchase
    FROM cte_imputed
    WHERE (user IS NOT NULL AND user != '')
      AND price != 0
    GROUP BY order_id, event_time, user
),
cte_data AS(
    SELECT
        user,
        MAX(SUBSTR(event_time,1,10)) AS last_purchase,
        COUNT(order_id) AS num_purchases,
        ROUND(SUM(single_order_purchase), 2) AS total_spend
    FROM cte_grouped
    GROUP BY
        user
),
cte_rfm AS(
    SELECT
        user,
        last_purchase,
        num_purchases,
        total_spend,
        NTILE(10) OVER (ORDER BY last_purchase) AS recency_percentile,
        NTILE(10) OVER (ORDER BY num_purchases) AS frequency_percentile,
        NTILE(10) OVER (ORDER BY total_spend) AS monetary_percentile
    FROM cte_data
    ORDER BY frequency_percentile DESC
)

SELECT *
FROM cte_rfm
ORDER BY
    recency_percentile DESC,
    frequency_percentile DESC,
    monetary_percentile DESC;
