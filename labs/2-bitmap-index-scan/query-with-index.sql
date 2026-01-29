\timing on
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_with_idx
WHERE status = 'pending' OR status = 'processing';
