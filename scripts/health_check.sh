#!/usr/bin/bash

# System health checker for guitar effects simulations
# Monitors resources and provides system status

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get system information
get_system_info() {
    echo "=== System Health Check ==="
    echo ""
    
    # Memory information
    echo -e "${BLUE}Memory Status:${NC}"
    free -h | grep -E "Mem|Swap"
    echo ""
    
    # CPU information
    echo -e "${BLUE}CPU Status:${NC}"
    lscpu | grep -E "Model name|CPU\(s\):|CPU MHz"
    echo ""
    
    # Disk space
    echo -e "${BLUE}Disk Space:${NC}"
    df -h | grep -E "Filesystem|/$|/home"
    echo ""
    
    # Load average
    echo -e "${BLUE}System Load:${NC}"
    uptime
    echo ""
}

# Check for potential issues
check_issues() {
    echo "=== Potential Issues ==="
    echo ""
    
    local issues_found=0
    
    # Check memory usage
    local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    if (( $(echo "$mem_usage > 85" | bc -l) )); then
        echo -e "${RED}⚠ High memory usage: ${mem_usage}%${NC}"
        ((issues_found++))
    fi
    
    # Check disk space
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        echo -e "${RED}⚠ Low disk space: ${disk_usage}% used${NC}"
        ((issues_found++))
    fi
    
    # Check for hanging processes
    local hanging_procs=$(pgrep -f "vvp\|iverilog" | wc -l)
    if [ "$hanging_procs" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $hanging_procs simulation processes still running${NC}"
        echo "  PIDs: $(pgrep -f "vvp\|iverilog" | tr '\n' ' ')"
        ((issues_found++))
    fi
    
    # Check for large temporary files
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local work_dir="$script_dir/work"
    if [ -d "$work_dir" ]; then
        local large_files=$(find "$work_dir" -type f -size +100M 2>/dev/null | wc -l)
        if [ "$large_files" -gt 0 ]; then
            echo -e "${YELLOW}⚠ Found $large_files large files (>100MB) in work directory${NC}"
            find "$work_dir" -type f -size +100M -exec ls -lh {} \; 2>/dev/null | head -5
            ((issues_found++))
        fi
    fi
    
    # Check CPU temperature (if available)
    if command -v sensors &> /dev/null; then
        local temp=$(sensors 2>/dev/null | grep -E "Core|Package" | grep -oE "\+[0-9]+\.[0-9]+°C" | head -1 | sed 's/+//;s/°C//')
        if [ -n "$temp" ] && (( $(echo "$temp > 80" | bc -l) )); then
            echo -e "${RED}⚠ High CPU temperature: ${temp}°C${NC}"
            ((issues_found++))
        fi
    fi
    
    if [ "$issues_found" -eq 0 ]; then
        echo -e "${GREEN}✓ No issues detected${NC}"
    else
        echo ""
        echo -e "${YELLOW}Total issues found: $issues_found${NC}"
    fi
    
    echo ""
}

# Cleanup recommendations
cleanup_recommendations() {
    echo "=== Cleanup Recommendations ==="
    echo ""
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local work_dir="$script_dir/work"
    
    if [ -d "$work_dir" ]; then
        # Count VCD files
        local vcd_count=$(find "$work_dir" -name "*.vcd" 2>/dev/null | wc -l)
        local vcd_size=$(du -sh "$work_dir"/*.vcd 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
        
        if [ "$vcd_count" -gt 0 ]; then
            echo "• VCD files: $vcd_count files"
            echo "  To clean: rm $work_dir/*.vcd"
        fi
        
        # Count simulation executables
        local sim_count=$(find "$work_dir" -name "*_sim" -type f 2>/dev/null | wc -l)
        if [ "$sim_count" -gt 0 ]; then
            echo "• Simulation executables: $sim_count files"
            echo "  To rebuild: cd scripts && ./compile_all.sh"
        fi
        
        # Check work directory size
        local work_size=$(du -sh "$work_dir" 2>/dev/null | cut -f1)
        echo "• Work directory size: $work_size"
        echo "  To clean: rm -rf $work_dir && mkdir -p $work_dir"
    fi
    
    # Check for hanging processes
    local hanging_procs=$(pgrep -f "vvp\|iverilog" | wc -l)
    if [ "$hanging_procs" -gt 0 ]; then
        echo "• Kill hanging processes: pkill -f \"vvp\\|iverilog\""
    fi
    
    echo ""
}

# Performance suggestions
performance_suggestions() {
    echo "=== Performance Suggestions ==="
    echo ""
    
    local mem_total=$(free -g | grep Mem | awk '{print $2}')
    local cpu_cores=$(nproc)
    
    echo "• System specs: ${cpu_cores} CPU cores, ${mem_total}GB RAM"
    
    if [ "$mem_total" -lt 4 ]; then
        echo "• Consider upgrading RAM for better simulation performance"
    fi
    
    if [ "$cpu_cores" -lt 4 ]; then
        echo "• Limited CPU cores may slow down compilation"
    fi
    
    echo "• Use ./run_sim.sh -t 30 to limit simulation time"
    echo "• Use ./run_sim.sh -q for quiet mode to reduce output"
    echo "• Enable VCD only when needed: ./run_sim.sh -v module_name"
    echo "• Run ./cleanup.sh regularly to free up disk space"
    
    echo ""
}

# Main execution
main() {
    get_system_info
    check_issues
    cleanup_recommendations
    performance_suggestions
    
    echo "=== Summary ==="
    echo "Run this script anytime to check system health before simulations."
    echo "For automated cleanup, use: ./cleanup.sh"
}

# Check if running as main script
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi