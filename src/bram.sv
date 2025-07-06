module bram #(
    parameter int T = 20000,
    parameter int B = 15  // 15 bits for 20,000 memory places
)(
    input  logic clk,
    input  logic we,
    input  logic [B-1:0] addr1,
    input  logic [B-1:0] addr2,
    input  logic [31:0] di,      // 32 bit word
    output logic [31:0] do1,
    output logic [31:0] do2
);

logic [31:0] RAM [0:T-1];

// Initialize RAM
initial begin
    for (int i = 0; i < T; i++) begin
        RAM[i] = 32'h00000000;
    end
end

// Write port and read port 1
always_ff @(posedge clk) begin
    if (we) begin
        RAM[addr1] <= di;
    end
    do1 <= RAM[addr1];
end

// Read port 2
always_ff @(posedge clk) begin
    do2 <= RAM[addr2];
end

endmodule
