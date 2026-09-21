
`timescale 1ns/1ps

module tiny_cpu_tb;

    reg clk;
    reg reset;

    wire [3:0] pc_out;
    wire [7:0] a_out;
    wire [7:0] b_out;
    wire [10:0] ir_out;
    wire halted;

    integer errors;

    tiny_cpu dut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .a_out(a_out),
        .b_out(b_out),
        .ir_out(ir_out),
        .halted(halted)
    );

    // Clock period = 10 ns
    always #5 clk = ~clk;

    // Check CPU registers and state after a clock edge.
    task check_cpu;
        input [3:0] expected_pc;
        input [7:0] expected_a;
        input [7:0] expected_b;
        input [10:0] expected_ir;
        input expected_halted;

        begin
            if (
                pc_out !== expected_pc ||
                a_out  !== expected_a  ||
                b_out  !== expected_b  ||
                ir_out !== expected_ir ||
                halted !== expected_halted
            ) begin
                $display(
                    "FAIL at %0t: PC=%0d A=%0d B=%0d IR=%b halted=%b",
                    $time, pc_out, a_out, b_out,
                    ir_out, halted
                );

                $display(
                    "Expected: PC=%0d A=%0d B=%0d IR=%b halted=%b",
                    expected_pc, expected_a, expected_b,
                    expected_ir, expected_halted
                );

                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS at %0t: PC=%0d A=%0d B=%0d IR=%b halted=%b",
                    $time, pc_out, a_out, b_out,
                    ir_out, halted
                );
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/tiny_cpu.vcd");
        $dumpvars(0, tiny_cpu_tb);

        clk = 0;
        reset = 0;
        errors = 0;

        // Reset all CPU registers.
        #2;
        reset = 1;
        #1;

        check_cpu(0, 0, 0, 11'b0, 0);

        reset = 0;

        // Edge 1: FETCH LOAD A, 10
        @(posedge clk);
        #1;
        check_cpu(1, 0, 0, {3'b000, 8'd10}, 0);

        // Edge 2: EXECUTE LOAD A, 10
        @(posedge clk);
        #1;
        check_cpu(1, 10, 0, {3'b000, 8'd10}, 0);

        // Edge 3: FETCH LOAD B, 4
        @(posedge clk);
        #1;
        check_cpu(2, 10, 0, {3'b001, 8'd4}, 0);

        // Edge 4: EXECUTE LOAD B, 4
        @(posedge clk);
        #1;
        check_cpu(2, 10, 4, {3'b001, 8'd4}, 0);

        // Edge 5: FETCH ADD
        @(posedge clk);
        #1;
        check_cpu(3, 10, 4, {3'b010, 8'd0}, 0);

        // Edge 6: EXECUTE ADD
        @(posedge clk);
        #1;
        check_cpu(3, 14, 4, {3'b010, 8'd0}, 0);

        // Edge 7: FETCH HALT
        @(posedge clk);
        #1;
        check_cpu(4, 14, 4, {3'b111, 8'd0}, 0);

        // Edge 8: EXECUTE HALT
        @(posedge clk);
        #1;
        check_cpu(4, 14, 4, {3'b111, 8'd0}, 1);

        // Verify the CPU remains halted.
        repeat (3) begin
            @(posedge clk);
            #1;
            check_cpu(4, 14, 4, {3'b111, 8'd0}, 1);
        end

        if (errors == 0) begin
            $display("ALL CPU TESTS PASSED");
        end
        else begin
            $display("%0d CPU TESTS FAILED", errors);
            $fatal(1, "CPU integration test failed");
        end

        $finish;

    end

endmodule