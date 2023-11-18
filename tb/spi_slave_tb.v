`timescale 1ns / 1ps

module spi_slave_tb;

  reg clk;
  reg rst;
  reg ss;
  reg mosi;
  wire miso;
  reg sck;
  wire done;
  reg [7:0] din;
  wire [7:0] dout;

  // Instantiate the Unit Under Test (UUT)
  spi_slave uut (
    .clk(clk),
    .rst(rst),
    .ss(ss),
    .mosi(mosi),
    .miso(miso),
    .sck(sck),
    .done(done),
    .din(din),
    .dout(dout)
  );

  // Clock generation
  always #5 clk = (clk === 1'b0); // 100MHz clock

  // Task to upload data
  task upload_data;
    input [7:0] data;
    integer i;
    begin
      ss <= 1'b0;  // Assert slave select
      for (i=7; i>=0; i=i-1) begin
        mosi <= data[i];  // Set MOSI to the current bit of data
        #10;  // Wait half period for stability
        sck <= 1'b1;  // Clock high
        #10;  // Complete the clock period
        sck <= 1'b0;  // Clock low
      end
      ss <= 1'b1;  // Deassert slave select
      #20;  // Wait some time after data upload
    end
  endtask

  // Test sequence
  initial begin
    // Initialize inputs
    clk <= 0;
    rst <= 1;
    ss <= 1;
    mosi <= 0;
    sck <= 0;
    din <= 8'hAA;  // Example data to load into the slave

    // Dump file
    $dumpfile("spi_slave.vcd");
    $dumpvars(0, spi_slave_tb);

    // Reset the system
    #15;
    rst <= 0;
    #10;
    rst <= 1;
    #20;

    // Upload data
    upload_data(8'h55);  // Send 0x55 as an example
    upload_data(8'h3C);  // Send another byte

    // Finish simulation
    #100;
    $finish;
  end

endmodule
