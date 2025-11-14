-- Step 2: Data Cleaning Script for inventory table

-- 1. Handle Missing Values
-- Replace NULL category with 'Unknown'
UPDATE inventory
SET category = 'Unknown'
WHERE category IS NULL;

-- Replace NULL price with the median price
UPDATE inventory
SET price = (
    SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY price)
    FROM inventory
    WHERE price IS NOT NULL
)
WHERE price IS NULL;

-- Replace NULL units_sold with 0
UPDATE inventory
SET units_sold = 0
WHERE units_sold IS NULL;

-- Replace NULL inventory_level (stock) with 0
UPDATE inventory
SET inventory_level = 0
WHERE inventory_level IS NULL;

-- Replace NULL units_ordered with 0
UPDATE inventory
SET units_ordered = 0
WHERE units_ordered IS NULL;

-- Replace NULL demand_forecast with 0
UPDATE inventory
SET demand_forecast = 0
WHERE demand_forecast IS NULL;

-- Replace NULL discount with 0
UPDATE inventory
SET discount = 0
WHERE discount IS NULL;

-- Replace NULL competitor_pricing with 0
UPDATE inventory
SET competitor_pricing = 0
WHERE competitor_pricing IS NULL;

-- Replace NULL weather_condition with 'Unknown'
UPDATE inventory
SET weather_condition = 'Unknown'
WHERE weather_condition IS NULL;

-- Replace NULL seasonality with 'Unknown'
UPDATE inventory
SET seasonality = 'Unknown'
WHERE seasonality IS NULL;

-- Replace NULL region with 'Unknown'
UPDATE inventory
SET region = 'Unknown'
WHERE region IS NULL;

-- Replace NULL store_id with 'Unknown'
UPDATE inventory
SET store_id = 'Unknown'
WHERE store_id IS NULL;

-- Replace NULL product_id with 'Unknown'
UPDATE inventory
SET product_id = 'Unknown'
WHERE product_id IS NULL;

-- 2. Standardize Text Columns
-- Convert category to INITCAP() format and trim whitespace
UPDATE inventory
SET category = INITCAP(TRIM(category));

-- Convert region to INITCAP() format and trim whitespace
UPDATE inventory
SET region = INITCAP(TRIM(region));

-- Convert weather_condition to INITCAP() format and trim whitespace
UPDATE inventory
SET weather_condition = INITCAP(TRIM(weather_condition));

-- Convert seasonality to INITCAP() format and trim whitespace
UPDATE inventory
SET seasonality = INITCAP(TRIM(seasonality));

-- Convert store_id to UPPER and trim whitespace
UPDATE inventory
SET store_id = UPPER(TRIM(store_id));

-- Convert product_id to UPPER and trim whitespace
UPDATE inventory
SET product_id = UPPER(TRIM(product_id));

-- 3. Remove Duplicates
-- Remove duplicate rows based on product_id + store_id + date
-- Keep the row with highest units_sold if duplicates exist
DELETE FROM inventory a
USING inventory b
WHERE a.ctid < b.ctid
  AND a.product_id = b.product_id
  AND a.store_id = b.store_id
  AND a.date = b.date
  AND a.units_sold <= b.units_sold;

-- 4. Fix Data Types
-- Ensure price is NUMERIC (already defined as NUMERIC, but ensure no invalid values)
-- Ensure demand_forecast is NUMERIC
-- Ensure competitor_pricing is NUMERIC
-- Ensure discount is NUMERIC
-- Ensure date is DATE (already defined as DATE)

-- 5. Outlier Removal (Data Science Step)
-- Remove extreme price outliers using 99th percentile
DELETE FROM inventory
WHERE price > (
    SELECT percentile_cont(0.99) WITHIN GROUP (ORDER BY price)
    FROM inventory
    WHERE price IS NOT NULL
);

-- Remove negative or impossible values
DELETE FROM inventory
WHERE price < 0
   OR units_sold < 0
   OR inventory_level < 0
   OR units_ordered < 0
   OR discount < 0
   OR competitor_pricing < 0
   OR demand_forecast < 0;

-- Execution instructions:
-- psql -U postgres -d retail_db -f cleaning.sql

