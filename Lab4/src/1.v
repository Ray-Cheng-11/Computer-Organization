`timescale 1ns / 1ps
// <your student id>

/** [Prerequisite] pipelined (Lab 3), forwarding, hazard_detection
 * This module is the pipelined MIPS processor "similar to" FIGURE 4.60 (control hazard is not solved).
 * You can implement it by any style you want, as long as it passes testbench.
 */

module pipelined #(
    parameter integer TEXT_BYTES = 1024,        // size in bytes of instruction memory
    parameter integer TEXT_START = 'h00400000,  // start address of instruction memory
    parameter integer DATA_BYTES = 1024,        // size in bytes of data memory
    parameter integer DATA_START = 'h10008000   // start address of data memory
) (
    input clk,  // clock
    input rstn  // negative reset
);

    /** [step 0] Copy from Lab 3
     * You should modify your pipelined processor from Lab 3, so copy to here first.
     */
     /* Instruction Memory */
    wire [31:0] instr_mem_address, instr_mem_instr;
    instr_mem #(
        .BYTES(TEXT_BYTES),
        .START(TEXT_START)
    ) instr_mem (
        .address(instr_mem_address),
        .instr  (instr_mem_instr)
    );

    /* Register Rile */
    wire [4:0] reg_file_read_reg_1, reg_file_read_reg_2, reg_file_write_reg;
    wire reg_file_reg_write;
    wire [31:0] reg_file_write_data, reg_file_read_data_1, reg_file_read_data_2;
    reg_file reg_file (
        .clk        (~clk),                 // only write when negative edge
        .rstn       (rstn),
        .read_reg_1 (reg_file_read_reg_1),
        .read_reg_2 (reg_file_read_reg_2),
        .reg_write  (reg_file_reg_write),
        .write_reg  (reg_file_write_reg),
        .write_data (reg_file_write_data),
        .read_data_1(reg_file_read_data_1),
        .read_data_2(reg_file_read_data_2)
    );

    /* ALU */
    wire [31:0] alu_a, alu_b, alu_result;
    wire [3:0] alu_ALU_ctl;
    wire alu_zero, alu_overflow;
    alu alu (
        .a       (alu_a),
        .b       (alu_b),
        .ALU_ctl (alu_ALU_ctl),
        .result  (alu_result),
        .zero    (alu_zero),
        .overflow(alu_overflow)
    );

    /* Data Memory */
    wire data_mem_mem_read, data_mem_mem_write;
    wire [31:0] data_mem_address, data_mem_write_data, data_mem_read_data;
    data_mem #(
        .BYTES(DATA_BYTES),
        .START(DATA_START)
    ) data_mem (
        .clk       (~clk),                 // only write when negative edge
        .mem_read  (data_mem_mem_read),
        .mem_write (data_mem_mem_write),
        .address   (data_mem_address),
        .write_data(data_mem_write_data),
        .read_data (data_mem_read_data)
    );

    /* ALU Control */
    wire [1:0] alu_control_alu_op;
    wire [5:0] alu_control_funct;
    wire [3:0] alu_control_operation;
    alu_control alu_control (
        .alu_op   (alu_control_alu_op),
        .funct    (alu_control_funct),
        .operation(alu_control_operation)
    );

    /* (Main) Control */
    wire [5:0] control_opcode;
    // Execution/address calculation stage control lines
    wire control_reg_dst, control_alu_src;
    wire [1:0] control_alu_op, control_branch_type;
    // Memory access stage control lines
    wire control_branch, control_mem_read, control_mem_write;
    // Wire-back stage control lines
    wire control_reg_write, control_mem_to_reg, control_addi_op;
    wire control_jump;
    control control (
        .opcode    (control_opcode),
        .reg_dst   (control_reg_dst),
        .alu_src   (control_alu_src),
        .mem_to_reg(control_mem_to_reg),
        .reg_write (control_reg_write),
        .mem_read  (control_mem_read),
        .mem_write (control_mem_write),
        .branch    (control_branch),
        .branch_type (control_branch_type), 
        .alu_op      (control_alu_op),
        .addi_op     (control_addi_op)
    );


    /** [step 1] Instruction fetch (IF)
     * 1. We need a register to store PC (acts like pipeline register).
     * 2. Wire pc to instruction memory.
     * 3. Implement an adder to calculate PC+4. (combinational)
     *    Hint: use "+" operator.
     * 4. Update IF/ID pipeline registers, and reset them @(negedge rstn)
     *    a. fetched instruction
     *    b. PC+4
     *    Hint: What else should be done when reset?
     *    Hint: Update of PC can be handle later in MEM stage.
     */
    // 1.
    reg [31:0] pc;  // DO NOT change this line
    // 2.
    assign instr_mem_address = pc;
    //3.
    wire [31:0] pc_4 = pc + 4;
    // 4.
    localparam [31:0] NOP = 32'b0000_0000_0000_0000_0000_0000_0001_0011; // addi x0, x0, 0;

    reg [31:0] IF_ID_instr, IF_ID_pc_4;
    reg [4:0]IF_ID_rs, IF_ID_rt;
    always @(posedge clk)begin
        if (rstn) begin
            if (~IF_ID_write||stall_1||stall_2||stall_3) begin
                IF_ID_instr <= IF_ID_instr;  // a.
                IF_ID_pc_4  <= IF_ID_pc_4;  // b.
            end
            else begin
                IF_ID_instr <= instr_mem_instr;  // a.
                IF_ID_pc_4 <= pc_4;  // b.
            end
        end
        
    end
    always@(negedge rstn)begin
        IF_ID_instr <= 0;
        IF_ID_pc_4  <= 0;
    end
    /** [step 2] Instruction decode and register file read (ID)
     * From top to down in FIGURE 4.51: (instr. refers to the instruction from IF/ID)
     * 1. Generate control signals of the instr. (as Lab 2)
     * 2. Read desired registers (from register file) in the instr.
     * 3. Calculate sign-extended immediate from the instr.
     * 4. Update ID/EX pipeline registers, and reset them @(negedge rstn)
     *    a. Control signals (WB, MEM, EX)
     *    b. ??? (something from IF/ID)
     *    c. Data read from register file
     *    d. Sign-extended immediate
     *    e. ??? & ??? (WB stage needs to know which reg to write)
     */
    // 1.
    assign control_opcode = IF_ID_instr[31:26];
    // 2.
    assign reg_file_read_reg_1 = IF_ID_instr[25:21];
    assign reg_file_read_reg_2 = IF_ID_instr[20:16];
    // 3.
    wire [31:0] sign_ext_imm; // sign-extended immediate
    assign sign_ext_imm = {{16{IF_ID_instr[15]}}, IF_ID_instr[15:0]};
    //addi
    wire [15:0] immediate = IF_ID_instr[15:0];
    wire[1:0]forward_1, forward_2;
    forwarding forwarding1 (
        .ID_EX_rs        (IF_ID_instr[25:21]),
        .ID_EX_rt        (IF_ID_instr[20:16]),
        .EX_MEM_reg_write(EX_MEM_reg_write),
        .EX_MEM_rd       (EX_MEM_write_reg),
        .MEM_WB_reg_write(MEM_WB_reg_write),
        .MEM_WB_rd       (MEM_WB_write_reg),
        .forward_A       (forward_1),
        .forward_B       (forward_2)
    );
    wire [31:0]beq1, beq2;
    assign beq1 = (forward_1 == 2'b00) ? EX_MEM_alu_result : (forward_1 == 2'b01) ? reg_file_write_data : reg_file_read_data_1;
    assign beq2 = (forward_2 == 2'b00) ? EX_MEM_alu_result : (forward_2 == 2'b01) ? reg_file_write_data : reg_file_read_data_2 ;
    wire [31:0] branch_target_addr; // calculated branch target address
    assign branch_target_addr = IF_ID_pc_4 + (sign_ext_imm << 2 );
    wire branch_taken; // decides whether to branch or not
    assign branch_taken = control_branch & (beq1==beq2); // branch if control signal is 1 and ALU zero is 0
    // 4.
    reg ID_EX_reg_dst, ID_EX_alu_src, ID_EX_mem_to_reg, ID_EX_reg_write, ID_EX_mem_read, ID_EX_mem_write, ID_EX_branch;
    reg [31:0]ID_EX_immediate;
    reg ID_EX_addi_op;
    reg [1:0]  ID_EX_alu_op, ID_EX_branch_type;
    reg [31:0] ID_EX_instr,ID_EX_pc_4 ;
    reg [31:0] ID_EX_sign_ext_imm; // sign-extended immediate
    reg [31:0] ID_EX_read_data_1, ID_EX_read_data_2; // data read from register file
    reg [4:0] ID_EX_rs, ID_EX_rt; // register number
    always @(posedge clk)
        if(stall||stall_1||stall_2||stall_3)begin
                ID_EX_reg_dst       <= 0;
                ID_EX_alu_src       <= 0;
                ID_EX_mem_to_reg    <= 0;
                ID_EX_reg_write     <= 0;
                ID_EX_mem_read      <= 0;
                ID_EX_mem_write     <= 0;
                ID_EX_branch        <= 0;
                ID_EX_branch_type   <= 0;
                ID_EX_alu_op        <= 0;
                ID_EX_addi_op       <= 0;
                ID_EX_instr         <= 0;
                ID_EX_immediate     <= 0;
                ID_EX_sign_ext_imm  <= 0;
                ID_EX_read_data_1   <= 0;
                ID_EX_read_data_2   <= 0;
                ID_EX_rs <= 0;
                ID_EX_rt <= 0;
            end
            else begin
                ID_EX_reg_dst       <= control_reg_dst;
                ID_EX_alu_src       <= control_alu_src;
                ID_EX_mem_to_reg    <= control_mem_to_reg;
                ID_EX_reg_write     <= control_reg_write;
                ID_EX_mem_read      <= control_mem_read;
                ID_EX_mem_write     <= control_mem_write;
                ID_EX_branch        <= control_branch;
                ID_EX_alu_op        <= control_alu_op;
                ID_EX_addi_op       <= control_addi_op;
                ID_EX_branch_type   <= control_branch_type;
                ID_EX_instr         <= IF_ID_instr;
                ID_EX_immediate     <= immediate;
                ID_EX_sign_ext_imm  <= sign_ext_imm;
                ID_EX_read_data_1   <= reg_file_read_data_1;
                ID_EX_read_data_2   <= reg_file_read_data_2;
                ID_EX_rs            <= reg_file_read_reg_1;
                ID_EX_rt            <= reg_file_read_reg_2;
            end
        always@(negedge rstn) begin
            ID_EX_reg_dst       <= 0;
            ID_EX_alu_src       <= 0;
            ID_EX_mem_to_reg    <= 0;
            ID_EX_reg_write     <= 0;
            ID_EX_mem_read      <= 0;
            ID_EX_mem_write     <= 0;
            ID_EX_branch        <= 0;
            ID_EX_branch_type   <= 0;
            ID_EX_alu_op        <= 0;
            ID_EX_addi_op       <= 0;
            ID_EX_instr         <= 0;
            ID_EX_pc_4          <= 0;
            ID_EX_immediate     <= 0;
            ID_EX_sign_ext_imm  <= 0;
            ID_EX_read_data_1   <= 0;
            ID_EX_read_data_2   <= 0;
            ID_EX_rs <= 0;
            ID_EX_rt <= 0;
        end

    /** [step 3] Execute or address calculation (EX)
     * From top to down in FIGURE 4.51
     * 1. Calculate branch target address from sign-extended immediate.
     * 2. Select correct operands of ALU like in Lab 2.
     * 3. Wire control signals to ALU control & ALU like in Lab 2.
     * 4. Select correct register to write.
     * 5. Update EX/MEM pipeline registers, and reset them @(negedge rstn)
     *    a. Control signals (WB, MEM)
     *    b. Branch target address
     *    c. ??? (What information does MEM stage need to determine whether to branch?)
     *    d. ALU result
     *    e. ??? (What information does MEM stage need when executing Store?)
     *    f. ??? (WB stage needs to know which reg to write)
     */
    // 1.
    

    // 2.
    reg branch_condition;
    always @(posedge clk)begin
        case(ID_EX_branch_type)
            2'b00: branch_condition = (reg_file_read_data_1 == reg_file_read_data_2);
            2'b01: branch_condition = (reg_file_read_data_1 != reg_file_read_data_2);
            2'b10: branch_condition = (reg_file_read_data_1 >= reg_file_read_data_2);
            2'b11: branch_condition = (reg_file_read_data_1 >  reg_file_read_data_2);
        endcase
    end
    // 3.
    assign alu_control_alu_op = ID_EX_alu_op;
    assign alu_control_funct = ID_EX_instr[5:0];
    assign alu_ALU_ctl = alu_control_operation;
    // 4.
    wire [4:0] ID_EX_write_reg; // register to write
    assign ID_EX_write_reg = (ID_EX_reg_dst) ? ID_EX_instr[15:11] : ID_EX_instr[20:16];
    // 5.
    reg EX_MEM_mem_write, EX_MEM_mem_read, EX_MEM_mem_to_reg, EX_MEM_branch,EX_MEM_reg_write;
    reg [1:0] EX_MEM_branch_type;
    reg[31:0] EX_MEM_immediate; // control signals
    reg EX_MEM_addi_op ;
    reg EX_MEM_alu_zero; // zero flag from ALU
    reg [31:0] EX_MEM_alu_result; // ALU result
    reg [4:0] EX_MEM_write_reg; // register to write
    reg [31:0] EX_MEM_read_data_1 , EX_MEM_read_data_2; // data read from register file
    reg [31:0] EX_MEM_branch_target_addr; // branch target address
    reg EX_MEM_branch_condition;
    always @(posedge clk)begin
        if (rstn) begin
            EX_MEM_mem_to_reg           <= ID_EX_mem_to_reg;
            EX_MEM_reg_write            <= ID_EX_reg_write;
            EX_MEM_mem_read             <= ID_EX_mem_read;
            EX_MEM_mem_write            <= ID_EX_mem_write;
            EX_MEM_branch               <= ID_EX_branch;
            EX_MEM_branch_type          <= ID_EX_branch_type;
            EX_MEM_addi_op              <= ID_EX_addi_op;
            EX_MEM_alu_zero             <= alu_zero;
            EX_MEM_alu_result           <= alu_result;
            EX_MEM_immediate            <= ID_EX_immediate;
            EX_MEM_write_reg            <= ID_EX_write_reg;
            EX_MEM_read_data_1          <= ID_EX_read_data_1;
            EX_MEM_read_data_2          <= ID_EX_read_data_2;
            EX_MEM_branch_target_addr   <= branch_target_addr;
            EX_MEM_branch_condition     <= branch_condition;
        end
        else if (~ rstn || (EX_MEM_branch && EX_MEM_branch_condition))begin
            EX_MEM_mem_to_reg           <= 0;
            EX_MEM_reg_write            <= 0;
            EX_MEM_mem_read             <= 0;
            EX_MEM_mem_write            <= 0;
            EX_MEM_branch               <= 0;
            EX_MEM_branch_type          <= 0;
            EX_MEM_addi_op              <= 0;
            EX_MEM_alu_zero             <= 0;
            EX_MEM_alu_result           <= 0;
            EX_MEM_immediate            <= 0;
            EX_MEM_write_reg            <= 0;
            EX_MEM_read_data_1          <= 0;
            EX_MEM_read_data_2          <= 0;
            EX_MEM_branch_target_addr   <= 0;
            EX_MEM_branch_condition     <= 0;
        end
    end

    /** [step 4] Memory access (MEM)
     * From top to down in FIGURE 4.51
     * 1. Decide whether to branch or not.
     * 2. Wire address & data to write
     * 3. Wire control signal of read/write
     * 4. Update MEM/WB pipeline registers, and reset them @(negedge rstn)
     *    a. Control signals (WB)
     *    b. ???
     *    c. ???
     *    d. ???
     * 5. Update PC.
     */
    // 1.
    
    // 2.
    assign data_mem_address =  EX_MEM_alu_result ;
    assign data_mem_write_data = EX_MEM_read_data_2 ;
    // 3.
    assign data_mem_mem_write = EX_MEM_mem_write ;
    assign data_mem_mem_read = EX_MEM_mem_read  ;
    // 4.
    reg MEM_WB_mem_to_reg, MEM_WB_reg_write,MEM_WB_addi_op; 
    reg [31:0] MEM_WB_immediate; // control signals
    reg [4:0]  MEM_WB_write_reg; // register to write
    reg [31:0] MEM_WB_alu_result; // ALU result
    reg [31:0] MEM_WB_read_data_1; // data read from register file
    reg [31:0] MEM_WB_mem_read_data; // data read from memory
    always @(posedge clk)
        if (rstn) begin
            MEM_WB_mem_to_reg      <= EX_MEM_mem_to_reg;
            MEM_WB_reg_write       <= EX_MEM_reg_write;
            MEM_WB_write_reg       <= EX_MEM_write_reg;
            MEM_WB_addi_op         <= EX_MEM_addi_op;
            MEM_WB_immediate       <= EX_MEM_immediate;
            MEM_WB_mem_read_data   <= data_mem_read_data;
            MEM_WB_read_data_1     <= EX_MEM_read_data_1;
            MEM_WB_alu_result      <= EX_MEM_alu_result;
        end
    always @(negedge rstn) begin
            MEM_WB_mem_to_reg    <= 0;
            MEM_WB_reg_write     <= 0;
            MEM_WB_write_reg     <= 0;
            MEM_WB_addi_op       <= 0;
            MEM_WB_immediate     <= 0;
            MEM_WB_mem_read_data <= 0;
            MEM_WB_read_data_1   <= 0;
            MEM_WB_alu_result    <= 0;

    end
    // 5.
    reg [31:0] pc_next;
    /*wire branchtype_result;
    assign branchtype_result = (EX_MEM_branch_type == 2'b00) ? EX_MEM_alu_zero : (EX_MEM_branch_type == 2'b01) ? ~EX_MEM_alu_zero : (EX_MEM_branch_type == 2'b10) ? ~EX_MEM_alu_result[31] : ~(EX_MEM_alu_zero | EX_MEM_alu_result[31]);
    */
    reg [31:0] display;
    always @(posedge clk)begin
        //display <= alu_a;
        if (rstn) begin
            if (~pc_write||stall_1||stall_2||stall_3)
                pc <= pc;
            else begin
                if (branch_taken) begin
                    pc <= branch_target_addr;
                end
            else 
                pc <= pc_4;
            end
        end
    end
    always @(negedge rstn)begin
            pc <= 32'h00400000;   
    end
    /** [step 5] Write-back (WB)
     * From top to down in FIGURE 4.51
     * 1. Wire RegWrite of register file.
     * 2. Select the data to write into register file.
     * 3. Select which register to write.
     */

    // 1.
    assign reg_file_reg_write = MEM_WB_reg_write; // control signal for register file write
    // 2.
    assign reg_file_write_data = (MEM_WB_addi_op)?(MEM_WB_read_data_1  + MEM_WB_immediate):(MEM_WB_mem_to_reg) ? MEM_WB_mem_read_data : MEM_WB_alu_result ;
    // 3.
    assign reg_file_write_reg = MEM_WB_write_reg;


    /** [step 2] Connect Forwarding unit
     * 1. add `ID_EX_rs` into ID/EX stage registers
     * 2. Use a mux to select correct ALU operands according to forward_A/B
     *    Hint don't forget that alu_b might be sign-extended immediate!
     */
    wire [1:0] forward_A, forward_B;
    forwarding forwarding (
        .ID_EX_rs        (ID_EX_rs),
        .ID_EX_rt        (ID_EX_rt),
        .EX_MEM_reg_write(EX_MEM_reg_write),
        .EX_MEM_rd       (EX_MEM_write_reg),
        .MEM_WB_reg_write(MEM_WB_reg_write),
        .MEM_WB_rd       (MEM_WB_write_reg),
        .forward_A       (forward_A),
        .forward_B       (forward_B)
    );
    assign alu_a = (forward_A == 2'b00) ? EX_MEM_alu_result : (forward_A == 2'b01) ? reg_file_write_data : ID_EX_read_data_1;
    assign alu_b = (forward_B == 2'b00) ? EX_MEM_alu_result : (forward_B == 2'b01) ? reg_file_write_data : (ID_EX_alu_src) ? ID_EX_sign_ext_imm : ID_EX_read_data_2 ;
    /** [step 4] Connect Hazard Detection unit
     * 1. use `pc_write` when updating PC
     * 2. use `IF_ID_write` when updating IF/ID stage registers
     * 3. use `stall` when updating ID/EX stage registers
     */
    hazard_detection hazard_detection (
        .ID_EX_mem_read(ID_EX_mem_read),
        .ID_EX_rt      (ID_EX_rt),
        .IF_ID_rs      (reg_file_read_reg_1),
        .IF_ID_rt      (reg_file_read_reg_2),
        .pc_write      (pc_write),            // implicitly declared
        .IF_ID_write   (IF_ID_write),         // implicitly declared
        .stall         (stall)                // implicitly declared
    );

    /** [step 5] Control Hazard
     * This is the most difficult part since the textbook does not provide enough information.
     * By reading p.377-379 "Reducing the Delay of Branches",
     * we can disassemble this into the following steps:
     * 1. Move branch target address calculation & taken or not from EX to ID
     * 2. Move branch decision from MEM to ID
     * 3. Add forwarding for registers used in branch decision from EX/MEM
     * 4. Add stalling:
          branch read registers right after an ALU instruction writes it -> 1 stall
          branch read registers right after a load instruction writes it -> 2 stalls
    */
    wire stall_1;
    assign stall_1 = (ID_EX_reg_write && control_branch && ((ID_EX_write_reg == IF_ID_rs) || (ID_EX_write_reg == IF_ID_rt))) ? 1'b1:1'b0;
    wire stall_2;
    assign stall_2 = (control_mem_read && control_branch && ((EX_MEM_write_reg == IF_ID_rs) || (EX_MEM_write_reg == IF_ID_rt))) ? 1'b1:1'b0;
    wire stall_3;
    assign stall_3 = (ID_EX_mem_read && control_branch && ((ID_EX_write_reg == IF_ID_rs) || (ID_EX_write_reg == IF_ID_rt))) ? 1'b1:1'b0;

endmodule  // pipelined
