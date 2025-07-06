# Vivado synthesis script for Guitar Effects SystemVerilog project
# This script can be used with Xilinx Vivado to synthesize the design

# Set the target device (adjust as needed for your FPGA)
set_property target_language SystemVerilog [current_project]

# Create a new project or use existing
# create_project guitar_effects ./guitar_effects_project -part xc7z020clg400-1

# Add source files
add_files -fileset sources_1 {
    ../src/bram.sv
    ../src/distortion.sv
    ../src/delay.sv
    ../src/octaver.sv
    ../src/trem.sv
    ../src/clk_slow.sv
    ../src/control.sv
}

# Add testbench files (for simulation)
add_files -fileset sim_1 {
    ../testbench/distortion_tb.sv
    ../testbench/delay_tb.sv
    ../testbench/octaver_tb.sv
    ../testbench/trem_tb.sv
}

# Set top level module (you would need to create a top-level module)
# set_property top guitar_effects_top [current_fileset]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Synthesis settings
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

# Launch synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis results
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed"
}

puts "Synthesis completed successfully!"

# Optional: Launch implementation
# launch_runs impl_1 -jobs 4
# wait_on_run impl_1

# Optional: Generate bitstream
# launch_runs impl_1 -to_step write_bitstream -jobs 4
# wait_on_run impl_1
