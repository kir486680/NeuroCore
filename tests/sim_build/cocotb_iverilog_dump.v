module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/fmul.fst");
    $dumpvars(0, fmul);
end
endmodule
