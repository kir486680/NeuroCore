
module systolic_array(
    input [31:0] inp_west0, inp_west3, inp_west6,
    input [31:0] inp_weight0, inp_weight1, inp_weight2, inp_weight3,
                  inp_weight4, inp_weight5, inp_weight6, inp_weight7, inp_weight8,
    input clk, rst, compute, weight_en
);


    wire [31:0] outp_south0, outp_south1, outp_south2,
                outp_south3, outp_south4, outp_south5,
                outp_south6, outp_south7, outp_south8;
    wire [31:0] outp_east0, outp_east1, outp_east2,
                outp_east3, outp_east4, outp_east5,
                outp_east6, outp_east7, outp_east8;


    //First row of the array 
    block P0 (32'd0,inp_west0, inp_weight0, outp_south0, outp_east0,clk, rst, compute, weight_en);
    block P1 (32'd0,outp_east0, inp_weight1, outp_south1, outp_east1,clk, rst, compute, weight_en);
    block P2 (32'd0,outp_east1, inp_weight2, outp_south2, outp_east2,clk, rst, compute, weight_en);

    //Second row of the array
    block P3(outp_south0,inp_west3, inp_weight3, outp_south3, outp_east3,clk, rst, compute, weight_en);
    block P4(outp_south1, outp_east3, inp_weight4, outp_south4, outp_east4,clk, rst, compute, weight_en);
    block P5(outp_south2, outp_east4, inp_weight5, outp_south5, outp_east5,clk, rst, compute, weight_en);

    //Third row of the array
    block P6(outp_south3,inp_west6, inp_weight6, outp_south6, outp_east6,clk, rst, compute, weight_en);
    block P7(outp_south4, outp_east6, inp_weight7, outp_south7, outp_east7,clk, rst, compute, weight_en);
    block P8(outp_south5, outp_east7, inp_weight8, outp_south8, outp_east8,clk, rst, compute, weight_en);
 
endmodule