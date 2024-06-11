`timescale 1ns / 1ps
// <your student id>

/** [Reading] 4.7 p.363-371
 * Understand when and how to forward
 */

/* checkout FIGURE 4.55 for definition of mux control signals */
/* checkout FIGURE 4.56/60 for how this unit should be connected */
module forwarding (
    input      [4:0] ID_EX_rs,          // inputs are pipeline registers relate to forwarding
    input      [4:0] ID_EX_rt,
    input            EX_MEM_reg_write,
    input      [4:0] EX_MEM_rd,
    input            MEM_WB_reg_write,
    input      [4:0] MEM_WB_rd,
    output     [1:0] forward_A,         // ALU operand is from: 00:ID/EX, 10: EX/MEM, 01:MEM/WB
    output     [1:0] forward_B
);
    /** [step 1] Forwarding
     * 1. EX hazard (p.366)
     * 2. MEM hazard (p.369)
     * 3. Solve potential data hazards between:
          the result of the instruction in the WB stage,
          the result of the instruction in the MEM stage,
          and the source operand of the instruction in the ALU stage.
          Hint: Be careful that the textbook is wrong here!
          Hint: Which of EX & MEM hazard has higher priority?
     */
    wire EX_MEM_RS;
    wire EX_MEM_RT;
    wire MEM_WB_RS;
    wire MEM_WB_RT;
    assign EX_MEM_RS = (EX_MEM_reg_write && (EX_MEM_rd != 0)) && (EX_MEM_rd == ID_EX_rs);
    assign EX_MEM_RT = (EX_MEM_reg_write && (EX_MEM_rd != 0)) && (EX_MEM_rd == ID_EX_rt);

    assign MEM_WB_RS = (MEM_WB_reg_write && (MEM_WB_rd != 0)) && (MEM_WB_rd == ID_EX_rs);
    assign MEM_WB_RT = (MEM_WB_reg_write && (MEM_WB_rd != 0)) && (MEM_WB_rd == ID_EX_rt);

    assign forward_A = EX_MEM_RS ? 2'b00 : (MEM_WB_RS ? 2'b01 : 2'b10); //EX_MEM_RS 00, MEM_WB_RS 01, origin 10
    assign forward_B = EX_MEM_RT ? 2'b00 : (MEM_WB_RT ? 2'b01 : 2'b10); //EX_MEM_RT 00, MEM_WB_RT 01, origin 10


endmodule
