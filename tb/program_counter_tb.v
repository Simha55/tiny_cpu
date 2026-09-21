`timescale 1ns/1ps

module program_counter_tb;

    reg clk;
    reg reset;
    reg pc_inc;
    reg pc_load;
    reg [3:0] load_addr;

    wire [3:0] pc_out;

    integer errors;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .pc_inc(pc_inc),
        .pc_load(pc_load),
        .load_addr(load_addr),
        .pc_out(pc_out)
    );

    // Clock period = 10 ns
    always #5 clk = ~clk;

    // Reusable output check
    task check_pc;
        input [3:0] expected;

        begin
            if (pc_out !== expected) begin
                $display(
                    "FAIL at %0t: expected PC=%0d, got PC=%0d",
                    $time, expected, pc_out
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS at %0t: PC=%0d",
                    $time, pc_out
                );
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        clk = 0;
        reset = 0;
        pc_inc = 0;
        pc_load = 0;
        load_addr = 0;
        errors = 0;

        // TEST 1: Asynchronous reset
        #2;
        reset = 1;
        #1;
        check_pc(0);

        reset = 0;

        // TEST 2: Increment from 0 to 1
        @(negedge clk);
        pc_inc = 1;

        @(posedge clk);
        #1;
        check_pc(1);

        // TEST 3: Increment from 1 to 2
        @(posedge clk);
        #1;
        check_pc(2);

        // TEST 4: Hold PC at 2
        @(negedge clk);
        pc_inc = 0;

        @(posedge clk);
        #1;
        check_pc(2);

        // TEST 5: Jump to address 9
        @(negedge clk);
        pc_load = 1;
        load_addr = 4'd9;

        @(posedge clk);
        #1;
        check_pc(9);

        // TEST 6: Hold after jump
        @(negedge clk);
        pc_load = 0;

        @(posedge clk);
        #1;
        check_pc(9);

        // TEST 7: Load has priority over increment
        @(negedge clk);
        pc_inc = 1;
        pc_load = 1;
        load_addr = 4'd15;

        @(posedge clk);
        #1;
        check_pc(15);

        // TEST 8: Increment wraps 15 to 0
        @(negedge clk);
        pc_load = 0;

        @(posedge clk);
        #1;
        check_pc(0);

        // TEST 9: Asynchronous reset from a nonzero value
        @(posedge clk);
        #1;
        check_pc(1);

        // Assert reset between clock edges
        #1;
        reset = 1;
        #1;
        check_pc(0);

        if (errors == 0) begin
            $display("ALL PROGRAM COUNTER TESTS PASSED");
        end
        else begin
            $display("%0d PROGRAM COUNTER TESTS FAILED", errors);
            $fatal(1, "Program counter verification failed");
        end

        $finish;
    end

endmodule