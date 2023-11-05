`timescale 1ns / 1ps

module systolic_array_tb;

    reg [31:0] inp_west0, inp_west3, inp_west6;
    reg [31:0] inp_weight0, inp_weight1, inp_weight2, inp_weight3,
               inp_weight4, inp_weight5, inp_weight6, inp_weight7, inp_weight8;
    reg clk, rst, compute, weight_en;

    // Instantiate the Unit Under Test (UUT)
    systolic_array uut (
        .inp_west0(inp_west0), .inp_west3(inp_west3), .inp_west6(inp_west6),
        .inp_weight0(inp_weight0), .inp_weight1(inp_weight1), .inp_weight2(inp_weight2),
        .inp_weight3(inp_weight3), .inp_weight4(inp_weight4), .inp_weight5(inp_weight5),
        .inp_weight6(inp_weight6), .inp_weight7(inp_weight7), .inp_weight8(inp_weight8),
        .clk(clk), .rst(rst), .compute(compute), .weight_en(weight_en)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        compute = 0;
        weight_en = 0;
        // Reset the system
        #100;
        rst = 0;
        
        // Load the weight matrix
        weight_en = 1;
        inp_weight0 = 32'd1;
        inp_weight1 = 32'd2;
        inp_weight2 = 32'd3;
        inp_weight3 = 32'd4;
        inp_weight4 = 32'd5;
        inp_weight5 = 32'd6;
        inp_weight6 = 32'd7;
        inp_weight7 = 32'd8;
        inp_weight8 = 32'd9;
        #20;
        weight_en = 0; // Disable weight loading

        // Input activation matrix
        inp_west0 = 32'd1;
        inp_west3 = 32'd0;
        inp_west6 = 32'd0;
        compute = 1; // Start computation
        #20;

        inp_west0 = 32'd4;
        inp_west3 = 32'd2;
        inp_west6 = 32'd0;
        #20;
        inp_west0 = 32'd7;
        inp_west3 = 32'd5;
        inp_west6 = 32'd3;
        #20;
        inp_west0 = 32'd0;
        inp_west3 = 32'd8;
        inp_west6 = 32'd6;
        #20;
        inp_west0 = 32'd0;
        inp_west3 = 32'd0;
        inp_west6 = 32'd9;
        // Observe the output for a few cycles
        // Note: You would need additional logic to read out the final results from the array
        #100;

        compute = 0; // Stop computation
        #20;

        // Add your own checks to validate the outputs
        // This will depend on how you decide to capture and observe the outputs
        // from the systolic array.

        // Finish simulation
        $finish;
    end


    initial begin
        $dumpfile("systolic_array_wave.vcd");
        $dumpvars(0, systolic_array_tb);
    end
    
endmodule
