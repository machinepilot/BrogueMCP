#!/bin/bash
# verify_directories.sh
# This script verifies that all required directories exist and creates them if they don't.
# Part of the Ages of Arda project's directory creation rules

# Define required directories
REQUIRED_DIRS=(
    "processing/temp"
    "processing/output"
    "processing/logs"
    "processing/epub_content"
    "processing/json_output"
    "processing/schemas"
    "processing/checkpoints"
    "processing/consolidated"
)

# Track results
CREATED=()
ALREADY_EXISTS=()
FAILED=()

# Define colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Verifying required directories..."

# Check and create each directory
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}[VERIFY] Directory exists: $dir${NC}"
        ALREADY_EXISTS+=("$dir")
    else
        mkdir -p "$dir" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${YELLOW}[CREATE] Created directory: $dir${NC}"
            CREATED+=("$dir")
        else
            echo -e "${RED}[ERROR] Failed to create directory: $dir${NC}"
            FAILED+=("$dir")
        fi
    fi
done

# Report summary
echo -e "\nDirectory Verification Summary:"
echo -e "------------------------------"
echo -e "${GREEN}Directories already existing: ${#ALREADY_EXISTS[@]}${NC}"
echo -e "${YELLOW}Directories created: ${#CREATED[@]}${NC}"
echo -e "${RED}Directories failed: ${#FAILED[@]}${NC}"

# If any directories failed to create, exit with error code
if [ ${#FAILED[@]} -gt 0 ]; then
    echo -e "${RED}ERROR: Failed to create some required directories.${NC}"
    echo -e "${RED}Please check permissions and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}Directory verification completed successfully.${NC}"
exit 0 