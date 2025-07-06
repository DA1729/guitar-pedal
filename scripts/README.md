# Guitar Effects Simulation Scripts

This directory contains safe, resource-monitored scripts for compiling and running SystemVerilog simulations of guitar effects modules.

## Quick Start

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Compile all modules
./scripts/compile_all.sh

# Run a specific simulation
./scripts/run_sim.sh distortion

# Check system health
./scripts/health_check.sh

# Clean up temporary files
./scripts/cleanup.sh
```

## Scripts Overview

### `compile_all.sh`
Compiles all guitar effects modules with safety checks:
- Resource monitoring during compilation
- Timeout protection (60s per module)
- Automatic cleanup of large files
- Detailed compilation reports

### `run_sim.sh`
Safely runs individual module simulations:
- Resource monitoring during simulation
- Configurable time limits
- VCD waveform generation (optional)
- Automatic cleanup of hanging processes

Usage:
```bash
./run_sim.sh <module_name> [options]

Options:
  -t TIME     Simulation time limit (default: 30s)
  -v          Enable VCD waveform output
  -q          Quiet mode
  --no-gui    Run without GUI (default)
```

Available modules:
- `clk_slow` - Clock divider
- `control` - Control module
- `delay` - Delay effect
- `distortion` - Distortion effect
- `octaver` - Octaver effect
- `trem` - Tremolo effect

### `health_check.sh`
Monitors system health and provides recommendations:
- Memory and CPU usage
- Disk space availability
- Detection of hanging processes
- Large file identification
- Performance suggestions

### `cleanup.sh`
Safe cleanup utility:
- Removes VCD files and temporary files
- Kills hanging simulation processes
- Configurable cleanup options
- Interactive or forced cleanup modes

Usage:
```bash
./cleanup.sh [options]

Options:
  -f, --force     Force cleanup without prompts
  -v, --verbose   Verbose output
  --vcd-only      Only clean VCD files
  --processes     Only kill hanging processes
```

## Safety Features

### Resource Protection
- Memory usage monitoring (warnings at 80%, emergency stop at 95%)
- CPU usage monitoring
- Automatic process timeouts
- Large file detection and cleanup

### System Stability
- Prevents infinite loops and runaway simulations
- Automatic cleanup of temporary files
- Process monitoring and termination
- Disk space monitoring

### Error Handling
- Graceful error recovery
- Detailed error reporting
- Automatic cleanup on script exit
- Resource leak prevention

## Usage Examples

### Basic Simulation
```bash
# Compile everything
./compile_all.sh

# Run distortion simulation for 60 seconds with VCD output
./run_sim.sh distortion -t 60 -v

# View waveforms
gtkwave scripts/work/distortion_waves.vcd
```

### Batch Processing
```bash
# Run all simulations quickly
for module in clk_slow control delay distortion octaver trem; do
    ./run_sim.sh $module -q -t 30
done
```

### Maintenance
```bash
# Check system health before long simulations
./health_check.sh

# Clean up after simulations
./cleanup.sh -f

# Or clean only VCD files
./cleanup.sh --vcd-only
```

## File Structure

```
scripts/
├── compile_all.sh      # Compilation script
├── run_sim.sh          # Simulation runner
├── health_check.sh     # System health monitor
├── cleanup.sh          # Cleanup utility
├── README.md          # This file
└── work/              # Build directory (created automatically)
    ├── *_sim          # Compiled simulation executables
    ├── *.vcd          # VCD waveform files
    └── *.tmp          # Temporary files
```

## Troubleshooting

### Common Issues

1. **Compilation fails**: Check that iverilog is installed (`sudo apt-get install iverilog`)
2. **High memory usage**: Run `./cleanup.sh` to free up space
3. **Hanging processes**: Use `./cleanup.sh --processes` to kill them
4. **Large VCD files**: Use `./cleanup.sh --vcd-only` to remove them

### Performance Tips

- Use `-q` flag for faster simulations
- Limit simulation time with `-t` option
- Only generate VCD when needed (`-v` flag)
- Run `./health_check.sh` before long simulations
- Clean up regularly with `./cleanup.sh`

### Emergency Recovery

If your system becomes unresponsive:
1. Kill all simulation processes: `pkill -f "vvp|iverilog"`
2. Clean up work directory: `rm -rf scripts/work && mkdir -p scripts/work`
3. Check system resources: `free -h && df -h`

## Requirements

- `iverilog` (Icarus Verilog) for compilation
- `vvp` (Icarus Verilog runtime) for simulation
- `gtkwave` (optional) for waveform viewing
- `bc` for floating-point calculations in resource monitoring

Install requirements on Ubuntu/Debian:
```bash
sudo apt-get install iverilog gtkwave bc
```