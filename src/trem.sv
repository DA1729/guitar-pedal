module trem (
    input  logic [31:0] x,
    output logic [31:0] y,
    input  logic clk_48,
    input  logic clk_190,
    input  logic clk_380,
    input  logic clk_95,
    input  logic clk_48hz,
    input  logic [3:0] options,
    input  logic [3:0] en
);

logic [31:0] data_o;
logic [31:0] data_i;
logic [63:0] temp_vec_64;

// Triangular wave signals
int count_int;
int count_int2;
int count_int4;
int count_int6;
logic direction = 1'b0;
logic direction_s2 = 1'b0;
logic direction_s4 = 1'b0;
logic direction_s6 = 1'b0;

// Generate various triangular waves
// Tremolo frequency - 1.6hz
always_comb begin
    if (count_int == 30) begin
        direction = 1'b1;
    end else if (count_int == 1) begin
        direction = 1'b0;
    end
end

always_ff @(posedge clk_95) begin
    if (direction == 1'b0) begin
        count_int <= count_int + 1;
    end else begin
        count_int <= count_int - 1;
    end
end

// Tremolo frequency - 3.2 hz
always_comb begin
    if (count_int2 == 30) begin
        direction_s2 = 1'b1;
    end else if (count_int2 == 1) begin
        direction_s2 = 1'b0;
    end
end

always_ff @(posedge clk_190) begin
    if (direction_s2 == 1'b0) begin
        count_int2 <= count_int2 + 1;
    end else begin
        count_int2 <= count_int2 - 1;
    end
end

// Tremolo frequency - 6.35hz
always_comb begin
    if (count_int4 == 30) begin
        direction_s4 = 1'b1;
    end else if (count_int4 == 1) begin
        direction_s4 = 1'b0;
    end
end

always_ff @(posedge clk_380) begin
    if (direction_s4 == 1'b0) begin
        count_int4 <= count_int4 + 1;
    end else begin
        count_int4 <= count_int4 - 1;
    end
end

// Tremolo frequency - 0.8hz
always_comb begin
    if (count_int6 == 30) begin
        direction_s6 = 1'b1;
    end else if (count_int6 == 1) begin
        direction_s6 = 1'b0;
    end
end

always_ff @(posedge clk_48hz) begin
    if (direction_s6 == 1'b0) begin
        count_int6 <= count_int6 + 1;
    end else begin
        count_int6 <= count_int6 - 1;
    end
end

// Main processing
always_ff @(posedge clk_48) begin
    if (en[2] == 1'b1) begin
        case (options)
            4'b1000: begin // tremolo frequency - 1.6hz
                temp_vec_64 <= signed'(x) * count_int;
                y <= {8'h00, temp_vec_64[23:0] >>> 4};
            end
            
            4'b0100: begin // tremolo frequency - 3.2 hz
                temp_vec_64 <= signed'(x) * count_int2;
                y <= {8'h00, temp_vec_64[23:0] >>> 4};
            end
            
            4'b0010: begin // tremolo frequency - 6.35hz
                temp_vec_64 <= signed'(x) * count_int4;
                y <= {8'h00, temp_vec_64[23:0] >>> 4};
            end
            
            4'b0001: begin // tremolo frequency - 0.8hz
                temp_vec_64 <= signed'(x) * count_int6;
                y <= {8'h00, temp_vec_64[23:0] >>> 4};
            end
            
            default: y <= x;
        endcase
    end else begin
        y <= x;
    end
end

endmodule
