module matrix_mul(
    input clk,
    input rst,
    input [`DATA_W-1:0] matrix_A[0:`A_M*`B_P-1],
    input [`DATA_W-1:0] matrix_B[0:`B_P*`B_N-1],
    output reg get_block_a,
    output reg get_block_b,
    output reg add_block,
    output reg mul_block,
    output reg mul_load,
    output reg operation_complete,
    output reg [`DATA_W-1:0] matrix_C[0:`A_M*`B_N-1]
);

// Define states
localparam IDLE        = 3'd0,
           GET_BLOCKS = 3'd1,
           MULTIPLY_BLOCK    = 3'd2,
           ACCUMULATE   = 3'd3,
           WRITE_BACK  = 3'd4,
           DONE        = 3'd5,
           MULTIPLY_WAIT = 3'd6;

reg [2:0] state, next_state;
reg [9:0] i, l, r, result_row, result_col; // this is for the loop counters
wire [`DATA_W-1:0] block_a[0:`J*`K-1]; // does not work if reg type because because we are feeding this is output to the block
wire [`DATA_W-1:0] block_b[0:`J*`K-1];
wire [`DATA_W-1:0] mul_result[0:`J*`K-1];

// Signals to indicate the completion of operations
reg block_get_a_done;
reg block_get_b_done;
reg block_multiply_done;
reg block_add_done;

localparam A_cols = 10'd5;
localparam A_size = 10'd10;

block_get block_get_A(
    .clk(clk),
    .rst(rst),
    .start(get_block_a),
    .start_row(i),
    .start_col(r),
    .num_cols(A_cols),
    .matrix_len(A_size),
    .buffer(matrix_A),
    .block(block_a),
    .block_get_done(block_get_a_done)
);

localparam B_cols = 10'd2;
localparam B_size = 10'd10;

block_get block_get_B(
    .clk(clk),
    .rst(rst),
    .start(get_block_b),
    .start_row(r),
    .start_col(l),
    .num_cols(B_cols),
    .matrix_len(B_size),
    .buffer(matrix_B),
    .block(block_b),
    .block_get_done(block_get_b_done)
);


block_add block_add(
    .clk(clk),
    .rst(rst),
    .start(add_block),
    .start_row(i),
    .start_col(l),
    .multiplied_block(block_b),
    .buffer_temp(block_a),
    .buffer_result(matrix_C),
    .block_add_done(block_add_done)
);

systolic_array systolic_array(
    .block_a(block_a),
    .block_b(block_b),
    .clk(clk),
    .rst(rst),
    .start(mul_block),
    .load(mul_load),
    .block_result(mul_result)
);

// Synchronous state transition logic
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // On reset, set the state to IDLE
        state <= IDLE;
    end else begin
        // On clock edge, transition to the next state
        state <= next_state;
    end
end

// The actual FSM states
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset logic
        state <= IDLE;
        next_state <= IDLE;
        i <= 0;
        l <= 0;
        r <= 0;
        get_block_a <= 0;
        get_block_b <= 0;
        add_block <= 0;
        mul_block <= 0;
        mul_load <= 0;
        operation_complete <= 0;
        // Reset other registers if necessary
    end else begin
        case (state)
            IDLE: begin
                if (~rst) begin 
                    i <= 0;
                    l <= 0;
                    r <= 0;
                    get_block_a <= 0;
                    get_block_b <= 0;
                    add_block <= 0;
                    mul_block <= 0;
                    mul_load <= 0;
                    operation_complete <= 0;
                    next_state = GET_BLOCKS;
                end
            end
            GET_BLOCKS: begin
                get_block_a <= 1;
                get_block_b <= 1;
                if (block_get_a_done && block_get_b_done) begin
                    get_block_a <= 0;
                    get_block_b <= 0;
                    next_state = ACCUMULATE;
                end
            end
            MULTIPLY_BLOCK: begin
                mul_load <= 1;
                next_state = MULTIPLY_WAIT;
            end
            MULTIPLY_WAIT: begin
                mul_load <= 0;
                if (block_multiply_done) begin
                    mul_block <= 0;
                    next_state = ACCUMULATE;
                end
            end
            ACCUMULATE: begin
                add_block <= 1;
                // Wait for the add operation to complete
                if (block_add_done) begin
                    add_block <= 0;
                    // Update your loop counters here
                    r <= r + `K;
                    if (r >= `A_P) begin
                        r <= 0;
                        l <= l + `K;
                        if (l >= `B_N) begin
                            l <= 0;
                            i <= i + `J;
                            if (i >= `A_M) begin
                                next_state = DONE;
                            end else begin
                                next_state = GET_BLOCKS;
                            end
                        end else begin
                            next_state = GET_BLOCKS;
                        end
                    end else begin
                        next_state = GET_BLOCKS;
                    end
                end
            end
            DONE: begin
                operation_complete <= 1;
                // Optionally, you can loop back to IDLE or hold in DONE state
                next_state = IDLE; // Or hold in DONE state if you prefer
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end
end


endmodule 