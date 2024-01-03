`timescale 1ns / 1ps
`default_nettype none

/*
    Terminology:
        Pixel: one memory address in one memory.
        Block: one memory address in all memories, makes up a 3x3 block of pixels.
*/

module memory_control #(
    parameter integer ADDR_WIDTH = 4,
    parameter integer HEIGHT_PIXELS = 6,
    parameter integer WIDTH_PIXELS = 6,
    parameter integer HEIGHT_BLOCKS = 2, // HEIGHT_PIXELS / PIXELS_PER_BLOCK
    parameter integer WIDTH_BLOCKS = 2,  // WIDTH_PIXELS / PIXELS_PER_BLOCK
    parameter integer PIXELS_PER_BLOCK = 3, // do not change
    parameter integer PIXEL_COUNTER_WIDTH, = 2 //$clog2(PIXELS_PER_BLOCK-1)
    parameter integer BLOCK_Y_COUNTER_WIDTH = 1, //$clog2(HEIGHT_BLOCKS-1)
    parameter integer BLOCK_X_COUNTER_WIDTH = 1 //$clog2(WIDTH_BLOCKS-1)
) (
    input wire clk,
    input wire enable,
    input wire reset,
    output wire [8:0] write_enable,
    output wire [8:0] read_enable,
    output wire [ADDR_WIDTH-1:0] write_addr, // route same address to all memories, only one is enabled at a time
    output wire [ADDR_WIDTH-1:0] read_addr_0,
    output wire [ADDR_WIDTH-1:0] read_addr_1,
    output wire [ADDR_WIDTH-1:0] read_addr_2,
    output wire [ADDR_WIDTH-1:0] read_addr_3,
    output wire [ADDR_WIDTH-1:0] read_addr_4,
    output wire [ADDR_WIDTH-1:0] read_addr_5,
    output wire [ADDR_WIDTH-1:0] read_addr_6,
    output wire [ADDR_WIDTH-1:0] read_addr_7,
    output wire [ADDR_WIDTH-1:0] read_addr_8
);
    // counter #(
    //     .WIDTH       (),
    //     .MAX_VALUE   (),
    //     .INCREMENT   (),
    //     .RESET_VALUE ()
    // ) x_pixel_counter (
    //     .clk         (clk),
    //     .resetn      (resetn),
    //     .enable      (),
    //     .count       (),
    //     .carry       ()
    // );

    // ====== Base Pixel/Block Counters ======
    
    wire [PIXEL_COUNTER_WIDTH-1:0] x_pixel_counter_count;
    wire x_pixel_counter_enable = enable;
    wire x_pixel_counter_carry;

    wire [BLOCK_X_COUNTER_WIDTH-1:0] x_block_counter_count;
    wire x_block_counter_enable = enable;
    wire x_block_counter_carry = x_pixel_counter_enable & x_pixel_counter_carry;

    wire [PIXEL_COUNTER_WIDTH-1:0] y_pixel_counter_count;
    wire y_pixel_counter_enable = x_block_counter_enable & x_block_counter_carry;
    wire y_pixel_counter_carry;
    
    wire [BLOCK_Y_COUNTER_WIDTH-1:0] y_block_counter_count;
    wire y_block_counter_enable = y_pixel_counter_enable & y_pixel_counter_carry;
    wire y_block_counter_carry;
    
    counter #(
        .WIDTH       (PIXEL_COUNTER_WIDTH),
        .MAX_VALUE   (PIXELS_PER_BLOCK),
        .INCREMENT   (1),
        .RESET_VALUE (0)
    ) x_pixel_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (x_pixel_counter_enable),
        .count       (x_pixel_counter_count),
        .carry       (x_pixel_counter_carry)
    );

    counter #(
        .WIDTH       (BLOCK_X_COUNTER_WIDTH),
        .MAX_VALUE   (WIDTH_BLOCKS),
        .INCREMENT   (1),
        .RESET_VALUE (0)
    ) x_block_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (x_block_counter_enable),
        .count       (x_block_counter_count),
        .carry       (x_block_counter_carry)
    );
    
    counter #(
        .WIDTH       (PIXEL_COUNTER_WIDTH),
        .MAX_VALUE   (PIXELS_PER_BLOCK),
        .INCREMENT   (1),
        .RESET_VALUE (0)
    ) y_pixel_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (y_pixel_counter_enable),
        .count       (y_pixel_counter_count),
        .carry       (y_pixel_counter_carry)
    );

    counter #(
        .WIDTH       (BLOCK_Y_COUNTER_WIDTH),
        .MAX_VALUE   (HEIGHT_BLOCKS),
        .INCREMENT   (1),
        .RESET_VALUE (0)
    ) y_block_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (y_block_counter_enable),
        .count       (y_block_counter_count),
        .carry       (y_block_counter_carry)
    );
    
    // ====== Pixel Compares ======

    wire [PIXELS_PER_BLOCK-1:0] center_y;
    wire [PIXELS_PER_BLOCK-1:0] center_x;
    wire [PIXELS_PER_BLOCK*PIXELS_PER_BLOCK-1:0] x_out_of_bounds;
    wire [PIXELS_PER_BLOCK*PIXELS_PER_BLOCK-1:0] y_out_of_bounds;
    
    assign center_x[0] = (x_pixel_counter == 2'd0) ? 1'b1 : 1'b0;
    assign center_x[1] = (x_pixel_counter == 2'd1) ? 1'b1 : 1'b0;
    assign center_x[2] = (x_pixel_counter == 2'd2) ? 1'b1 : 1'b0;
    assign center_y[0] = (y_pixel_counter == 2'd0) ? 1'b1 : 1'b0;
    assign center_y[1] = (y_pixel_counter == 2'd1) ? 1'b1 : 1'b0;
    assign center_y[2] = (y_pixel_counter == 2'd2) ? 1'b1 : 1'b0;

    assign write_enable[0] = center_x[0] & center_y[0];
    assign write_enable[1] = center_x[1] & center_y[0];
    assign write_enable[2] = center_x[2] & center_y[0];
    assign write_enable[3] = center_x[0] & center_y[1];
    assign write_enable[4] = center_x[1] & center_y[1];
    assign write_enable[5] = center_x[2] & center_y[1];
    assign write_enable[6] = center_x[0] & center_y[2];
    assign write_enable[7] = center_x[1] & center_y[2];
    assign write_enable[8] = center_x[2] & center_y[2];

    assign {x_out_of_bounds[0], x_out_of_bounds[3], x_out_of_bounds[6]} = {3{x_pixel_counter_carry & x_block_counter_carry}};
    assign {x_out_of_bounds[1], x_out_of_bounds[4], x_out_of_bounds[7]} = 3'b0;
    assign {x_out_of_bounds[2], x_out_of_bounds[5], x_out_of_bounds[8]} = {3{(~|x_pixel_counter_count) & (~|x_block_counter_count)}};

    assign y_out_of_bounds[2:0] = {3{y_pixel_counter_carry & y_block_counter_carry}};
    assign y_out_of_bounds[5:3] = 3'b0;
    assign y_out_of_bounds[8:6] = {3{(~|y_pixel_counter_count) & (~|y_block_counter_count)}};

    assign read_enable = ~(x_out_of_bounds | y_out_of_bounds);

    // ====== Write Address ======

    wire [ADDR_WIDTH-1:0] write_addr_x_counter_count;
    wire write_addr_x_counter_enable = x_pixel_counter_enable & x_pixel_counter_carry;
    wire write_addr_x_counter_carry;
    
    wire [ADDR_WIDTH-1:0] write_addr_x_counter_count;
    wire write_addr_y_counter_enable = y_pixel_counter_enable & y_pixel_counter_carry;
    wire write_addr_y_counter_carry;

    counter #(
        .WIDTH       (ADDR_WIDTH),
        .MAX_VALUE   (WIDTH_BLOCKS),
        .INCREMENT   (1),
        .RESET_VALUE (0)
    ) write_addr_x_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (write_addr_x_counter_enable),
        .count       (write_addr_x_counter_count),
        .carry       (write_addr_x_counter_carry)
    );

    counter #(
        .WIDTH       (ADDR_WIDTH),
        .MAX_VALUE   (HEIGHT_BLOCKS * WIDTH_BLOCKS),
        .INCREMENT   (WIDTH_BLOCKS),
        .RESET_VALUE (0)
    ) write_addr_y_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (write_addr_y_counter_enable),
        .count       (write_addr_y_counter_count),
        .carry       (write_addr_y_counter_carry)
    );

    assign write_addr = write_addr_x_counter_count + write_addr_y_counter_count;
    
    // ====== Read Address ======
    
    // counter_model('read_enable_x_counters_0', width // 3, lambda: x_pixel_counter.get_count() == 1, lambda: False, increment=1),
    wire [ADDR_WIDTH-1:0] read_addr_x0_counter_count;
    wire read_addr_x0_counter_enable = x_pixel_counter_enable & (x_pixel_counter_count == PIXELS_PER_BLOCK - 1);
    wire read_addr_x0_counter_carry;

    counter #(
        .WIDTH       (ADDR_WIDTH),
        .MAX_VALUE   (WIDTH_BLOCKS),
        .INCREMENT   (1),
        .RESET_VALUE (0)
    ) read_addr_x0_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (read_addr_x0_counter_enable),
        .count       (read_addr_x0_counter_count),
        .carry       (read_addr_x0_counter_carry)
    );
    
    // x_block_counter,
    wire [ADDR_WIDTH-1:0] read_addr_x1_counter_count = x_pixel_counter_count;
    wire read_addr_x1_counter_carry = x_pixel_counter_carry;

    // counter_model('read_enable_x_counters_2', width // 3, lambda: x_pixel_counter.get_count() == 0, lambda: False, increment=1, reset_value=2)
    wire [ADDR_WIDTH-1:0] read_addr_x2_counter_count;
    wire read_addr_x2_counter_enable = x_pixel_counter_enable & (~|x_pixel_counter_count);
    wire read_addr_x2_counter_carry;

    counter #(
        .WIDTH       (ADDR_WIDTH),
        .MAX_VALUE   (WIDTH_BLOCKS),
        .INCREMENT   (1),
        .RESET_VALUE (WIDTH_BLOCKS-1)
    ) read_addr_x2_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (read_addr_x2_counter_enable),
        .count       (read_addr_x2_counter_count),
        .carry       (read_addr_x2_counter_carry)
    );

    // counter_model('read_enable_y_pixel_counters_0', addr_high, lambda: end_of_line() and y_pixel_counter.get_count() == 1, lambda: False, increment=height//3),
    wire [ADDR_WIDTH-1:0] read_addr_y0_counter_count;
    wire read_addr_y0_counter_enable = x_block_counter_carry & x_block_counter_enable & (y_pixel_counter_count == 1);
    wire read_addr_y0_counter_carry;

    counter #(
        .WIDTH       (ADDR_WIDTH),
        .MAX_VALUE   (HEIGHT_BLOCKS * WIDTH_BLOCKS),
        .INCREMENT   (HEIGHT_BLOCKS),
        .RESET_VALUE (0)
    ) read_addr_y0_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (read_addr_y0_counter_enable),
        .count       (read_addr_y0_counter_count),
        .carry       (read_addr_y0_counter_carry)
    );

    // counter_model('read_enable_y_pixel_counters_1', addr_high, lambda: x_block_counter.get_carry() and x_pixel_counter.get_carry() and y_pixel_counter.get_count() == 2, lambda: False, increment=height//3),
    wire [ADDR_WIDTH-1:0] read_addr_y1_counter_count;
    wire read_addr_y1_counter_enable = x_block_counter_carry & x_block_counter_enable & (y_pixel_counter_count == 2);
    wire read_addr_y1_counter_carry;

    counter #(
        .WIDTH       (ADDR_WIDTH),
        .MAX_VALUE   (HEIGHT_BLOCKS * WIDTH_BLOCKS),
        .INCREMENT   (HEIGHT_BLOCKS),
        .RESET_VALUE (0)
    ) read_addr_y1_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (read_addr_y1_counter_enable),
        .count       (read_addr_y1_counter_count),
        .carry       (read_addr_y1_counter_carry)
    );
    
    // counter_model('read_enable_y_pixel_counters_2', addr_high, lambda: end_of_line() and y_pixel_counter.get_count() == 0, lambda: False, increment=height//3, reset_value=2)
    wire [ADDR_WIDTH-1:0] read_addr_y2_counter_count;
    wire read_addr_y2_counter_enable = x_block_counter_carry & x_block_counter_enable & (y_pixel_counter_count == 0);
    wire read_addr_y2_counter_carry;

    counter #(
        .WIDTH       (ADDR_WIDTH),
        .MAX_VALUE   (HEIGHT_BLOCKS * WIDTH_BLOCKS),
        .INCREMENT   (HEIGHT_BLOCKS),
        .RESET_VALUE ((HEIGHT_BLOCKS - 1) * WIDTH_BLOCKS)
    ) read_addr_y2_counter (
        .clk         (clk),
        .resetn      (resetn),
        .enable      (read_addr_y2_counter_enable),
        .count       (read_addr_y2_counter_count),
        .carry       (read_addr_y2_counter_carry)
    );
endmodule