This project is a SystemVerilog conversion of the original VHDL guitar effects processor designed by Vladi & Adi as part of their TAU EE Senior year project.

## Project Structure

```
guitar_ver/
├── src/                    # SystemVerilog source files
│   ├── bram.sv            # Block RAM module
│   ├── distortion.sv      # Distortion/overdrive effect
│   ├── delay.sv           # Delay effect
│   ├── octaver.sv         # Octave shifting effect
│   ├── trem.sv            # Tremolo effect
│   ├── clk_slow.sv        # Clock divider
│   └── control.sv         # User interface controller
├── testbench/             # SystemVerilog testbenches
│   ├── distortion_tb.sv
│   ├── delay_tb.sv
│   ├── octaver_tb.sv
│   └── trem_tb.sv
├── scripts/               # Build and synthesis scripts
│   ├── compile_and_sim.sh # Compilation and simulation script
│   ├── synthesize.tcl     # Vivado synthesis script
│   └── run_vivado.sh      # Vivado runner script
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
- **For Simulation**: Icarus Verilog (`iverilog`) and GTKWave
- **For Synthesis**: Xilinx Vivado (2019.1 or later)

### Installation
```bash
# Ubuntu/Debian
sudo apt-get install iverilog gtkwave

# macOS
brew install icarus-verilog
```

### Running Simulations
```bash
cd scripts
chmod +x compile_and_sim.sh
./compile_and_sim.sh
```

This will compile and simulate all modules, generating waveform files in the `work/` directory.

### Synthesis with Vivado
```bash
cd scripts
chmod +x run_vivado.sh
./run_vivado.sh
```

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

This project maintains the same license as the original VHDL implementation.
