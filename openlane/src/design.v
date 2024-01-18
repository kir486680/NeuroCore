
`include "define.v"

module NeuralChip (
    input 	     CLK, // system clock 
    input 	     RESET, // reset button
    input 	     RXD, // UART receive
    output 	     TXD         // UART transmit
    );

    wire [4:0] count;
    reg [`DATA_W-1:0] block_a1, block_a2, block_a3, block_a4, block_b1, block_b2, block_b3, block_b4;
    wire [`DATA_W-1:0] block_result1, block_result2, block_result3, block_result4;
    reg start, load;
    wire block_multiply_done;
    systolic_array systolic_array_inst (
         .block_a1(block_a1),
         .block_a2(block_a2),
         .block_a3(block_a3),
         .block_a4(block_a4),
         .block_b1(block_b1),
         .block_b2(block_b2),
         .block_b3(block_b3),
         .block_b4(block_b4),
         .clk(CLK),
         .rst(RESET),
         .start(start),
         .load(load),
         .counter(count),
         .block_multiply_done(block_multiply_done),
         .block_result1(block_result1),
         .block_result2(block_result2),
         .block_result3(block_result3),
         .block_result4(block_result4)
            //.LEDS(LEDS)
     );

     reg send_data =0;

     localparam IDLE_MUL = 0, LOAD = 1, START = 2, DONE_MUL = 3;
     reg [2:0] current_mul_state = IDLE_MUL;
     reg [2:0] next_mul_state = IDLE_MUL;
     
    // Update current_mul_state and send_data in a single always block
     always @(posedge CLK) begin
        if (!RESET) begin
            current_mul_state <= IDLE_MUL;
            send_data <= 0;  // Reset send_data on RESET
        end
        else begin
            current_mul_state <= next_mul_state;
            // Update send_data only in the sequential block
            if (current_mul_state == START && block_multiply_done) begin
                send_data <= 1;
            end
            else if(send_data == DONE_SEND)begin
                send_data <= 0;
            end
        end
    end


     // Calculate next state and send_data based on current state and inputs
     always @(*) begin
        next_mul_state = IDLE_MUL;
         case (current_mul_state)
             IDLE_MUL: begin
                 if (state_receive == DONE_RECEIVE) begin
                     next_mul_state = LOAD;
                 end else begin
                     next_mul_state = IDLE_MUL;
                 end
            
             end
             LOAD: begin
                 next_mul_state = START;
                 load = 1;
                 start = 0;
                 // Other LOAD state logic
             end
             START: begin
                    load = 0;
                    start = 1;
                 if (block_multiply_done) begin 
                     next_mul_state = DONE_MUL;
                     //send_data = 1;
                 end else
                     next_mul_state = START;
                 // Other START state logic
             end
             DONE_MUL: begin
                 // DONE_MUL state logic
                next_mul_state = IDLE_MUL;
             end
             default: next_mul_state = IDLE_MUL;
         endcase
     end



    // UART stuff 
    wire [7:0] rx_data;
    wire       rx_ready;
    wire       rx_ack;
    wire       rx_error;
    reg [7:0] tx_data;
    wire       tx_ready;
    wire       tx_ack;
    UART #(
        .FREQ(12_000_000),
        .BAUD(9600)
    ) uart (
        .reset(RESET),
        .clk(CLK),
        .rx_i(RXD),
        .rx_data_o(rx_data),
        .rx_ready_o(rx_ready),
        .rx_ack_i(rx_ack),
        .rx_error_o(rx_error),
        .tx_o(TXD),
        .tx_data_i(tx_data),
        .tx_ready_i(tx_ready),
        .tx_ack_o(tx_ack)
    );

    reg [7:0] received_data = 8'h00;
    reg data_received = 1'b0;
    reg data_processed = 1'b0;

    localparam IDLE = 0, RECEIVE_BR1_HIGH = 1, RECEIVE_BR1_LOW = 2, 
    RECEIVE_BR2_HIGH = 3, RECEIVE_BR2_LOW = 4, 
    RECEIVE_BR3_HIGH = 5, RECEIVE_BR3_LOW = 6,
    RECEIVE_BR4_HIGH = 7, RECEIVE_BR4_LOW = 8, 
    RECEIVE_BR5_HIGH = 9, RECEIVE_BR5_LOW = 10,
    RECEIVE_BR6_HIGH = 11, RECEIVE_BR6_LOW = 12,
    RECEIVE_BR7_HIGH = 13, RECEIVE_BR7_LOW = 14,
    RECEIVE_BR8_HIGH = 15, RECEIVE_BR8_LOW = 16,
    DONE_RECEIVE = 17;
    //now need to keep track of the state of the data that is being received
    reg [5:0] state_receive = IDLE;
   
    always @(posedge CLK) begin
        if (!RESET) begin
            data_received <= 1'b0;
            data_processed <= 1'b0;
            received_data <= 8'h00;
            state_receive <= IDLE;

        end
        else begin
        if (rx_ready && !data_received) begin
            // New data is available and not yet processed
            received_data <= rx_data; // Store the incoming data
            data_received <= 1'b1;    // Set flag to indicate data is ready to be processed
        // state machine to receive the data
            case (state_receive)
            IDLE: begin
                
                if (rx_data == 8'b11111110) begin
                    data_processed <= 1'b1;
                    state_receive <= RECEIVE_BR1_HIGH;
                 
                end
            end
            RECEIVE_BR1_HIGH: begin
                block_a1[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR1_LOW;
            end
            RECEIVE_BR1_LOW: begin
                block_a1[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR2_HIGH;
            end
            RECEIVE_BR2_HIGH: begin
                block_a2[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR2_LOW;
            end
            RECEIVE_BR2_LOW: begin
                block_a2[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR3_HIGH;
            end
            RECEIVE_BR3_HIGH: begin
                block_a3[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR3_LOW;
            end
            RECEIVE_BR3_LOW: begin
                block_a3[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR4_HIGH;
            end
            RECEIVE_BR4_HIGH: begin
                block_a4[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR4_LOW;
            end
            RECEIVE_BR4_LOW: begin
                block_a4[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR5_HIGH;
            end
            RECEIVE_BR5_HIGH: begin
                block_b1[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR5_LOW;
            end
            RECEIVE_BR5_LOW: begin
                block_b1[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR6_HIGH;
            end
            RECEIVE_BR6_HIGH: begin
                block_b2[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR6_LOW;
            end
            RECEIVE_BR6_LOW: begin
                block_b2[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR7_HIGH;
            end
            RECEIVE_BR7_HIGH: begin
                block_b3[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR7_LOW;
            end
            RECEIVE_BR7_LOW: begin
                block_b3[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR8_HIGH;
            end
            RECEIVE_BR8_HIGH: begin
                block_b4[15:8] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= RECEIVE_BR8_LOW;
            end
            RECEIVE_BR8_LOW: begin
                block_b4[7:0] <= rx_data;
                data_processed <= 1'b1;
                state_receive <= DONE_RECEIVE;
                
            end
            DONE_RECEIVE: begin
                if (rx_data == 8'b11111111) begin
                    state_receive <= IDLE;
                    data_processed <= 1'b1;
                end
            end
        endcase
        end
    end
        // Once data is processed, reset the flag
        if (data_processed) begin // Assuming data_processed is set once you're done processing
            data_received <= 1'b0;
            data_processed <= 1'b0;
        end
    end

// Acknowledge reception to UART module
    assign rx_ack = rx_ready && !data_received;


    reg [7:0] data_to_send = 8'h00;
    reg data_available = 1'b0;
    
// Define states
    localparam IDLE_SEND = 0, SEND_BR1_HIGH = 1, SEND_BR1_LOW = 2, 
    SEND_BR2_HIGH = 3, SEND_BR2_LOW = 4, 
    SEND_BR3_HIGH = 5, SEND_BR3_LOW = 6,
    SEND_BR4_HIGH = 7, SEND_BR4_LOW = 8, DONE_SEND = 9;

    reg [3:0] send_state = IDLE_SEND;


    always @(posedge CLK) begin
        if(!RESET) begin
            data_to_send <= 8'h00;
            data_available <= 1'b0;
            send_state <= IDLE_SEND;
        end
        else begin

        if(send_data) begin
        if (!data_available && tx_ack && received_data == 8'b11111111) begin
            // Load new data to send
            data_available <= 1'b1;
            
            case (send_state)
                IDLE_SEND: begin
                    tx_data <= 8'b11111110;
                    send_state <= SEND_BR1_HIGH;
                end
                SEND_BR1_HIGH: begin
                    tx_data <= block_result1[15:8];
                    send_state <= SEND_BR1_LOW;
                end
                SEND_BR1_LOW: begin
                    tx_data <= block_result1[7:0];
                    send_state <= SEND_BR2_HIGH;
                end
                SEND_BR2_HIGH: begin
                    tx_data <= block_result2[15:8];
                    send_state <= SEND_BR2_LOW;
                end
                SEND_BR2_LOW: begin
                    tx_data <= block_result2[7:0];
                    send_state <= SEND_BR3_HIGH;
                end
                SEND_BR3_HIGH: begin
                    tx_data <= block_result3[15:8];
                    send_state <= SEND_BR3_LOW;
                end
                SEND_BR3_LOW: begin
                    tx_data <= block_result3[7:0];
                    send_state <= SEND_BR4_HIGH;
                end
                SEND_BR4_HIGH: begin
                    tx_data <= block_result4[15:8];
                    send_state <= SEND_BR4_LOW;
                end
                SEND_BR4_LOW: begin
                    tx_data <= block_result4[7:0];
                    send_state <= DONE_SEND;
                end
                DONE_SEND: begin
                    tx_data <= 8'b11111111;
                    send_state <= IDLE_SEND;
                end
            endcase

        end
        else if (tx_ready && data_available) begin
            data_available <= 1'b0; // Reset to load next data chunk
        end
    end
    end
    end
    
    assign tx_ready = data_available; // Only ready when new data is loaded


endmodule

//send all ones 11111111 from pc to show that the mult result data has been sent 
//send all ones 11111111 from controller to show the last piece of the data has been sent to pc 
// send b111111110 from controller to how that we are beginning to send the data to pc.



module systolic_array (
    input [`DATA_W-1:0] block_a1, // the block of matrix A
    input [`DATA_W-1:0] block_a2, // the block of matrix A
    input [`DATA_W-1:0] block_a3, // the block of matrix A
    input [`DATA_W-1:0] block_a4, // the block of matrix A
    input [`DATA_W-1:0] block_b1, // the block of matrix B
    input [`DATA_W-1:0] block_b2, // the block of matrix B
    input [`DATA_W-1:0] block_b3, // the block of matrix B
    input [`DATA_W-1:0] block_b4, // the block of matrix B
    input clk, rst, start, load,
    output reg [4:0] counter,
    output reg block_multiply_done,
    output reg [`DATA_W-1:0] block_result1, // the result matrix
    output reg [`DATA_W-1:0] block_result2, // the result matrix
    output reg [`DATA_W-1:0] block_result3, // the result matrix
    output reg [`DATA_W-1:0] block_result4, // the result matrix

);

    wire [`DATA_W-1:0] block_a[0:`J*`K-1]; // the block of matrix A
    wire [`DATA_W-1:0] block_b[0:`J*`K-1]; // the block of matrix B
    assign block_a[0] = block_a1;
    assign block_a[1] = block_a2;
    assign block_a[2] = block_a3;
    assign block_a[3] = block_a4;
    assign block_b[0] = block_b1;
    assign block_b[1] = block_b2;
    assign block_b[2] = block_b3;
    assign block_b[3] = block_b4;

        // Parameters for dimensions
    parameter ROWS = `J; // Number of rows
    parameter COLS = `K; // Number of columns

    wire [`DATA_W-1:0] north_south_wires[ROWS-1:0][COLS-1:0];
    wire [`DATA_W-1:0] east_west_wires[ROWS-1:0][COLS-1:0];


    //create a wire to connect to the output of all the members of last row north_sout
    wire [`DATA_W-1:0] north_south_wires_last_row[COLS-1:0];
    genvar k;
    generate
        for (k = 0; k < COLS; k = k + 1) begin: assign_last_row
            assign north_south_wires_last_row[k] = north_south_wires[ROWS-1][k];
        end
    endgenerate

    // Shift registers
    reg [`DATA_W-1:0] shift_registers[ROWS-1:0][COLS+ROWS-1:0];
    reg [`DATA_W-1:0] shift_registers_last_row[ROWS+ROWS-2:0][COLS-1:0];//takes 2n-1 to complete the product

    
    // Load matrix A into shift registers with offset when compute is true
    integer i;
    integer j;
    always @(posedge clk) begin
        if (!rst) begin
            for (i = 0; i < ROWS; i++) begin
                for (j = 0; j < COLS + ROWS - 1; j++) begin
                    shift_registers[i][j] <= `DATA_W'd0;
                end
            end
            for (i = 0; i < ROWS + ROWS -1; i++) begin
                for (j = 0; j < COLS; j++) begin
                    shift_registers_last_row[i][j] <= `DATA_W'd0;
                end
            end
            counter <= 5'd0;
            block_multiply_done <= 1'b0;
           
        end
        else if (load) begin
            block_multiply_done <= 1'b0;
            for (i = 0; i < ROWS; i++) begin
        // Initialize the entire row to 0 first
                for (j = 0; j < COLS + ROWS - 1; j++) begin
                    shift_registers[i][j] <= `DATA_W'd0;
                end
                // Load matrix A into the shift register
                for (j = 0; j < COLS; j++) begin
                    shift_registers[i][j + i] <= block_a[i * COLS + j];
                end
            end
        end
        else if (start) begin
            for (i = 0; i < ROWS; i++) begin
                for (j = 0; j < COLS + ROWS - 1; j++) begin
                    shift_registers[i][j] <= shift_registers[i][j+1];
                end
                // Load new data into the leftmost position 
                shift_registers[i][COLS + ROWS - 2] <= `DATA_W'd0; 
            end

            for (i = 0; i < ROWS + ROWS -1; i++) begin
                for (j = 0; j < COLS; j++) begin
                    if (i == 0) begin
                        shift_registers_last_row[i][j] <= north_south_wires[ROWS-1][j];
                    end else begin
                        shift_registers_last_row[i][j] <= shift_registers_last_row[i-1][j];
                    end
                end
            end
            if (counter == 5'd5) begin
                //this is wayyy too manual right now. need to figure out how to do this in a loop
                block_result1 <= shift_registers_last_row[2][0];
                block_result2 <= shift_registers_last_row[1][0];
                block_result3 <= shift_registers_last_row[1][1];
                block_result4 <= shift_registers_last_row[0][1];
                counter <= `DATA_W'd0;
                block_multiply_done <= 1'b1;
            end else if(block_multiply_done != 1'b1)begin
                counter <= counter + 1;
            end
        end
    end





    // These P blocks are hardcoded which is not optimal
    // Block P1 (top-left corner)
    block P1(
        .inp_north(`DATA_W'd0),
        .inp_west(shift_registers[0][0]),
        .weight_in(block_b[0]),
        .outp_south(north_south_wires[0][0]),
        .outp_east(east_west_wires[0][0]),
        .clk(clk),
        .rst(rst),
        .compute(start),
        .weight_en(load)
    );

    // Block P2 (top-right corner)
    block P2(
        .inp_north(`DATA_W'd0),
        .inp_west(east_west_wires[0][0]),
        .weight_in(block_b[2]),
        .outp_south(north_south_wires[0][1]),
        .outp_east(east_west_wires[0][1]),
        .clk(clk),
        .rst(rst),
        .compute(start),
        .weight_en(load)
    );

    // Block P3 (bottom-left corner)
    block P3(
        .inp_north(north_south_wires[0][0]),
        .inp_west(shift_registers[1][0]),
        .weight_in(block_b[1]),
        .outp_south(north_south_wires[1][0]),
        .outp_east(east_west_wires[1][0]),
        .clk(clk),
        .rst(rst),
        .compute(start),
        .weight_en(load)
    );

    // Block P4 (bottom-right corner)
    block P4(
        .inp_north(north_south_wires[0][1]),
        .inp_west(east_west_wires[1][0]),
        .weight_in(block_b[3]),
        .outp_south(north_south_wires[1][1]),
        .outp_east(east_west_wires[1][1]),
        .clk(clk),
        .rst(rst),
        .compute(start),
        .weight_en(load)
    );
 
 
endmodule




module block(inp_north, inp_west, weight_in, outp_south, outp_east,  clk, rst, compute, weight_en);
//we are implementing a weight stationary systolic array. activations are marched in from the activation storage buffer. The activations move horizontally from left to right and the partial sums move vertically from top to bottom.
////activations move horizontally from west to east
    input [`DATA_W-1:0] inp_north, inp_west; // north input is the partial sum and they move from north to south
// weights are the weight matrix that is loaded into the systolic array initially and is not changed during the computation
    input [`DATA_W-1:0] weight_in;
    reg [`DATA_W-1:0] weight;
    output reg [`DATA_W-1:0] outp_south, outp_east;
    input clk, rst, compute, weight_en;
    
    // Instantiate fmul module
    wire [`DATA_W-1:0] mul_result;
    fmul fmul (
        .a_in(inp_west),
        .b_in(weight),
        .result(mul_result)
    );
    wire [`DATA_W-1:0] add_result;
    fadd add_instance (
        .a_in(inp_north),
        .b_in(mul_result),
        .result(add_result)
    );
    always @(posedge clk) begin
        if(!rst ) begin
            outp_east <= `DATA_W'd0;
            outp_south <= `DATA_W'd0;
            weight <= `DATA_W'd0;
        end
        else begin 
            if (weight_en) begin
                weight <= weight_in;
            end
            if (compute) begin
                outp_east <= inp_west;
                //outp_south <= inp_north + inp_west * weight;
                outp_south <= add_result;
            end
        end 
    end
endmodule

//basically a close copy of https://github.com/ReaLLMASIC/nanoGPT/blob/master/HW/SA/verilog/fadd.sv
module fadd(
    input [16-1:0] a_in, b_in, // Inputs in the format of IEEE-`EXP_W-154 Representation.
    output [16-1:0] result // Outputs in the format of IEEE-`EXP_W-154 Representation.
);

wire Exception;
wire output_sign;
wire operation_sub_addBar;

wire [16-1:0] operand_a, operand_b;
wire [`M_W:0] significand_a, significand_b;
wire [`EXP_W-1:0] exponent_diff;

wire [`M_W:0] significand_b_add;
wire [`EXP_W-1:0] exponent_b_add;

wire [`M_W+1:0] significand_add;
wire [16-2:0] add_sum;

wire [`EXP_W-1:0] exp_a, exp_b;


//for operations always operand_a must not be less than b_in
assign {operand_a,operand_b} = (a_in[16-2:0] < b_in[16-2:0]) ? {b_in,a_in} : {a_in,b_in};

assign exp_a = operand_a[16-2:`M_W]; // extract exponent from operand_a
assign exp_b = operand_b[16-2:`M_W]; // extract exponent from operand_b

//Exception flag sets 1 if either one of the exponent is 255.
assign Exception = (&operand_a[16-2:`M_W]) | (&operand_b[16-2:`M_W]);

assign output_sign = operand_a[16-1] ; // since the operand_a is always greater than operand_b, the sign of the result will be same as operand_a.

//operation_sub_addBar is 1 if we are doing subtraction else 0.
assign operation_sub_addBar =  ~(operand_a[16-1] ^ operand_b[16-1]);

//Assigining significand values according to Hidden Bit.
assign significand_a = {1'b1,operand_a[`M_W-1:0]}; // expand the mantissa by 1 bit before multiplication since its always implied
assign significand_b = {1'b1,operand_b[`M_W-1:0]}; // same as above

//Evaluating Exponent Difference
assign exponent_diff = operand_a[16-2:`M_W] - operand_b[16-2:`M_W];

//Shifting significand_b to the right according to exponent_diff. Exapmle: if we have 1.0101 >> 2 = 0.0101 then exponent_diff = 2 and significand_b_add = significand_b >> exponent_diff
assign significand_b_add = significand_b >> exponent_diff;

//Adding exponent_diff to exponent_b. Exapmle: if we have 1.0101 << 2 = 101.01 then exponent_diff = 2 and exponent_b_add = exponent_b + exponent_diff
assign exponent_b_add = operand_b[16-2:`M_W] + exponent_diff; 

//------------------------------------------------ADD BLOCK------------------------------------------//
//if we are adding(operation_sub_addBar=1) need to add significand_b_add to significand_a. 
//Or sets the significand to zero if the signs are different(this means we are doing subtraction), effectively determining the core operation of the floating-point addition based on the sign of the operands.
assign significand_add = ( operation_sub_addBar) ? (significand_a + significand_b_add) : {(`M_W+2){1'b0}}; 

//Taking care of the resulting mantissa. 
//If there is a carry, then the result is normalized by shifting the significand right by one bit(because its implied) and incrementing the exponent by one.
//If there is no carry, we just use the result of the addition, and we have `M_W-1:0 due to the fact that we are using the hidden bit(implied 1).
assign add_sum[`M_W-1:0] = significand_add[`M_W+1] ? significand_add[`M_W:1] : significand_add[`M_W-1:0];

// Taking care of the resulting exponent.
//If carry generates in sum value then exponent must be added with 1 else feed as it is.
assign add_sum[16-2:`M_W] = significand_add[`M_W+1] ? (1'b1 + operand_a[16-2:`M_W]) : operand_a[16-2:`M_W];

assign result = Exception ? {(16){1'b0}} : {output_sign,add_sum};

endmodule


//basically a close copy of https://github.com/ReaLLMASIC/nanoGPT/blob/master/HW/SA/verilog/fmul.sv
module fmul(
    input [16-1:0] a_in,
    input [16-1:0] b_in,
    output [16-1:0] result
);

    reg [`MULT_W-1:0] mul_fix_out;
    reg [`M_W-1:0] M_result;
    wire [`EXP_W-1:0] e_result;
    wire sign;
    reg [`EXP_W:0] e_result0;
    reg overflow;
    reg zero_check;
    
    // Multiplication logic
    always @* begin
        mul_fix_out = {1'b1, a_in[`M_W-1:0]} * {1'b1, b_in[`M_W-1:0]}; //extend the mantissa by 1 bit before multiplication
    end

    // Zero check
    always @* begin
        if (a_in[16-2:`M_W] == 0 || b_in[16-2:`M_W] == 0) begin
            zero_check = 1'b1;
        end else begin
            zero_check = 1'b0;
        end
    end

    // Generate Mantissa. We are only considering the most significat bits of the product to generate the mantissa.
    always @* begin
        //select two MSBs of the product
        case(mul_fix_out[`MULT_W-1:`MULT_W-2])
           //Example: If mul_fix_out is 8 bits wide and represents 01xxxxxx (binary), it extracts xxxxxx, assuming the MSBs are 01
            2'b01: M_result = mul_fix_out[`MULT_W-3:`M_W]; //MSB is dropped(as it is always 1)
            //In 2'b10 or 2'b11 case: 10yyyyyy → Shift → 0yyyyyy (Extract yyyyyy)
            2'b10: M_result = mul_fix_out[`MULT_W-2:`M_W+1]; // Between two and just under 4. product larger than normalized range, so we need to shift right 
            2'b11: M_result = mul_fix_out[`MULT_W-2:`M_W+1]; // same as line above. 
            default: M_result = mul_fix_out[`MULT_W-2:`M_W+1]; // default same as two lines above
        endcase
    end

    // Overflow check
    always @* begin
        //Different cases for overflow:
        //1. If either of the inputs is zero, then the result is zero and there is no overflow.
        //2. Underflow check: If the sum of the exponents is less than the minimum exponent, then the result is zero and there is no overflow. {2'b0,{(EXP_W-1){1'b1}}} is the minimum exponent(001111111 in case of 32bit float)
        //3. Overflow check: If the sum of the exponents is greater than the maximum exponent, then the result is infinity and there is overflow. EXP_MAX is the maximum exponent.
        overflow = (zero_check || ({1'b0, a_in[16-2:`M_W]} + {1'b0, b_in[16-2:`M_W]} + {{`EXP_W{1'b0}}, mul_fix_out[`MULT_W-1]}) < {2'b0,{(`EXP_W-1){1'b1}}} || ({1'b0, a_in[16-2:`M_W]} + {1'b0, b_in[16-2:`M_W]} + {8'd0, mul_fix_out[`MULT_W-1]}) > `EXP_MAX);

        if (~zero_check) begin
            if (overflow) begin
                e_result0 = {(`EXP_W+1){1'b1}};
            end else begin
                //1. We extend the exponent by 1 bit because the result of addition of two exponents can be 1 bit larger than the exponent itself.
                //2. We add the MSB of the mantissa multiplication(before normalization) to the exponent sum to account for the shifting of the mantissa.
                //3. We subtract the bias from the exponent sum to get the final exponent because just adding two exponents would give us exp1 + exp2 + 2 x bias.
                e_result0 = ({1'b0, a_in[16-2:`M_W]} + {1'b0, b_in[16-2:`M_W]} + {{`EXP_W{1'b0}}, mul_fix_out[`MULT_W-1]}) - {2'b0,{(`EXP_W-1){1'b1}}};
            end
        end else begin
            e_result0 = 0;
        end
    end
    assign e_result = e_result0[`EXP_W-1:0];

    // Sign calculation
    assign sign = a_in[16-1] ^ b_in[16-1];

    wire [`M_W-1:0] overflow_mask;
    assign overflow_mask = overflow ? 0 : {(`M_W){1'b1}};

    assign result = {sign, e_result, overflow_mask & M_result};
endmodule


module UART #(
        parameter FREQ  = 1_000_000,
        parameter BAUD  = 9600
    ) (
        input           reset,
        input           clk,
        // Receiver half
        input           rx_i,
        output [7:0]    rx_data_o,
        output          rx_ready_o,
        input           rx_ack_i,
        output          rx_error_o,
        // Transmitter half
        output          tx_o,
        input  [7:0]    tx_data_i,
        input           tx_ready_i,
        output          tx_ack_o
    );

    // RX oversampler
    reg        rx_sampler_reset = 1'b0;
    wire       rx_sampler_clk;
    ClockDiv #(
        .FREQ_I(FREQ),
        .FREQ_O(BAUD * 3),
        .PHASE(1'b1),
        .MAX_PPM(50_000)
    ) rx_sampler_clk_div (
        .reset(rx_sampler_reset),
        .clk_i(clk),
        .clk_o(rx_sampler_clk)
    );

    reg  [2:0] rx_sample  = 3'b000;
    wire       rx_sample1 = (rx_sample == 3'b111 ||
                             rx_sample == 3'b110 ||
                             rx_sample == 3'b101 ||
                             rx_sample == 3'b011);
    always @(posedge rx_sampler_clk or negedge rx_sampler_reset)
        if(!rx_sampler_reset)
            rx_sample <= 3'b000;
        else
            rx_sample <= {rx_sample[1:0], rx_i};

    (* fsm_encoding="one-hot" *)
    reg  [1:0] rx_sampleno  = 2'd2;
    wire       rx_samplerdy = (rx_sampleno == 2'd2);
    always @(posedge rx_sampler_clk or negedge rx_sampler_reset)
        if(!rx_sampler_reset)
            rx_sampleno <= 2'd2;
        else case(rx_sampleno)
            2'd0: rx_sampleno <= 2'd1;
            2'd1: rx_sampleno <= 2'd2;
            2'd2: rx_sampleno <= 2'd0;
        endcase

    // RX strobe generator
    reg  [1:0] rx_strobereg = 2'b00;
    wire       rx_strobe    = (rx_strobereg == 2'b01);
    always @(posedge clk or negedge reset)
        if(!reset)
            rx_strobereg <= 2'b00;
        else
            rx_strobereg <= {rx_strobereg[0], rx_samplerdy};

    // RX state machine
    localparam RX_IDLE  = 3'd0,
               RX_START = 3'd1,
               RX_DATA  = 3'd2,
               RX_STOP  = 3'd3,
               RX_FULL  = 3'd4,
               RX_ERROR = 3'd5;
    reg  [2:0] rx_state = 3'd0;
    reg  [7:0] rx_data  = 8'b00000000;
    reg  [2:0] rx_bitno = 3'd0;
    always @(posedge clk or negedge reset)
        if(!reset) begin
            rx_sampler_reset <= 1'b0;
            rx_state <= RX_IDLE;
            rx_data <= 8'b00000000;
            rx_bitno <= 3'd0;
        end else case(rx_state)
            RX_IDLE:
                if(!rx_i) begin
                    rx_sampler_reset <= 1'b1;
                    rx_state <= RX_START;
                end
            RX_START:
                if(rx_strobe)
                    rx_state <= RX_DATA;
            RX_DATA:
                if(rx_strobe) begin
                    if(rx_bitno == 3'd7)
                        rx_state <= RX_STOP;
                    rx_data <= {rx_sample1, rx_data[7:1]};
                    rx_bitno <= rx_bitno + 3'd1;
                end
            RX_STOP:
                if(rx_strobe) begin
                    rx_sampler_reset <= 1'b0;
                    if(rx_sample1 == 1'b0)
                        rx_state <= RX_ERROR;
                    else
                        rx_state <= RX_FULL;
                end
            RX_FULL:
                if(rx_ack_i)
                    rx_state <= RX_IDLE;
                else if(!rx_i)
                    rx_state <= RX_ERROR;
        endcase

    assign rx_data_o  = rx_data;
    assign rx_ready_o = (rx_state == RX_FULL);
    assign rx_error_o = (rx_state == RX_ERROR);

    // TX sampler
    reg        tx_sampler_reset = 1'b0;
    wire       tx_sampler_clk;
    ClockDiv #(
        .FREQ_I(FREQ),
        // Make sure TX baud is exactly the same as RX baud, even after all the rounding that
        // might have happened inside rx_sampler_clk_div, by replicating it here.
        // Otherwise, anything that sends an octet every time it receives an octet will
        // eventually catch a frame error.
        .FREQ_O(FREQ / ((FREQ / (BAUD * 3) / 2) * 2) / 3),
        .PHASE(1'b0),
        .MAX_PPM(50_000)
    ) tx_sampler_clk_div (
        .reset(tx_sampler_reset),
        .clk_i(clk),
        .clk_o(tx_sampler_clk)
    );

    // TX strobe generator
    reg  [1:0] tx_strobereg = 2'b00;
    wire       tx_strobe    = (tx_strobereg == 2'b01);
    always @(posedge clk or negedge reset)
        if(!reset)
            tx_strobereg <= 2'b00;
        else
            tx_strobereg <= {tx_strobereg[0], tx_sampler_clk};

    // TX state machine
    localparam TX_IDLE  = 3'd0,
               TX_START = 3'd1,
               TX_DATA  = 3'd2,
               TX_STOP0 = 3'd3,
               TX_STOP1 = 3'd4;
    reg  [2:0] tx_state = 3'd0;
    reg  [7:0] tx_data  = 8'b00000000;
    reg  [2:0] tx_bitno = 3'd0;
    reg        tx_buf   = 1'b1;
    always @(posedge clk or negedge reset)
        if(!reset) begin
            tx_sampler_reset <= 1'b0;
            tx_state <= 3'd0;
            tx_data <= 8'b00000000;
            tx_bitno <= 3'd0;
            tx_buf <= 1'b1;
        end else case(tx_state)
            TX_IDLE:
                if(tx_ready_i) begin
                    tx_sampler_reset <= 1'b1;
                    tx_state <= TX_START;
                    tx_data <= tx_data_i;
                end
            TX_START:
                if(tx_strobe) begin
                    tx_state <= TX_DATA;
                    tx_buf <= 1'b0;
                end
            TX_DATA:
                if(tx_strobe) begin
                    if(tx_bitno == 3'd7)
                        tx_state <= TX_STOP0;
                    tx_data <= {1'b0, tx_data[7:1]};
                    tx_bitno <= tx_bitno + 3'd1;
                    tx_buf <= tx_data[0];
                end
            TX_STOP0:
                if(tx_strobe) begin
                    tx_state <= TX_STOP1;
                    tx_buf <= 1'b1;
                end
            TX_STOP1:
                if(tx_strobe) begin
                    tx_sampler_reset <= 1'b0;
                    tx_state <= TX_IDLE;
                end
        endcase

    assign tx_o       = tx_buf;
    assign tx_ack_o   = (tx_state == TX_IDLE);

endmodule



module ClockDiv #(
        parameter FREQ_I  = 2,
        parameter FREQ_O  = 1,
        parameter PHASE   = 1'b0,
        parameter MAX_PPM = 1_000_000
    ) (
        input  reset,
        input  clk_i,
        output clk_o
    );

    // This calculation always rounds frequency up.
    localparam INIT = FREQ_I / FREQ_O / 2 - 1;
    localparam ACTUAL_FREQ_O = FREQ_I / ((INIT + 1) * 2);
    localparam PPM = 64'd1_000_000 * (ACTUAL_FREQ_O - FREQ_O) / FREQ_O;
    generate
        if(INIT < 0)
            _ERROR_FREQ_TOO_HIGH_ error();
        if(PPM > MAX_PPM)
            _ERROR_FREQ_DEVIATION_TOO_HIGH_ error();
    endgenerate

    reg [$clog2(INIT):0] cnt = 0;
    reg                  clk = PHASE;
    always @(posedge clk_i or negedge reset)
        if(!reset) begin
            cnt <= 0;
            clk <= PHASE;
        end else begin
            if(cnt == 0) begin
                clk <= ~clk;
                cnt <= INIT;
            end else begin
                cnt <= cnt - 1;
            end
        end

    assign clk_o = clk;

endmodule