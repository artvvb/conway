`timescale 1ns / 1ps
`default_nettype none

module bram #(
    parameter integer DATA_WIDTH = 8,
    parameter integer DEPTH = 200,
    parameter integer ADDR_WIDTH = 8
) (
    input wire clk,
    // input wire resetn,
    
    input wire [ADDR_WIDTH-1:0] write_addr,
    input wire write_enable,
    input wire [DATA_WIDTH-1:0] write_data,

    // note: memory read latency of one clock cycle
    input wire [ADDR_WIDTH-1:0] read_addr,
    input wire read_enable,
    output wire [DATA_WIDTH-1:0] read_data
);
    reg [DATA_WIDTH-1:0] memory [DEPTH-1:0];

    initial begin : mem_init
        integer i;
        for (i=0; i<DEPTH; i=i+1) begin
            memory[i] = 'b0;
        end
    end

    always @(posedge clk) begin
        if (write_enable) begin
            memory[write_addr] <= write_data;
        end

        if (read_enable) begin
            read_data <= memory[read_addr];
        end
    end
endmodule