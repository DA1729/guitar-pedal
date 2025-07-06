#!/usr/bin/bash

# Safe cleanup utility for guitar effects simulations
# Removes temporary files and kills hanging processes

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/work"

# Usage information
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -f, --force     Force cleanup without prompts"
    echo "  -v, --verbose   Verbose output"
    echo "  -q, --quiet     Quiet mode"
    echo "  --vcd-only      Only clean VCD files"
    echo "  --processes     Only kill hanging processes"
    echo "  --temp-only     Only clean temporary files"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Examples:"
    echo "  $0              Interactive cleanup"
    echo "  $0 -f           Force cleanup everything"
    echo "  $0 --vcd-only   Clean only VCD files"
}

# Parse command line arguments
FORCE=false
VERBOSE=false
QUIET=false
VCD_ONLY=false
PROCESSES_ONLY=false
TEMP_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --vcd-only)
            VCD_ONLY=true
            shift
            ;;
        --processes)
            PROCESSES_ONLY=true
            shift
            ;;
        --temp-only)
            TEMP_ONLY=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Logging function
log() {
    local level=$1
    shift
    if [ "$QUIET" != "true" ]; then
        case $level in
            INFO)
                echo -e "${BLUE}[INFO]${NC} $*"
                ;;
            SUCCESS)
                echo -e "${GREEN}[SUCCESS]${NC} $*"
                ;;
            WARNING)
                echo -e "${YELLOW}[WARNING]${NC} $*"
                ;;
            ERROR)
                echo -e "${RED}[ERROR]${NC} $*"
                ;;
            VERBOSE)
                if [ "$VERBOSE" = "true" ]; then
                    echo -e "${BLUE}[VERBOSE]${NC} $*"
                fi
                ;;
        esac
    fi
}

