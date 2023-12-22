module block_add(
    input clk,
    input rst,
    input start,
    input [9:0] start_row,
    input [9:0] start_col,
    input [`DATA_W-1:0] multiplied_block[0:`J*`K-1],
    input [`DATA_W-1:0] buffer_temp[0:`A_M*`B_N-1],
    output reg [`DATA_W-1:0] buffer_result[0:`A_M*`B_N-1],
    output reg block_add_done
);

reg [`J*`K-1:0] addition_complete;

// State Machine
reg [1:0] state;
localparam IDLE = 2'b00, ADD = 2'b01, DONE = 2'b10;

// Instantiate fadd modules
genvar i, j;
generate
    for (i = 0; i < `J; i = i + 1) begin : gen_i
        for (j = 0; j < `K; j = j + 1) begin : gen_j
            wire [`DATA_W-1:0] fadd_result;
            fadd fadd_unit(
                .a_in(buffer_temp[((start_row + i) * `B_N) + start_col + j]),
                .b_in(multiplied_block[i * `K + j]),
                .result(fadd_result)
            );

            // Sequential logic for result and completion
            always @(posedge clk) begin
                if (rst) begin
                    buffer_result[((start_row + i) * `B_N) + start_col + j] <= 0;
                    addition_complete[i * `K + j] <= 0;
                    //$display("buffer_result[%d] = %d", ((start_row + i) * `B_N) + start_col + j, buffer_result[((start_row + i) * `B_N) + start_col + j]);
                end else if (state == ADD) begin
                    if ((start_row + i) < `A_M && (start_col + j) < `B_N) begin
                        buffer_result[((start_row + i) * `B_N) + start_col + j] <= fadd_result;
                        addition_complete[i * `K + j] <= 1'b1;
                        //$display("buffer_result[%d] = %d", ((start_row + i) * `B_N) + start_col + j, buffer_result[((start_row + i) * `B_N) + start_col + j]);
                    end else begin
                        addition_complete[i * `K + j] <= 1'b0;
                    end
                end
            end
        end
    end
endgenerate

// State machine logic
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        block_add_done <= 1'b0;
    end else begin
        case (state)
            IDLE: if (start) state <= ADD;
            ADD: if (&addition_complete) state <= DONE;
            DONE: begin
                block_add_done <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
end

endmodule
