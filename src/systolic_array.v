
module systolic_array(
    input [15:0] inp_west0, inp_west3, inp_west6,
    input [15:0] inp_weight0, inp_weight1, inp_weight2, inp_weight3,
                  inp_weight4, inp_weight5, inp_weight6, inp_weight7, inp_weight8,
    input clk, rst, compute, weight_en
);


    wire [15:0] outp_south0, outp_south1, outp_south2,
                outp_south3, outp_south4, outp_south5,
                outp_south6, outp_south7, outp_south8;
    wire [15:0] outp_east0, outp_east1, outp_east2,
                outp_east3, outp_east4, outp_east5,
                outp_east6, outp_east7, outp_east8;

    //This buffer is going to move to the right and feed the data into the blocks
    // reg[15:0] buffer_0[0:PE_W];
    // reg[15:0] buffer_1[0:PE_W+1];
    // reg[15:0] buffer_2[0:PE_W+2];
    // reg[15:0] buffer_3[0:PE_W+3];

    //First row of the array 
    block P0 (15'd0,inp_west0, inp_weight0, outp_south0, outp_east0,clk, rst, compute, weight_en);
    block P1 (15'd0,outp_east0, inp_weight1, outp_south1, outp_east1,clk, rst, compute, weight_en);
    block P2 (15'd0,outp_east1, inp_weight2, outp_south2, outp_east2,clk, rst, compute, weight_en);

    //Second row of the array
    block P3(outp_south0,inp_west3, inp_weight3, outp_south3, outp_east3,clk, rst, compute, weight_en);
    block P4(outp_south1, outp_east3, inp_weight4, outp_south4, outp_east4,clk, rst, compute, weight_en);
    block P5(outp_south2, outp_east4, inp_weight5, outp_south5, outp_east5,clk, rst, compute, weight_en);

    //Third row of the array
    block P6(outp_south3,inp_west6, inp_weight6, outp_south6, outp_east6,clk, rst, compute, weight_en);
    block P7(outp_south4, outp_east6, inp_weight7, outp_south7, outp_east7,clk, rst, compute, weight_en);
    block P8(outp_south5, outp_east7, inp_weight8, outp_south8, outp_east8,clk, rst, compute, weight_en);
 
endmodule