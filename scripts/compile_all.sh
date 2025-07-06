#!/usr/bin/bash

# Safe compilation script for guitar effects SystemVerilog files
# Includes resource monitoring and cleanup to prevent system crashes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="$SCRIPT_DIR/work"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Resource monitoring functions
check_resources() {
    local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    echo -e "${YELLOW}System Resources:${NC}"
    echo "  Memory usage: ${mem_usage}%"
    echo "  CPU usage: ${cpu_usage}%"
    
    # Warning thresholds
    if (( $(echo "$mem_usage > 80" | bc -l) )); then
        echo -e "${RED}WARNING: High memory usage detected!${NC}"
    fi
    
    if (( $(echo "$cpu_usage > 90" | bc -l) )); then
        echo -e "${RED}WARNING: High CPU usage detected!${NC}"
    fi
}

# Cleanup function
cleanup() {
    echo -e "${YELLOW}Cleaning up...${NC}"
    if [ -d "$WORK_DIR" ]; then
        find "$WORK_DIR" -name "*.vcd" -size +100M -delete 2>/dev/null || true
        find "$WORK_DIR" -name "work-*" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
    
    # Kill any hanging simulation processes
    pkill -f "vvp\|iverilog" 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup completed.${NC}"
}

# Set up trap for cleanup on exit
trap cleanup EXIT

# Create work directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "=== Guitar Effects Compilation Script ==="
echo "Project directory: $PROJECT_DIR"
echo "Work directory: $WORK_DIR"
echo ""

# Check initial system resources
check_resources
echo ""

# Check if iverilog is installed
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}Error: iverilog not found. Please install it:${NC}"
    echo "  sudo apt-get install iverilog"
    exit 1
fi

# Source files
SRC_FILES=(
    "$PROJECT_DIR/src/bram.sv"
    "$PROJECT_DIR/src/clk_slow.sv"
    "$PROJECT_DIR/src/control.sv"
    "$PROJECT_DIR/src/delay.sv"
    "$PROJECT_DIR/src/distortion.sv"
    "$PROJECT_DIR/src/octaver.sv"
    "$PROJECT_DIR/src/trem.sv"
)

# Testbench files
TB_FILES=(
    "$PROJECT_DIR/testbench/clk_slow_tb.sv"
    "$PROJECT_DIR/testbench/control_tb.sv"
    "$PROJECT_DIR/testbench/delay_tb.sv"
    "$PROJECT_DIR/testbench/distortion_tb.sv"
    "$PROJECT_DIR/testbench/octaver_tb.sv"
    "$PROJECT_DIR/testbench/trem_tb.sv"
)

# Compile each module
compile_module() {
    local module_name=$1
    local src_file=$2
    local tb_file=$3
    
    echo -e "${YELLOW}Compiling $module_name...${NC}"
    
    # Check if files exist
    if [ ! -f "$src_file" ]; then
        echo -e "${RED}Error: Source file $src_file not found${NC}"
        return 1
    fi
    
    if [ ! -f "$tb_file" ]; then
        echo -e "${RED}Error: Testbench file $tb_file not found${NC}"
        return 1
    fi
    
    # Compile with resource limits
    timeout 60s iverilog -g2012 -o "${module_name}_sim" "$src_file" "$tb_file" 2>&1 | head -50
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $module_name compiled successfully${NC}"
        return 0
    else
        echo -e "${RED}✗ $module_name compilation failed${NC}"
        return 1
    fi
}

# Compile all modules
SUCCESS_COUNT=0
FAIL_COUNT=0

declare -A MODULES=(
    ["clk_slow"]="$PROJECT_DIR/src/clk_slow.sv $PROJECT_DIR/testbench/clk_slow_tb.sv"
    ["control"]="$PROJECT_DIR/src/control.sv $PROJECT_DIR/testbench/control_tb.sv"
    ["delay"]="$PROJECT_DIR/src/delay.sv $PROJECT_DIR/testbench/delay_tb.sv"
    ["distortion"]="$PROJECT_DIR/src/distortion.sv $PROJECT_DIR/testbench/distortion_tb.sv"
    ["octaver"]="$PROJECT_DIR/src/octaver.sv $PROJECT_DIR/testbench/octaver_tb.sv"
    ["trem"]="$PROJECT_DIR/src/trem.sv $PROJECT_DIR/testbench/trem_tb.sv"
)

for module in "${!MODULES[@]}"; do
    files=(${MODULES[$module]})
    src_file="${files[0]}"
    tb_file="${files[1]}"
    
    if compile_module "$module" "$src_file" "$tb_file"; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
    fi
    
    # Check resources after each compilation
    check_resources
    echo ""
done

echo "=== Compilation Summary ==="
echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}All modules compiled successfully!${NC}"
    echo "Run individual simulations with: ./run_sim.sh <module_name>"
else
    echo -e "${YELLOW}Some modules failed to compile. Check errors above.${NC}"
fi