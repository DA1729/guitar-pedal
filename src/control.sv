module control (
    input  logic [7:0] switches,    // left to right
    input  logic clk_12hz,
    input  logic clk_1hz5,
    output logic [7:0] leds = 8'b10000000,  // left to right
    input  logic [2:0] butn_in,     // left to right - L,C,R
    output logic [3:0] en = 4'b0000,
    output logic [3:0] options0,
    output logic [3:0] options1,
    output logic [3:0] options2,
    output logic [3:0] options3
);

logic ok = 1'b0;
logic [2:0] butn_i;
int sele = 0;

assign butn_i = butn_in;

// Enable processing
always_comb begin
    en[0] = switches[0];
    en[1] = switches[1];
    en[2] = switches[2];
    en[3] = switches[3];
end

// Scroll between effects
always_ff @(posedge clk_12hz) begin
    if (ok == 1'b0) begin
        case ({sele, butn_i})
            {2'd0, 3'b001}: sele <= 1;
            {2'd1, 3'b100}: sele <= 0;
            {2'd1, 3'b001}: sele <= 2;
            {2'd2, 3'b100}: sele <= 1;
            {2'd2, 3'b001}: sele <= 3;
            {2'd3, 3'b100}: sele <= 2;
            default: sele <= sele;
        endcase
    end
end

// LED control for effect selection
always_comb begin
    if (ok == 1'b0) begin
        case (sele)
            0: leds = 8'b10000000;
            1: leds = 8'b01000000;
            2: leds = 8'b00100000;
            3: leds = 8'b00010000;
            default: leds = 8'b10000000;
        endcase
    end
end

// Change effect parameters
always_comb begin
    if (ok == 1'b1) begin
        case (sele)
            0: options0 = switches[4:7];
            1: options1 = switches[4:7];
            2: options2 = switches[4:7];
            3: options3 = switches[4:7];
            default: begin
                options0 = 4'b0000;
                options1 = 4'b0000;
                options2 = 4'b0000;
                options3 = 4'b0000;
            end
        endcase
    end
end

// Mode toggle (effect selection vs effect control)
always_ff @(posedge clk_1hz5) begin
    if (butn_i == 3'b010) begin
        ok <= ~ok;
    end
end

endmodule
