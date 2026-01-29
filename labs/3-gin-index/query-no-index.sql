\timing on

-- Query 1: Array contains element
\echo '=== Array Contains Query ==='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT id, title, tags FROM articles_no_idx
WHERE tags @> ARRAY['postgresql'];

-- Query 2: JSONB containment
\echo ''
\echo '=== JSONB Containment Query ==='
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT id, title, metadata FROM articles_no_idx
WHERE metadata @> '{"category": "tutorial", "published": true}';
