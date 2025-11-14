-- Load data from CSV into inventory table
-- IMPORTANT NOTES:
-- - The path must be absolute (full path from root)
-- - Must use forward slashes (/) instead of backslashes (\)
-- - Using \copy (client-side) instead of COPY (server-side) to avoid permission issues

\copy inventory(date, store_id, product_id, category, region, inventory_level, units_sold, units_ordered, demand_forecast, price, discount, weather_condition, holiday_promotion, competitor_pricing, seasonality) FROM 'C:/Users/14122/OneDrive/Desktop/fashion_SQLAnalytics/data/retail_store_inventory.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',')

-- Execution instructions:
-- From the project root directory:
-- psql -U postgres -d retail_db -f sql/schema.sql
-- psql -U postgres -d retail_db -f sql/load_data.sql

