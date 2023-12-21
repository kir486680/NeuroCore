
module systolic_array(
    input [`DATA_W-1:0] block_a[0:`J*`K-1], // the block of matrix A
    input [`DATA_W-1:0] block_b[0:`J*`K-1], // the block of matrix B
    input clk, rst, start, load,
    output reg block_multiply_done,
    output reg [`DATA_W-1:0] block_result[0:`J*`K-1] // the result matrix
);




        // Parameters for dimensions
    parameter ROWS = `J; // Number of rows
    parameter COLS = `K; // Number of columns

    reg [`DATA_W-1:0] north_south_wires[ROWS-1:0][COLS-1:0];
    reg [`DATA_W-1:0] east_west_wires[ROWS-1:0][COLS-1:0];
    //create a wire to connect to the output of all the members of last row north_sout
    wire [`DATA_W-1:0] north_south_wires_last_row[COLS-1:0];
    genvar k;
    generate
        for (k = 0; k < COLS; k = k + 1) begin: assign_last_row
            assign north_south_wires_last_row[k] = north_south_wires[ROWS-1][k];
        end
    endgenerate

    //create a counter to count the number of cycles since the start signal was asserted
    reg [`DATA_W-1:0] counter;

    // Shift registers
    reg [`DATA_W-1:0] shift_registers[ROWS-1:0][COLS+ROWS-1:0];
    reg [`DATA_W-1:0] shift_registers_last_row[ROWS+ROWS-2:0][COLS-1:0];//takes 2n-1 to complete the product
    // Load matrix A into shift registers with offset when compute is true
    always @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < ROWS; i++) begin
                for (int j = 0; j < COLS + ROWS - 1; j++) begin
                    shift_registers[i][j] <= `DATA_W'd0;
                end
            end
            for (int i = 0; i < ROWS + ROWS -1; i++) begin
                for (int j = 0; j < COLS; j++) begin
                    shift_registers_last_row[i][j] <= `DATA_W'd0;
                end
            end
            counter <= `DATA_W'd0;
        end
        else if (load) begin
            block_multiply_done <= 1'b0;
            for (int i = 0; i < ROWS; i++) begin
        // Initialize the entire row to 0 first
                for (int j = 0; j < COLS + ROWS - 1; j++) begin
                    shift_registers[i][j] <= `DATA_W'd0;
                end
                // Load matrix A into the shift register
                for (int j = 0; j < COLS; j++) begin
                    shift_registers[i][j + i] <= block_a[i * COLS + j];
                end
            end
        end
        else if (start) begin
            for (int i = 0; i < ROWS; i++) begin
                for (int j = 0; j < COLS + ROWS - 1; j++) begin
                    shift_registers[i][j] <= shift_registers[i][j+1];
                end
                // Load new data into the leftmost position 
                shift_registers[i][COLS + ROWS - 2] <= `DATA_W'd0; //this might be wrong
                //$display("shift_registers[%d][%d] = %d", i, COLS + ROWS - 2, shift_registers[i][COLS + ROWS - 1]);
            end

            for (int i = 0; i < ROWS + ROWS -1; i++) begin
                for (int j = 0; j < COLS; j++) begin
                    if (i == 0) begin
                        shift_registers_last_row[i][j] <= north_south_wires[ROWS-1][j];
                    end else begin
                        shift_registers_last_row[i][j] <= shift_registers_last_row[i-1][j];
                    end
                end
            end
            if (counter == `DATA_W'd5) begin
                //this is wayyy too manual right now. need to figure out how to do this in a loop
                block_result[0] <= shift_registers_last_row[2][0];
                block_result[1] <= shift_registers_last_row[1][1];
                block_result[2] <= shift_registers_last_row[1][0];
                block_result[3] <= shift_registers_last_row[0][1];
                counter <= `DATA_W'd0;
                block_multiply_done <= 1'b1;
            end else begin
                counter <= counter + 1;
            end
            $display("counter = %d", counter);
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
        .weight_in(block_b[1]),
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
        .weight_in(block_b[2]),
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
        // dont know how to debug generated blocks like this. This is for the future
    // // Generate weights for each PE block
    // genvar i, j;
    // generate
    //     for (i = 0; i < `J; i = i + 1) begin
    //         for (j = 0; j < `K; j = j + 1) begin
    //             int index = i * `K + j;
    //             if(j==0) begin //check if its 0th column. this means that we need to connect west input to shift register
    //                 if(i==0) begin //check if the 0th row. this means that we need to connect north input to 0
    //                     block P(
    //                         .inp_north(`DATA_W'd0),
    //                         .inp_west(shift_registers[i][0]),
    //                         .weight_in(block_b[i * `K + j]),
    //                         .outp_south(north_south_wires[i][j]),
    //                         .outp_east(east_west_wires[i][j]),
    //                         .clk(clk),
    //                         .rst(rst),
    //                         .compute(compute),
    //                         .weight_en(weight_en)

    //                     );
    //                 end else begin
    //                     block P(
    //                         .inp_north(north_south_wires[i-1][j]),
    //                         .inp_west(shift_registers[i][0]),
    //                         .weight_in(block_b[i * `K + j]),
    //                         .outp_south(north_south_wires[i][j]),
    //                         .outp_east(east_west_wires[i][j]),
    //                         .clk(clk),
    //                         .rst(rst),
    //                         .compute(compute),
    //                         .weight_en(weight_en)
    //                     );
    //                 end

    //             end else begin
    //                 if(i==0) begin //check if the 0th row. this means that we need to connect north input to 0
    //                     block P(
    //                         .inp_north(`DATA_W'd0),
    //                         .inp_west(east_west_wires[i][j-1]),
    //                         .weight_in(block_b[i * `K + j]),
    //                         .outp_south(north_south_wires[i][j]),
    //                         .outp_east(east_west_wires[i][j]),
    //                         .clk(clk),
    //                         .rst(rst),
    //                         .compute(compute),
    //                         .weight_en(weight_en)

    //                     );
    //                 end else begin //this is the most general case
    //                     block P(
    //                         .inp_north(north_south_wires[i-1][j]),
    //                         .inp_west(east_west_wires[i][j-1]),
    //                         .weight_in(block_b[i * `K + j]),
    //                         .outp_south(north_south_wires[i][j]),
    //                         .outp_east(east_west_wires[i][j]),
    //                         .clk(clk),
    //                         .rst(rst),
    //                         .compute(compute),
    //                         .weight_en(weight_en)
    //                     );
    //                 end
    //             end
    //         end
    //     end
    // endgenerate
 
endmodule