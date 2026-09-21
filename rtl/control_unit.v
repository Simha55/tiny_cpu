
module control_unit (
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] opcode,
    input  wire       a_zero,

    output reg        ir_write,
    output reg        pc_inc,
    output reg        pc_load,
    output reg        reg_a_write,
    output reg        reg_b_write,
    output reg        a_sel,
    output reg  [1:0] alu_op,
    output wire       halted
);

    // Instruction opcodes
    localparam OP_LOAD_A = 3'b000;
    localparam OP_LOAD_B = 3'b001;
    localparam OP_ADD    = 3'b010;
    localparam OP_SUB    = 3'b011;
    localparam OP_AND    = 3'b100;
    localparam OP_JMP    = 3'b101;
    localparam OP_JZ     = 3'b110;
    localparam OP_HALT   = 3'b111;

    // FSM states
    localparam FETCH   = 2'b00;
    localparam EXECUTE = 2'b01;
    localparam HALTED  = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    assign halted = (state == HALTED);

    // 1. State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    // 2. Next-state logic
    always @(*) begin
        next_state = state;

        case (state)
            FETCH: begin
                next_state = EXECUTE;
            end

            EXECUTE: begin
                if (opcode == OP_HALT)
                    next_state = HALTED;
                else
                    next_state = FETCH;
            end

            HALTED: begin
                next_state = HALTED;
            end

            default: begin
                next_state = FETCH;
            end
        endcase
    end

    // 3. Control-signal generation
    always @(*) begin
        // Defaults: do not modify any registers
        ir_write    = 1'b0;
        pc_inc      = 1'b0;
        pc_load     = 1'b0;
        reg_a_write = 1'b0;
        reg_b_write = 1'b0;
        a_sel       = 1'b0;
        alu_op      = 2'b00;

        case (state)
            FETCH: begin
                ir_write = 1'b1;
                pc_inc   = 1'b1;
            end

            EXECUTE: begin
                case (opcode)
                    OP_LOAD_A: begin
                        reg_a_write = 1'b1;
                        a_sel       = 1'b0;
                    end

                    OP_LOAD_B: begin
                        reg_b_write = 1'b1;
                    end

                    OP_ADD: begin
                        reg_a_write = 1'b1;
                        a_sel       = 1'b1;
                        alu_op      = 2'b00;
                    end

                    OP_SUB: begin
                        reg_a_write = 1'b1;
                        a_sel       = 1'b1;
                        alu_op      = 2'b01;
                    end

                    OP_AND: begin
                        reg_a_write = 1'b1;
                        a_sel       = 1'b1;
                        alu_op      = 2'b10;
                    end

                    OP_JMP: begin
                        pc_load = 1'b1;
                    end

                    OP_JZ: begin
                        if (a_zero)
                            pc_load = 1'b1;
                    end

                    OP_HALT: begin
                        // Next-state logic enters HALTED.
                        // No register writes are enabled.
                    end

                    default: begin
                        // No operation for an unknown opcode.
                    end
                endcase
            end

            HALTED: begin
                // All write controls remain disabled.
            end

            default: begin
                // All controls retain their safe defaults.
            end
        endcase
    end

endmodule