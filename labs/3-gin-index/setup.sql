-- Lab 3: GIN Index
-- Demonstrates GIN (Generalized Inverted Index) for JSONB and array queries

-- Table without index
DROP TABLE IF EXISTS articles_no_idx;
CREATE TABLE articles_no_idx (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    tags TEXT[],
    metadata JSONB
);

-- Table with GIN index
DROP TABLE IF EXISTS articles_with_idx;
CREATE TABLE articles_with_idx (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    tags TEXT[],
    metadata JSONB
);

-- Define tag and category options
DO $$
DECLARE
    tag_options TEXT[] := ARRAY['postgresql', 'mysql', 'mongodb', 'redis', 'elasticsearch',
                                 'docker', 'kubernetes', 'aws', 'gcp', 'azure',
                                 'python', 'javascript', 'golang', 'rust', 'java'];
    category_options TEXT[] := ARRAY['tutorial', 'guide', 'reference', 'news', 'opinion'];
BEGIN
    -- Insert 100000 random rows into both tables
    INSERT INTO articles_no_idx (title, tags, metadata)
    SELECT
        'Article ' || i,
        ARRAY[
            tag_options[1 + (random() * 14)::INT],
            tag_options[1 + (random() * 14)::INT],
            tag_options[1 + (random() * 14)::INT]
        ],
        jsonb_build_object(
            'author', 'Author ' || (random() * 100)::INT,
            'category', category_options[1 + (random() * 4)::INT],
            'views', (random() * 10000)::INT,
            'published', (random() > 0.3)
        )
    FROM generate_series(1, 100000) AS i;

    INSERT INTO articles_with_idx (title, tags, metadata)
    SELECT
        'Article ' || i,
        ARRAY[
            tag_options[1 + (random() * 14)::INT],
            tag_options[1 + (random() * 14)::INT],
            tag_options[1 + (random() * 14)::INT]
        ],
        jsonb_build_object(
            'author', 'Author ' || (random() * 100)::INT,
            'category', category_options[1 + (random() * 4)::INT],
            'views', (random() * 10000)::INT,
            'published', (random() > 0.3)
        )
    FROM generate_series(1, 100000) AS i;
END $$;

-- Create GIN indexes for array and JSONB columns
CREATE INDEX idx_articles_tags_gin ON articles_with_idx USING GIN (tags);
CREATE INDEX idx_articles_metadata_gin ON articles_with_idx USING GIN (metadata);

-- Analyze tables for accurate statistics
ANALYZE articles_no_idx;
ANALYZE articles_with_idx;

SELECT 'Setup complete. Tables created with 100000 rows each.' AS status;
