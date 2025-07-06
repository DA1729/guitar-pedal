module clk_slow (
    input  logic clk_in,
    output logic clk_190hz,
    output logic clk_380hz,
    output logic clk_95hz,
    output logic clk_48hz,
    output logic clk_12hz,
    output logic clk1hz5
);

logic [25:0] clk_cntr = 26'h0;

always_ff @(posedge clk_in) begin
    clk_cntr <= clk_cntr + 1;
end

// For control block
assign clk_12hz = clk_cntr[21];
assign clk1hz5 = clk_cntr[24];

// For tremolo
assign clk_380hz = clk_cntr[16];
assign clk_190hz = clk_cntr[17];
assign clk_95hz = clk_cntr[18];
assign clk_48hz = clk_cntr[19];

// Other clocks (commented out in original)
// assign clk_24khz = clk_cntr[10];
// assign clk3k = clk_cntr[13];
// assign clk_1k5hz = clk_cntr[14];
// assign clk_762hz = clk_cntr[15];

endmodule
