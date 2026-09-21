module program_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       pc_inc,
    input  wire       pc_load,
    input  wire [3:0] load_addr,
    output reg  [3:0] pc_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 4'd0;
        end
        else if (pc_load) begin
            pc_out <= load_addr;
        end
        else if (pc_inc) begin
            pc_out <= pc_out + 4'd1;
        end
    end

endmodule