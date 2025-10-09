#!/usr/bin/env bash
# Render all R plot scripts in the scripts directory

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}F1 Analytics - Rendering All Plots${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Create plots directory if it doesn't exist
if [ ! -d "plots" ]; then
    echo -e "${YELLOW}Creating plots directory...${NC}"
    mkdir -p plots
fi

# Create data cache directory if it doesn't exist
if [ ! -d "data/cache" ]; then
    echo -e "${YELLOW}Creating data/cache directory...${NC}"
    mkdir -p data/cache
fi

# Define script categories and dependencies
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Data gathering scripts (must run first)
DATA_SCRIPTS=(
    "calculate_driver_points_robust.R"
)

# Analysis scripts (depend on data gathering)
ANALYSIS_SCRIPTS=(
    "analyze_driver_points.R"
    "visualize_driver_points.R"
)

# Other scripts (no dependencies)
OTHER_SCRIPTS=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.R" -type f | grep -v -E "$(printf '%s|' "${DATA_SCRIPTS[@]}" "${ANALYSIS_SCRIPTS[@]}")" | sort)

# Count total scripts
TOTAL_SCRIPTS=$((${#DATA_SCRIPTS[@]} + ${#ANALYSIS_SCRIPTS[@]} + $(echo "$OTHER_SCRIPTS" | grep -c "^" || echo "0")))

if [ "$TOTAL_SCRIPTS" -eq 0 ]; then
    echo -e "${YELLOW}No R scripts found in scripts/ directory${NC}"
    echo -e "${YELLOW}Create some R scripts that generate plots!${NC}"
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
echo -e "${YELLOW}Phase 1: Data Gathering${NC}"
echo -e "${YELLOW}========================${NC}"
for script in "${DATA_SCRIPTS[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    if [ -f "$script_path" ]; then
        run_script "$script_path"
        echo ""
    else
        echo -e "${YELLOW}Warning: Data script $script not found, skipping...${NC}"
    fi
done

# 2. Run analysis scripts (depend on data gathering)
echo -e "${YELLOW}Phase 2: Analysis${NC}"
echo -e "${YELLOW}=================${NC}"
for script in "${ANALYSIS_SCRIPTS[@]}"; do
    script_path="$SCRIPT_DIR/$script"
    if [ -f "$script_path" ]; then
        run_script "$script_path"
        echo ""
    else
        echo -e "${YELLOW}Warning: Analysis script $script not found, skipping...${NC}"
    fi
done

# 3. Run other scripts
if [ -n "$OTHER_SCRIPTS" ]; then
    echo -e "${YELLOW}Phase 3: Other Scripts${NC}"
    echo -e "${YELLOW}======================${NC}"
    for script in $OTHER_SCRIPTS; do
        run_script "$script"
        echo ""
    done
fi

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total scripts: ${TOTAL_SCRIPTS}"
echo -e "${GREEN}Successful: ${SUCCESS_COUNT}${NC}"
echo -e "${RED}Failed: ${FAIL_COUNT}${NC}"

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed scripts:${NC}"
    for failed in "${FAILED_SCRIPTS[@]}"; do
        echo -e "  ${RED}✗${NC} $failed"
    done
    exit 1
else
    echo ""
    echo -e "${GREEN}All plots generated successfully! 🏎️${NC}"
    exit 0
fi
