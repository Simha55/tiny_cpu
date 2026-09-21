module instruction_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        ir_write,
    input  wire [10:0] instruction_in,
    output reg  [10:0] instruction_out
);

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            instruction_out <= 11'b0;
        end
        else if (ir_write) begin
            instruction_out <= instruction_in;
        end

    end

endmodule