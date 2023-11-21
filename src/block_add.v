module block_add(
    input clk, 
    input rst,
    input [9:0] start_row,
    input [9:0] start_col,
    input [9:0] num_cols,
    input [`DATA_W-1:0] multiplied_block[0:`J*`K-1],
    input [`DATA_W-1:0] buffer_temp[0:15],
    output reg [`DATA_W-1:0] buffer_result[0:`A_M*`B_N-1]
);

// Instantiate fadd modules for each element of the block
genvar i, j;
generate
    for (i = 0; i < `J; i = i + 1) begin : gen_i
        for (j = 0; j < `K; j = j + 1) begin : gen_j
            wire [`DATA_W-1:0] fadd_result; // Temporary wire for this fadd instance
            fadd fadd_unit(
                .a_in(buffer_temp[start_row * num_cols + start_col + i * num_cols + j]),  // Assuming `num_cols` is the total number of columns in the matrix
                .b_in(multiplied_block[i * `K + j]),
                .result(fadd_result)
            );
            // Use non-blocking assignment inside always block to assign the result to buffer_result
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    buffer_result[start_row * num_cols + start_col + i * num_cols + j] <= 0;
                end else begin
                    // Check if the result indices are within the matrix dimensions
                    if ((start_row + i) < `A_M && (start_col + j) < `B_N) begin
                        buffer_result[start_row * num_cols + start_col + i * num_cols + j] <= fadd_result;
                    end
                end
            end
        end
    end
endgenerate

endmodule 