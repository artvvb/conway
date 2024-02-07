module top (
    input  wire clk,
    output wire [3:0] vga_r,
    output wire [3:0] vga_g,
    output wire [3:0] vga_b,
    output wire vga_hs,
    output wire vga_vs,
    output wire led,
    output wire uart_tx,
    input  wire uart_rx
);
    assign vga_r = 0;
    assign vga_g = 0;
    assign vga_b = 0;
    assign vga_hs = 0;
    assign vga_vs = 0;
    assign uart_tx = 0;

    wire carry;
    counter #(
        .WIDTH($clog2(32'd50000000)),
        .MAX_VALUE(32'd49999999),
        .INCREMENT(1),
        .RESET_VALUE('b0)
    ) counter_inst (
        .clk    (clk),
        .resetn (1'b1),
        .enable (1'b1),
        .count  (),
        .carry  (carry)
    );

    reg led_reg = 1'b0;
    always@(posedge clk) begin
        if (carry == 1'b1) begin
            led_reg <= ~led_reg;
        end
    end

    assign led = led_reg;
endmodule