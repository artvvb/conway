`timescale 1ns / 1ps
`default_nettype none
module top_tb;
    reg clk = 0;
    initial begin
        forever #10 clk = ~clk;
    end
    
    wire led;
    top top_inst (
        .clk(clk),
        .vga_r(),
        .vga_g(),
        .vga_b(),
        .vga_hs(),
        .vga_vs(),
        .led(led),
        .uart_tx(),
        .uart_rx()
    );

    initial begin
        $dumpfile("sim/top_tb.vcd");
        $dumpvars(0, top_tb);
        #1000;
        $display("Sim done");
        $finish();
    end
endmodule
