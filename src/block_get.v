module get_block(
    input clk,
    input rst,
    input [9:0] start_row,
    input [9:0] start_col,
    input [9:0] num_cols,
    input [`DATA_W-1:0] buffer[0:15], // Define the size properly
    output reg [`DATA_W-1:0] block[0:`J*`K-1] // Use parameter to define J, K and DATA_W
);

parameter J = `J; // Define the block rows
parameter K = `K; // Define the block columns

integer i, j;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < J*K; i = i + 1) begin
            block[i] <= 0;
        end
    end else begin
        for (i = 0; i < J; i = i + 1) begin
            for (j = 0; j < K; j = j + 1) begin
                //$display("start_row = %d, start_col = %d, num_cols = %d, i = %d, j = %d, block[%d] = %d, buffer[%d] = %d", start_row, start_col, num_cols, i, j, i*K + j, block[i*K + j], (start_row + i)*num_cols + (start_col + j), buffer[(start_row + i)*num_cols + (start_col + j)]);
                block[i*K + j] <= buffer[(start_row + i)*num_cols + (start_col + j)];
            end
        end
    end
end

endmodule
