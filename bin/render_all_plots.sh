#!/usr/bin/env bash
# Render all R plot scripts in the scripts directory

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Color functions for cleaner output
red() { echo -e "${RED}$*${NC}"; }
green() { echo -e "${GREEN}$*${NC}"; }
yellow() { echo -e "${YELLOW}$*${NC}"; }
blue() { echo -e "${BLUE}$*${NC}"; }

blue "========================================"
blue "F1 Analytics - Rendering All Plots"
blue "========================================"
echo ""

# Create plots directory if it doesn't exist
if [ ! -d "plots" ]; then
    yellow "Creating plots directory..."
    mkdir -p plots
fi

# Create data cache directory if it doesn't exist
if [ ! -d "data/cache" ]; then
    yellow "Creating data/cache directory..."
    mkdir -p data/cache
fi

# Define script categories and dependencies
SCRIPT_DIR="scripts"

# Utility scripts that should not be run directly
# These are helper/library scripts sourced by other scripts
UTILITY_SCRIPTS=(
    "color_utils.R"
    "utils.R"
)

# Data gathering scripts (must run first)
DATA_SCRIPTS=(
    "_setup_project.R"
    "calculate_driver_points_robust.R"
)

# Analysis scripts (depend on data gathering)
ANALYSIS_SCRIPTS=(
    "analyze_driver_points.R"
    "visualize_driver_points.R"
)

# Build exclusion pattern for utility scripts
UTILITY_PATTERN=$(printf '%s|' "${UTILITY_SCRIPTS[@]}" | sed 's/|$//')

# Other scripts (no dependencies, excluding utility scripts)
OTHER_SCRIPTS=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.R" -type f | grep -v -E "$(printf '%s|' "${DATA_SCRIPTS[@]}" "${ANALYSIS_SCRIPTS[@]}" | sed 's/|$//')" | grep -v -E "$UTILITY_PATTERN" | sort)

# Count total scripts
TOTAL_SCRIPTS=$((${#DATA_SCRIPTS[@]} + ${#ANALYSIS_SCRIPTS[@]} + $(echo "$OTHER_SCRIPTS" | grep -c "^" || echo "0")))

if [ "$TOTAL_SCRIPTS" -eq 0 ]; then
    yellow "No R scripts found in scripts/ directory"
    yellow "Create some R scripts that generate plots!"
    exit 0
fi

echo -e "Found ${GREEN}${TOTAL_SCRIPTS}${NC} R script(s) to run"
echo -e "  - Data gathering: ${GREEN}${#DATA_SCRIPTS[@]}${NC}"
echo -e "  - Analysis: ${GREEN}${#ANALYSIS_SCRIPTS[@]}${NC}"
echo -e "  - Other: ${GREEN}$(echo "$OTHER_SCRIPTS" | grep -c "^" || echo "0")${NC}"
echo ""

# Track results
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()
CURRENT=0

# Function to run a script
run_script() {
    local script_path="$1"
    local script_name=$(basename "$script_path")

    CURRENT=$((CURRENT + 1))
    echo -e "${BLUE}[${CURRENT}/${TOTAL_SCRIPTS}]${NC} Running ${GREEN}${script_name}${NC}..."

    # Run the R script and capture output
    if Rscript "$script_path" 2>&1; then
        echo -e "${GREEN}✓${NC} ${script_name} completed successfully"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        return 0
    else
        echo -e "${RED}✗${NC} ${script_name} failed"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$script_name")
        return 1
    fi
}

# 1. Run data gathering scripts first
yellow "Phase 1: Data Gathering"
yellow "========================"
for script in "${DATA_SCRIPTS[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    if [ -f "$script_path" ]; then
        run_script "$script_path"
        echo ""
    else
        yellow "Warning: Data script $script not found, skipping..."
    fi
done

# 2. Run analysis scripts (depend on data gathering)
yellow "Phase 2: Analysis"
yellow "================="
for script in "${ANALYSIS_SCRIPTS[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    if [ -f "$script_path" ]; then
        run_script "$script_path"
        echo ""
    else
        yellow "Warning: Analysis script $script not found, skipping..."
    fi
done

# 3. Run other scripts
if [ -n "$OTHER_SCRIPTS" ]; then
    yellow "Phase 3: Other Scripts"
    yellow "======================"
    for script in $OTHER_SCRIPTS; do
        run_script "$script"
        echo ""
    done
fi

# Summary
blue "========================================"
blue "Summary"
blue "========================================"
echo "Total scripts: ${TOTAL_SCRIPTS}"
green "Successful: ${SUCCESS_COUNT}"
red "Failed: ${FAIL_COUNT}"

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    red "Failed scripts:"
    for failed in "${FAILED_SCRIPTS[@]}"; do
        echo -e "  ${RED}✗${NC} $failed"
    done
    exit 1
else
    echo ""
    green "All plots generated successfully! 🏎️"
    exit 0
fi
