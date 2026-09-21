`timescale 1ns/1ps

module instruction_register_tb;

    reg clk;
    reg reset;
    reg ir_write;
    reg [10:0] instruction_in;

    wire [10:0] instruction_out;

    integer errors;


    instruction_register dut (
        .clk(clk),
        .reset(reset),
        .ir_write(ir_write),
        .instruction_in(instruction_in),
        .instruction_out(instruction_out)
    );


    always #5 clk = ~clk;


    initial begin

        $dumpfile("waveforms/instruction_register.vcd");
        $dumpvars(0, instruction_register_tb);

        clk = 0;
        reset = 0;
        ir_write = 0;
        instruction_in = 0;
        errors = 0;


        // Test reset
        #2;
        reset = 1;
        #1;

        if (instruction_out !== 11'b0) begin
            $display("FAIL: reset");
            errors = errors + 1;
        end
        else begin
            $display("PASS: reset");
        end

        reset = 0;


        // Put LOAD A,10 on input
        @(negedge clk);

        instruction_in = {3'b000, 8'd10};
        ir_write = 1;


        // Capture at rising edge
        @(posedge clk);
        #1;

        if (instruction_out !== {3'b000, 8'd10}) begin
            $display("FAIL: instruction not captured");
            errors = errors + 1;
        end
        else begin
            $display("PASS: instruction captured");
        end


        // Change input but disable write
        @(negedge clk);

        instruction_in = {3'b001, 8'd4};
        ir_write = 0;


        @(posedge clk);
        #1;

        if (instruction_out !== {3'b000, 8'd10}) begin
            $display("FAIL: IR changed when ir_write=0");
            errors = errors + 1;
        end
        else begin
            $display("PASS: IR held its value");
        end


        // Enable writing again
        @(negedge clk);

        ir_write = 1;


        @(posedge clk);
        #1;

        if (instruction_out !== {3'b001, 8'd4}) begin
            $display("FAIL: second instruction not captured");
            errors = errors + 1;
        end
        else begin
            $display("PASS: second instruction captured");
        end


        if (errors == 0) begin
            $display("ALL INSTRUCTION REGISTER TESTS PASSED");
        end
        else begin
            $display("%0d TESTS FAILED", errors);
        end


        $finish;

    end

endmodule