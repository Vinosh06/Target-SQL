# Creating a new data base

create database case_study_1;

# First Create a Database and import all in the data's in a table

# 1. Import the dataset and do usual exploratory analysis steps like checking the structure & characteristics of the dataset:
# 1.1 Data type of all columns in the "customers" table.

# Customer Table:
# Preview the Data:
SELECT * FROM `Business_Case_study_1.customers`
LIMIT 10;

# Count Total Records:
SELECT COUNT(*) AS total_customers 
FROM `Business_Case_study_1.customers`;

# Unique Customer IDs:
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers 
FROM `Business_Case_study_1.customers`;

# Distribution of Customers by State:
SELECT customer_state, COUNT(*) AS customer_count
FROM `Business_Case_study_1.customers`
GROUP BY customer_state
ORDER BY customer_count DESC;

# Sellers Table:
# Preview the Data
SELECT * FROM `Business_Case_study_1.sellers`
LIMIT 10;

# Count Total Records:
SELECT COUNT(*) AS total_sellers 
FROM `Business_Case_study_1.sellers`;

# Distribution of Sellers by State:
SELECT seller_state, COUNT(*) AS seller_count
FROM `Business_Case_study_1.sellers`
GROUP BY seller_state
ORDER BY seller_count DESC;

# Orders Table:
# Preview the Data:
SELECT * FROM `Business_Case_study_1.orders`
LIMIT 10;

# Count Total Orders:
SELECT COUNT(*) AS total_orders 
FROM `Business_Case_study_1.orders`;

# Distribution of Orders by Status:
SELECT order_status, COUNT(*) AS order_count
FROM `Business_Case_study_1.orders`
GROUP BY order_status
ORDER BY order_count DESC;

# Orders Over Time (Yearly):
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year, COUNT(*) AS order_count
FROM `Business_Case_study_1.orders`
GROUP BY year
ORDER BY year;

# Order_items Table
# Preview the Data:
SELECT * FROM `Business_Case_study_1.order_items`
LIMIT 10;

# Count Total Items Ordered:
SELECT COUNT(*) AS total_items_ordered 
FROM `Business_Case_study_1.order_items`;

# Calculate Average Price and Freight Value:
SELECT AVG(price) AS avg_price, AVG(freight_value) AS avg_freight_value
FROM `Business_Case_study_1.order_items`;

# Total Revenue from Orders:
SELECT SUM(price) AS total_revenue 
FROM `Business_Case_study_1.order_items`;

# Payments Table
# Preview the Data:
SELECT * FROM `Business_Case_study_1.payments`
LIMIT 10;

# Distribution of Payment Types:
SELECT payment_type, COUNT(*) AS payment_count
FROM `Business_Case_study_1.payments`
GROUP BY payment_type
ORDER BY payment_count DESC;

# Average Payment Value:
SELECT AVG(payment_value) AS avg_payment_value
FROM `Business_Case_study_1.payments`;

# Reviews Table
# Preview the Data:
SELECT * FROM `Business_Case_study_1.order_reviews`
LIMIT 10;

# Average Review Score:
SELECT AVG(review_score) AS avg_review_score 
FROM `Business_Case_study_1.order_reviews`;

# Distribution of Review Scores:
SELECT review_score, COUNT(*) AS score_count
FROM `Business_Case_study_1.order_reviews`
GROUP BY review_score
ORDER BY review_score;

#Products Table
# Preview the Data:
SELECT * FROM `Business_Case_study_1.products`
LIMIT 10;

# Count Total Products:
SELECT COUNT(*) AS total_products 
FROM `Business_Case_study_1.products`;

# Top Product Categories by Count:
SELECT `product category`, COUNT(*) AS category_count
FROM `Business_Case_study_1.products`
GROUP BY `product category`
ORDER BY category_count DESC
LIMIT 10;

# Geolocation Table
#Preview the Data:
SELECT * FROM `Business_Case_study_1.geolocation`
LIMIT 10;

# Count Total Records:
SELECT COUNT(*) AS total_geolocations 
FROM `Business_Case_study_1.geolocation`;

# Unique Zip Code Prefixes:
SELECT COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes
FROM `Business_Case_study_1.geolocation`;

# Distribution of Locations by State:
SELECT geolocation_state, COUNT(*) AS location_count
FROM `Business_Case_study_1.geolocation`
GROUP BY geolocation_state
ORDER BY location_count DESC;


# 1.2 Get the time range between which the orders were placed.

# Minimum and Maximum Order Date
SELECT MIN(order_purchase_timestamp) AS earliest_order_date, MAX(order_purchase_timestamp) AS latest_order_date
FROM `Business_Case_study_1.orders`;

# Total Orders by Year
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS year, COUNT(*) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY year
ORDER BY year;

# Total Orders by Month
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month, 
    COUNT(*) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY year, month
