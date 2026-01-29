#!/bin/bash

LAB_DIR="$1"

if [ -z "$LAB_DIR" ]; then
    echo "Usage: $0 <lab-directory>"
    exit 1
fi

LAB_NAME=$(basename "$LAB_DIR")
SESSION_NAME="pg-lab-${LAB_NAME}"

# Kill existing session if exists
tmux kill-session -t "$SESSION_NAME" 2>/dev/null

# Create new tmux session with split panes
tmux new-session -d -s "$SESSION_NAME" -n "comparison"

# Left pane: No index query
tmux send-keys -t "$SESSION_NAME" "echo '=== WITHOUT INDEX ===' && docker compose exec -T postgres psql -U postgres -d pg_labs < ${LAB_DIR}/query-no-index.sql" C-m

# Split vertically
tmux split-window -h -t "$SESSION_NAME"

# Right pane: With index query
tmux send-keys -t "$SESSION_NAME" "echo '=== WITH INDEX ===' && docker compose exec -T postgres psql -U postgres -d pg_labs < ${LAB_DIR}/query-with-index.sql" C-m

# Attach to session
tmux attach-session -t "$SESSION_NAME"
