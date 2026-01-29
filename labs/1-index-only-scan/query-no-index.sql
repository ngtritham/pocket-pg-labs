\timing on
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT id, name, price FROM products_no_idx WHERE category = 'Electronics';
