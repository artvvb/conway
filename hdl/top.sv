`timescale 1ns / 1ps
`include "counter.sv"
`include "vga.sv"

module top (
    input  logic        clk,
    input  logic        reset,
    output logic [3:0]  vga_r,
    output logic [3:0]  vga_g,
    output logic [3:0]  vga_b,
    output logic        vga_hs,
    output logic        vga_vs,
    input  logic        uart_rx,
    output logic        uart_tx,
    output logic [15:0] led
);
    logic enable_strobe;
    
    counter #(
        .width       (2),
        .max_value   (4),
        .increment   (1),
        .reset_value (0)
    ) strobe_counter (
        .clk    (clk),
        .reset  (reset),
        .enable (1),
        .count  (),
        .carry  (enable_strobe)
    );
    logic        pixel_tready;
    logic [11:0] pixel_tdata;
    counter #(
        .width       (12),
        .max_value   (4096),
        .increment   (1),
        .reset_value (0)
    ) color_counter (
        .clk    (clk),
        .reset  (reset),
        .enable (pixel_tready),
        .count  (pixel_tdata),
        .carry  ()
    );

    vga vga_inst (
        .clk           (clk),
        .reset         (reset),
        .enable_strobe (enable_strobe),
        .pixel_tvalid  (1),
        .pixel_tready  (pixel_tready),
        .pixel_tdata   (pixel_tdata), // {r[3:0], g[3:0], b[3:0]}
        .vga_r         (vga_r),
        .vga_g         (vga_g),
        .vga_b         (vga_b),
        .vga_hs        (vga_hs),
        .vga_vs        (vga_vs),
        .error         (led[0]),
        .running       (led[1])
    );
endmodule
