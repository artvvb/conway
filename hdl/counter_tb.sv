module counter_tb;
    logic clk = 0;
    always #5 clk = ~clk;
    logic reset;
    initial begin
        reset = 1;
        @(posedge clk) reset <= 0;
    end
    logic enable;
    logic [3:0] count;
    logic carry;
    counter #(
        .width(4),
        .reset_value(1),
        .increment(3),
        .max_value(15)
    ) dut (.*);
    initial begin
        enable = 0;
        @(posedge clk);
        enable <= 0;
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        enable <= 1;
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd4 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd7 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd10 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd13 && carry == 1) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd4 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd7 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd10 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd13 && carry == 1) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd4 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd7 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd10 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd13 && carry == 1) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd4 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd7 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd10 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd13 && carry == 1) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        enable <= 0;
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        #1 assert (count == 'd1 && carry == 0) else
            $fatal(1, "Something didn't match the expected result");
        @(posedge clk);
        $display("Test passed");
        $finish;
    end
endmodule
