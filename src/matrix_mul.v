module matrix_mul(
    input clk,
    input rst,
    input [`DATA_W-1:0] matrix_A[0:`A_M*`B_N-1],
    input [`DATA_W-1:0] matrix_B[0:`B_N*`A_M-1],
    output reg get_block_a,
    output reg get_block_b,
    output reg add_block,
    output reg operation_complete,
    output reg [`DATA_W-1:0] matrix_C[0:`A_M*`B_N-1]
)

// Define states
localparam IDLE        = 3'd0,
           GET_BLOCK_A = 3'd1,
           GET_BLOCK_B = 3'd2,
           MULTIPLY_BLOCK    = 3'd3,
           ACCUMULATE   = 3'd4,
           WRITE_BACK  = 3'd5,
           DONE        = 3'd6;

reg [2:0] state, next_state;
reg [9:0] i, l, r, result_row, result_col;
reg [`DATA_W-1:0] block[0:`J*`K-1] block_a;
reg [`DATA_W-1:0] block[0:`J*`K-1] block_b;

block_get block_get_A(
    .clk(clk),
    .rst(rst),
    .start(get_block_a),
    .start_row(i),
    .start_col(r),
    .num_cols(`A_P),
    .matrix_len(`A_M*`A_N),
    .buffer(matrix_A),
    .block(block_a)
);

block_get block_get_B(
    .clk(clk),
    .rst(rst),
    .start(get_block_b),
    .start_row(r),
    .start_col(l),
    .num_cols(`B_N),
    .matrix_len(`B_N*`B_P),
    .buffer(matrix_B),
    .block(block_b)
);

block_add block_add(
    .clk(clk),
    .rst(rst),
    .start(add_block),
    .start_row(`J),
    .start_col(`K),
    .num_cols(`B_N),
    .multiplied_block(block_b),
    .buffer_temp(block_a),
    .buffer_result(matrix_C)
);

// State transition logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (state)
        IDLE: begin
            i = 0, l=0, r=0;
            next_state = GET_BLOCK_A;
        end
        GET_BLOCK_A: begin
            // Assume a condition or a signal that indicates the block is ready
            if () begin
                // We've reached the end of the matrix A
                current_row = 10'd0;
                current_col = 10'd0;
                next_state = GET_BLOCK_B;
            end else begin
                next_state = GET_BLOCK_A;
            end
            //(current_row + `J) > `A_M && (current_col + `K ) > `A_P
        end
        GET_BLOCK_B: begin
            if () begin
                next_state = MULTIPLY_BLOCK;
            end else begin
                next_state = GET_BLOCK_B;
            end
            //(current_row + `J) > `B_P && (current_col + `K ) > `B_N
        end
        MULTIPLY_BLOCK: begin
            if (/* multiplication done */) begin
                next_state = ADD_BLOCK;
            end else begin
                next_state = MULTIPLY_BLOCK;
            end
        end
        ACCUMULATE: begin
            // Accumulate result
            // Update loop counters and check loop conditions
            if (/* accumulation complete */) begin
                // Check if we're done with all loops
                if (r >= p) begin
                    if (l >= n) begin
                        if (i >= m) begin
                            next_state = DONE
                        end else begin
                            i = i + `J;
                            next_state = GET_BLOCK_A;
                        end
                    end else begin
                        l = l + `K;
                        next_state = GET_BLOCK_A;
                    end
                    ;
                end else begin
                    r = r + `K;
                    next_state = GET_BLOCK_A; 
                end
            end else begin
                next_state = ACCUMULATE;
            end
        end
        WRITE_BACK: begin
            if (/* write back done */) begin
                // Check if we've processed the entire matrix
                if (/* entire matrix processed */) begin
                    next_state = DONE;
                end else begin
                    // Move to the next block
                    next_state = GET_BLOCK_A;
                end
            end else begin
                next_state = WRITE_BACK;
            end
        end
        DONE: begin
            next_state = IDLE;
        end
        default: begin
            next_state = IDLE;
        end
    endcase
end  

always @(posedge clk or posedge rst) begin
    if(rst) begin
        i = 10'd0;
        l = 10'd0;
        r = 10'd0;
    end else begin 
        case(state)
        GET_BLOCK_A: begin
            get_block_a = 1'b1;
        end
        GET_BLOCK_B: begin
            get_block_b = 1'b1;
        end
        ACCUMULATE: begin
        end
        endcase 
    end
end 


endmodule 