ORDER BY year, month;

# Total Orders by Quarter
SELECT 
    CONCAT('Q', CAST(EXTRACT(QUARTER FROM order_purchase_timestamp) AS STRING)) AS quarter, 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
    COUNT(*) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY year, quarter
ORDER BY year, quarter;

# Peak days of order placement
SELECT 
    EXTRACT(DAYOFWEEK FROM order_purchase_timestamp) AS day_of_week, 
    COUNT(*) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY day_of_week
ORDER BY total_orders DESC;

# Orders Placed During Each Hour of the Day
SELECT 
    EXTRACT(HOUR FROM order_purchase_timestamp) AS hour_of_day, 
    COUNT(*) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY hour_of_day
ORDER BY hour_of_day;

# Average time to deliver orders
SELECT 
    AVG(TIMESTAMP_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY)) AS avg_delivery_time_in_days
FROM `Business_Case_study_1.orders`
WHERE order_delivered_customer_date IS NOT NULL;

# 1.3 Count the Cities & States of customers who ordered during the given period.
# Period is taken randomly - we can mention the period we needed

SELECT 
    c.customer_city AS city,
    c.customer_state AS state,
    COUNT(*) AS total_orders
FROM `Business_Case_study_1.orders` o
JOIN `Business_Case_study_1.customers` c
ON o.customer_id = c.customer_id
WHERE o.order_purchase_timestamp BETWEEN '2016-01-01' AND '2018-12-31'
GROUP BY city, state
ORDER BY total_orders DESC;

-----------------------------------------------------------------------------------------------------------------------------------

# 2. In-depth Exploration:
# 2.1 Is there a growing trend in the no. of orders placed over the past years?

# Calculate Year-over-Year Growth
WITH yearly_orders AS (
    SELECT 
        EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
        COUNT(order_id) AS total_orders
    FROM `Business_Case_study_1.orders`
    GROUP BY year
    ORDER BY year
)
SELECT 
    year,
    total_orders,
    LAG(total_orders) OVER (ORDER BY year) AS previous_year_orders,
    ROUND(((total_orders - LAG(total_orders) OVER (ORDER BY year)) / 
            LAG(total_orders) OVER (ORDER BY year)) * 100, 2) AS year_over_year_growth
FROM yearly_orders;

# Monthly Trend Analysis
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    COUNT(order_id) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY year, month
ORDER BY year, month;

# Categorize by Order Status
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    order_status,
    COUNT(order_id) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY year, order_status
ORDER BY year, total_orders DESC;

# Customer Growth Over the Years
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM `Business_Case_study_1.orders`
GROUP BY year
ORDER BY year;

# Region-Wise Growth
SELECT 
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    c.customer_state AS state,
    COUNT(o.order_id) AS total_orders
FROM `Business_Case_study_1.orders` o
JOIN `Business_Case_study_1.customers` c
ON o.customer_id = c.customer_id
GROUP BY year, state
ORDER BY year, total_orders DESC;

# 2.2 Can we see some kind of monthly seasonality in terms of the no. of orders being placed?

# Monthly Seasonality
SELECT 
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
    COUNT(order_id) AS total_orders
FROM `Business_Case_study_1.orders`
GROUP BY month
ORDER BY month;

# Average Orders per Month
SELECT 
    month,ROUND(AVG(total_orders), 2) AS avg_monthly_orders
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
        COUNT(order_id) AS total_orders
    FROM `Business_Case_study_1.orders`
    GROUP BY year, month
) AS yearly_data
GROUP BY month
ORDER BY month;

# 2.3 During what time of the day, do the Brazilian customers mostly place their orders

SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM o.order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
        WHEN EXTRACT(HOUR FROM o.order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM o.order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(o.order_id) AS total_orders
FROM `Business_Case_study_1.orders` o
JOIN `Business_Case_study_1.customers` c
ON o.customer_id = c.customer_id
WHERE c.customer_state IS NOT NULL
GROUP BY time_of_day
ORDER BY total_orders DESC;

-----------------------------------------------------------------------------------------------------------------------------------

# 3. Evolution of E-commerce orders in the Brazil region:
# 3.1 Get the month on month no. of orders placed in each state.

SELECT 
    c.customer_state AS state,
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    COUNT(o.order_id) AS total_orders
FROM `Business_Case_study_1.orders` o
JOIN `Business_Case_study_1.customers` c
ON o.customer_id = c.customer_id
WHERE c.customer_state IS NOT NULL
GROUP BY state, year, month
ORDER BY state, year, month;

# Top Performing States:
SELECT state, month, total_orders,
    LAG(total_orders) OVER (PARTITION BY state ORDER BY year, month) AS previous_month_orders,
    ROUND((total_orders - LAG(total_orders) OVER (PARTITION BY state ORDER BY year, month)) / 
          LAG(total_orders) OVER (PARTITION BY state ORDER BY year, month) * 100, 2) AS percent_change
FROM (SELECT c.customer_state AS state,
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
        COUNT(o.order_id) AS total_orders
    FROM `Business_Case_study_1.orders` o
    JOIN `Business_Case_study_1.customers` c
    ON o.customer_id = c.customer_id
    WHERE c.customer_state IS NOT NULL
    GROUP BY state, year, month
) monthly_data
ORDER BY state, year, month;

# 3.2 How are the customers distributed across all the states?

SELECT 
    customer_state AS state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM `Business_Case_study_1.customers`
GROUP BY customer_state
ORDER BY total_customers DESC;

# Proportion of Customers:
SELECT 
    customer_state AS state,
    COUNT(DISTINCT customer_unique_id) AS total_customers,
    ROUND(COUNT(DISTINCT customer_unique_id) * 100.0 / 
          (SELECT COUNT(DISTINCT customer_unique_id) FROM `Business_Case_study_1.customers`), 2) AS customer_percentage
FROM `Business_Case_study_1.customers`
GROUP BY customer_state
ORDER BY total_customers DESC;

-----------------------------------------------------------------------------------------------------------------------------------

# 4. Impact on Economy: Analyze the money movement by e-commerce by looking at order prices, freight and others.
# 4.1 Get the % increase in the cost of orders from year 2017 to 2018 (include months between Jan to Aug only).You can use the "payment_value" column in the payments table to get the cost of orders.

WITH yearly_payment_data AS (
    SELECT 
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
        SUM(p.payment_value) AS total_payment
    FROM `Business_Case_study_1.payments` p
    JOIN `Business_Case_study_1.orders` o
    ON p.order_id = o.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) IN (2017, 2018)
      AND EXTRACT(MONTH FROM o.order_purchase_timestamp) BETWEEN 1 AND 8
    GROUP BY year
)
SELECT 
    year,
    total_payment,
    LAG(total_payment) OVER (ORDER BY year) AS previous_year_payment,
    ROUND(((total_payment - LAG(total_payment) OVER (ORDER BY year)) / 
           LAG(total_payment) OVER (ORDER BY year)) * 100, 2) AS percent_increase
FROM yearly_payment_data;


# 4.2 Calculate the Total & Average value of order price for each state.

SELECT 
    c.customer_state AS state,
    ROUND(SUM(p.payment_value), 2) AS total_order_value,
    ROUND(AVG(p.payment_value), 2) AS avg_order_value,
    ROUND(SUM(p.payment_value) * 100.0 / (SELECT SUM(payment_value) FROM 
    `Business_Case_study_1.payments`), 2) AS contribution_percentage
FROM `Business_Case_study_1.payments` p
JOIN `Business_Case_study_1.orders` o
ON p.order_id = o.order_id
JOIN `Business_Case_study_1.customers` c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_order_value DESC;

# 4.3 Calculate the Total & Average value of order freight for each state.

SELECT 
    c.customer_state AS state,
    ROUND(SUM(oi.freight_value), 2) AS total_freight_value,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_value
FROM `Business_Case_study_1.order_items` oi
JOIN `Business_Case_study_1.orders` o
ON oi.order_id = o.order_id
JOIN `Business_Case_study_1.customers` c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_freight_value DESC;

-----------------------------------------------------------------------------------------------------------------------------------

# 5. Analysis based on sales, freight and delivery time.
# 5.1 Find the no. of days taken to deliver each order from the order’s purchase date as delivery time.Also, calculate the difference (in days) between the estimated & actual delivery date of an order.

SELECT 
    order_id,
    DATE(order_purchase_timestamp) AS purchase_date,
    DATE(order_delivered_customer_date) AS actual_delivery_date,
    DATE(order_estimated_delivery_date) AS estimated_delivery_date,
    DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS time_to_deliver,
    DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS diff_estimated_delivery
FROM `Business_Case_study_1.orders`
WHERE order_status = 'delivered'
ORDER BY order_id;

# 5.2 Find out the top 5 states with the highest & lowest average freight value.

WITH StateFreight AS (SELECT c.customer_state AS state,
        ROUND(AVG(oi.freight_value), 2) AS avg_freight_value
    FROM `Business_Case_study_1.order_items` oi
    JOIN `Business_Case_study_1.orders` o
    ON oi.order_id = o.order_id
    JOIN `Business_Case_study_1.customers` c
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
), RankedFreight AS (SELECT state, avg_freight_value,
        RANK() OVER (ORDER BY avg_freight_value DESC) AS rank_highest,
        RANK() OVER (ORDER BY avg_freight_value ASC) AS rank_lowest
    FROM StateFreight
) SELECT state, avg_freight_value FROM RankedFreight
WHERE rank_highest <= 5 OR rank_lowest <= 5
ORDER BY avg_freight_value DESC;

