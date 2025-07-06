#!/bin/bash
# Script to run Vivado synthesis for Guitar Effects project

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Guitar Effects Vivado Synthesis Script${NC}"
echo "======================================"

# Check if Vivado is available
if ! command -v vivado &> /dev/null; then
    echo -e "${RED}Error: Vivado is not installed or not in PATH${NC}"
    echo "Please install Xilinx Vivado and source the settings script"
    echo "Example: source /tools/Xilinx/Vivado/2023.1/settings64.sh"
    exit 1
fi

# Create project directory if it doesn't exist
mkdir -p ../vivado_project

# Run Vivado with the synthesis script
echo -e "${YELLOW}Launching Vivado synthesis...${NC}"
cd ../vivado_project

vivado -mode batch -source ../scripts/synthesize.tcl

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Synthesis completed successfully!${NC}"
    echo "Project files are in the vivado_project directory"
else
    echo -e "${RED}Synthesis failed${NC}"
    echo "Check the vivado.log file for error details"
fi
