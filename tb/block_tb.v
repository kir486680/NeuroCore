
`timescale 1ns/1ps

module block_tb;

    reg [31:0] inp_north, inp_west, weight_in;
    reg clk, rst, compute, weight_en;
    wire [31:0] outp_south, outp_east;
    
    // Instantiate the block module
    block uut (
        .inp_north(inp_north), 
        .inp_west(inp_west), 
        .weight_in(weight_in), 
        .outp_south(outp_south), 
        .outp_east(outp_east), 
        .clk(clk), 
        .rst(rst), 
        .compute(compute), 
        .weight_en(weight_en)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Generate a clock with 10ns period (100MHz)
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;  // Assert reset
        weight_en = 0;
        compute = 0;
        inp_north = 0;
        inp_west = 0;
        weight_in = 0;
        
        // Wait for a few clock cycles
        #(20);
        
        // Deassert reset
        rst = 0;  
        weight_en = 1;
        weight_in = 32'd13;  // Load a sample weight
        inp_west = 32'd2;   // Load a sample activation

        // Wait for the weight to be loaded
        #(10);
        weight_en = 0;
        
        // Start computation
        compute = 1;
        #(10);
        inp_west = 32'd3;
        inp_north = 32'd5;  // Load a sample partial sum

        // Continue the simulation for several cycles to observe behavior
        // This should be expanded with specific cases and assertions as needed
        #(100);
        
        // Finish the simulation
        $finish;
    end

    // Optional: Monitor outputs and important signal transitions
    initial begin
        $monitor("Time = %t, rst = %b, compute = %b, weight_en = %b, inp_north = %h, inp_west = %h, weight_in = %h, outp_south = %h, outp_east = %h",
                 $time, rst, compute, weight_en, inp_north, inp_west, weight_in, outp_south, outp_east);
    end

    initial begin
        $dumpfile("block_wave.vcd");
        $dumpvars(0, block_tb);
    end
    
endmodule