# Confirm action
confirm() {
    if [ "$FORCE" = "true" ]; then
        return 0
    fi
    
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Kill hanging processes
kill_processes() {
    if [ "$VCD_ONLY" = "true" ] || [ "$TEMP_ONLY" = "true" ]; then
        return 0
    fi
    
    log INFO "Checking for hanging simulation processes..."
    
    local hanging_procs=$(pgrep -f "vvp\|iverilog" 2>/dev/null | wc -l)
    
    if [ "$hanging_procs" -gt 0 ]; then
        log WARNING "Found $hanging_procs hanging simulation processes"
        
        if [ "$VERBOSE" = "true" ]; then
            echo "PIDs:"
            pgrep -f "vvp\|iverilog" 2>/dev/null | while read pid; do
                echo "  $pid: $(ps -p $pid -o cmd --no-headers 2>/dev/null | head -c 60)..."
            done
        fi
        
        if confirm "Kill $hanging_procs hanging processes?"; then
            pkill -f "vvp\|iverilog" 2>/dev/null
            log SUCCESS "Killed hanging processes"
        else
            log INFO "Skipping process cleanup"
        fi
    else
        log INFO "No hanging processes found"
    fi
}

# Clean VCD files
clean_vcd_files() {
    if [ "$PROCESSES_ONLY" = "true" ] || [ "$TEMP_ONLY" = "true" ]; then
        return 0
    fi
    
    if [ ! -d "$WORK_DIR" ]; then
        log INFO "Work directory doesn't exist, skipping VCD cleanup"
        return 0
    fi
    
    log INFO "Checking for VCD files..."
    
    local vcd_files=$(find "$WORK_DIR" -name "*.vcd" 2>/dev/null)
    local vcd_count=$(echo "$vcd_files" | wc -l)
    
    if [ -n "$vcd_files" ] && [ "$vcd_count" -gt 0 ]; then
        local total_size=$(du -sh $vcd_files 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "unknown")
        log WARNING "Found $vcd_count VCD files (total size: $total_size)"
        
        if [ "$VERBOSE" = "true" ]; then
            echo "VCD files:"
            echo "$vcd_files" | while read file; do
                if [ -f "$file" ]; then
                    echo "  $(ls -lh "$file" | awk '{print $5 " " $9}')"
                fi
            done
        fi
        
        if confirm "Remove $vcd_count VCD files?"; then
            find "$WORK_DIR" -name "*.vcd" -delete 2>/dev/null
            log SUCCESS "Removed VCD files"
        else
            log INFO "Skipping VCD cleanup"
        fi
    else
        log INFO "No VCD files found"
    fi
}

# Clean temporary files
clean_temp_files() {
    if [ "$PROCESSES_ONLY" = "true" ] || [ "$VCD_ONLY" = "true" ]; then
        return 0
    fi
    
    if [ ! -d "$WORK_DIR" ]; then
        log INFO "Work directory doesn't exist, skipping temp cleanup"
        return 0
    fi
    
    log INFO "Checking for temporary files..."
    
    local temp_files_found=0
    local temp_patterns=("*.tmp" "*.log" "core.*" "*.out" "dump.vcd" "work-*")
    
    for pattern in "${temp_patterns[@]}"; do
        local files=$(find "$WORK_DIR" -name "$pattern" -type f 2>/dev/null)
        if [ -n "$files" ]; then
            local count=$(echo "$files" | wc -l)
            log VERBOSE "Found $count files matching $pattern"
            ((temp_files_found += count))
        fi
    done
    
    # Check for large files
    local large_files=$(find "$WORK_DIR" -type f -size +50M 2>/dev/null)
    if [ -n "$large_files" ]; then
        local large_count=$(echo "$large_files" | wc -l)
        log WARNING "Found $large_count large files (>50MB)"
        if [ "$VERBOSE" = "true" ]; then
            echo "$large_files" | while read file; do
                echo "  $(ls -lh "$file" | awk '{print $5 " " $9}')"
            done
        fi
        ((temp_files_found += large_count))
    fi
    
    if [ "$temp_files_found" -gt 0 ]; then
        if confirm "Remove $temp_files_found temporary/large files?"; then
            for pattern in "${temp_patterns[@]}"; do
                find "$WORK_DIR" -name "$pattern" -type f -delete 2>/dev/null
            done
            find "$WORK_DIR" -type f -size +50M -delete 2>/dev/null
            log SUCCESS "Removed temporary files"
        else
            log INFO "Skipping temporary file cleanup"
        fi
    else
        log INFO "No temporary files found"
    fi
}

# Clean empty directories
clean_empty_dirs() {
    if [ ! -d "$WORK_DIR" ]; then
        return 0
    fi
    
    log INFO "Removing empty directories..."
    
    find "$WORK_DIR" -type d -empty -delete 2>/dev/null
    
    log VERBOSE "Empty directories removed"
}

# Show cleanup summary
show_summary() {
    if [ "$QUIET" = "true" ]; then
        return 0
    fi
    
    echo ""
    echo "=== Cleanup Summary ==="
    
    if [ -d "$WORK_DIR" ]; then
        local work_size=$(du -sh "$WORK_DIR" 2>/dev/null | cut -f1)
        echo "Work directory size: $work_size"
        
        local file_count=$(find "$WORK_DIR" -type f 2>/dev/null | wc -l)
        echo "Files remaining: $file_count"
        
        if [ "$file_count" -gt 0 ]; then
            echo "File breakdown:"
            find "$WORK_DIR" -type f 2>/dev/null | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -5 | while read count ext; do
                echo "  $count .$ext files"
            done
        fi
    else
        echo "Work directory: Not found"
    fi
    
    local hanging_procs=$(pgrep -f "vvp\|iverilog" 2>/dev/null | wc -l)
    echo "Hanging processes: $hanging_procs"
    
    echo ""
    echo "Cleanup completed successfully!"
}

# Main execution
main() {
    log INFO "Starting cleanup process..."
    
    # Execute cleanup functions
    kill_processes
    clean_vcd_files
    clean_temp_files
    clean_empty_dirs
    show_summary
    
    log SUCCESS "Cleanup process completed"
}

# Check if running as main script
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi