`timescale 1ns / 1ps

`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: signal != value"); \
            $finish; \
        end

`include "alu_ops.vh"

module alu_top;
    // Inputs
    reg reset;
    reg clk;
    reg [31:0] rs1;
    reg [31:0] rs2;
    reg [4:0] op;
    wire carry;
    wire overflow;
    wire zero;
    reg cspr[2:0];
    // Outputs
    wire [31:0] out;
    
    alu uut (
        .reset(reset),
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .result(out),
        .carry(carry),
        .overflow(overflow),
        .zero(zero),
        .op(op)
    );
    
    assign cspr[2] = carry;
    assign cspr[1] = overflow;
    assign cspr[0] = zero;
    
    // Clock generation
    always #5 clk = ~clk; // 100 MHz clock
    
    initial begin
        // Initialize Inputs
        reset = 0;
        clk = 0;
        rs1 = 0;
        rs2 = 0;
        op = 0;

        // Wait for global reset
        #10;
        assert(out == 0);
        assert(zero == 1);
        assert(overflow == 0);
        assert(carry == 0);
        
        reset = 1;
        rs1 = 32'hF0F0F0F1;
        rs2 = 32'h0F0F0F0F;
        op = `AND;
        #10;
        assert(out == (32'hF0F0F0F1 & 32'h0F0F0F0F)) else $fatal("AND Test Failed: %h & %h != %h", rs1, rs2, out);
        assert(zero == 0) else $fatal("AND zero flag Test Failed: %h & %h != %h and zf = %b", rs1, rs2, out, zero);
        assert(overflow == 0) else $fatal("AND overflow flag Test Failed: %h & %h != %h and of = %b", rs1, rs2, out, overflow);
        assert(carry == 0) else $fatal("AND carry flag Test Failed: %h & %h != %h and cf = %b", rs1, rs2, out, carry);

        rs1 = 32'hF0F0F0F1;
        rs2 = 32'h0F0F0F0F;
        op = `OR;
        #10;
        assert(out == (32'hF0F0F0F1 | 32'h0F0F0F0F)) else $fatal("OR Test Failed: %h & %h != %h", rs1, rs2, out);
        assert(zero == 0) else $fatal("OR zero flag Test Failed: %h & %h != %h and zf = %b", rs1, rs2, out, zero);
        assert(overflow == 0) else $fatal("OR overflow flag Test Failed: %h & %h != %h and of = %b", rs1, rs2, out, overflow);
        assert(carry == 0) else $fatal("OR carry flag Test Failed: %h & %h != %h and cf = %b", rs1, rs2, out, carry);
        
        // ADD
        rs1 = 32'h00F0F0FE;
        rs2 = 32'h0F0F0F0F;
        op = `ADD;
        #10;
        assert(out == (32'h00F0F0FE + 32'h0F0F0F0F)) else $fatal("ADD Test Failed: %d & %d != %d", rs1, rs2, out);
        assert(zero == 0) else $fatal("ADD zero flag Test Failed: %h & %h != %h and zf = %b", rs1, rs2, out, zero);
        assert(overflow == 0) else $fatal("ADD overflow flag Test Failed: %h & %h != %h and of = %b", rs1, rs2, out, overflow);
        assert(carry == 0) else $fatal("ADD carry flag Test Failed: %h & %h != %h and cf = %b", rs1, rs2, out, carry);
        
        // ADD with carry and overflow.
        rs1 = 32'h80000000;
        rs2 = 32'hFF0F0F0F;
        op = `ADD;
        #10;
        assert(out == (32'h80000000 + 32'hFF0F0F0F)) else $fatal("ADD1 Test Failed: %d & %d != %d", rs1, rs2, out);
        assert(zero == 0) else $fatal("ADD1 zero flag Test Failed: %h & %h != %h and zf = %b", rs1, rs2, out, zero);
        assert(overflow == 1) else $fatal("ADD1 overflow flag Test Failed: %h & %h != %h and of = %b", rs1, rs2, out, overflow);
        assert(carry == 1) else $fatal("ADD1 carry flag Test Failed: %h & %h != %h and cf = %b", rs1, rs2, out, carry);
        
        // SUB
        rs1 = 10;
        rs2 = 5;
        op = `SUB;
        #10;
        assert(out == (10 - 5)) else $fatal("SUB Test Failed: %d & %d != %d", rs1, rs2, out);
        assert(zero == 0) else $fatal("SUB zero flag Test Failed: %h & %h != %h and zf = %b", rs1, rs2, out, zero);
        assert(overflow == 0) else $fatal("SUB overflow flag Test Failed: %h & %h != %h and of = %b", rs1, rs2, out, overflow);
        assert(carry == 0) else $fatal("SUB carry flag Test Failed: %h & %h != %h and cf = %b", rs1, rs2, out, carry);
        
        // SUB with borrow and overflow.
        rs1 = 32'h80000000;
        rs2 = 32'h7F0F0F0F;
        op = `SUB;
        #10;
        assert(out == (32'h80000000 - 32'h7F0F0F0F)) else $fatal("SUB Test Failed: %d & %d != %d", rs1, rs2, out);
        assert(zero == 0) else $fatal("SUB zero flag Test Failed: %h & %h != %h and zf = %b", rs1, rs2, out, zero);
        assert(overflow == 1) else $fatal("SUB overflow flag Test Failed: %d & %d != %d and of = %d", rs1, rs2, 32'h80000000 - 32'h7F0F0F0F, overflow);
        assert(carry == 0) else $fatal("SUB carry flag Test Failed: %h & %h != %h and cf = %b", rs1, rs2, out, carry);
        
        // Test XOR
        rs1 = 32'hF0F0F0F0;
        rs2 = 32'h0F0F0F0F;
        op = `XOR;
        #10;
        assert(out == (32'hF0F0F0F0 ^ 32'h0F0F0F0F)) else $fatal("XOR Test Failed: %h ^ %h != %h", rs1, rs2, out);

         // Test SLL
         rs1 = 32'd1;
         rs2 = 32'd4;
         op = `SLL;
         #10;
         assert(out == (32'd1 << 32'd4)) else $fatal("SLL Test Failed: %d << %d != %d", rs1, rs2, out);

        // Test SRL
        rs1 = 32'hF0F0F0F0;
        rs2 = 32'd4;
        op = `SRL;
        #10;
        assert(out == (32'hF0F0F0F0 >> 32'd4)) else $fatal("SRL Test Failed: %h >> %d != %h", rs1, rs2, out);

        // Test SLT
        rs1 = 32'd10;
        rs2 = 32'd15;
        op = `SLT;
        #10;
        assert(out == 32'b1) else $fatal("SLT Test Failed1: %d < %d != %d", $signed(rs1), $signed(rs2), out);
        
        // Test SLT
        rs1 = -32'd10;
        rs2 = -32'd15;
        op = `SLT;
        #10;
        assert(out == 32'b0) else $fatal("SLT Test Failed2: %d < %d != %d", $signed(rs1), $signed(rs2), out);
        
        // Test SLT
        rs1 = -32'sd10;  // Signed negative number
        rs2 = 32'sd5;    // Signed positive number
        op = `SLT;
        #10;
        assert(out == 32'b1) else $fatal("SLT Test Failed3: %d < %d != %b", $signed(rs1), $signed(rs2), out);


        // Test SLTU
        rs1 = 32'hF0000000;
        rs2 = 32'h0F000000;
        op = `SLTU;
        #10;
        assert(out == (32'hF0000000 < 32'h0F000000)) else $fatal("SLTU Test Failed: %h < %h != %d", rs1, rs2, out);

        // Test SRA
        rs1 = 32'hF0F0F0F0;
        rs2 = 32'd4;
        op = `SRA;
        #10;
        assert(out == (32'hF0F0F0F0 >>> 32'd4)) else $fatal("SRA Test Failed: %h >>> %d != %h", rs1, rs2, out);

        // Test Reset
        reset = 0;
        #10;
        assert(out == 0) else $fatal("Reset Test Failed: out != 0");
        $stop;
    end
endmodule
