-- Step 4: Feature Engineering Script for inventory table

-- 1. Revenue
ALTER TABLE inventory ADD COLUMN revenue NUMERIC;

UPDATE inventory
SET revenue = price * units_sold
WHERE price IS NOT NULL AND units_sold IS NOT NULL;

-- 2. Profit
ALTER TABLE inventory ADD COLUMN profit NUMERIC;

UPDATE inventory
SET profit = revenue * 0.30
WHERE revenue IS NOT NULL;

-- 3. Days Since Restock (using date column as reference)
ALTER TABLE inventory ADD COLUMN days_since_restock INT;

UPDATE inventory
SET days_since_restock = CURRENT_DATE - date
WHERE date IS NOT NULL;

-- 4. Stock Risk Score (using inventory_level)
ALTER TABLE inventory ADD COLUMN stock_risk NUMERIC;

UPDATE inventory
SET stock_risk = inventory_level / NULLIF(units_sold, 0)
WHERE inventory_level IS NOT NULL AND units_sold IS NOT NULL;

-- 5. Price Segment (Low / Medium / High)
ALTER TABLE inventory ADD COLUMN price_segment TEXT;

-- Calculate percentiles first
DO $$
DECLARE
    p25 NUMERIC;
    p75 NUMERIC;
BEGIN
    SELECT percentile_cont(0.25) WITHIN GROUP (ORDER BY price) INTO p25
    FROM inventory
    WHERE price IS NOT NULL;
    
    SELECT percentile_cont(0.75) WITHIN GROUP (ORDER BY price) INTO p75
    FROM inventory
    WHERE price IS NOT NULL;
    
    UPDATE inventory
    SET price_segment = CASE
        WHEN price > p75 THEN 'High'
        WHEN price < p25 THEN 'Low'
        ELSE 'Medium'
    END
    WHERE price IS NOT NULL;
END $$;

-- 6. Sales Rank (Percentile Rank)
ALTER TABLE inventory ADD COLUMN sales_rank NUMERIC;

UPDATE inventory
SET sales_rank = PERCENT_RANK() OVER (ORDER BY units_sold DESC)
WHERE units_sold IS NOT NULL;

-- 7. SQL-Based Cluster Segmentation
ALTER TABLE inventory ADD COLUMN cluster INT;

UPDATE inventory
SET cluster = CASE
    WHEN price_segment = 'Low' AND sales_rank < 0.25 THEN 1
    WHEN price_segment = 'High' AND sales_rank > 0.75 THEN 2
    ELSE 3
END
WHERE price_segment IS NOT NULL AND sales_rank IS NOT NULL;

-- 8. Performance Score (Weighted Index - adapted to use available columns)
-- Using: 0.4 * units_sold + 0.3 * demand_forecast + 0.3 * revenue
ALTER TABLE inventory ADD COLUMN performance_score NUMERIC;

UPDATE inventory
SET performance_score = 
    (0.4 * COALESCE(units_sold, 0)) +
    (0.3 * COALESCE(demand_forecast, 0)) +
    (0.3 * COALESCE(revenue, 0))
WHERE units_sold IS NOT NULL OR demand_forecast IS NOT NULL OR revenue IS NOT NULL;

-- To run:
-- psql -U postgres -d retail_db -f feature_engineering.sql

