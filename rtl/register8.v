module register8 (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [7:0] data_in,
    output reg [7:0] data_out
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            data_out <= 8'b0;
        else if (write_enable)
            data_out <= data_in;
    end

endmodule