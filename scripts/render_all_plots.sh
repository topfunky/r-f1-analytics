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

# Find all R scripts in the scripts directory (excluding this shell script)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
R_SCRIPTS=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.R" -type f | sort)

# Count total scripts
TOTAL_SCRIPTS=$(echo "$R_SCRIPTS" | grep -c "^" || echo "0")

if [ "$TOTAL_SCRIPTS" -eq 0 ]; then
    echo -e "${YELLOW}No R scripts found in scripts/ directory${NC}"
    echo -e "${YELLOW}Create some R scripts that generate plots!${NC}"
    exit 0
fi

echo -e "Found ${GREEN}${TOTAL_SCRIPTS}${NC} R script(s) to run"
echo ""

# Track results
SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_SCRIPTS=()

# Run each R script
CURRENT=0
for script in $R_SCRIPTS; do
    CURRENT=$((CURRENT + 1))
    SCRIPT_NAME=$(basename "$script")
    
    echo -e "${BLUE}[${CURRENT}/${TOTAL_SCRIPTS}]${NC} Running ${GREEN}${SCRIPT_NAME}${NC}..."
    
    # Run the R script and capture output
    if Rscript "$script" 2>&1; then
        echo -e "${GREEN}✓${NC} ${SCRIPT_NAME} completed successfully"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}✗${NC} ${SCRIPT_NAME} failed"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_SCRIPTS+=("$SCRIPT_NAME")
    fi
    echo ""
done

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
