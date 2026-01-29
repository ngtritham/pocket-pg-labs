.PHONY: up down psql setup run cleanup

# Start PostgreSQL container
up:
	docker compose up -d
	@echo "Waiting for PostgreSQL to be ready..."
	@until docker compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do sleep 1; done
	@echo "PostgreSQL is ready!"

# Stop and remove container
down:
	docker compose down -v

# Connect to PostgreSQL shell
psql:
	docker compose exec postgres psql -U postgres -d pg_labs

# Find lab directory by number prefix
define find_lab
$(shell ls -d labs/$(1)-* 2>/dev/null | head -1)
endef

# Setup lab tables and data
setup:
ifndef LAB
	$(error LAB is required. Usage: make setup LAB=1)
endif
	$(eval LAB_DIR := $(call find_lab,$(LAB)))
	@if [ -z "$(LAB_DIR)" ]; then echo "Lab $(LAB) not found"; exit 1; fi
	@echo "Setting up $(LAB_DIR)..."
	docker compose exec -T postgres psql -U postgres -d pg_labs -f /dev/stdin < $(LAB_DIR)/setup.sql

# Run lab comparison in tmux split panes
run:
ifndef LAB
	$(error LAB is required. Usage: make run LAB=1)
endif
	$(eval LAB_DIR := $(call find_lab,$(LAB)))
	@if [ -z "$(LAB_DIR)" ]; then echo "Lab $(LAB) not found"; exit 1; fi
	@./scripts/run-lab.sh $(LAB_DIR)

# Cleanup lab tables
cleanup:
ifndef LAB
	$(error LAB is required. Usage: make cleanup LAB=1)
endif
	$(eval LAB_DIR := $(call find_lab,$(LAB)))
	@if [ -z "$(LAB_DIR)" ]; then echo "Lab $(LAB) not found"; exit 1; fi
	@echo "Cleaning up $(LAB_DIR)..."
	docker compose exec -T postgres psql -U postgres -d pg_labs -f /dev/stdin < $(LAB_DIR)/cleanup.sql
