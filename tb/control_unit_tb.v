
`timescale 1ns/1ps

module control_unit_tb;

    reg clk;
    reg reset;
    reg [2:0] opcode;
    reg a_zero;

    wire ir_write;
    wire pc_inc;
    wire pc_load;
    wire reg_a_write;
    wire reg_b_write;
    wire a_sel;
    wire [1:0] alu_op;
    wire halted;

    integer errors;

    control_unit dut (
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

    always #5 clk = ~clk;

    // Check all control signals at once.
    task check_controls;
        input [7:0] expected;
        reg [7:0] actual;
        begin
            actual = {
                ir_write,
                pc_inc,
                pc_load,
                reg_a_write,
                reg_b_write,
                a_sel,
                alu_op
            };

            if (actual !== expected) begin
                $display(
                    "FAIL at %0t: expected=%b actual=%b",
                    $time, expected, actual
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS at %0t: controls=%b",
                    $time, actual
                );
            end
        end
    endtask

    // Start in FETCH, then advance to EXECUTE.
    task enter_execute;
        begin
            @(negedge clk);
            opcode = 3'b000;
            a_zero = 1'b0;

            #1;
            check_controls(8'b11000000);

            @(posedge clk);
            #1;
        end
    endtask

    // Advance from EXECUTE back to FETCH.
    task return_to_fetch;
        begin
            @(posedge clk);
            #1;
            check_controls(8'b11000000);
        end
    endtask

    initial begin
        $dumpfile("waveforms/control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        clk = 0;
        reset = 0;
        opcode = 0;
        a_zero = 0;
        errors = 0;

        // Reset: FSM enters FETCH immediately
        #2;
        reset = 1;
        #1;
        check_controls(8'b11000000);

        reset = 0;

        // FETCH -> EXECUTE: LOAD A
        @(posedge clk);
        #1;
        check_controls(8'b00010000);
        return_to_fetch();

        // LOAD B
        enter_execute();
        opcode = 3'b001;
        #1;
        check_controls(8'b00001000);
        return_to_fetch();

        // ADD
        enter_execute();
        opcode = 3'b010;
        #1;
        check_controls(8'b00010100);
        return_to_fetch();

        // SUB
        enter_execute();
        opcode = 3'b011;
        #1;
        check_controls(8'b00010101);
        return_to_fetch();

        // AND
        enter_execute();
        opcode = 3'b100;
        #1;
        check_controls(8'b00010110);
        return_to_fetch();

        // JMP
        enter_execute();
        opcode = 3'b101;
        #1;
        check_controls(8'b00100000);
        return_to_fetch();

        // JZ when A is nonzero: do not jump
        enter_execute();
        opcode = 3'b110;
        a_zero = 0;
        #1;
        check_controls(8'b00000000);

        // JZ when A is zero: jump
        a_zero = 1;
        #1;
        check_controls(8'b00100000);
        return_to_fetch();

        // HALT
        enter_execute();
        opcode = 3'b111;
        #1;
        check_controls(8'b00000000);

        @(posedge clk);
        #1;

        if (halted !== 1'b1) begin
            $display("FAIL: CPU did not enter HALTED");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CPU entered HALTED");
        end

        check_controls(8'b00000000);

        // Verify HALTED is persistent
        @(posedge clk);
        #1;

        if (halted !== 1'b1) begin
            $display("FAIL: CPU left HALTED unexpectedly");
            errors = errors + 1;
        end
        else begin
            $display("PASS: CPU remains HALTED");
        end

        // Reset should recover from HALTED
        @(negedge clk);
        reset = 1;
        #1;

        if (halted !== 1'b0) begin
            $display("FAIL: reset did not leave HALTED");
            errors = errors + 1;
        end
        else begin
            $display("PASS: reset returned CPU to FETCH");
        end

        check_controls(8'b11000000);

        if (errors == 0)
            $display("ALL CONTROL UNIT TESTS PASSED");
        else begin
            $display("%0d CONTROL UNIT TESTS FAILED", errors);
            $fatal(1, "Control unit verification failed");
        end

        $finish;
    end

endmodule