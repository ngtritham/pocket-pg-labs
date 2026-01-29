-- Lab 1: Index-Only Scan
-- Demonstrates the difference between sequential scan and index-only scan

-- Table without index
DROP TABLE IF EXISTS products_no_idx;
CREATE TABLE products_no_idx (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC(10,2),
    category VARCHAR(50)
);

-- Table with covering index
DROP TABLE IF EXISTS products_with_idx;
CREATE TABLE products_with_idx (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    price NUMERIC(10,2),
    category VARCHAR(50)
);

-- Insert 100000 random rows into both tables
INSERT INTO products_no_idx (name, price, category)
SELECT
    'Product ' || i,
    (random() * 1000)::NUMERIC(10,2),
    CASE (i % 5)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Food'
        WHEN 3 THEN 'Books'
        ELSE 'Home'
    END
FROM generate_series(1, 100000) AS i;

INSERT INTO products_with_idx (name, price, category)
SELECT
    'Product ' || i,
    (random() * 1000)::NUMERIC(10,2),
    CASE (i % 5)
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Food'
        WHEN 3 THEN 'Books'
        ELSE 'Home'
    END
FROM generate_series(1, 100000) AS i;

-- Create covering index (includes all selected columns)
CREATE INDEX idx_products_category_covering
ON products_with_idx (category)
INCLUDE (id, name, price);

-- Analyze tables for accurate statistics
ANALYZE products_no_idx;
ANALYZE products_with_idx;

-- Vacuum to update visibility map (required for index-only scan)
VACUUM ANALYZE products_with_idx;

SELECT 'Setup complete. Tables created with 100000 rows each.' AS status;
