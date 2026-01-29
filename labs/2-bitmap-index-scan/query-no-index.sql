\timing on
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders_no_idx
WHERE status = 'pending' OR status = 'processing';
