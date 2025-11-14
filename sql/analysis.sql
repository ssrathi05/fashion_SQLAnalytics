-- Step 5: Advanced Analytics Script for inventory table

-- 1. Top Selling Products
-- Top 20 products by units_sold
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(performance_score), 2) AS avg_performance_score
FROM inventory
WHERE units_sold IS NOT NULL
GROUP BY product_id, category
ORDER BY total_units_sold DESC
LIMIT 20;

-- Top 20 by revenue
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(performance_score), 2) AS avg_performance_score
FROM inventory
WHERE revenue IS NOT NULL
GROUP BY product_id, category
ORDER BY total_revenue DESC
LIMIT 20;

-- Top 20 by profit
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(performance_score), 2) AS avg_performance_score
FROM inventory
WHERE profit IS NOT NULL
GROUP BY product_id, category
ORDER BY total_profit DESC
LIMIT 20;

-- Top 20 by performance_score
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(performance_score), 2) AS avg_performance_score
FROM inventory
WHERE performance_score IS NOT NULL
GROUP BY product_id, category
ORDER BY avg_performance_score DESC
LIMIT 20;

-- 2. Bottom Performers
-- Bottom 20 by units_sold
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit
FROM inventory
WHERE units_sold IS NOT NULL
GROUP BY product_id, category
HAVING SUM(units_sold) > 0
ORDER BY total_units_sold ASC
LIMIT 20;

-- Bottom 20 by revenue
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit
FROM inventory
WHERE revenue IS NOT NULL
GROUP BY product_id, category
HAVING SUM(revenue) > 0
ORDER BY total_revenue ASC
LIMIT 20;

-- Bottom 20 by profit
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit
FROM inventory
WHERE profit IS NOT NULL
GROUP BY product_id, category
HAVING SUM(profit) > 0
ORDER BY total_profit ASC
LIMIT 20;

-- 3. Category Analytics
SELECT
    category,
    COUNT(DISTINCT product_id) AS product_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(performance_score), 2) AS avg_performance_score,
    ROUND(
        (SUM(revenue) * 100.0 / NULLIF((SELECT SUM(revenue) FROM inventory WHERE revenue IS NOT NULL), 0)), 
        2
    ) AS revenue_share_percent
FROM inventory
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_revenue DESC;

-- 4. Store Analytics (adapted from supplier analytics)
SELECT
    store_id,
    COUNT(DISTINCT product_id) AS product_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(performance_score), 2) AS avg_performance_score,
    ROUND(
        (SUM(revenue) * 100.0 / NULLIF((SELECT SUM(revenue) FROM inventory WHERE revenue IS NOT NULL), 0)), 
        2
    ) AS revenue_contribution_percent
FROM inventory
WHERE store_id IS NOT NULL
GROUP BY store_id
ORDER BY total_revenue DESC;

-- 5. Cluster Analysis
-- Cluster 1
SELECT
    'Cluster 1' AS cluster_name,
    COUNT(DISTINCT product_id) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(units_sold), 2) AS avg_units_sold,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(AVG(stock_risk), 2) AS avg_stock_risk
FROM inventory
WHERE cluster = 1;

-- Category distribution for Cluster 1
SELECT
    'Cluster 1' AS cluster_name,
    category,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM inventory WHERE cluster = 1), 0), 2) AS percentage
FROM inventory
WHERE cluster = 1
GROUP BY category
ORDER BY count DESC;

-- Cluster 2
SELECT
    'Cluster 2' AS cluster_name,
    COUNT(DISTINCT product_id) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(units_sold), 2) AS avg_units_sold,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(AVG(stock_risk), 2) AS avg_stock_risk
FROM inventory
WHERE cluster = 2;

-- Category distribution for Cluster 2
SELECT
    'Cluster 2' AS cluster_name,
    category,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM inventory WHERE cluster = 2), 0), 2) AS percentage
FROM inventory
WHERE cluster = 2
GROUP BY category
ORDER BY count DESC;

-- Cluster 3
SELECT
    'Cluster 3' AS cluster_name,
    COUNT(DISTINCT product_id) AS product_count,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(units_sold), 2) AS avg_units_sold,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(AVG(stock_risk), 2) AS avg_stock_risk
FROM inventory
WHERE cluster = 3;

-- Category distribution for Cluster 3
SELECT
    'Cluster 3' AS cluster_name,
    category,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM inventory WHERE cluster = 3), 0), 2) AS percentage
FROM inventory
WHERE cluster = 3
GROUP BY category
ORDER BY count DESC;

-- 6. Stock Risk Analysis
-- Products with highest stock_risk
SELECT
    product_id,
    category,
    inventory_level,
    units_sold,
    ROUND(stock_risk, 2) AS stock_risk,
    ROUND(revenue, 2) AS revenue
