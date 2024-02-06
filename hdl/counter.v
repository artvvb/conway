module counter #(
    parameter integer WIDTH = 8,
    parameter [WIDTH-1:0] MAX_VALUE = 100, // not inclusive
    parameter [WIDTH-1:0] INCREMENT = 10,
    parameter [WIDTH-1:0] RESET_VALUE = 20
) (
    input wire clk,
    input wire resetn,
    input wire enable,
    output reg [WIDTH-1:0] count,
    output wire carry
);
    initial begin
        count = RESET_VALUE;
    end
    always@(posedge clk) begin
        if (resetn == 1'b0) begin
            count <= RESET_VALUE;
        end else if (enable == 1'b1) begin
            if (carry == 1'b1) begin
                count <= RESET_VALUE;
            end else begin
                count <= count + 1'b1;
            end
        end
    end

    assign carry = (count + 1 >= MAX_VALUE) ? 1'b1 : 1'b0;
endmodule