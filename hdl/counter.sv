`ifndef COUNTER_SV
`define COUNTER_SV

module counter #(
    parameter integer width = 8,
    parameter integer max_value = 100, // not inclusive
    parameter integer increment = 10,
    parameter integer reset_value = 20
) (
    input  logic clk,
    input  logic reset,
    input  logic enable,
    output logic [width-1:0] count = reset_value,
    output logic carry
);
    always_ff @( posedge clk ) begin : counter_inst
        if (reset) begin
            count <= reset_value;
        end else if (enable) begin
            if (carry) begin
                count <= reset_value;
            end else begin
                count <= count + increment;
            end
        end
    end

    assign carry = (count + increment >= max_value) ? 1'b1 : 1'b0;
endmodule

`endif