#!/usr/bin/env bash
# Custom statusline for Claude Code
# Displays: session duration, API cost %, jj commit, last exit code, and directory

INPUT=$(cat)

# Parse JSON using jq
SESSION_DURATION=$(echo "$INPUT" | jq -r '.session.durationSeconds // 0')
COST_PERCENT=$(echo "$INPUT" | jq -r '.session.costPercentage // 0')
EXIT_CODE=$(echo "$INPUT" | jq -r '.lastCommand.exitCode // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Get jj commit ID (short form)
JJ_COMMIT=$(cd "$CWD" && jj log -r @ --no-graph -T 'change_id.shortest()' 2>/dev/null || echo "N/A")

# Format session duration
MINUTES=$((SESSION_DURATION / 60))
SECONDS=$((SESSION_DURATION % 60))

# Build statusline with plain text (no ANSI color codes)

echo -n "⏱️  ${MINUTES}m${SECONDS}s | "
echo -n "💰 ${COST_PERCENT}% | "
echo -n "🔧 jj:${JJ_COMMIT}"

# Show exit code if available
if [ -n "$EXIT_CODE" ]; then
    if [ "$EXIT_CODE" = "0" ]; then
        echo -n " | ✓ $EXIT_CODE"
    else
        echo -n " | ✗ $EXIT_CODE"
    fi
fi

echo -n " | $(basename "$CWD")"
