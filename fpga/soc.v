`default_nettype none
`include "uart.v"
`include "define.v"
`include "systolic_array.v"
module SOC (
    input 	     CLK, // system clock 
    input 	     RESET, // reset button
    output reg [4:0] LEDS, // system LEDs
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

    // assign LEDS[3:1] = current_mul_state;
    //assign LEDS[4] = block_multiply_done;
    assign LEDS[2:0] = current_mul_state;
    assign LEDS[4] = state_receive == DONE_RECEIVE ? 1 : 0;
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
    DONE_RECEIVE = 17, DONE_RECEIVE = 18;
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
                 
                    
                    
                    //check if blocka1, blocka2, blocka3, blocka4 are all 0, if so, then light up LEDS[0]
                    if(block_a1 == 0 && block_a2 == 0 && block_a3 == 0 && block_a4 == 0) begin
                        //LEDS[0] <= 0;
                    end
                    else begin
                        //LEDS[0] <= 1;
                    end
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


    //Assign LEDS[3]  to 1 if the send_staet is IDLE_SEND
    assign LEDS[3] = send_data;
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