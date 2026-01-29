# Pocket PostgreSQL Labs

Hands-on PostgreSQL labs demonstrating query execution plans and index scan techniques with side-by-side comparisons.

## Prerequisites

- Docker & Docker Compose
- tmux
- make

## Quick Start

```bash
# Start PostgreSQL
make up

# Setup and run a lab
make setup LAB=1
make run LAB=1

# Cleanup
make cleanup LAB=1
make down
```

## Available Commands

| Command                | Description                            |
| ---------------------- | -------------------------------------- |
| `make up`              | Start PostgreSQL container             |
| `make down`            | Stop and remove container              |
| `make psql`            | Connect to PostgreSQL shell            |
| `make setup LAB=<n>`   | Setup tables and data for lab n        |
| `make run LAB=<n>`     | Run lab comparison in tmux split panes |
| `make cleanup LAB=<n>` | Drop tables for lab n                  |

## Labs

### Lab 1: Index-Only Scan

**Location:** `labs/1-index-only-scan/`

Demonstrates the difference between sequential scan and index-only scan using a covering index.

**Key Concepts:**

- Covering index with `INCLUDE` clause
- Index-only scan avoids heap fetches when all columns are in the index
- `VACUUM` updates visibility map enabling index-only scans

**Expected Results:**

```
Without Index: Seq Scan        (~7ms)
With Index:    Index Only Scan (~4ms, Heap Fetches: 0)
```

### Lab 2: Bitmap Index Scan

**Location:** `labs/2-bitmap-index-scan/`

Demonstrates bitmap index scan with OR conditions.

**Key Concepts:**

- Bitmap index scan combines multiple index conditions
- Efficient for queries returning many rows
- BitmapOr combines results from multiple bitmap scans

**Expected Results:**

```
Without Index: Seq Scan
With Index:    Bitmap Heap Scan + BitmapOr
```

### Lab 3: GIN Index

**Location:** `labs/3-gin-index/`

Demonstrates GIN (Generalized Inverted Index) for JSONB and array queries.

**Key Concepts:**

- GIN indexes are optimized for composite values (arrays, JSONB, full-text)
- Supports containment operators (`@>`, `<@`, `?`, `?|`, `?&`)
- Efficient for searching elements within arrays or keys/values in JSONB

**Expected Results:**

```
Without Index: Seq Scan
With Index:    Bitmap Heap Scan + Bitmap Index Scan on GIN index
```

## Project Structure

```
pocket-pg-labs/
├── docker-compose.yml      # PostgreSQL 17 container
├── Makefile                # Lab execution commands
├── .env                    # Database credentials
├── scripts/
│   └── run-lab.sh          # tmux split pane runner
├── data/                   # PostgreSQL data (gitignored)
└── labs/
    ├── 1-index-only-scan/
    │   ├── setup.sql           # Create tables + load 100k rows
    │   ├── query-no-index.sql  # EXPLAIN ANALYZE without index
    │   ├── query-with-index.sql# EXPLAIN ANALYZE with index
    │   └── cleanup.sql         # Drop tables
    ├── 2-bitmap-index-scan/
    │   ├── setup.sql
    │   ├── query-no-index.sql
    │   ├── query-with-index.sql
    │   └── cleanup.sql
    └── 3-gin-index/
        ├── setup.sql
        ├── query-no-index.sql
        ├── query-with-index.sql
        └── cleanup.sql
```

## Adding New Labs

1. Create folder `labs/<n>-<lab-name>/`
2. Add SQL files:
   - `setup.sql` - Create tables and load data
   - `query-no-index.sql` - Query without index optimization
   - `query-with-index.sql` - Query with index optimization
   - `cleanup.sql` - Drop tables
3. Run with `make setup LAB=<n>` and `make run LAB=<n>`
