-- ============================================================
-- CAFE SALES BUSINESS ANALYSIS
-- ============================================================


-- ============================================================
-- Q1. Which items generate the most revenue?
-- ============================================================
SELECT
    item,
    ROUND(SUM(total_spent), 2)          AS total_revenue
FROM cafe_sales
GROUP BY item
ORDER BY total_revenue DESC;


-- ============================================================
-- Q2. What are the peak sales days of the week?
-- ============================================================
SELECT
    TO_CHAR(transaction_date, 'Day')    AS day_name,
    EXTRACT(DOW FROM transaction_date)  AS day_number,
    COUNT(*)                            AS total_transactions,
    ROUND(SUM(total_spent), 2)          AS total_revenue
FROM cafe_sales
GROUP BY day_name, day_number
ORDER BY day_number;


-- ============================================================
-- Q3. Which payment method is most popular and does it vary by location?
-- ============================================================
SELECT
    location,
    payment_method,
    COUNT(*)                                                                AS total_transactions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY location), 2) AS pct_within_location
FROM cafe_sales
GROUP BY location, payment_method
ORDER BY location, total_transactions DESC;


-- ============================================================
-- Q4. How has monthly revenue trended across the year?
-- ============================================================
SELECT
    EXTRACT(YEAR FROM transaction_date)             AS year,
    EXTRACT(MONTH FROM transaction_date)            AS month_number,
    TO_CHAR(transaction_date, 'Month')              AS month_name,
    COUNT(*)                                        AS total_transactions,
    ROUND(SUM(total_spent), 2)                      AS total_revenue,
    ROUND(AVG(total_spent), 2)                      AS avg_order_value
FROM cafe_sales
GROUP BY year, month_number, month_name
ORDER BY year, month_number;


-- ============================================================
-- Q5. What is the average order value per item and per location?
-- ============================================================
SELECT
    item,
    location,
    COUNT(*)                            AS total_orders,
    ROUND(AVG(total_spent), 2)          AS avg_order_value,
    ROUND(SUM(total_spent), 2)          AS total_revenue
FROM cafe_sales
GROUP BY item, location
ORDER BY item, location;


-- ============================================================
-- Q6. Which items sell the highest quantity but generate below average revenue?
-- ============================================================
SELECT
    item,
    SUM(quantity)                       AS total_quantity_sold,
    ROUND(SUM(total_spent), 2)          AS total_revenue,
    ROUND(AVG(total_spent), 2)          AS avg_order_value
FROM cafe_sales
GROUP BY item
HAVING ROUND(AVG(total_spent), 2) < (
    SELECT ROUND(AVG(total_spent), 2)
    FROM cafe_sales
)
ORDER BY total_quantity_sold DESC;


-- ============================================================
-- Q7. What percentage of transactions are per location per month?
-- ============================================================
SELECT
    TO_CHAR(transaction_date, 'Month')                                          AS month_name,
    EXTRACT(MONTH FROM transaction_date)                                        AS month_number,
    location,
    COUNT(*)                                                                    AS total_transactions,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (
        PARTITION BY EXTRACT(MONTH FROM transaction_date)), 2)                  AS pct_of_month
FROM cafe_sales
GROUP BY month_name, month_number, location
ORDER BY month_number, location;


-- ============================================================
-- Q8. What is the busiest hour of the day? (only if time data exists)
-- ============================================================
SELECT
    EXTRACT(HOUR FROM transaction_date::TIMESTAMP)  AS hour_of_day,
    COUNT(*)                                        AS total_transactions,
    ROUND(SUM(total_spent), 2)                      AS total_revenue
FROM cafe_sales
WHERE transaction_date IS NOT NULL
GROUP BY hour_of_day
ORDER BY hour_of_day;