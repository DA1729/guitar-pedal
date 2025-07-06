module delay #(
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

// Triangular wave parameters
logic direction = 1'b0;
int count = 5;

logic [B-1:0] i = '0;
int max_delay = T-1;

// BRAM signals
logic we = 1'b1;
logic [B-1:0] addr1 = '0;
logic [B-1:0] addr2 = '0;
logic [31:0] data_in;
logic [31:0] data_out1;
logic [31:0] data_out2;

// Instantiate BRAM
bram #(
    .T(T),
    .B(B)
) bram_inst (
    .clk(clk_48),
    .we(we),
    .addr1(addr1),
    .addr2(addr2),
    .di(data_in),
    .do1(data_out1),
    .do2(data_out2)
);

// Triangular wave generation - creates long delay
always_comb begin
    if (count == 2440) begin
        direction = 1'b1;
    end else if (count == 0) begin
        direction = 1'b0;
    end
end

always_ff @(posedge clk_48) begin
    if (direction == 1'b0) begin
        count <= count + 1;
    end else begin
        count <= count - 1;
    end
end

// Index counter
always_ff @(posedge clk_48) begin
    if (i == max_delay - 2) begin
        i <= '0;
    end else begin
        i <= i + 1;
    end
end

// BRAM write pointer
always_ff @(posedge clk_48) begin
    if (addr1 == max_delay - 2) begin
        addr1 <= '0;
    end else begin
        addr1 <= addr1 + 1;
    end
end

// BRAM read pointer
always_ff @(posedge clk_48) begin
    if (options == 4'b1000 || options == 4'b0100 || options == 4'b0010 || 
        options == 4'b1100 || options == 4'b1110) begin
        if (addr2 == max_delay - 2) begin
            addr2 <= '0;
        end
        addr2 <= i + 1;
    end
end

// Main processing
always_ff @(posedge clk_48) begin
    if (en[3] == 1'b1) begin
        case (options)
            4'b1000: begin // IIR, play Buckethead's Whitewash!
                max_delay <= T - 1;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= y_temp_s;
                y <= y_temp_s;
            end
            
            4'b1100: begin // IIR, faster delay
                max_delay <= T/2 - 1;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= y_temp_s;
                y <= y_temp_s;
            end
            
            4'b1110: begin // IIR, very slight reverb
                max_delay <= T/2 - 1;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 3});
                data_in <= y_temp_s;
                y <= y_temp_s;
            end
            
            4'b0100: begin // IIR, long delay
                max_delay <= count;
                y_temp_s <= signed'(x) + signed'({8'h00, data_out2[23:0] >>> 1});
                data_in <= y_temp_s;
                y <= y_temp_s;
            end
            
            4'b0010: begin // FIR single tap, long delay
                max_delay <= count;
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
