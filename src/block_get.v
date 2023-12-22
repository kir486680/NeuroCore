module block_get(
    input clk,
    input rst,
    input start,
    input [9:0] start_row,
    input [9:0] start_col,
    input [9:0] num_cols,
    input [9:0] matrix_len,
    input [`DATA_W-1:0] buffer[0:9], // the original matrix
    output reg [`DATA_W-1:0] block[0:`J*`K-1], // Use parameter to define J, K and DATA_W
    output reg block_get_done // Indicates when block get is complete
);

parameter J = `J; // Define the block rows
parameter K = `K; // Define the block columns

reg [`J*`K-1:0] get_complete;

integer i, j;

// Combinational logic for block_get_done and block assignment
always @(*) begin
    if (rst) begin
        block_get_done = 1'b0;
        for (i = 0; i < J*K; i = i + 1) begin
            block[i] = 0;
            get_complete[i] = 1'b0;
        end
    end else if (start) begin
        block_get_done = 1'b0;
        for (i = 0; i < J; i = i + 1) begin
            for (j = 0; j < K; j = j + 1) begin
                if (start_row + i < (matrix_len / num_cols) && start_col + j < num_cols) begin
                    block[i*K + j] = buffer[(start_row + i)*num_cols + (start_col + j)];
                    get_complete[i*K + j] = 1'b1;
                end else begin
                    get_complete[i*K + j] = 1'b1;
                end
            end
        end
        block_get_done = &get_complete;
    end else begin
        for (i = 0; i < J*K; i = i + 1) begin
            get_complete[i] = 1'b0;
        end
        block_get_done = 1'b0;
    end
end

endmodule
