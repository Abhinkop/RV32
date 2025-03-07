`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2024 03:10:20 PM
// Design Name: 
// Module Name: alu
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

`include "alu_ops.vh"

module alu(
    input reset,
    input clk,
    input [31:0] rs1,
    input [31:0] rs2,
    output [31:0] result,
    output carry,
    output overflow,
    output zero,
    input [4:0] op
    );
    
    
    reg [32:0] out;
    reg [31:0] rs1_old;
    reg [31:0] rs2_old;
    reg [4:0] prev_op;
    
    assign zero = (out[31:0] == 0) ? 1:0;
    assign carry = ((prev_op == `ADD) | (prev_op == `SUB))? out[32]:0;
    assign overflow = ((prev_op == `ADD) | (prev_op == `SUB))? ((out[31] & ~rs1_old[31] & ~rs2_old[31]) | (~out[31] & rs1_old[31] & rs2_old[31])) : 0;
    assign result = out[31:0];
    
    always @(posedge clk) begin
        rs1_old <= rs1;
        rs2_old <= rs2;
        if(!reset)
        begin
            out <= 0;
            rs1_old <= 0;
            rs2_old <= 0;
            prev_op <= 0;
        end
        else
        begin
            prev_op = op;
            rs1_old <= rs1;
            if(op == `SUB)
            begin
            rs2_old <= (~rs2 + 1);
            end
            else
            begin
            rs2_old <= rs2;
            end
            case(op)
                `AND   : out <= rs1 & rs2 ;     
                `OR    : out <= rs1 | rs2 ; 
                `ADD   : out <= rs1 + rs2 ;     
                `SUB   : out <= rs1 + (~rs2 + 1) ;     
                `XOR   : out <= rs1 ^ rs2 ;     
                `SLL   : out <= rs1 << rs2 ;     
                `SRL   : out <= rs1 >> rs2 ;     
                `SLT   : out <= ($signed(rs1) < $signed(rs2)) ? 32'b1 : 32'b0;     
                `SLTU  : out <= (rs1 < rs2)  ? 32'b1 : 32'b0;     
                `SRA   : out <= rs1 >>> rs2 ;  
                default :   out <= 0;
             endcase
        end
            
    end
endmodule
