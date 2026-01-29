-- Lab 2: Bitmap Index Scan
-- Demonstrates bitmap index scan with OR conditions

-- Table without index
DROP TABLE IF EXISTS orders_no_idx;
CREATE TABLE orders_no_idx (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    status VARCHAR(20),
    amount NUMERIC(10,2)
);

-- Table with index
DROP TABLE IF EXISTS orders_with_idx;
CREATE TABLE orders_with_idx (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    status VARCHAR(20),
    amount NUMERIC(10,2)
);

-- Insert 100000 random rows into both tables
INSERT INTO orders_no_idx (customer_id, order_date, status, amount)
SELECT
    (random() * 100)::INTEGER + 1,
    CURRENT_DATE - (random() * 365)::INTEGER,
    CASE (i % 5)
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'shipped'
        WHEN 3 THEN 'delivered'
        ELSE 'cancelled'
    END,
    (random() * 500)::NUMERIC(10,2)
FROM generate_series(1, 100000) AS i;

INSERT INTO orders_with_idx (customer_id, order_date, status, amount)
SELECT
    (random() * 100)::INTEGER + 1,
    CURRENT_DATE - (random() * 365)::INTEGER,
    CASE (i % 5)
        WHEN 0 THEN 'pending'
        WHEN 1 THEN 'processing'
        WHEN 2 THEN 'shipped'
        WHEN 3 THEN 'delivered'
        ELSE 'cancelled'
    END,
    (random() * 500)::NUMERIC(10,2)
FROM generate_series(1, 100000) AS i;

-- Create indexes for bitmap scan
CREATE INDEX idx_orders_status ON orders_with_idx (status);
CREATE INDEX idx_orders_date ON orders_with_idx (order_date);

-- Analyze tables for accurate statistics
ANALYZE orders_no_idx;
ANALYZE orders_with_idx;

SELECT 'Setup complete. Tables created with 100000 rows each.' AS status;
