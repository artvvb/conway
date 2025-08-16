`include "counter.sv"

module vga (
    input logic clk, // 25 MHz pixel clock OR 100 MHz system clock
    input logic reset,

    input wire enable_strobe, // enable every couple cycles to divide down a faster system clock

    input logic pixel_tvalid,
    output logic pixel_tready,
    input logic [11:0] pixel_tdata, // {r[3:0], g[3:0], b[3:0]}

    output logic [3:0] vga_r,
    output logic [3:0] vga_g,
    output logic [3:0] vga_b,
    output logic vga_hs,
    output logic vga_vs,

    output logic error,
    output logic running
);
    // Horizontal Timings
    localparam integer h_active_pixels  = 640;
    localparam integer h_front_porch    = 16;
    localparam integer h_sync_width     = 96;
    localparam integer h_back_porch     = 48;
    localparam integer h_blanking_total = 160;
    localparam integer h_total_pixels   = 800;
    localparam integer h_sync_polarity  = 1'b0;

    // Vertical Timings
    localparam integer v_active_lines   = 480;
    localparam integer v_front_porch    = 10;
    localparam integer v_sync_width     = 2;
    localparam integer v_back_porch     = 33;
    localparam integer v_blanking_total = 45;
    localparam integer v_total_lines    = 525;
    localparam integer v_sync_polarity  = 1'b0;

    // Internal Signals
    logic [9:0] x_count;
    logic x_carry;
    logic [9:0] y_count;
    logic y_carry;
    logic active_video;

    assign pixel_tready = active_video;

    // State Codes
    typedef enum integer { 
        STATE_IDLE,
        STATE_RUNNING,
        STATE_ERROR // Throw an error condition when pixel data underflows. tvalid is only allowed to be low when tready is low.
    } state_t;
    state_t state = STATE_IDLE;

    // Implementation
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= STATE_IDLE;
        end else case (state)
        STATE_IDLE:
            if (pixel_tvalid)
                state <= STATE_RUNNING; // we hold off on generating 
        STATE_RUNNING:
            if (!pixel_tvalid && pixel_tready)
                state <= STATE_ERROR;
        STATE_ERROR:
            state <= state; // require manual reset
        default:
            state <= STATE_IDLE;
        endcase
    end

    assign error = (state == STATE_ERROR);
    assign running = (state == STATE_RUNNING);

    counter #(
        .width       ($clog2(h_total_pixels-1)),
        .max_value   (h_total_pixels),
        .increment   (1),
        .reset_value (0)
    ) x_counter (
        .clk    (clk),
        .reset  (reset || !running),
        .enable (enable_strobe),
        .count  (x_count),
        .carry  (x_carry)
    );

    counter #(
        .width       ($clog2(v_total_lines-1)),
        .max_value   (v_total_lines),
        .increment   (1),
        .reset_value (0)
    ) y_counter (
        .clk    (clk),
        .reset  (reset || !running),
        .enable (enable_strobe && x_carry),
        .count  (y_count),
        .carry  (y_carry)
    );

    always_comb begin
        if (x_count < h_active_pixels && y_count < v_active_lines)
            active_video = 1;
        else
            active_video = 0;
    end


    always_ff @(posedge clk) begin
        if (reset || !running) begin
            vga_r <= 'b0;
            vga_g <= 'b0;
            vga_b <= 'b0;
            vga_hs <= 'b1;
            vga_vs <= 'b1;
        end else begin
            if (active_video) begin
                vga_r <= pixel_tdata[11:8];
                vga_g <= pixel_tdata[7:4];
                vga_b <= pixel_tdata[3:0];
            end else begin
                vga_r <= 4'b0;
                vga_g <= 4'b0;
                vga_b <= 4'b0;
            end

            if (x_count >= h_active_pixels + h_front_porch &&
                x_count < h_active_pixels + h_front_porch + h_sync_width) begin
                vga_hs <= h_sync_polarity;
            end else begin
                vga_hs <= !h_sync_polarity;
            end
            if (y_count >= v_active_lines + v_front_porch &&
                y_count < v_active_lines + v_front_porch + v_sync_width) begin
                vga_vs <= v_sync_polarity;
            end else begin
                vga_vs <= !v_sync_polarity;
            end
        end
    end
endmodule