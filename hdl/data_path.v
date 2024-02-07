module data_path #(
    parameter integer ADDR_WIDTH = 2,
    parameter integer HEIGHT_PIXELS = 6,
    parameter integer WIDTH_PIXELS = 6,
    parameter integer HEIGHT_BLOCKS = 2, // HEIGHT_PIXELS / PIXELS_PER_BLOCK
    parameter integer WIDTH_BLOCKS = 2  // WIDTH_PIXELS / PIXELS_PER_BLOCK
) (
    input wire clk,
    input wire resetn,
    
    input wire [8:0] write_enable,
    input wire [8:0] read_enable,
    input wire [ADDR_WIDTH-1:0] write_addr, // route same address to all memories, only one is enabled at a time
    input wire [ADDR_WIDTH-1:0] read_addr_0,
    input wire [ADDR_WIDTH-1:0] read_addr_1,
    input wire [ADDR_WIDTH-1:0] read_addr_2,
    input wire [ADDR_WIDTH-1:0] read_addr_3,
    input wire [ADDR_WIDTH-1:0] read_addr_4,
    input wire [ADDR_WIDTH-1:0] read_addr_5,
    input wire [ADDR_WIDTH-1:0] read_addr_6,
    input wire [ADDR_WIDTH-1:0] read_addr_7,
    input wire [ADDR_WIDTH-1:0] read_addr_8,
    input wire frame_buffer_select,

    output wire data_out
);
    localparam frame_buffer_0_write_select = 1;
    localparam frame_buffer_1_write_select = 0;

    wire write_data;

    wire [1:0] frame_buffer_write_enable;
    wire [1:0] frame_buffer_read_enable;
    assign frame_buffer_write_enable[0] = frame_buffer_0_write_select ^ frame_buffer_select;
    assign frame_buffer_write_enable[1] = ~frame_buffer_write_enable[0];
    assign frame_buffer_read_enable = ~frame_buffer_write_enable;

    reg [1:0] frame_buffer_write_enable_last;
    reg [1:0] frame_buffer_read_enable_last;
    reg [8:0] write_enable_last;
    always @(posedge clk) begin
        if (resetn == 1'b0) begin
            frame_buffer_write_enable_last <= 1'b0;
            frame_buffer_read_enable_last <= 1'b0;
            write_enable_last <= 'b0;
        end else begin
            frame_buffer_write_enable_last <= frame_buffer_write_enable;
            frame_buffer_read_enable_last <= frame_buffer_read_enable;
            write_enable_last <= write_enable;
        end
    end // maybe shouldn't be doing lasts in here?

    wire [8:0] center_select = write_enable_last; // FIXME: center needs to be one cycle ahead of write_enable
    wire [8:0] frame_buffer_read_data [1:0];

    wire [ADDR_WIDTH-1:0] read_addr [8:0];
    assign read_addr[0] = read_addr_0;
    assign read_addr[1] = read_addr_1;
    assign read_addr[2] = read_addr_2;
    assign read_addr[3] = read_addr_3;
    assign read_addr[4] = read_addr_4;
    assign read_addr[5] = read_addr_5;
    assign read_addr[6] = read_addr_6;
    assign read_addr[7] = read_addr_7;
    assign read_addr[8] = read_addr_8;
    
    reg center_value;
    wire [8:0] read_data;
    reg [7:0] neighbor_values;

    genvar bram_i;
    genvar frame_buffer_i;

    generate
        for (bram_i = 0; bram_i < 9; bram_i = bram_i + 1) begin
            for (frame_buffer_i = 0; frame_buffer_i < 2; frame_buffer_i = frame_buffer_i + 1) begin
                bram #(
                    .DATA_WIDTH (1),
                    .DEPTH      (HEIGHT_BLOCKS * WIDTH_BLOCKS - 1),
                    .ADDR_WIDTH (ADDR_WIDTH)
                ) frame_buffer_i_bram_i (
                    .clk          (clk),
                    .write_addr   (write_addr),
                    .write_enable (frame_buffer_write_enable[frame_buffer_i] & write_enable[bram_i]),
                    .write_data   (write_data),
                    .read_addr    (read_addr[bram_i]),
                    .read_enable  (frame_buffer_read_enable[frame_buffer_i] & read_enable[bram_i]),
                    .read_data    (frame_buffer_read_data[frame_buffer_i][bram_i])
                );
            end
        end
    endgenerate


    assign read_data = (frame_buffer_read_enable_last[frame_buffer_select]) ? frame_buffer_read_data[1] : frame_buffer_read_data[0];
    
    always @(*) begin
        casez (center_select)
        9'b000000001: center_value = read_data[0];
        9'b00000001z: center_value = read_data[1];
        9'b0000001zz: center_value = read_data[2];
        9'b000001zzz: center_value = read_data[3];
        9'b00001zzzz: center_value = read_data[4];
        9'b0001zzzzz: center_value = read_data[5];
        9'b001zzzzzz: center_value = read_data[6];
        9'b01zzzzzzz: center_value = read_data[7];
        9'b1zzzzzzzz: center_value = read_data[8];
        default: center_value = 1'b0;
        endcase
    end

    always @(*) begin
        casez (center_select)
        9'b000000001: neighbor_values = read_data[8:1];
        9'b00000001z: neighbor_values = {read_data[8:2], read_data[0]};
        9'b0000001zz: neighbor_values = {read_data[8:3], read_data[1:0]};
        9'b000001zzz: neighbor_values = {read_data[8:4], read_data[2:0]};
        9'b00001zzzz: neighbor_values = {read_data[8:5], read_data[3:0]};
        9'b0001zzzzz: neighbor_values = {read_data[8:6], read_data[4:0]};
        9'b001zzzzzz: neighbor_values = {read_data[8:7], read_data[5:0]};
        9'b01zzzzzzz: neighbor_values = {read_data[8], read_data[6:0]};
        9'b1zzzzzzzz: neighbor_values = read_data[7:0];
        default: neighbor_values = 'b0;
        endcase
    end

    conway conway_inst (
        .center_value    (center_value),
        .neighbor_values (neighbor_values),
        .data_out        (write_data)
    );

    assign data_out = write_data;
endmodule