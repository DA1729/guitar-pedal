#!/usr/bin/env python3

import os
import subprocess
import sys

# Define the effects to simulate
effects = [
    {"name": "distortion", "sim_file": "distortion_sim"},
    {"name": "octaver", "sim_file": "octaver_sim"},
    {"name": "delay", "sim_file": "delay_sim"},
    {"name": "trem", "sim_file": "trem_sim"}
]

# Working directory
work_dir = "/home/da999/Documents/fun/projects/guitar_effects/scripts/work"
results_dir = "/home/da999/Documents/fun/projects/guitar_effects/sim_results"

# Change to work directory
os.chdir(work_dir)

print("=== Guitar Effects VCD Generation ===")
print(f"Working directory: {work_dir}")
print(f"Results directory: {results_dir}")
print()

# Run each simulation
for effect in effects:
    print(f"Running {effect['name']} simulation...")
    
    # Check if simulation file exists
    if not os.path.exists(effect['sim_file']):
        print(f"  Warning: {effect['sim_file']} not found, skipping...")
        continue
    
    # Run simulation
    try:
        result = subprocess.run(
            [f"./{effect['sim_file']}"],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        # Check if VCD file was created
        vcd_file = f"{effect['name']}_waves.vcd"
        if os.path.exists(vcd_file):
            print(f"  ✓ VCD file generated: {vcd_file}")
            # Move to results directory
            subprocess.run(['mv', vcd_file, f"{results_dir}/{effect['name']}_waves.vcd"])
            print(f"  ✓ Moved to sim_results/{effect['name']}_waves.vcd")
        else:
            print(f"  ✗ VCD file not generated")
            
    except subprocess.TimeoutExpired:
        print(f"  ✗ Simulation timed out")
    except Exception as e:
        print(f"  ✗ Error running simulation: {e}")
    
    print()

print("VCD generation completed!")