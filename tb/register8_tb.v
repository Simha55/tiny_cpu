`timescale 1ns/1ps

module register8_tb;

    reg clk;
    reg reset;
    reg write_enable;
    reg [7:0] data_in;

    wire [7:0] data_out;

    integer errors;

    register8 dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        $dumpfile("waveforms/register8.vcd");
        $dumpvars(0, register8_tb);

        errors = 0;

        clk = 0;
        reset = 0;
        write_enable = 0;
        data_in = 0;

        // Test 1: asynchronous reset
        #2;
        reset = 1;
        #1;

        if (data_out !== 8'd0) begin
            $display("FAIL: reset did not clear register");
            errors = errors + 1;
        end
        else begin
            $display("PASS: reset cleared register");
        end

        reset = 0;

        // Test 2: write data when write_enable = 1
        data_in = 8'd25;
        write_enable = 1;

        @(posedge clk);
        #1;

        if (data_out !== 8'd25) begin
            $display("FAIL: register did not capture 25");
            errors = errors + 1;
        end
        else begin
            $display("PASS: register captured 25");
        end

        // Test 3: changing data_in without a clock edge
        data_in = 8'd60;
        #2;

        if (data_out !== 8'd25) begin
            $display("FAIL: register changed without clock edge");
            errors = errors + 1;
        end
        else begin
            $display("PASS: register held value between clock edges");
        end

        // Test 4: write_enable = 0
        write_enable = 0;
        data_in = 8'd99;

        @(posedge clk);
        #1;

        if (data_out !== 8'd25) begin
            $display("FAIL: register changed when write_enable = 0");
            errors = errors + 1;
        end
        else begin
            $display("PASS: register held value when write_enable = 0");
        end

        // Test 5: asynchronous reset without waiting for clock
        reset = 1;
        #1;

        if (data_out !== 8'd0) begin
            $display("FAIL: asynchronous reset failed");
            errors = errors + 1;
        end
        else begin
            $display("PASS: asynchronous reset worked");
        end

        if (errors == 0) begin
            $display("ALL REGISTER TESTS PASSED");
        end
        else begin
            $display("%0d REGISTER TESTS FAILED", errors);
        end

        $finish;

    end

endmodule