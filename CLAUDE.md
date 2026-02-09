# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pocket PostgreSQL Labs is an educational repository demonstrating PostgreSQL query execution plans and index optimization techniques. Each lab provides side-by-side comparison of queries with and without optimized indexes using tmux split panes.

## Common Commands

```bash
# Start PostgreSQL container (waits for health check)
make up

# Stop container and remove volumes
make down

# Connect to PostgreSQL shell
make psql

# Run a lab (N = lab number)
make setup LAB=N     # Create tables and load 100k rows
make run LAB=N       # Execute in tmux split panes (left: no index, right: with index)
make cleanup LAB=N   # Drop test tables
```

## Architecture

### Lab Structure

Each lab in `labs/` follows a consistent 4-file pattern:

| File                   | Purpose                                                                           |
| ---------------------- | --------------------------------------------------------------------------------- |
| `setup.sql`            | Creates twin tables (with/without index), loads 100k rows via `generate_series()` |
| `query-no-index.sql`   | Baseline query without optimization                                               |
| `query-with-index.sql` | Query with index optimization                                                     |
| `cleanup.sql`          | Drops test tables                                                                 |

### Current Labs

1. **1-index-only-scan** - Covering indexes with `INCLUDE` clause to eliminate heap fetches
2. **2-bitmap-index-scan** - `BitmapOr` for OR conditions returning many rows
3. **3-gin-index** - GIN indexes for array/JSONB containment operators (`@>`, `<@`, `?`)

### Execution Flow

1. Makefile's `find_lab` function locates lab directory by numeric prefix
2. `scripts/run-lab.sh` creates a tmux session with horizontal split
3. Left pane runs query without index, right pane runs query with index
4. Both use `EXPLAIN ANALYZE` with BUFFERS for plan comparison

### Adding New Labs

Create `labs/N-<descriptive-name>/` with the 4 SQL files. The Makefile auto-discovers labs by numeric prefix.

## Environment

- PostgreSQL 17 via Docker Compose
- Database: `pg_labs`, User: `postgres`, Password: `postgres`, Port: 5432
- Prerequisites: Docker, tmux, make
