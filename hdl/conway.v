module conway (
    input wire center_value,
    input wire [7:0] neighbor_values,
    output reg data_out
);
    reg [3:0] neighbor_value_weight;

    always @(*) begin
        neighbor_value_weight = neighbor_values[0] +
                                neighbor_values[1] +
                                neighbor_values[2] +
                                neighbor_values[3] +
                                neighbor_values[4] +
                                neighbor_values[5] +
                                neighbor_values[6] +
                                neighbor_values[7];
    end

    always @(*) begin
        if (center_value == 1'b0) begin
            if (neighbor_weight == 4'd3) begin
                data_out = 1'b1;
            end
        end else begin
            if (neighbor_weight < 4'd2) begin
                data_out = 1'b0;
            end else if (neighbor_weight > 4'd3) begin
                data_out = 1'b0;
            end else begin
                data_out = 1'b1;
            end
        end
    end
endmodule