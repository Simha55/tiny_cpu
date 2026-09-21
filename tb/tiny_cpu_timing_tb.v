
`timescale 1ns/1ps

module tiny_cpu_timing_tb;

    reg clk = 0;
    reg reset = 0;

    wire [3:0] pc_out;
    wire [7:0] a_out;
    wire [7:0] b_out;
    wire [10:0] ir_out;
    wire halted;

    integer cycles;
    time start_time;
    time end_time;

    tiny_cpu dut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .a_out(a_out),
        .b_out(b_out),
        .ir_out(ir_out),
        .halted(halted)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/tiny_cpu_timing.vcd");
        $dumpvars(0, tiny_cpu_timing_tb);

        cycles = 0;

        // Apply reset before the first clock edge.
        #2;
        reset = 1;
        #1;
        reset = 0;

        // Start measuring at the beginning of
        // the first clock cycle.
        start_time = 0;

        while (halted !== 1'b1 && cycles < 100) begin
            @(posedge clk);
            cycles = cycles + 1;

            // Allow nonblocking assignments to update.
            #1;

            $display(
                "Cycle=%0d Time=%0t PC=%0d A=%0d B=%0d IR=%b Halted=%b",
                cycles, $time, pc_out, a_out,
                b_out, ir_out, halted
            );
        end

        if (halted !== 1'b1) begin
            $display("FAIL: CPU did not halt");
            $fatal(1);
        end

        end_time = $time;

        $display("--------------------------");
        $display("Total clock cycles = %0d", cycles);
        $display("Observed halt time = %0t", end_time);
        $display(
            "Program time at 10 ns/cycle = %0d ns",
            cycles * 10
        );
        $display("Final A = %0d", a_out);
        $display("Final B = %0d", b_out);

        $finish;
    end

endmodule