-- Step 6: SQL Views for Reporting and Dashboards

-- 1. View: category_performance
CREATE OR REPLACE VIEW category_performance AS
SELECT
    category,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(AVG(demand_forecast), 2) AS avg_demand_forecast,
    ROUND(AVG(performance_score), 2) AS avg_performance_score
FROM inventory
WHERE category IS NOT NULL
GROUP BY category;

-- 2. View: store_performance (adapted from supplier_performance)
CREATE OR REPLACE VIEW store_performance AS
SELECT
    store_id AS store,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(demand_forecast), 2) AS avg_demand_forecast,
    COUNT(DISTINCT product_id) AS num_products,
    ROUND(AVG(stock_risk), 2) AS avg_stock_risk,
    ROUND(AVG(days_since_restock), 2) AS avg_days_since_restock
FROM inventory
WHERE store_id IS NOT NULL
GROUP BY store_id;

-- 3. View: top_sellers
CREATE OR REPLACE VIEW top_sellers AS
SELECT
    product_id AS product_name,
    category,
    ROUND(price, 2) AS price,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    ROUND(stock_risk, 2) AS stock_risk,
    ROUND(performance_score, 2) AS performance_score
FROM inventory
WHERE units_sold IS NOT NULL
ORDER BY units_sold DESC
LIMIT 20;

-- 4. View: top_revenue_products
CREATE OR REPLACE VIEW top_revenue_products AS
SELECT
    product_id AS product_name,
    category,
    ROUND(price, 2) AS price,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit,
    ROUND(performance_score, 2) AS performance_score
FROM inventory
WHERE revenue IS NOT NULL
ORDER BY revenue DESC
LIMIT 20;

-- 5. View: cluster_summary
CREATE OR REPLACE VIEW cluster_summary AS
WITH cluster_stats AS (
    SELECT
        cluster,
        COUNT(DISTINCT product_id) AS num_products,
        ROUND(AVG(price), 2) AS avg_price,
        ROUND(AVG(units_sold), 2) AS avg_units_sold,
        ROUND(AVG(revenue), 2) AS avg_revenue,
        ROUND(AVG(profit), 2) AS avg_profit,
        ROUND(AVG(stock_risk), 2) AS avg_stock_risk
    FROM inventory
    WHERE cluster IS NOT NULL
    GROUP BY cluster
),
dominant_categories AS (
    SELECT DISTINCT ON (cluster)
        cluster,
        category AS dominant_category
    FROM (
        SELECT
            cluster,
            category,
            COUNT(*) AS category_count,
            ROW_NUMBER() OVER (PARTITION BY cluster ORDER BY COUNT(*) DESC) AS rn
        FROM inventory
        WHERE cluster IS NOT NULL AND category IS NOT NULL
        GROUP BY cluster, category
    ) AS ranked
    WHERE rn = 1
)
SELECT
    cs.cluster,
    cs.num_products,
    cs.avg_price,
    cs.avg_units_sold,
    cs.avg_revenue,
    cs.avg_profit,
    cs.avg_stock_risk,
    dc.dominant_category
FROM cluster_stats cs
LEFT JOIN dominant_categories dc ON cs.cluster = dc.cluster
ORDER BY cs.cluster;

-- 6. View: stock_risk_dashboard
CREATE OR REPLACE VIEW stock_risk_dashboard AS
SELECT
    product_id AS product_name,
    category,
    inventory_level AS stock,
    units_sold,
    ROUND(stock_risk, 2) AS stock_risk,
    days_since_restock,
    price_segment
FROM inventory
WHERE stock_risk IS NOT NULL
ORDER BY stock_risk ASC;

-- 7. View: revenue_curve
CREATE OR REPLACE VIEW revenue_curve AS
WITH product_revenue AS (
    SELECT
        product_id AS product_name,
        SUM(revenue) AS revenue
    FROM inventory
    WHERE revenue IS NOT NULL
    GROUP BY product_id
)
SELECT
    product_name,
    ROUND(revenue, 2) AS revenue,
    ROUND(SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS cumulative_revenue,
    ROUND(
        SUM(revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100.0 / 
        NULLIF(SUM(revenue) OVER (), 0),
        2
    ) AS cumulative_percentage
FROM product_revenue
ORDER BY revenue DESC;

-- 8. View: performance_ranked
CREATE OR REPLACE VIEW performance_ranked AS
SELECT
    RANK() OVER (ORDER BY performance_score DESC) AS performance_rank,
    product_id AS product_name,
    category,
    ROUND(price, 2) AS price,
    units_sold,
    ROUND(revenue, 2) AS revenue,
    ROUND(profit, 2) AS profit,
    ROUND(demand_forecast, 2) AS demand_forecast,
    ROUND(stock_risk, 2) AS stock_risk,
    ROUND(performance_score, 2) AS performance_score
FROM inventory
WHERE performance_score IS NOT NULL
ORDER BY performance_score DESC;

-- To run:
-- psql -U postgres -d retail_db -f views.sql

