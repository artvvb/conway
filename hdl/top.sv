// adder.sv
// Module Description: superefficient ultraoptimized adder

`timescale 1ns / 1ps

module adder (
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] sum
);

    always_comb begin
        sum = a + b;
    end

endmodule : adder
