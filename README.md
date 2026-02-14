## eCommerce Segmentation

<img src="images/eCommerce_banner.png">

## Problem Statement
RFM analysis is a marketing technique used to identify and segment customers based on 3 key metrics:

- <b>Recency (R)</b>: Measures how recently a customer made their last purchase
- <b>Frequency (F)</b>: Tracks how often a customer makes purchases within a specific timeframe
- <b>Monetary (M)</b>: Assesses the total amount of money a customer spends

By analysing these three metrics, businesses can classify customers into distinct segments (like "Champions," "At Risk," 
and "New Customers") and tailor marketing strategies accordingly. This enables targeted marketing strategies to improve 
customer retention and drive sales growth.

<img src="images/RFM_segments_example.png">

Example image of RFM Segments dashboard by [John Abbasi](https://www.peelinsights.com/post/what-is-rfm-analysis)


## Dataset
The eCommerce purchase history from electronics store dataset from Kaggle
[https://www.kaggle.com/datasets/mkechinov/ecommerce-purchase-history-from-electronics-store](https://www.kaggle.com/datasets/mkechinov/ecommerce-purchase-history-from-electronics-store) 
is used for this project. The dataset was transformed into a SQLite database with the following fields:

- `event_time`: The date & time the event occurred in yyyy-MM-dd HH:mm:ss UTC format
- `order_id`: Order ID
- `product_id`: Product ID
- `category_id`: Product category ID
- `category_code`: Name for given category (if present)
- `brand`: Brand name
- `Price`: Product price
- `user_id`: User ID associated with event

## EDA

EDA was performed using SQL

### Key Findings:
- The dataset extends until 2020-11-21. However, it contains a significant number of purchases from 1970-01-01, this is
likely some form of error as the only years present in the dataset were 2020 and 1970
- `user` contained null values while `price` contained null values, indicating missing data. This data 
encompasses 16% of the total rows
- 1,637,398 of `user_id` contained an empty string, which equated to 62% the total rows. This required further investigation as
this was a significant proportion of the dataset
- All `price` values that were null also had null `user_id` values. It was discovered for these records that the
`category_code` and the `brand` fields contained the `price` and `user_id` for these records respectively
- 1,198,255 rows had duplicate `order_id` values. If a `order_id` was duplicated, it indicates that the user purchased
multiple products in a single order

Full description of EDA can be found in [EDA.sql](https://github.com/ejml1/eCommerce-Customer-Segmentation/blob/master/EDA.sql)
