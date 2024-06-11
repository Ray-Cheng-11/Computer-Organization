//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/24/2024 07:14:12 AM
// Design Name: 
// Module Name: msb_bit_alu
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
`timescale 1ns / 1ps
// <111550012>

/* checkout FIGURE C.5.10 (Bottom) */
/* [Prerequisite] complete bit_alu.v */
module msb_bit_alu (
    input        a,          // 1 bit, a
    input        b,          // 1 bit, b
    input        less,       // 1 bit, Less
    input        a_invert,   // 1 bit, Ainvert
    input        b_invert,   // 1 bit, Binvert
    input        carry_in,   // 1 bit, CarryIn
    input  [1:0] operation,  // 2 bit, Operation
    output reg   result,     // 1 bit, Result (Must it be a reg?)
    output       set,        // 1 bit, Set
    output       overflow    // 1 bit, Overflow
);

    /* Try to implement the most significant bit ALU by yourself! */
     /* [step 1] invert input on demand */
    wire ai, bi;  
    assign ai = a_invert ? ~a : a;  
    assign bi = b_invert ? ~b : b;

    /* [step 2] implement a 1-bit full adder */
    wire sum;
    wire carry_out; 
    assign carry_out = (ai & bi) | (carry_in & (ai ^ bi)) ;
    assign sum       = (ai ^ bi )^ carry_in;
    
    assign overflow  = ((operation == 2'b10)||(operation == 2'b11))? (carry_in != carry_out):'b0; //CarryIn of MSB != CarryOut of MSB
    assign overflow_count =  carry_in ^ carry_out;
    assign set       = (overflow_count) ^ sum;
    /* [step 3] using a mux to assign result */
       always @(*) begin  // `*` auto captures sensitivity ports, now it's combinational logic
            case (operation)  // `case` is similar to `switch` in C
                2'b00:   result <= ai & bi;  // AND
                2'b01:   result <= ai | bi;  // OR
                2'b10:   result <= sum;  // ADD
                2'b11:   result <= less;  // SLT
                default: result <= 0;  // should not happened
            endcase
        end
    // assign result = operation[1] ? (operation[0] ? less : sum) : (operation[0] ? (ai | bi) : (ai & bi));
endmodule
