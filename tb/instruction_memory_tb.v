`timescale 1ns/1ps

module instruction_memory_tb;

    reg  [3:0] address;
    wire [10:0] instruction;

    integer errors;

    instruction_memory dut (
        .address(address),
        .instruction(instruction)
    );


    task check_instruction;

        input [3:0] test_address;
        input [10:0] expected;

        begin

            address = test_address;

            #1;

            if (instruction !== expected) begin
                $display(
                    "FAIL: address=%0d expected=%b got=%b",
                    address,
                    expected,
                    instruction
                );

                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: address=%0d instruction=%b",
                    address,
                    instruction
                );
            end

        end

    endtask


    initial begin

        $dumpfile("waveforms/instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        errors = 0;
        address = 0;


        // Check all 16 occupied instruction addresses.
        check_instruction(4'd0, {3'b000, 8'd10}); // LOAD A, 10
        check_instruction(4'd1, {3'b001, 8'd4}); // LOAD B, 4
        check_instruction(4'd2, {3'b010, 8'd0}); // ADD
        check_instruction(4'd3, {3'b001, 8'd2}); // LOAD B, 2
        check_instruction(4'd4, {3'b011, 8'd0}); // SUB
        check_instruction(4'd5, {3'b001, 8'd15}); // LOAD B, 15
        check_instruction(4'd6, {3'b100, 8'd0}); // AND
        check_instruction(4'd7, {3'b000, 8'd20}); // LOAD A, 20
        check_instruction(4'd8, {3'b001, 8'd5}); // LOAD B, 5
        check_instruction(4'd9, {3'b010, 8'd0}); // ADD
        check_instruction(4'd10, {3'b001, 8'd3}); // LOAD B, 3
        check_instruction(4'd11, {3'b011, 8'd0}); // SUB
        check_instruction(4'd12, {3'b001, 8'd7}); // LOAD B, 7
        check_instruction(4'd13, {3'b100, 8'd0}); // AND
        check_instruction(4'd14, {3'b010, 8'd0}); // ADD
        check_instruction(4'd15, {3'b111, 8'd0}); // HALT

        if (errors == 0) begin
            $display("ALL INSTRUCTION MEMORY TESTS PASSED");
        end
        else begin
            $display("%0d TESTS FAILED", errors);
            $fatal(1, "Instruction memory verification failed");
        end


        $finish;

    end

endmodule