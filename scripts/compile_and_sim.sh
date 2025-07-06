#!/bin/bash
# SystemVerilog compilation and simulation script for Guitar Effects project

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Guitar Effects SystemVerilog Compilation and Simulation Script${NC}"
echo "============================================================="

# Project directories
SRC_DIR="../src"
TB_DIR="../testbench"
WORK_DIR="work"

# Create work directory if it doesn't exist
mkdir -p $WORK_DIR

# Function to compile and simulate a module
compile_and_simulate() {
    local module_name=$1
    local has_dependencies=$2
    
    echo -e "${YELLOW}Compiling and simulating $module_name...${NC}"
    
    # Compile dependencies first if needed
    if [ "$has_dependencies" = "true" ]; then
        echo "  Compiling dependencies..."
        iverilog -g2012 -o $WORK_DIR/${module_name}_sim $SRC_DIR/bram.sv $SRC_DIR/$module_name.sv $TB_DIR/${module_name}_tb.sv
    else
        iverilog -g2012 -o $WORK_DIR/${module_name}_sim $SRC_DIR/$module_name.sv $TB_DIR/${module_name}_tb.sv
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}Compilation successful${NC}"
        echo "  Running simulation..."
        cd $WORK_DIR
        ./${module_name}_sim
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}Simulation completed successfully${NC}"
        else
            echo -e "  ${RED}Simulation failed${NC}"
        fi
        cd ..
    else
        echo -e "  ${RED}Compilation failed${NC}"
    fi
    echo ""
}

# Check if Icarus Verilog is available
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}Error: Icarus Verilog (iverilog) is not installed or not in PATH${NC}"
    echo "Please install Icarus Verilog to compile SystemVerilog files"
    echo "Ubuntu/Debian: sudo apt-get install iverilog"
    echo "macOS: brew install icarus-verilog"
    exit 1
fi

# Compile and simulate each module
echo "Starting compilation and simulation of all modules..."
echo ""

# Modules without dependencies
compile_and_simulate "distortion" "false"
compile_and_simulate "clk_slow" "false"
compile_and_simulate "control" "false"
compile_and_simulate "trem" "false"

# Modules with BRAM dependency
compile_and_simulate "delay" "true"
compile_and_simulate "octaver" "true"

echo -e "${GREEN}All modules processed!${NC}"
echo ""
echo "Simulation results and waveform files (if generated) are in the work/ directory"
echo "To view waveforms, use: gtkwave work/<module_name>.vcd"
