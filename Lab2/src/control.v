`timescale 1ns / 1ps
// 111550012

/** [Reading] 4.4 p.318-321
 * "Designing the Main Control Unit"
 */
/** [Prerequisite] alu_control.v
 * This module is the Control unit in FIGURE 4.17
 * You can implement it by any style you want.
 */

/* checkout FIGURE 4.16/18 to understand each definition of control signals */
module control (
    input  [5:0] opcode,      // the opcode field of a instruction is [?:?]
    output       reg_dst,     // select register destination: rt(0), rd(1)
    output       alu_src,     // select 2nd operand of ALU: rt(0), sign-extended(1)
    output       jump,        // this is a jump instruction or not
    output       mem_to_reg,  // select data write to register: ALU(0), memory(1)
    output       reg_write,   // enable write to register file
    output       mem_read,    // enable read form data memory
    output       mem_write,   // enable write to data memory
    output       branch,      // this is a branch instruction or not (work with alu.zero)
    output       lui_op, // this is a lui instruction or not
    output       ori_op, // this is a ori instruction or not
    output [1:0] alu_op       // ALUOp passed to ALU Control unit
);

    /* implement "combinational" logic satisfying requirements in FIGURE 4.18 */
    /* You can check the "Green Card" to get the opcode/funct for each instruction. */
    wire lw_op;
    assign lui_op = (opcode == 6'b001111);
    assign ori_op = (opcode == 6'b001101);
    assign lw_op = (opcode == 6'b100011) || lui_op || ori_op;
    assign reg_dst = (opcode == 6'b000000);
    assign branch = (opcode == 6'b000100);
    assign mem_read = lw_op;
    assign mem_to_reg = lw_op;
    assign alu_op[1] = (opcode == 6'b000000);
    assign alu_op[0] = (opcode == 6'b000100);
    assign mem_write = (opcode == 6'b101011);
    assign alu_src = (lw_op || (opcode == 6'b101011));
    assign reg_write = ((opcode == 6'b000000) || lw_op);
    assign jump = (opcode == 6'b000010);


endmodule