FROM inventory
WHERE stock_risk IS NOT NULL
ORDER BY stock_risk DESC
LIMIT 20;

-- Products most likely to stock out
SELECT
    product_id,
    category,
    inventory_level,
    units_sold,
    ROUND(stock_risk, 2) AS stock_risk,
    ROUND(revenue, 2) AS revenue
FROM inventory
WHERE stock_risk IS NOT NULL AND stock_risk < 0.2
ORDER BY stock_risk ASC
LIMIT 20;

-- Products that haven't been restocked in the longest time
SELECT
    product_id,
    category,
    date,
    days_since_restock,
    inventory_level,
    units_sold,
    ROUND(revenue, 2) AS revenue
FROM inventory
WHERE days_since_restock IS NOT NULL
ORDER BY days_since_restock DESC
LIMIT 20;

-- 7. Revenue Insights
-- Top 10% of products by revenue
SELECT
    product_id,
    category,
    SUM(revenue) AS total_revenue,
    SUM(profit) AS total_profit,
    SUM(units_sold) AS total_units_sold
FROM (
    SELECT
        product_id,
        category,
        revenue,
        profit,
        units_sold,
        NTILE(10) OVER (ORDER BY revenue DESC) AS revenue_decile
    FROM inventory
    WHERE revenue IS NOT NULL
) AS ranked
WHERE revenue_decile = 1
GROUP BY product_id, category
ORDER BY total_revenue DESC;

-- Pareto insight: revenue from top 20% of products
WITH product_revenue AS (
    SELECT
        product_id,
        SUM(revenue) AS total_revenue
    FROM inventory
    WHERE revenue IS NOT NULL
    GROUP BY product_id
),
ranked_products AS (
    SELECT
        product_id,
        total_revenue,
        NTILE(5) OVER (ORDER BY total_revenue DESC) AS revenue_quintile
    FROM product_revenue
)
SELECT
    'Top 20% Products' AS segment,
    COUNT(*) AS product_count,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(SUM(total_revenue) * 100.0 / NULLIF((SELECT SUM(total_revenue) FROM product_revenue), 0), 2) AS revenue_percentage
FROM ranked_products
WHERE revenue_quintile = 1;

-- Cumulative revenue curve
SELECT
    product_id,
    category,
    revenue,
    SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
    ROUND(
        SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100.0 / 
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS cumulative_percentage
FROM inventory
WHERE revenue IS NOT NULL
ORDER BY revenue DESC
LIMIT 100;

-- 8. Price Sensitivity Approximation
-- Covariance of price and units_sold
SELECT
    'price vs units_sold' AS relationship,
    ROUND(AVG(price * units_sold) - AVG(price) * AVG(units_sold), 2) AS covariance,
    ROUND(
        (AVG(price * units_sold) - AVG(price) * AVG(units_sold)) / 
        NULLIF((STDDEV(price) * STDDEV(units_sold)), 0), 
        4
    ) AS correlation
FROM inventory
WHERE price IS NOT NULL AND units_sold IS NOT NULL
UNION ALL
-- Covariance of price and revenue
SELECT
    'price vs revenue',
    ROUND(AVG(price * revenue) - AVG(price) * AVG(revenue), 2),
    ROUND(
        (AVG(price * revenue) - AVG(price) * AVG(revenue)) / 
        NULLIF((STDDEV(price) * STDDEV(revenue)), 0), 
        4
    )
FROM inventory
WHERE price IS NOT NULL AND revenue IS NOT NULL
UNION ALL
-- Covariance of demand_forecast and units_sold
SELECT
    'demand_forecast vs units_sold',
    ROUND(AVG(demand_forecast * units_sold) - AVG(demand_forecast) * AVG(units_sold), 2),
    ROUND(
        (AVG(demand_forecast * units_sold) - AVG(demand_forecast) * AVG(units_sold)) / 
        NULLIF((STDDEV(demand_forecast) * STDDEV(units_sold)), 0), 
        4
    )
FROM inventory
WHERE demand_forecast IS NOT NULL AND units_sold IS NOT NULL;

-- 9. Performance Score Ranking
SELECT
    RANK() OVER (ORDER BY performance_score DESC) AS performance_rank,
    product_id,
    category,
    ROUND(price, 2) AS price,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit,
    ROUND(stock_risk, 2) AS stock_risk,
    ROUND(performance_score, 2) AS performance_score
FROM inventory
WHERE performance_score IS NOT NULL
ORDER BY performance_score DESC
LIMIT 50;

-- To run:
-- psql -U postgres -d retail_db -f analysis.sql

