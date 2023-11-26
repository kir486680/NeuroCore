module block_add(
    input clk, 
    input rst,
    input start,
    input [9:0] start_row,
    input [9:0] start_col,
    input [`DATA_W-1:0] multiplied_block[0:`J*`K-1], // This is the block of matrix B multiplied by the block of matrix A
    input [`DATA_W-1:0] buffer_temp[0:`A_M*`B_N-1], // the result matrix
    output reg [`DATA_W-1:0] buffer_result[0:`A_M*`B_N-1], //updated result matrix
    output reg block_add_done // Indicates when addition is complete
);

// Internal signal to keep track of addition completion for each element
reg [`J*`K-1:0] addition_complete;

// Combinational logic for block_add_done
always @(*) begin
    if (rst) begin
        // Reset block_add_done only on reset
        block_add_done = 1'b0;
    end else if (&addition_complete) begin
        // Set block_add_done high when all additions are complete
        block_add_done = 1'b1;
    end else begin
        // Keep block_add_done low otherwise
        block_add_done = 1'b0;
    end
end

// Instantiate fadd modules for each element of the block
genvar i, j;
generate
    for (i = 0; i < `J; i = i + 1) begin : gen_i
        for (j = 0; j < `K; j = j + 1) begin : gen_j
            wire [`DATA_W-1:0] fadd_result; // Temporary wire for this fadd instance
            fadd fadd_unit(
                .a_in(buffer_temp[((start_row + i) * `B_N) + start_col + j]),  // Assuming `num_cols` is the total number of columns in the matrix
                .b_in(multiplied_block[i * `K + j]),
                .result(fadd_result)
            );

            // Combinational logic for assigning results to buffer_result
            always @(*) begin
                if (rst) begin
                    buffer_result[((start_row + i) * `B_N) + start_col + j] = 0;
                    addition_complete[i * `K + j] = 0;
                end else if(start) begin
                    if ((start_row + i) < `A_M && (start_col + j) < `B_N) begin
                        buffer_result[((start_row + i) * `B_N) + start_col + j] = fadd_result;
                        addition_complete[i * `K + j] = 1'b1;
                    end else begin
                        addition_complete[i * `K + j] = 1'b0;
                    end
                end else begin
                    // No action if not reset or start
                end
            end
        end
    end
endgenerate

endmodule
