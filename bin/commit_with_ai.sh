#!/bin/bash

# commit_with_ai_final.sh - Create a jujutsu commit using cursor-agent to generate commit message
# Final version that works in both interactive and non-interactive environments

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
	echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
	echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Format all code before proceeding
print_info "Formatting code with make format..."
if command -v make &>/dev/null && [ -f "Makefile" ]; then
	if make format >/dev/null 2>&1; then
		print_info "Code formatting completed successfully"
	else
		print_warning "Code formatting failed, continuing with commit process"
	fi
else
	print_warning "make command or Makefile not found, skipping code formatting"
fi

# Check if cursor-agent is available
if ! command -v cursor-agent &>/dev/null; then
	print_error "cursor-agent command not found. Please install cursor-agent CLI."
	exit 1
fi

# Check if jj is available
if ! command -v jj &>/dev/null; then
	print_error "jj (jujutsu) command not found. Please install jujutsu."
	exit 1
fi

# Check if there are any changes to commit
print_info "Checking for changes to commit..."

# Get the current diff
if ! jj diff >/tmp/jj_diff.txt 2>/dev/null; then
	print_error "Failed to get diff from jj. Make sure you're in a jujutsu repository."
	exit 1
fi

# Check if there are any changes
if [ ! -s /tmp/jj_diff.txt ]; then
	print_warning "No changes detected. Nothing to commit."
	exit 0
fi

print_info "Found changes. Generating commit message with cursor-agent..."

# Create a simple prompt and save to file
cat >/tmp/commit_prompt.txt <<EOF
Generate a conventional commit message for this diff:

$(cat /tmp/jj_diff.txt)
EOF

# Generate commit message using cursor-agent with timeout
print_info "Calling cursor-agent to generate commit message..."
if timeout 30 cursor-agent --print "$(cat /tmp/commit_prompt.txt)" >/tmp/generated_commit_message.txt 2>/dev/null; then
	print_info "Successfully generated commit message"
else
	print_error "Failed to generate commit message with cursor-agent (timeout or error)."
	print_info "Falling back to manual commit message generation..."

	# Fallback: generate a simple commit message based on file changes
	if grep -q "Added executable file" /tmp/jj_diff.txt; then
		COMMIT_MESSAGE="feat: add new shell script"
	elif grep -q "Modified file" /tmp/jj_diff.txt; then
		COMMIT_MESSAGE="fix: update existing file"
	else
		COMMIT_MESSAGE="chore: update project files"
	fi

	print_info "Using fallback commit message: $COMMIT_MESSAGE"
	echo "$COMMIT_MESSAGE" >/tmp/generated_commit_message.txt
fi

# Extract the commit message from the response
COMMIT_MESSAGE=$(grep -E "^(feat|fix|docs|style|refactor|perf|test|chore|devops):" /tmp/generated_commit_message.txt | head -n 1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

# If no conventional commit found, try to extract from code blocks
if [ -z "$COMMIT_MESSAGE" ]; then
	COMMIT_MESSAGE=$(grep -A 1 -B 1 "\`\`\`" /tmp/generated_commit_message.txt | grep -E "^(feat|fix|docs|style|refactor|perf|test|chore|devops):" | head -n 1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
fi

# If still no conventional commit found, take the first line and clean it up
if [ -z "$COMMIT_MESSAGE" ]; then
	COMMIT_MESSAGE=$(head -n 1 /tmp/generated_commit_message.txt | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
fi

# Validate the commit message format
if [[ ! "$COMMIT_MESSAGE" =~ ^(feat|fix|docs|style|refactor|perf|test|chore|devops): ]]; then
	print_warning "Generated commit message doesn't follow conventional commit format. Using as-is."
fi

# Show the diff summary and proposed commit message
echo
print_info "=== CHANGES SUMMARY ==="
jj diff --stat
echo
print_info "=== PROPOSED COMMIT MESSAGE ==="
echo "$COMMIT_MESSAGE"
echo

# Check if we're in an interactive environment
if [ -t 0 ]; then
	# Interactive mode - ask for confirmation
	read -p "Do you want to proceed with this commit message? (y/N): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		print_warning "Commit cancelled by user."
		exit 0
	fi
else
	# Non-interactive mode - auto-confirm
	print_info "Non-interactive mode detected. Proceeding with commit..."
fi

# Create the commit
print_info "Creating commit with jj..."
if jj commit -m "$COMMIT_MESSAGE"; then
	print_success "Commit created successfully!"
	echo
	print_info "=== COMMIT DETAILS ==="
	jj log -r '@' --limit 1
else
	print_error "Failed to create commit."
	exit 1
fi

# Clean up temporary files
rm -f /tmp/jj_diff.txt /tmp/commit_prompt.txt /tmp/generated_commit_message.txt

print_success "Done!"
