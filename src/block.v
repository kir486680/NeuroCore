module block(inp_north, inp_west, weight_in, outp_south, outp_east,  clk, rst, compute, weight_en);
//we are implementing a weight stationary systolic array. activations are marched in from the activation storage buffer. The activations move horizontally from left to right and the partial sums move vertically from top to bottom.
////activations move horizontally from west to east
    input [`DATA_W:0] inp_north, inp_west; // north input is the partial sum and they move from north to south
// weights are the weight matrix that is loaded into the systolic array initially and is not changed during the computation
    input [`DATA_W:0] weight_in;
    reg [`DATA_W:0] weight;
    output reg [`DATA_W:0] outp_south, outp_east;
    input clk, rst, compute, weight_en;
    
    // Instantiate fmul module
    wire [`DATA_W:0] mul_result;
    fmul mul_instance (
        .a_in(inp_west),
        .b_in(weight),
        .result(mul_result)
    );
    wire [`DATA_W:0] add_result;
    fadd add_instance (
        .a_in(inp_north),
        .b_in(mul_result),
        .result(add_result)
    );


    always @(posedge rst or posedge clk) begin
        if(rst) begin
            outp_east <= 0;
            outp_south <= 0;
            weight <= 0;
        end
        else begin 
            if (weight_en) begin
                weight <= weight_in;
            end
            if (compute) begin
                outp_east <= inp_west;
               // outp_south <= inp_north + inp_west * weight;
                outp_south <= add_result;
            end
        end 
    end
endmodule