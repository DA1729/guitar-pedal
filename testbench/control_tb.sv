module control_tb;

    logic [7:0] switches;
    logic clk_12hz;
    logic clk_1hz5;
    logic [7:0] leds;
    logic [2:0] butn_in;
    logic [3:0] en;
    logic [3:0] options0;
    logic [3:0] options1;
    logic [3:0] options2;
    logic [3:0] options3;
    
    parameter real CLOCK_PERIOD_12HZ = 83.33e-6; // 83.33 microseconds (12Hz)
    parameter real CLOCK_PERIOD_1HZ5 = 0.67e-3; // 0.67 milliseconds (1.5Hz)
    
    // Instantiate the unit under test
    control uut (
        .switches(switches),
        .clk_12hz(clk_12hz),
        .clk_1hz5(clk_1hz5),
        .leds(leds),
        .butn_in(butn_in),
        .en(en),
        .options0(options0),
        .options1(options1),
        .options2(options2),
        .options3(options3)
    );
    
    // Clock generation
    initial begin
        clk_12hz = 0;
        forever #(CLOCK_PERIOD_12HZ/2) clk_12hz = ~clk_12hz;
    end
    
    initial begin
        clk_1hz5 = 0;
        forever #(CLOCK_PERIOD_1HZ5/2) clk_1hz5 = ~clk_1hz5;
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        switches = 8'b00000000;
        butn_in = 3'b000;
        
        // Wait for initial state
        #(CLOCK_PERIOD_12HZ * 10);
        
        // Test switch enables
        switches = 8'b00001111;
        #(CLOCK_PERIOD_12HZ * 5);
        
        // Test button navigation (right button)
        butn_in = 3'b001;
        #(CLOCK_PERIOD_12HZ * 2);
        butn_in = 3'b000;
        #(CLOCK_PERIOD_12HZ * 5);
        
        // Test left button
        butn_in = 3'b100;
        #(CLOCK_PERIOD_12HZ * 2);
        butn_in = 3'b000;
        #(CLOCK_PERIOD_12HZ * 5);
        
        // Test mode toggle (center button)
        butn_in = 3'b010;
        #(CLOCK_PERIOD_1HZ5 * 2);
        butn_in = 3'b000;
        
        // Test option switches in control mode
        switches = 8'b11110000;
        #(CLOCK_PERIOD_12HZ * 5);
        
        $finish;
    end
    
    // Monitor output
    initial begin
        $monitor("Time: %0t, switches: %b, butn_in: %b, leds: %b, en: %b, options0: %b", 
                 $time, switches, butn_in, leds, en, options0);
    end

endmodule