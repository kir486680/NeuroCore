`include "block.v"

module systolic_array(inp_west0, inp_west3, inp_west6, inp_weight0, inp_weight1, inp_weight2, inp_weight3,
                        inp_weight4, inp_weight5, inp_weight6, inp_weight7, inp_weight8, clk, rst, done);

    input [31:0] inp_west0, inp_west3, inp_west6, inp_weight0, inp_weight1, inp_weight2, inp_weight3,
                        inp_weight4, inp_weight5, inp_weight6, inp_weight7, inp_weight8;
    output reg done;
    input clk, rst;
    reg [3:0] count;

    wire [31:0] outp_south0, outp_south1, outp_south2, outp_south3, outp_south4, outp_south5, outp_south6, outp_south7, outp_south8;
    wire [31:0] outp_east0, outp_east1, outp_east2, outp_east3, outp_east4, outp_east5, outp_east6, outp_east7, outp_east8;


    //First row of the array 
    block P0 (32'd0,inp_west0, inp_weight0, clk, rst, outp_south0, outp_east0);
    block P1 (32'd0, outp_east0, inp_weight1, clk, rst, outp_south1, outp_east1);
    block P2 (32'd0, outp_east1, inp_weight2, clk, rst, outp_south2, outp_east2);

    //Second row of the array
    block P3 (outp_south0, inp_west3, inp_weight3, clk, rst, outp_south3, outp_east3);
    block P4 (outp_south1, outp_east3, inp_weight4, clk, rst, outp_south4, outp_east4);
    block P5 (outp_south2, outp_east4, inp_weight5, clk, rst, outp_south5, outp_east5);

    //Third row of the array
    block P6 (outp_south3, inp_west6, inp_weight6, clk, rst, outp_south6, outp_east6);
    block P7 (outp_south4, outp_east6, inp_weight7, clk, rst, outp_south7, outp_east7);
    block P8 (outp_south5, outp_east7, inp_weight8, clk, rst, outp_south8, outp_east8);


    always @(posedge clk or posedge rst) begin 
        if(rst) begin
            done <= 0;
            count <= 0;
        end
        else begin
            if(count == 6) begin
                done <= 1;
                count <= 0;
            end
            else begin
                done <= 0;
                count <= count + 1;
            end
        end
    end

endmodule