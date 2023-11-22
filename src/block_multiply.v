module block_multiply(
    input [`BIT_W-1:0] inp_a, inp_b,
    input load_enable,
    input clk,
    input rst,
    input start,
    output reg done
);


reg[`BIT_W-1:0] buffer_A[0:9];
reg[3:0] buffer_A_cnt;
reg[`BIT_W-1:0] buffer_B[0:9];
reg[3:0] buffer_B_cnt;
reg[`BIT_W-1:0] buffer_result[0:9];

//State Machine Declaration 
reg [3:0] state;
localparam  IDLE = 4'd0, 
            LOAD = 4'd1, 
            COMPUTE = 4'd2, 
            STORE = 4'd3,
            SPLIT = 4'd4;

//TODO: instantiate the systolic array multiplier



//State Machine Logic 
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        buffer_A_cnt <= 4'd0;
        buffer_B_cnt <= 4'd0;
    end else begin
        case(state)
            IDLE: begin
                if (start) state <= LOAD;
            end
            LOAD: begin
                if(load_enable && buffer_A_cnt < 4'd10 && buffer_B_cnt < 4'd10) begin
                buffer_A[buffer_A_cnt] <= inp_a;
                buffer_B[buffer_B_cnt] <= inp_b;
                buffer_A_cnt <= buffer_A_cnt + 4'd1;
                buffer_B_cnt <= buffer_B_cnt + 4'd1;
                end
                
                if(buffer_A_cnt == 4'd9 && buffer_B_cnt == 4'd9) begin
                    state <= SPLIT;
                    buffer_A_cnt <= 4'd0;
                    buffer_B_cnt <= 4'd0;
                end

            end
            SPLIT: begin
 
            end
            COMPUTE: begin
                
            end
            STORE: begin
               
            end
            default: begin
                state <= IDLE;
            end
        endcase
    end
end


endmodule 
