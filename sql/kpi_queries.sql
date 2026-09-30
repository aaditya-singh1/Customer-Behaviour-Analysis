-- Customer Behaviour Analysis - Key SQL Queries

-- 1. Overall Business KPIs
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity * price) AS total_revenue,
    SUM(quantity * price) / COUNT(DISTINCT order_id) AS average_order_value
FROM transactions t
JOIN products p ON t.product_id = p.product_id;

-- 2. Category-Wise Revenue Distribution
SELECT 
    p.category,
    SUM(t.quantity * p.price) AS category_revenue,
    ROUND(100.0 * SUM(t.quantity * p.price) / (SELECT SUM(quantity * price) FROM transactions t2 JOIN products p2 ON t2.product_id = p2.product_id), 2) AS revenue_share_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- 3. Customer Purchase Frequency & Repeat Rate
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS order_count
    FROM transactions
    GROUP BY customer_id
)
SELECT 
    COUNT(customer_id) AS total_customers,
    SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(100.0 * SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) / COUNT(customer_id), 2) AS repeat_rate_pct
FROM customer_orders;

-- 4. RFM Segmentation Base Query
WITH customer_rfm AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(order_id) AS frequency,
        SUM(quantity * price) AS monetary
    FROM transactions t
    JOIN products p ON t.product_id = p.product_id
    GROUP BY customer_id
)
SELECT 
    customer_id,
    DATEDIFF(CURRENT_DATE, last_order_date) AS recency_days,
    frequency,
    monetary
FROM customer_rfm;
