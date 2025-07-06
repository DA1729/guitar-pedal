module distortion (
    input  logic [31:0] x,
    output logic [31:0] y,
    input  logic clk_48,
    input  logic [3:0] options,
    input  logic [3:0] en
);

logic signed [31:0] y_temp_s = 32'h00000000;

always_ff @(posedge clk_48) begin
    if (en[0] == 1'b1) begin
        case (options)
            4'b1000: begin // weak overdrive
                if (signed'(x[23:0]) >= 70000) begin
                    y <= 32'(signed'(70000));
                end else if (signed'(x[23:0]) <= -70000) begin
                    y <= 32'(signed'(-70000));
                end else begin
                    y <= x;
                end
            end
            
            4'b0100: begin // strong overdrive
                if (signed'(x[23:0]) >= 70000) begin
                    y <= 32'(signed'(90000));
                end else if (signed'(x[23:0]) <= -70000) begin
                    y <= 32'(signed'(-90000));
                end else begin
                    y <= x;
                end
            end
            
            4'b0010: begin // overdrive
                if (signed'(x[23:0]) >= 50000) begin
                    y <= 32'(signed'(50000));
                end else if (signed'(x[23:0]) <= -50000) begin
                    y <= 32'(signed'(-50000));
                end else begin
                    y <= x;
                end
            end
            
            4'b0001: begin // distortion
                if (signed'(x[23:0]) >= 0 && signed'(x[23:0]) < 50) begin
                    y <= 32'(signed'(200));
                end else if (signed'(x[23:0]) >= 50 && signed'(x[23:0]) < 100) begin
                    y <= 32'(signed'(500));
                end else if (signed'(x[23:0]) >= 100 && signed'(x[23:0]) < 200) begin
                    y <= 32'(signed'(1000));
                end else if (signed'(x[23:0]) >= 200 && signed'(x[23:0]) < 500) begin
                    y <= 32'(signed'(2000));
                end else if (signed'(x[23:0]) >= 500 && signed'(x[23:0]) < 1000) begin
                    y <= 32'(signed'(3000));
                end else if (signed'(x[23:0]) >= 1000 && signed'(x[23:0]) < 2000) begin
                    y <= 32'(signed'(4000));
                end else if (signed'(x[23:0]) >= 2000 && signed'(x[23:0]) < 3000) begin
                    y <= 32'(signed'(5000));
                end else if (signed'(x[23:0]) >= 3000 && signed'(x[23:0]) < 4500) begin
                    y <= 32'(signed'(5500));
                end else if (signed'(x[23:0]) >= 4000 && signed'(x[23:0]) < 5000) begin
                    y <= 32'(signed'(6000));
                end else if (signed'(x[23:0]) >= 5000 && signed'(x[23:0]) < 5500) begin
                    y <= 32'(signed'(7000));
                end else if (signed'(x[23:0]) >= 5500 && signed'(x[23:0]) < 6000) begin
                    y <= 32'(signed'(8000));
                end else if (signed'(x[23:0]) >= 6000 && signed'(x[23:0]) < 6500) begin
                    y <= 32'(signed'(9000));
                end else if (signed'(x[23:0]) >= 6500 && signed'(x[23:0]) < 7000) begin
                    y <= 32'(signed'(10000));
                end else if (signed'(x[23:0]) >= 7000 && signed'(x[23:0]) < 7500) begin
                    y <= 32'(signed'(20000));
                end else if (signed'(x[23:0]) >= 7500 && signed'(x[23:0]) < 8000) begin
                    y <= 32'(signed'(30000));
                end else if (signed'(x[23:0]) >= 8000 && signed'(x[23:0]) < 8500) begin
                    y <= 32'(signed'(50000));
                end else if (signed'(x[23:0]) >= 8500 && signed'(x[23:0]) < 9000) begin
                    y <= 32'(signed'(70000));
                end else if (signed'(x[23:0]) >= 9000 && signed'(x[23:0]) < 9500) begin
                    y <= 32'(signed'(95000));
                end else if (signed'(x[23:0]) >= 9500 && signed'(x[23:0]) < 10000) begin
                    y <= 32'(signed'(105000));
                end else if (signed'(x[23:0]) >= 10000 && signed'(x[23:0]) < 15000) begin
                    y <= 32'(signed'(110000));
                end else if (signed'(x[23:0]) >= 15000 && signed'(x[23:0]) < 20000) begin
                    y <= 32'(signed'(115000));
                end else if (signed'(x[23:0]) >= 20000 && signed'(x[23:0]) < 25000) begin
                    y <= 32'(signed'(120000));
                end else if (signed'(x[23:0]) >= 25000 && signed'(x[23:0]) < 30000) begin
                    y <= 32'(signed'(125000));
                end else if (signed'(x[23:0]) >= 30000 && signed'(x[23:0]) < 35000) begin
                    y <= 32'(signed'(130000));
                end else if (signed'(x[23:0]) >= 35000 && signed'(x[23:0]) < 40000) begin
                    y <= 32'(signed'(135000));
                end else if (signed'(x[23:0]) >= 40000 && signed'(x[23:0]) < 45000) begin
                    y <= 32'(signed'(140000));
                end else if (signed'(x[23:0]) >= 45000 && signed'(x[23:0]) < 50000) begin
                    y <= 32'(signed'(145000));
                end else if (signed'(x[23:0]) >= 50000 && signed'(x[23:0]) < 60000) begin
                    y <= 32'(signed'(150000));
                end else if (signed'(x[23:0]) >= 60000 && signed'(x[23:0]) < 70000) begin
                    y <= 32'(signed'(160000));
                end else if (signed'(x[23:0]) >= 70000 && signed'(x[23:0]) < 80000) begin
                    y <= 32'(signed'(170000));
                end else if (signed'(x[23:0]) >= 80000 && signed'(x[23:0]) < 90000) begin
                    y <= 32'(signed'(180000));
                end else if (signed'(x[23:0]) >= 90000 && signed'(x[23:0]) < 100000) begin
                    y <= 32'(signed'(190000));
                end else if (signed'(x[23:0]) >= 100000 && signed'(x[23:0]) < 120000) begin
                    y <= 32'(signed'(200000));
                end else if (signed'(x[23:0]) >= 120000 && signed'(x[23:0]) < 140000) begin
                    y <= 32'(signed'(220000));
                end else if (signed'(x[23:0]) >= 140000 && signed'(x[23:0]) < 160000) begin
                    y <= 32'(signed'(240000));
                end else if (signed'(x[23:0]) >= 160000 && signed'(x[23:0]) < 170000) begin
                    y <= 32'(signed'(260000));
                end else if (signed'(x[23:0]) >= 170000 && signed'(x[23:0]) < 190000) begin
                    y <= 32'(signed'(270000));
                end else if (signed'(x[23:0]) >= 190000 && signed'(x[23:0]) < 200000) begin
                    y <= 32'(signed'(290000));
                end else if (signed'(x[23:0]) >= 200000 && signed'(x[23:0]) < 220000) begin
                    y <= 32'(signed'(300000));
                end else if (signed'(x[23:0]) >= 220000 && signed'(x[23:0]) < 240000) begin
                    y <= 32'(signed'(320000));
                end else if (signed'(x[23:0]) >= 240000 && signed'(x[23:0]) < 260000) begin
                    y <= 32'(signed'(340000));
                end else if (signed'(x[23:0]) >= 260000 && signed'(x[23:0]) < 280000) begin
                    y <= 32'(signed'(360000));
                end else if (signed'(x[23:0]) >= 280000 && signed'(x[23:0]) < 300000) begin
                    y <= 32'(signed'(380000));
                end else if (signed'(x[23:0]) >= 300000) begin
                    y <= 32'(signed'(400000));
                end else if (signed'(x[23:0]) <= 0 && signed'(x[23:0]) > -50) begin
                    y <= 32'(signed'(-200));
                end else if (signed'(x[23:0]) <= -50 && signed'(x[23:0]) > -100) begin
                    y <= 32'(signed'(-500));
                end else if (signed'(x[23:0]) <= -100 && signed'(x[23:0]) > -200) begin
                    y <= 32'(signed'(-1000));
                end else if (signed'(x[23:0]) <= -200 && signed'(x[23:0]) > -500) begin
                    y <= 32'(signed'(-2000));
                end else if (signed'(x[23:0]) <= -500 && signed'(x[23:0]) > -1000) begin
                    y <= 32'(signed'(-3000));
                end else if (signed'(x[23:0]) <= -1000 && signed'(x[23:0]) > -2000) begin
                    y <= 32'(signed'(-4000));
                end else if (signed'(x[23:0]) <= -2000 && signed'(x[23:0]) > -3000) begin
                    y <= 32'(signed'(-5000));
                end else if (signed'(x[23:0]) <= -3000 && signed'(x[23:0]) > -4500) begin
                    y <= 32'(signed'(-5500));
                end else if (signed'(x[23:0]) <= -4000 && signed'(x[23:0]) > -5000) begin
                    y <= 32'(signed'(-6000));
                end else if (signed'(x[23:0]) <= -5000 && signed'(x[23:0]) > -5500) begin
                    y <= 32'(signed'(-7000));
                end else if (signed'(x[23:0]) <= -5500 && signed'(x[23:0]) > -6000) begin
                    y <= 32'(signed'(-8000));
                end else if (signed'(x[23:0]) <= -6000 && signed'(x[23:0]) > -6500) begin
                    y <= 32'(signed'(-9000));
                end else if (signed'(x[23:0]) <= -6500 && signed'(x[23:0]) > -7000) begin
                    y <= 32'(signed'(-10000));
                end else if (signed'(x[23:0]) <= -7000 && signed'(x[23:0]) > -7500) begin
                    y <= 32'(signed'(-20000));
                end else if (signed'(x[23:0]) <= -7500 && signed'(x[23:0]) > -8000) begin
                    y <= 32'(signed'(-30000));
                end else if (signed'(x[23:0]) <= -8000 && signed'(x[23:0]) > -8500) begin
                    y <= 32'(signed'(-50000));
                end else if (signed'(x[23:0]) <= -8500 && signed'(x[23:0]) > -9000) begin
                    y <= 32'(signed'(-70000));
                end else if (signed'(x[23:0]) <= -9000 && signed'(x[23:0]) > -9500) begin
                    y <= 32'(signed'(-95000));
                end else if (signed'(x[23:0]) <= -9500 && signed'(x[23:0]) > -10000) begin
                    y <= 32'(signed'(-105000));
                end else if (signed'(x[23:0]) <= -10000 && signed'(x[23:0]) > -15000) begin
                    y <= 32'(signed'(-110000));
                end else if (signed'(x[23:0]) <= -15000 && signed'(x[23:0]) > -20000) begin
                    y <= 32'(signed'(-115000));
                end else if (signed'(x[23:0]) <= -20000 && signed'(x[23:0]) > -25000) begin
                    y <= 32'(signed'(-120000));
                end else if (signed'(x[23:0]) <= -25000 && signed'(x[23:0]) > -30000) begin
                    y <= 32'(signed'(-125000));
                end else if (signed'(x[23:0]) <= -30000 && signed'(x[23:0]) > -35000) begin
                    y <= 32'(signed'(-130000));
                end else if (signed'(x[23:0]) <= -35000 && signed'(x[23:0]) > -40000) begin
                    y <= 32'(signed'(-135000));
                end else if (signed'(x[23:0]) <= -40000 && signed'(x[23:0]) > -45000) begin
                    y <= 32'(signed'(-140000));
                end else if (signed'(x[23:0]) <= -45000 && signed'(x[23:0]) > -50000) begin
                    y <= 32'(signed'(-145000));
                end else if (signed'(x[23:0]) <= -50000 && signed'(x[23:0]) > -60000) begin
                    y <= 32'(signed'(-150000));
                end else if (signed'(x[23:0]) <= -60000 && signed'(x[23:0]) > -70000) begin
                    y <= 32'(signed'(-160000));
                end else if (signed'(x[23:0]) <= -70000 && signed'(x[23:0]) > -80000) begin
                    y <= 32'(signed'(-170000));
                end else if (signed'(x[23:0]) <= -80000 && signed'(x[23:0]) > -90000) begin
                    y <= 32'(signed'(-180000));
                end else if (signed'(x[23:0]) <= -90000 && signed'(x[23:0]) > -100000) begin
                    y <= 32'(signed'(-190000));
                end else if (signed'(x[23:0]) <= -100000 && signed'(x[23:0]) > -120000) begin
                    y <= 32'(signed'(-200000));
                end else if (signed'(x[23:0]) <= -120000 && signed'(x[23:0]) > -140000) begin
                    y <= 32'(signed'(-240000));
                end else if (signed'(x[23:0]) <= -140000 && signed'(x[23:0]) > -160000) begin
                    y <= 32'(signed'(-240000));
                end else if (signed'(x[23:0]) <= -160000 && signed'(x[23:0]) > -170000) begin
                    y <= 32'(signed'(-260000));
                end else if (signed'(x[23:0]) <= -170000 && signed'(x[23:0]) > -190000) begin
                    y <= 32'(signed'(-270000));
                end else if (signed'(x[23:0]) <= -190000 && signed'(x[23:0]) > -200000) begin
                    y <= 32'(signed'(-290000));
                end else if (signed'(x[23:0]) <= -200000 && signed'(x[23:0]) > -220000) begin
                    y <= 32'(signed'(-300000));
                end else if (signed'(x[23:0]) <= -220000 && signed'(x[23:0]) > -240000) begin
                    y <= 32'(signed'(-320000));
                end else if (signed'(x[23:0]) <= -240000 && signed'(x[23:0]) > -260000) begin
                    y <= 32'(signed'(-340000));
                end else if (signed'(x[23:0]) <= -260000 && signed'(x[23:0]) > -280000) begin
                    y <= 32'(signed'(-360000));
                end else if (signed'(x[23:0]) <= -280000 && signed'(x[23:0]) > -300000) begin
                    y <= 32'(signed'(-380000));
                end else if (signed'(x[23:0]) <= -300000) begin
                    y <= 32'(signed'(-400000));
                end else begin
                    y <= x;
                end
            end
            
            default: y <= x;
        endcase
    end else begin
        y <= x;
    end
end

endmodule
