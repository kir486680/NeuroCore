`timescale 1ns / 1ps

module fmul_tb;

    `define BIT_W 32

    // Inputs
    reg [`BIT_W-1:0] a_in;
    reg [`BIT_W-1:0] b_in;

    // Outputs
    wire [`BIT_W-1:0] result;

    // Instantiate the Unit Under Test (UUT)
    fmul uut (
        .a_in(a_in), 
        .b_in(b_in), 
        .result(result)
    );

    initial begin
        // Initialize Inputs
        a_in = 0;
        b_in = 0;

        // Wait 100 ns for global reset to finish
        #100;

        // Apply test cases
        // Note: You will need to replace these with actual test values that are meaningful for your application.
        // These are just placeholders to demonstrate the structure of the testbench.

        a_in = 32'b01000000110000000000000000000000; // Replace 'xxxxxxxx' with actual test data
        b_in = 32'b01000000111000000000000000000000; // Replace 'xxxxxxxx' with actual test data
        #10; // Wait for some time

        // a_in = 32'hxxxxxxxx; // Next test data
        // b_in = 32'hxxxxxxxx;
        // #10;

        // Add as many test cases as needed to thoroughly test your module

        // Finish the simulation
        $finish;
    end

    initial begin
        $dumpfile("fmul_wave.vcd");
        $dumpvars(0, fmul_tb);
    end
      
endmodule
