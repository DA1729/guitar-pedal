module octaver #(
    parameter int T = 20000,
    parameter int B = 15  // 15 bits for 20,000 memory places
)(
    input  logic [31:0] x,
    output logic [31:0] y,
    input  logic clk_48,
    input  logic [3:0] options,
    input  logic [3:0] en
);

logic signed [31:0] y_temp_s = 32'h00000000;

logic [B-1:0] i = '0;
int max_delay = T-1;

// BRAM signals
logic we = 1'b1;
logic [B-1:0] addr1 = '0;
logic [B-1:0] addr2 = '0;
logic [31:0] data_in;
logic [31:0] data_out1;
logic [31:0] data_out2;

// Instantiate BRAM for octaver
bram #(
    .T(T),
    .B(B)
) bram_oct_inst (
    .clk(clk_48),
    .we(we),
    .addr1(addr1),
    .addr2(addr2),
    .di(data_in),
    .do1(data_out1),
    .do2(data_out2)
);

// Memory index counter
always_ff @(posedge clk_48) begin
    if (i == max_delay - 2) begin
        i <= '0;
    end else begin
        i <= i + 1;
    end
end

// BRAM write pointer (addr1)
always_ff @(posedge clk_48) begin
    if (addr1 == max_delay - 2) begin
        addr1 <= '0;
    end else begin
        addr1 <= addr1 + 1;
    end
end

// BRAM read pointer (addr2)
always_ff @(posedge clk_48) begin
    // 1 octave up
    if (options == 4'b1000 || options == 4'b1100 || options == 4'b1110 || 
        options == 4'b0011 || options == 4'b1111 || options == 4'b0111) begin
        if (addr2 >= max_delay - 2) begin
            addr2 <= '0;
        end
        addr2 <= (i << 1) + 1;
    end
    // 2 octaves up
    else if (options == 4'b0100 || options == 4'b0001) begin
        if (addr2 >= max_delay - 2) begin
            addr2 <= '0;
        end
        addr2 <= (i << 2) + 1;
    end
    // 1 octave down
    else if (options == 4'b0010) begin
        if (addr2 >= max_delay - 2) begin
            addr2 <= '0;
        end
        addr2 <= (i >> 1) + 1;
    end
end

// Main processing
always_ff @(posedge clk_48) begin
    if (en[1] == 1'b1) begin
        case (options)
            4'b1000: begin // FIR, 1up, 3000
                max_delay <= 3000;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= x;
                y <= y_temp_s;
            end
            
            4'b1100: begin // FIR, 1up, 8000
                max_delay <= 8000;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= x;
                y <= y_temp_s;
            end
            
            4'b1110: begin // FIR, 1up, 15000
                max_delay <= 15000;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= x;
                y <= y_temp_s;
            end
            
            4'b1111: begin // IIR, 1up, 5000 (T/4)
                max_delay <= 5000;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= y_temp_s;
                y <= y_temp_s;
            end
            
            4'b0111: begin // IIR, 1up, 10000 (T/2)
                max_delay <= 10000;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= y_temp_s;
                y <= y_temp_s;
            end
            
            4'b0011: begin // IIR, 1up, 19999 (T-1)
                max_delay <= 19999;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= y_temp_s;
                y <= y_temp_s;
            end
            
            4'b0100: begin // FIR, 2up, 3000
                max_delay <= 3000;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= x;
                y <= y_temp_s;
            end
            
            4'b0001: begin // FIR, 2up, 500 - robot sound
                max_delay <= 500;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= x;
                y <= y_temp_s;
            end
            
            4'b0010: begin // FIR, 1down, 8000
                max_delay <= 8000;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= x;
                y <= y_temp_s;
            end
            
            default: y <= x;
        endcase
    end else begin
        y <= x;
    end
end

endmodule
