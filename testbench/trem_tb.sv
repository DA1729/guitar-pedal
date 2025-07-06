module trem_tb;

    logic [31:0] x;
    logic [31:0] y;
    logic clk_48 = 1'b0;
    logic clk_190;
    logic clk_380 = 1'b0;
    logic clk_95;
    logic clk_48hz;
    logic [3:0] options = 4'b0010;
    logic [3:0] en = 4'b0010;
    
    parameter real CLOCK_PERIOD = 20e-6; // 20 microseconds
    parameter real CLOCK_PERIOD380 = 2.63e-3; // 2.63 milliseconds
    int rand_num = 0;
    
    // Instantiate the unit under test
    trem uut (
        .x(x),
        .y(y),
        .clk_48(clk_48),
        .clk_190(clk_190),
        .clk_380(clk_380),
        .clk_95(clk_95),
        .clk_48hz(clk_48hz),
        .options(options),
        .en(en)
    );
    
    // Clock generation - 48MHz
    initial begin
        clk_48 = 0;
        forever #(CLOCK_PERIOD/2) clk_48 = ~clk_48;
    end
    
    // Clock generation - 380Hz
    initial begin
        clk_380 = 0;
        forever #(CLOCK_PERIOD380/2) clk_380 = ~clk_380;
    end
    
    // Generate other clocks from main clocks (simplified for testbench)
    assign clk_190 = clk_380;  // For simplicity in testbench
    assign clk_95 = clk_380;
    assign clk_48hz = clk_380;
    
    // Random number generation
    initial begin
        forever begin
            rand_num = $urandom_range(0, 150000);
            x = rand_num;
            #(CLOCK_PERIOD);
        end
    end
    
    // Test sequence
    initial begin
        // Run simulation for a reasonable time
        #(CLOCK_PERIOD380 * 100);
        
        // Test different options
        options = 4'b1000;
        #(CLOCK_PERIOD380 * 50);
        
        options = 4'b0100;
        #(CLOCK_PERIOD380 * 50);
        
        options = 4'b0001;
        #(CLOCK_PERIOD380 * 50);
        
        $finish;
    end
    
    // Monitor output
    initial begin
        $monitor("Time: %0t, x: %d, y: %d, options: %b", $time, signed'(x), signed'(y), options);
    end

endmodule