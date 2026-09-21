
module alu (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [1:0] alu_op,
    output reg  [7:0] result
);

    always @(*) begin
        case (alu_op)
            2'b00: result = A + B;
            2'b01: result = A - B;
            2'b10: result = A & B;
            default: result = 8'b0;
        endcase
    end

endmodule