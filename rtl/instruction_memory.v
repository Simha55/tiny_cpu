module instruction_memory (
    input  wire [3:0]  address,
    output reg  [10:0] instruction
);

    always @(*) begin
        case (address)

            4'd0:  instruction = {3'b000, 8'd10}; // LOAD A, 10
            4'd1:  instruction = {3'b001, 8'd4};  // LOAD B, 4
            4'd2:  instruction = {3'b010, 8'd0};  // ADD: A = 14
            4'd3:  instruction = {3'b001, 8'd2};  // LOAD B, 2
            4'd4:  instruction = {3'b011, 8'd0};  // SUB: A = 12
            4'd5:  instruction = {3'b001, 8'd15}; // LOAD B, 15
            4'd6:  instruction = {3'b100, 8'd0};  // AND: A = 12
            4'd7:  instruction = {3'b000, 8'd20}; // LOAD A, 20
            4'd8:  instruction = {3'b001, 8'd5};  // LOAD B, 5
            4'd9:  instruction = {3'b010, 8'd0};  // ADD: A = 25
            4'd10: instruction = {3'b001, 8'd3};  // LOAD B, 3
            4'd11: instruction = {3'b011, 8'd0};  // SUB: A = 22
            4'd12: instruction = {3'b001, 8'd7};  // LOAD B, 7
            4'd13: instruction = {3'b100, 8'd0};  // AND: A = 6
            4'd14: instruction = {3'b010, 8'd0};  // ADD: A = 13
            4'd15: instruction = {3'b111, 8'd0};  // HALT

            default: instruction = 11'b0;

        endcase
    end

endmodule