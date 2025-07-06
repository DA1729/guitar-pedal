#!/usr/bin/bash

# Safe simulation runner for guitar effects modules
# Includes resource monitoring and automatic cleanup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/work"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage function
usage() {
    echo "Usage: $0 <module_name> [options]"
    echo ""
    echo "Available modules:"
    echo "  clk_slow    - Clock divider simulation"
    echo "  control     - Control module simulation"
    echo "  delay       - Delay effect simulation"
    echo "  distortion  - Distortion effect simulation"
    echo "  octaver     - Octaver effect simulation"
    echo "  trem        - Tremolo effect simulation"
    echo ""
    echo "Options:"
    echo "  -t TIME     - Simulation time limit (default: 30s)"
    echo "  -v          - Enable VCD waveform output"
    echo "  -q          - Quiet mode (less output)"
    echo "  --no-gui    - Run without GUI (default)"
    echo ""
    echo "Examples:"
    echo "  $0 distortion -v -t 60"
    echo "  $0 clk_slow -q"
}

# Resource monitoring
monitor_resources() {
    local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    if [ "$QUIET" != "true" ]; then
        echo -e "${BLUE}Resources: Memory ${mem_usage}%, CPU ${cpu_usage}%${NC}"
    fi
    
    # Emergency stop if resources too high
    if (( $(echo "$mem_usage > 95" | bc -l) )); then
        echo -e "${RED}EMERGENCY: Memory usage critical (${mem_usage}%)! Stopping simulation.${NC}"
        cleanup
        exit 1
    fi
}

# Cleanup function
cleanup() {
    echo -e "${YELLOW}Cleaning up simulation...${NC}"
    
    # Kill any running simulations
    pkill -f "vvp.*_sim" 2>/dev/null || true
    
    # Clean up large files
    if [ -d "$WORK_DIR" ]; then
        find "$WORK_DIR" -name "*.vcd" -size +50M -delete 2>/dev/null || true
        find "$WORK_DIR" -name "dump.vcd" -delete 2>/dev/null || true
    fi
    
    echo -e "${GREEN}Cleanup completed.${NC}"
}

# Set up trap for cleanup
trap cleanup EXIT

# Parse command line arguments
MODULE=""
TIME_LIMIT=30
ENABLE_VCD=false
QUIET=false
GUI_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--time)
            TIME_LIMIT="$2"
            shift 2
            ;;
        -v|--vcd)
            ENABLE_VCD=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --gui)
            GUI_MODE=true
            shift
            ;;
        --no-gui)
            GUI_MODE=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
        *)
            if [ -z "$MODULE" ]; then
                MODULE="$1"
            else
                echo -e "${RED}Multiple modules specified. Only one module allowed.${NC}"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate module name
if [ -z "$MODULE" ]; then
    echo -e "${RED}Error: Module name required${NC}"
    usage
    exit 1
fi

# Check if work directory exists
if [ ! -d "$WORK_DIR" ]; then
    echo -e "${RED}Error: Work directory not found. Run compile_all.sh first.${NC}"
    exit 1
fi

cd "$WORK_DIR"

# Check if compiled simulation exists
SIM_FILE="${MODULE}_sim"
if [ ! -f "$SIM_FILE" ]; then
    echo -e "${RED}Error: Simulation file $SIM_FILE not found${NC}"
    echo "Available simulations:"
    ls -1 *_sim 2>/dev/null || echo "  None found"
    echo ""
    echo "Run compile_all.sh first to compile modules."
    exit 1
fi

# Pre-simulation checks
echo "=== Guitar Effects Simulation Runner ==="
echo "Module: $MODULE"
echo "Time limit: ${TIME_LIMIT}s"
echo "VCD output: $ENABLE_VCD"
echo "Work directory: $WORK_DIR"
echo ""

# Check initial resources
monitor_resources
echo ""

# Set up VCD output if requested
if [ "$ENABLE_VCD" = true ]; then
    export VCD_OUTPUT="${MODULE}_waves.vcd"
    echo -e "${BLUE}VCD output will be saved to: $VCD_OUTPUT${NC}"
fi

# Run simulation with timeout and resource monitoring
echo -e "${YELLOW}Starting simulation...${NC}"
echo "Press Ctrl+C to stop simulation early"
echo ""

# Start resource monitoring in background
if [ "$QUIET" != "true" ]; then
    (
        while true; do
            sleep 5
            monitor_resources
        done
    ) &
    MONITOR_PID=$!
fi

# Run the simulation with timeout
if timeout "${TIME_LIMIT}s" vvp "$SIM_FILE" 2>&1 | head -1000; then
    SIMULATION_EXIT=$?
    if [ $SIMULATION_EXIT -eq 0 ]; then
        echo -e "${GREEN}✓ Simulation completed successfully${NC}"
    else
        echo -e "${YELLOW}⚠ Simulation ended with status $SIMULATION_EXIT${NC}"
    fi
else
    TIMEOUT_EXIT=$?
    if [ $TIMEOUT_EXIT -eq 124 ]; then
        echo -e "${YELLOW}⚠ Simulation timed out after ${TIME_LIMIT}s${NC}"
    else
        echo -e "${RED}✗ Simulation failed with error $TIMEOUT_EXIT${NC}"
    fi
fi

# Stop resource monitoring
if [ "$QUIET" != "true" ] && [ -n "$MONITOR_PID" ]; then
    kill $MONITOR_PID 2>/dev/null || true
fi

# Show VCD file info if generated
if [ "$ENABLE_VCD" = true ] && [ -f "$VCD_OUTPUT" ]; then
    VCD_SIZE=$(du -h "$VCD_OUTPUT" | cut -f1)
    echo -e "${GREEN}VCD file generated: $VCD_OUTPUT (${VCD_SIZE})${NC}"
    echo "View with: gtkwave $VCD_OUTPUT"
fi

# Final resource check
echo ""
monitor_resources