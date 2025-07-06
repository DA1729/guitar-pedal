**Note**: This is a hobby project done purely for fun and learning in my free time. It's not intended to be a serious commercial or research project with novel contributions - just an enjoyable exploration of digital signal processing and SystemVerilog.

## Project Structure

```
guitar_effects/
├── src/                    # SystemVerilog source files
│   ├── bram.sv            # Block RAM module
│   ├── distortion.sv      # Distortion/overdrive effect
│   ├── delay.sv           # Delay effect
│   ├── octaver.sv         # Octave shifting effect
│   ├── trem.sv            # Tremolo effect
│   ├── clk_slow.sv        # Clock divider
│   └── control.sv         # User interface controller
├── testbench/             # SystemVerilog testbenches
│   ├── clk_slow_tb.sv     # Clock divider testbench
│   ├── control_tb.sv      # Control module testbench
│   ├── distortion_tb.sv   # Distortion effect testbench
│   ├── delay_tb.sv        # Delay effect testbench
│   ├── octaver_tb.sv      # Octaver effect testbench
│   └── trem_tb.sv         # Tremolo effect testbench
├── scripts/               # Safe build and simulation scripts
│   ├── compile_all.sh     # Compilation script with safety checks
│   ├── run_sim.sh         # Simulation runner with resource monitoring
│   ├── health_check.sh    # System health monitoring
│   ├── cleanup.sh         # Safe cleanup utility
│   ├── README.md          # Scripts documentation
│   └── work/              # Build directory (auto-created)
└── README.md
```

## Guitar Effects Modules

### 1. Distortion (`distortion.sv`)
- **Function**: Implements various distortion and overdrive effects
- **Options**: 
  - `4'b1000`: Weak overdrive
  - `4'b0100`: Strong overdrive  
  - `4'b0010`: Overdrive
  - `4'b0001`: Distortion with complex mapping
- **Enable**: `en[0]`

### 2. Delay (`delay.sv`)
- **Function**: Provides delay-based effects including echo and reverb
- **Options**:
  - `4'b1000`: IIR delay (full length)
  - `4'b1100`: IIR delay (half length)
  - `4'b1110`: IIR slight reverb
  - `4'b0100`: IIR long delay (variable)
  - `4'b0010`: FIR single tap delay
- **Enable**: `en[3]`

### 3. Octaver (`octaver.sv`)
- **Function**: Pitch shifting effects (octave up/down)
- **Options**:
  - `4'b1000-4'b0011`: Various 1-octave up effects
  - `4'b0100`, `4'b0001`: 2-octave up effects
  - `4'b0010`: 1-octave down effect
- **Enable**: `en[1]`

### 4. Tremolo (`trem.sv`)
- **Function**: Amplitude modulation effects
- **Options**:
  - `4'b1000`: 1.6 Hz tremolo
  - `4'b0100`: 3.2 Hz tremolo
  - `4'b0010`: 6.35 Hz tremolo
  - `4'b0001`: 0.8 Hz tremolo
- **Enable**: `en[2]`

### 5. Clock Divider (`clk_slow.sv`)
- **Function**: Generates various clock frequencies from main clock
- **Outputs**: 190Hz, 380Hz, 95Hz, 48Hz, 12Hz, 1.5Hz clocks

### 6. Control (`control.sv`)
- **Function**: User interface controller for effect selection and parameter control
- **Inputs**: 8 switches, 3 buttons
- **Outputs**: 8 LEDs, effect enables, and option settings

## Building and Simulation

### Prerequisites
- **For Simulation**: Icarus Verilog (`iverilog`), GTKWave, and `bc` (for resource monitoring)
- **For Synthesis**: Xilinx Vivado (2019.1 or later)
- **Platform**: Tested on Linux only (Ubuntu/Debian). macOS and Windows compatibility not verified.

### Installation
```bash
# Ubuntu/Debian
sudo apt-get install iverilog gtkwave bc

# macOS
brew install icarus-verilog
```

### Quick Start
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Compile all modules (with safety checks)
./scripts/compile_all.sh

# Run a specific simulation
./scripts/run_sim.sh distortion

# Run with VCD output and 60-second time limit
./scripts/run_sim.sh distortion -v -t 60

# Check system health before long simulations
./scripts/health_check.sh

# Clean up temporary files
./scripts/cleanup.sh
```

### Safe Simulation Features
The new scripts include comprehensive safety features to prevent system crashes:

- **Resource Monitoring**: Tracks memory/CPU usage, emergency stop at 95% memory
- **Timeout Protection**: 60s compilation limit, 30s simulation default
- **Process Management**: Automatic cleanup of hanging processes
- **File Size Limits**: Removes large VCD files (>50MB) automatically
- **Emergency Recovery**: Graceful shutdown with cleanup on exit

### Available Modules
All modules can be simulated individually:
- `clk_slow` - Clock divider simulation
- `control` - Control module simulation  
- `delay` - Delay effect simulation
- `distortion` - Distortion effect simulation
- `octaver` - Octaver effect simulation
- `trem` - Tremolo effect simulation

### Script Options
The `run_sim.sh` script supports various options:
```bash
./scripts/run_sim.sh <module> [options]
  -t TIME     Simulation time limit (default: 30s)
  -v          Enable VCD waveform output
  -q          Quiet mode (less output)
  --no-gui    Run without GUI (default)
```

### Maintenance
```bash
# Check system health and get recommendations
./scripts/health_check.sh

# Clean up all temporary files
./scripts/cleanup.sh -f

# Clean only VCD files
./scripts/cleanup.sh --vcd-only

# Kill hanging processes only
./scripts/cleanup.sh --processes
```

### Emergency Recovery
If simulations cause system issues:
1. Kill all processes: `./scripts/cleanup.sh --processes`
2. Clean up files: `./scripts/cleanup.sh -f`
3. Check system: `./scripts/health_check.sh`

See `scripts/README.md` for detailed script documentation.

## Key SystemVerilog Conversion Changes

1. **Module Declaration**: Changed from VHDL `entity/architecture` to SystemVerilog `module`
2. **Data Types**: 
   - `std_logic` → `logic`
   - `std_logic_vector` → `logic [n:0]`
   - `signed` → `logic signed [n:0]`
3. **Processes**: VHDL `process` blocks converted to SystemVerilog `always_ff` and `always_comb`
4. **Arithmetic**: Updated shift operations and type casting for SystemVerilog syntax
5. **Memory**: BRAM implementation updated to use SystemVerilog array syntax
6. **Testbenches**: Converted to SystemVerilog testbench methodology with `initial` blocks

## Original VHDL Project Credit

This SystemVerilog implementation is based on the original VHDL design by:
- **Vladi & Adi**
- **TAU EE Senior Year Project**
- **FPGA Design and Implementation of Electric Guitar Audio Effects**

## Usage Notes

- All modules are parameterizable for different memory sizes and bit widths
- The project is designed for FPGA implementation (originally targeting Xilinx Zynq-7000)
- Audio data is processed as 32-bit signed integers
- Sample rate is designed for 48kHz audio processing

## License

This project is licensed under the **MIT License**, following the original terms of the VHDL implementation.

- Original VHDL project by **Vladi & Adi** — *FPGA Design and Implementation of Electric Guitar Audio Effects* (TAU EE Senior Year Project).
- SystemVerilog conversion and scripting infrastructure by **Daksh Pandey**, 2025.

You are free to use, modify, and distribute this project under the terms of the MIT License.  
See the [LICENSE](LICENSE) file for full details.
