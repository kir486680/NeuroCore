module block(inp_north, inp_west, weight_in, outp_south, outp_east,  clk, rst, compute, weight_en);
//we are implementing a weight stationary systolic array. activations are marched in from the activation storage buffer. The activations move horizontally from left to right and the partial sums move vertically from top to bottom.
////activations move horizontally from west to east
    input [31:0] inp_north, inp_west; // north input is the partial sum and they move from north to south
// weights are the weight matrix that is loaded into the systolic array initially and is not changed during the computation
    input [31:0] weight_in;
    reg [31:0] weight;
    output reg [31:0] outp_south, outp_east;
    input clk, rst, compute, weight_en;
    
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
                outp_south <= inp_north + (inp_west * weight);
            end
        end 
    end
endmodule