`timescale 1ns / 1ps

module reg_bank(
    input reset,
    input clk,
    input w_enable,
    input [4:0] raddr1,
    input [4:0] raddr2,
    input [4:0] waddr,
    output reg [31:0] dout1,
    output reg [31:0] dout2,
    input [31:0] din
    );

    reg [32:0] registers[31:0];

    always @(posedge clk) begin
        if(!reset) begin
            for (integer i = 0; i < 32 ; i = i+1) begin
                registers[i] <= i;
            end
        end
        else begin
            dout1 <= registers[raddr1];
            dout2 <= registers[raddr2];
            if(w_enable && waddr != 0) begin
                registers[waddr] <= din;
            end
        end
    end
endmodule
