module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/systolic_array.fst");
    $dumpvars(0, systolic_array);
end
endmodule
