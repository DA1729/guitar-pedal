module clk_slow_tb;

    logic clk_in;
    logic clk_190hz;
    logic clk_380hz;
    logic clk_95hz;
    logic clk_48hz;
    logic clk_12hz;
    logic clk1hz5;
    
    parameter real CLOCK_PERIOD = 20e-9; // 20 nanoseconds (50MHz)
    
    // Instantiate the unit under test
    clk_slow uut (
        .clk_in(clk_in),
        .clk_190hz(clk_190hz),
        .clk_380hz(clk_380hz),
        .clk_95hz(clk_95hz),
        .clk_48hz(clk_48hz),
        .clk_12hz(clk_12hz),
        .clk1hz5(clk1hz5)
    );
    
    // Clock generation
    initial begin
        clk_in = 0;
        forever #(CLOCK_PERIOD/2) clk_in = ~clk_in;
    end
    
    // Test sequence
    initial begin
        // Run simulation for enough time to see the slow clocks toggle
        #(CLOCK_PERIOD * 100000);
        $finish;
    end
    
    // Monitor output clocks
    initial begin
        $monitor("Time: %0t, clk_1hz5: %b, clk_12hz: %b, clk_48hz: %b, clk_95hz: %b, clk_190hz: %b, clk_380hz: %b", 
                 $time, clk1hz5, clk_12hz, clk_48hz, clk_95hz, clk_190hz, clk_380hz);
    end

endmodule