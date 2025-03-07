`timescale 1ns / 1ps

`include "alu_ops.vh"

module reg_bank_alu_tb();


    reg reset;
    reg clk;
    reg w_enable;
    wire [31:0] rs1;
    wire [31:0] rs2;
    wire [31:0] rddata;
    wire [4:0] raddr1;
    wire [4:0] raddr2;
    wire [4:0] waddr;
    wire [4:0] op;

    reg [19:0] fetch;
    reg [19:0] exec;
    reg [19:0] wb;
    reg [2:0] status;

    assign raddr1 = fetch[19:15];
    assign raddr2 = fetch[14:10];
    assign waddr = wb[9:5];
    assign op = exec[4:0];

    alu alu_ut (
        .reset(reset),
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .result(rddata),
        .carry(status[2]),
        .overflow(status[1]),
        .zero(status[0]),
        .op(op)
    );

    reg_bank rb_ut (
        .reset(reset),
        .clk(clk),
        .w_enable(w_enable),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .dout1(rs1),
        .dout2(rs2),
        .din(rddata)
    );


    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 0;
        w_enable = 0;
        fetch = 0;
        exec = 0;
        wb = 0;
        #10;
        reset = 1;
        fetch = {5'd2,5'd3,5'd4,`ADD};
        #10;
        exec <= fetch;
        wb <= exec;
        fetch = {5'd3,5'd4,5'd5,`ADD};
        #10;
        w_enable = 1;
        exec <= fetch;
        wb <= exec;
        fetch = {5'd4,5'd5,5'd6,`ADD};
        #10;
        w_enable = 1;
        exec <= fetch;
        wb <= exec;
        #10;
        wb <= exec;
        w_enable = 1;
        #10;
        $stop;
    end


endmodule
