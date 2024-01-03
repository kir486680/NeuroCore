`default_nettype none
`include "block.v"

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
    output reg [4:0] LEDS
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

    


    //assign LEDS[0] = load;
    //assign LEDS[1] = start;
    //assign LEDS[2] = block_multiply_done;
    //assign LEDS[3] = rst;

    // Shift registers
    reg [`DATA_W-1:0] shift_registers[ROWS-1:0][COLS+ROWS-1:0];
    reg [`DATA_W-1:0] shift_registers_last_row[ROWS+ROWS-2:0][COLS-1:0];//takes 2n-1 to complete the product

    //assign LEDS to the shift_registers_last_row
    


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
                shift_registers[i][COLS + ROWS - 2] <= `DATA_W'd0; //this might be wrong
                //$display("shift_registers[%d][%d] = %d", i, COLS + ROWS - 2, shift_registers[i][COLS + ROWS - 1]);
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
            //$display("counter = %d", counter);
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
