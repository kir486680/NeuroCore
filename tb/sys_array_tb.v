`include "systolic_array.v"
module sys_array_tb;

reg rst, clk;
reg [31:0] inp_west0, inp_west3, inp_west6, inp_weight0, inp_weight1, inp_weight2, inp_weight3,
inp_weight4, inp_weight5, inp_weight6, inp_weight7, inp_weight8; 
wire done;


systolic_array uut (
    .inp_west0(inp_west0), .inp_west3(inp_west3), .inp_west6(inp_west6),
    .inp_weight0(inp_weight0), .inp_weight1(inp_weight1), .inp_weight2(inp_weight2),
    .inp_weight3(inp_weight3), .inp_weight4(inp_weight4), .inp_weight5(inp_weight5),
    .inp_weight6(inp_weight6), .inp_weight7(inp_weight7), .inp_weight8(inp_weight8),
    .clk(clk), .rst(rst), .done(done)
);

initial begin 
    #3 inp_west0 <= 32'd1;
    #10 inp_west0 <= 32'd4;
    #10 inp_west0 <= 32'd7;
end;

initial begin 
    #3 inp_west3 <= 32'd0;
    #10 inp_west3 <= 32'd2;
    #10 inp_west3 <= 32'd5;
    #10 inp_west3 <= 32'd8;
end;

initial begin 
    #3 inp_west6 <= 32'd0;
    #10 inp_west6 <= 32'd0;
    #10 inp_west6 <= 32'd3;
    #10 inp_west6 <= 32'd6;
    #10 inp_west6 <= 32'd9;
end;

initial begin
    rst <= 0;
    clk <= 0;
    inp_weight0 <= 32'd1;
    inp_weight1 <= 32'd2;
    inp_weight2 <= 32'd3;
    inp_weight3 <= 32'd4;
    inp_weight4 <= 32'd5;
    inp_weight5 <= 32'd6;
    inp_weight6 <= 32'd7;
    inp_weight7 <= 32'd8;
    inp_weight8 <= 32'd9;
end

initial begin
	repeat(9)
		#5 clk <= ~clk;
end

initial begin
	$dumpfile("wave.vcd");
	$dumpvars(0, sys_array_tb);
end

endmodule
