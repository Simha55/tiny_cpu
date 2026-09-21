
module tiny_cpu (
    input  wire       clk,
    input  wire       reset,

    output wire [3:0] pc_out,
    output wire [7:0] a_out,
    output wire [7:0] b_out,
    output wire [10:0] ir_out,
    output wire       halted
);

    // -------------------------------
    // Internal control signals
    // -------------------------------

    wire ir_write;
    wire pc_inc;
    wire pc_load;

    wire reg_a_write;
    wire reg_b_write;

    wire a_sel;
    wire [1:0] alu_op;

    // -------------------------------
    // Internal datapath signals
    // -------------------------------

    wire [10:0] instruction;
    wire [2:0] opcode;
    wire [7:0] operand;

    wire [7:0] alu_result;
    wire [7:0] a_data_in;

    wire a_zero;

    // -------------------------------
    // Decode instruction fields
    // -------------------------------

    assign opcode  = ir_out[10:8];
    assign operand = ir_out[7:0];

    // Detect whether A is zero.
    assign a_zero = (a_out == 8'd0);

    // Select the value to write into A:
    // a_sel = 0 -> immediate operand
    // a_sel = 1 -> ALU result
    assign a_data_in = a_sel ? alu_result : operand;

    // -------------------------------
    // 1. Program Counter
    // -------------------------------

    program_counter pc (
        .clk(clk),
        .reset(reset),
        .pc_inc(pc_inc),
        .pc_load(pc_load),
        .load_addr(operand[3:0]),
        .pc_out(pc_out)
    );

    // -------------------------------
    // 2. Instruction Memory
    // -------------------------------

    instruction_memory imem (
        .address(pc_out),
        .instruction(instruction)
    );

    // -------------------------------
    // 3. Instruction Register
    // -------------------------------

    instruction_register ir (
        .clk(clk),
        .reset(reset),
        .ir_write(ir_write),
        .instruction_in(instruction),
        .instruction_out(ir_out)
    );

    // -------------------------------
    // 4. A Register
    // -------------------------------

    register8 reg_a (
        .clk(clk),
        .reset(reset),
        .write_enable(reg_a_write),
        .data_in(a_data_in),
        .data_out(a_out)
    );

    // -------------------------------
    // 5. B Register
    // -------------------------------

    register8 reg_b (
        .clk(clk),
        .reset(reset),
        .write_enable(reg_b_write),
        .data_in(operand),
        .data_out(b_out)
    );

    // -------------------------------
    // 6. ALU
    // -------------------------------

    alu cpu_alu (
        .A(a_out),
        .B(b_out),
        .alu_op(alu_op),
        .result(alu_result)
    );

    // -------------------------------
    // 7. Control Unit
    // -------------------------------

    control_unit controller (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .a_zero(a_zero),

        .ir_write(ir_write),
        .pc_inc(pc_inc),
        .pc_load(pc_load),

        .reg_a_write(reg_a_write),
        .reg_b_write(reg_b_write),

        .a_sel(a_sel),
        .alu_op(alu_op),

        .halted(halted)
    );

endmodule