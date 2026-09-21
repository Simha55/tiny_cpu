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


        check_instruction(
            4'd0,
            {3'b000, 8'd10}
        );


        check_instruction(
            4'd1,
            {3'b001, 8'd4}
        );


        check_instruction(
            4'd2,
            {3'b010, 8'd0}
        );


        check_instruction(
            4'd3,
            {3'b111, 8'd0}
        );


        // Check unused address
        check_instruction(
            4'd8,
            11'b0
        );


        if (errors == 0) begin
            $display("ALL INSTRUCTION MEMORY TESTS PASSED");
        end
        else begin
            $display("%0d TESTS FAILED", errors);
        end


        $finish;

    end

endmodule