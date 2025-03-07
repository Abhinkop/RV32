`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2024 04:31:40 PM
// Design Name: 
// Module Name: reg_bank_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_bank_tb();

    // Inputs
    reg reset;
    reg clk;
    reg w_enable;
    reg [4:0] raddr1;
    reg [4:0] raddr2;
    reg [4:0] waddr;
    reg [31:0] din;

    // Outputs
    reg [31:0] dout1;
    reg [31:0] dout2;

    reg_bank uut (
        .reset(reset),
        .clk(clk),
        .w_enable(w_enable),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .dout1(dout1),
        .dout2(dout2),
        .din(din)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        w_enable = 0;
        raddr1 = 0;
        raddr2 = 0;
        waddr = 0;
        din = 0;

        // Wait for global reset
        #10;

        reset = 1;
        w_enable = 1;
        waddr = 1;
        din = 10;
        raddr1 = 1;
        raddr2 = 2;
        #10
        
        assert(dout1 == 0);
        assert(dout2 == 0);

        
        w_enable = 1;
        waddr = 2;
        din = 2;
        raddr1 = 1;
        raddr2 = 2;
        #10
        assert(dout1 == 10);
        assert(dout2 == 0);
        
        w_enable = 1;
        waddr = 0;
        din = 10;
        raddr1 = 0;
        raddr2 = 2;
        #10
        assert(dout1 == 0);
        assert(dout2 == 2);

        w_enable = 0;
        raddr1 = 0;
        raddr2 = 2;
        din = 5;
        #10
        assert(dout1 == 0);
        assert(dout2 == 2);
        
        
        $stop;
    end
endmodule
