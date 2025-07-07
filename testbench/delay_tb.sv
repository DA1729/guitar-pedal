module delay_tb;

    logic [31:0] x = 32'h00000000;
    logic [31:0] y;
    logic clk_48 = 1'b1;
    logic [3:0] options = 4'b0100;
    logic [3:0] en = 4'b0001;
    
    parameter real CLOCK_PERIOD = 20e-6; // 20 microseconds
    int rand_num = 0;
    
    // Instantiate the unit under test
    delay uut (
        .x(x),
        .y(y),
        .clk_48(clk_48),
        .options(options),
        .en(en)
    );
    
    // Clock generation
    initial begin
        clk_48 = 0;
        forever #(CLOCK_PERIOD/2) clk_48 = ~clk_48;
    end
    
    // Input stimulus - incrementing counter
    initial begin
        forever begin
            x = x + 1;
            #(CLOCK_PERIOD);
        end
    end
    
    // Test sequence
    initial begin
        // Enable VCD dump
        $dumpfile("delay_waves.vcd");
        $dumpvars(0, delay_tb);
        
        // Run simulation for a reasonable time
        #(CLOCK_PERIOD * 1000);
        
        // Test different options
        options = 4'b1000;
        #(CLOCK_PERIOD * 100);
        
        options = 4'b1100;
        #(CLOCK_PERIOD * 100);
        
        options = 4'b0010;
        #(CLOCK_PERIOD * 100);
        
        $finish;
    end
    
    // Monitor output
    initial begin
        $monitor("Time: %0t, x: %d, y: %d, options: %b", $time, signed'(x), signed'(y), options);
    end

endmodule
