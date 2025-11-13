-- Step 3: Exploratory Data Analysis (EDA) Script for inventory table

-- 1. Basic Row Counts
SELECT 'Total Rows' AS metric, COUNT(*) AS value FROM inventory
UNION ALL
SELECT 'Unique Products', COUNT(DISTINCT product_id) FROM inventory
UNION ALL
SELECT 'Unique Categories', COUNT(DISTINCT category) FROM inventory
UNION ALL
SELECT 'Unique Stores', COUNT(DISTINCT store_id) FROM inventory
UNION ALL
SELECT 'Unique Regions', COUNT(DISTINCT region) FROM inventory;

-- 2. Missing Values Report
SELECT
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN store_id IS NULL THEN 1 ELSE 0 END) AS missing_store_id,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN inventory_level IS NULL THEN 1 ELSE 0 END) AS missing_inventory_level,
    SUM(CASE WHEN units_sold IS NULL THEN 1 ELSE 0 END) AS missing_units_sold,
    SUM(CASE WHEN units_ordered IS NULL THEN 1 ELSE 0 END) AS missing_units_ordered,
    SUM(CASE WHEN demand_forecast IS NULL THEN 1 ELSE 0 END) AS missing_demand_forecast,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS missing_discount,
    SUM(CASE WHEN weather_condition IS NULL THEN 1 ELSE 0 END) AS missing_weather_condition,
    SUM(CASE WHEN holiday_promotion IS NULL THEN 1 ELSE 0 END) AS missing_holiday_promotion,
    SUM(CASE WHEN competitor_pricing IS NULL THEN 1 ELSE 0 END) AS missing_competitor_pricing,
    SUM(CASE WHEN seasonality IS NULL THEN 1 ELSE 0 END) AS missing_seasonality
FROM inventory;

-- 3. Category-Level Analysis
SELECT
    category,
    COUNT(DISTINCT product_id) AS product_count,
    COUNT(*) AS record_count,
    ROUND(AVG(price), 2) AS avg_price,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(price * units_sold), 2) AS total_revenue
FROM inventory
GROUP BY category
ORDER BY total_revenue DESC;

-- 4. Store-Level Analysis (adapted from supplier-level)
SELECT
    store_id,
    COUNT(DISTINCT product_id) AS product_count,
    COUNT(*) AS record_count,
    ROUND(SUM(price * units_sold), 2) AS total_revenue,
    ROUND(AVG(price), 2) AS avg_price
FROM inventory
GROUP BY store_id
ORDER BY total_revenue DESC;

-- 5. Price + Sales Distributions
SELECT
    'price' AS metric,
    MIN(price) AS min_value,
    MAX(price) AS max_value,
    ROUND(AVG(price), 2) AS avg_value,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 2) AS median_value,
    ROUND(STDDEV(price), 2) AS stddev_value
FROM inventory
WHERE price IS NOT NULL
UNION ALL
SELECT
    'units_sold',
    MIN(units_sold),
    MAX(units_sold),
    ROUND(AVG(units_sold), 2),
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY units_sold), 2),
    ROUND(STDDEV(units_sold), 2)
FROM inventory
WHERE units_sold IS NOT NULL
UNION ALL
SELECT
    'inventory_level',
    MIN(inventory_level),
    MAX(inventory_level),
    ROUND(AVG(inventory_level), 2),
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY inventory_level), 2),
    ROUND(STDDEV(inventory_level), 2)
FROM inventory
WHERE inventory_level IS NOT NULL
UNION ALL
SELECT
    'demand_forecast',
    MIN(demand_forecast),
    MAX(demand_forecast),
    ROUND(AVG(demand_forecast), 2),
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY demand_forecast), 2),
    ROUND(STDDEV(demand_forecast), 2)
FROM inventory
WHERE demand_forecast IS NOT NULL;

-- 6. Revenue Calculations
-- Top 10 products by revenue
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(price * units_sold), 2) AS total_revenue
FROM inventory
GROUP BY product_id, category
ORDER BY total_revenue DESC
LIMIT 10;

-- Bottom 10 products by revenue
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(SUM(price * units_sold), 2) AS total_revenue
FROM inventory
GROUP BY product_id, category
HAVING SUM(price * units_sold) > 0
ORDER BY total_revenue ASC
LIMIT 10;

-- Revenue summary statistics
SELECT
    MIN(revenue) AS min_revenue,
    MAX(revenue) AS max_revenue,
    ROUND(AVG(revenue), 2) AS avg_revenue,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue), 2) AS median_revenue,
    ROUND(STDDEV(revenue), 2) AS stddev_revenue
FROM (
    SELECT (price * units_sold) AS revenue
    FROM inventory
    WHERE price IS NOT NULL AND units_sold IS NOT NULL
) AS revenue_calc;

-- 7. Correlation-Like Analysis in SQL
-- Price vs Units Sold
SELECT
    'price vs units_sold' AS relationship,
    ROUND(AVG(price * units_sold) - AVG(price) * AVG(units_sold), 2) AS covariance,
    ROUND(
        (AVG(price * units_sold) - AVG(price) * AVG(units_sold)) / 
        (STDDEV(price) * STDDEV(units_sold)), 
        4
    ) AS correlation
FROM inventory
WHERE price IS NOT NULL AND units_sold IS NOT NULL
UNION ALL
-- Price vs Inventory Level
SELECT
    'price vs inventory_level',
    ROUND(AVG(price * inventory_level) - AVG(price) * AVG(inventory_level), 2),
    ROUND(
        (AVG(price * inventory_level) - AVG(price) * AVG(inventory_level)) / 
        (STDDEV(price) * STDDEV(inventory_level)), 
        4
    )
FROM inventory
WHERE price IS NOT NULL AND inventory_level IS NOT NULL
UNION ALL
-- Units Sold vs Demand Forecast
SELECT
    'units_sold vs demand_forecast',
    ROUND(AVG(units_sold * demand_forecast) - AVG(units_sold) * AVG(demand_forecast), 2),
    ROUND(
        (AVG(units_sold * demand_forecast) - AVG(units_sold) * AVG(demand_forecast)) / 
        (STDDEV(units_sold) * STDDEV(demand_forecast)), 
        4
    )
FROM inventory
WHERE units_sold IS NOT NULL AND demand_forecast IS NOT NULL;

-- 8. Outlier Detection (EDA Only)
-- Price above 95th percentile
SELECT
    product_id,
    category,
    price,
    units_sold,
    (price * units_sold) AS revenue
FROM inventory
WHERE price > (
    SELECT percentile_cont(0.95) WITHIN GROUP (ORDER BY price)
    FROM inventory
    WHERE price IS NOT NULL
)
ORDER BY price DESC
LIMIT 20;

-- Units_sold above 95th percentile
SELECT
    product_id,
    category,
    price,
    units_sold,
    (price * units_sold) AS revenue
FROM inventory
WHERE units_sold > (
    SELECT percentile_cont(0.95) WITHIN GROUP (ORDER BY units_sold)
    FROM inventory
    WHERE units_sold IS NOT NULL
)
ORDER BY units_sold DESC
LIMIT 20;

-- Inventory Level below 5th percentile
SELECT
    product_id,
    category,
    inventory_level,
    units_sold,
    price
FROM inventory
WHERE inventory_level < (
    SELECT percentile_cont(0.05) WITHIN GROUP (ORDER BY inventory_level)
    FROM inventory
    WHERE inventory_level IS NOT NULL
)
ORDER BY inventory_level ASC
LIMIT 20;

-- To run:
-- psql -U postgres -d retail_db -f eda.sql

