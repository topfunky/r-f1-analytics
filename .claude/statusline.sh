#!/usr/bin/env bash
# Custom statusline for Claude Code
# Displays: model, session duration, API cost (USD), lines added, jj commit, and directory

INPUT=$(cat)

# Parse JSON using jq
SESSION_DURATION=$(echo "$INPUT" | jq -r '(.cost.total_duration_ms // 0) / 1000 | floor')
COST_USD=$(echo "$INPUT" | jq -r '.cost.total_cost_usd // 0')
LINES_ADDED=$(echo "$INPUT" | jq -r '.cost.total_lines_added // 0')
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "N/A"')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Get jj commit ID (short form)
JJ_COMMIT=$(cd "$CWD" && jj log -r @ --no-graph -T 'change_id.shortest()' 2>/dev/null || echo "N/A")

# Format session duration
MINUTES=$((SESSION_DURATION / 60))
SECONDS=$((SESSION_DURATION % 60))

# Build statusline with plain text (no ANSI color codes)

echo -n "🤖 ${MODEL} | "
echo -n "⏱️  ${MINUTES}m${SECONDS}s | "
printf "💰 \$%.2f | " "$COST_USD"
echo -n "📝 +${LINES_ADDED} | "
echo -n "🔧 jj:${JJ_COMMIT} | "
echo -n "$(basename "$CWD")"
