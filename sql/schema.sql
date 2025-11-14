-- Drop the table if it exists
DROP TABLE IF EXISTS inventory;

-- Create the inventory table matching the CSV structure
CREATE TABLE inventory (
    date DATE,
    store_id TEXT,
    product_id TEXT,
    category TEXT,
    region TEXT,
    inventory_level INT,
    units_sold INT,
    units_ordered INT,
    demand_forecast NUMERIC,
    price NUMERIC,
    discount NUMERIC,
    weather_condition TEXT,
    holiday_promotion INT,
    competitor_pricing NUMERIC,
    seasonality TEXT
);

