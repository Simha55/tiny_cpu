
`timescale 1ns/1ps

module alu_tb;

    reg  [7:0] A;
    reg  [7:0] B;
    reg  [1:0] alu_op;

    wire [7:0] result;

    integer errors;

    // Instantiate the ALU
    alu dut (
        .A(A),
        .B(B),
        .alu_op(alu_op),
        .result(result)
    );

    // Check one test case
    task check;
        input [7:0] test_A;
        input [7:0] test_B;
        input [1:0] test_op;
        input [7:0] expected;

        begin
            A = test_A;
            B = test_B;
            alu_op = test_op;

            // Allow combinational logic to settle
            #1;

            if (result !== expected) begin
                $display(
                    "FAIL: A=%d B=%d OP=%b Expected=%d Got=%d",
                    A, B, alu_op, expected, result
                );

                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: A=%d B=%d OP=%b Result=%d",
                    A, B, alu_op, result
                );
            end
        end
    endtask

    initial begin

        // Generate waveform file
        $dumpfile("waveforms/alu.vcd");
        $dumpvars(0, alu_tb);

        errors = 0;

        A = 0;
        B = 0;
        alu_op = 0;

        // ADD tests
        check(10, 4, 2'b00, 14);
        check(25, 15, 2'b00, 40);
        check(255, 1, 2'b00, 0);

        // SUB tests
        check(10, 4, 2'b01, 6);
        check(4, 10, 2'b01, 250);
        check(20, 20, 2'b01, 0);

        // AND tests
        check(8'b10101010,
              8'b11001100,
              2'b10,
              8'b10001000);

        check(8'hFF, 8'h00, 2'b10, 8'h00);

        // Reserved operation
        check(10, 4, 2'b11, 0);

        if (errors == 0) begin
            $display("ALL ALU TESTS PASSED");
        end
        else begin
            $display("%0d ALU TESTS FAILED", errors);
            $fatal(1, "ALU verification failed");
        end

        $finish;
    end

endmodule