# 5.3 Find out the top 5 states with the highest & lowest average delivery time.

WITH StateDeliveryTime AS (
    SELECT c.customer_state AS state,
        ROUND(AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)), 2) AS avg_delivery_time
    FROM `Business_Case_study_1.orders` o
    JOIN `Business_Case_study_1.customers` c
    ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
),
RankedDelivery AS (SELECT state, avg_delivery_time,
        RANK() OVER (ORDER BY avg_delivery_time DESC) AS rank_highest,
        RANK() OVER (ORDER BY avg_delivery_time ASC) AS rank_lowest
    FROM StateDeliveryTime
)
SELECT state, avg_delivery_time FROM RankedDelivery
WHERE rank_highest <= 5 OR rank_lowest <= 5
ORDER BY avg_delivery_time DESC;

# 5.4 Find out the top 5 states where the order delivery is really fast as compared to the estimated date of delivery. You can use the difference between the averages of actual & estimated delivery date to figure out how fast the delivery was for each state.

WITH StateDeliveryComparison AS (
    SELECT c.customer_state AS state,
        ROUND(AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY)), 2) AS avg_delivery_diff
    FROM `Business_Case_study_1.orders` o
    JOIN `Business_Case_study_1.customers` c
    ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
),
RankedStates AS (SELECT state, avg_delivery_diff,
        RANK() OVER (ORDER BY avg_delivery_diff ASC) AS rank_fastest
    FROM StateDeliveryComparison
)
SELECT state, avg_delivery_diff
FROM RankedStates
WHERE rank_fastest <= 5
ORDER BY avg_delivery_diff ASC;

-----------------------------------------------------------------------------------------------------------------------------------

# 6. Analysis based on the payments:
# 6.1 Find the month on month no. of orders placed using different payment types.

SELECT EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month,
    p.payment_type,
    COUNT(DISTINCT p.order_id) AS total_orders
FROM `Business_Case_study_1.orders` o
JOIN `Business_Case_study_1.payments` p
ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY year, month, p.payment_type
ORDER BY year, month, p.payment_type;

# 6.2 Find the no. of orders placed on the basis of the payment installments that have been paid.

SELECT 
    p.payment_installments,
    COUNT(DISTINCT p.order_id) AS total_orders
FROM `Business_Case_study_1.payments` p
GROUP BY p.payment_installments
ORDER BY p.payment_installments;

# Actionable Insights & Recommendations

# 1. Customer Behavior Insights

# Insight: Most orders are placed during the Afternoon (13:00–18:00) and Night (19:00–23:00).
# Recommendation: Schedule promotional campaigns, discounts, and advertisements during these hours to maximize engagement and sales.

# Insight: Customers in SP and other urban states dominate the e-commerce market.
# Recommendation: Focus on enhancing delivery speed and customer experience in urban areas while investing in marketing and logistics infrastructure in underrepresented states to expand the customer base.

# 2. Order Trends

# Insight: A growing trend in e-commerce orders is observed, particularly in 2017–2018.
# Recommendation: Capitalize on the growing e-commerce adoption by diversifying product offerings and enhancing digital marketing strategies.

#Insight: There is a noticeable monthly seasonality, with peaks observed during certain months.
# Recommendation: Align inventory management and logistics planning with peak months to avoid stockouts and ensure timely delivery.

# 3. Delivery Insights

#Insight: Delivery times vary significantly across states, with some states experiencing faster deliveries than estimated.
# Recommendation: Analyze logistics in high-performing states and replicate best practices across other regions. For states with slower deliveries, identify bottlenecks and collaborate with local carriers.

# Insight: Certain states show a significant difference between estimated and actual delivery times.
# Recommendation: Improve delivery time estimation models to set realistic expectations and enhance customer satisfaction.

# 4. Payment Insights

#Insight: Credit card payments dominate, with installment plans being widely used.
# Recommendation: Offer attractive installment options and partnerships with financial institutions to encourage higher-value purchases.

# Insight: Payments with multiple installments are common, especially in higher-value orders.
# Recommendation: Promote installment plans during marketing campaigns to attract budget-conscious customers.

# 5. Economic Impact

# Insight: The cost of orders (freight and product value) increased by over 10% from 2017 to 2018.
# Recommendation: Monitor pricing strategies and freight costs to remain competitive. Consider implementing cost-saving measures in the supply chain.

# Insight: States with higher average freight values often correspond to regions farther from logistics hubs.
# Recommendation: Optimize distribution centers and explore local partnerships to reduce freight costs in remote regions.

# 6. State-Wise Insights

# Insight: Certain states like SP show the highest order values and fastest deliveries, while others lag.
# Recommendation: Conduct a state-wise performance review and tailor strategies for low-performing regions to boost customer acquisition and retention.
