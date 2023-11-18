import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
from cocotb.binary import BinaryValue

@cocotb.test()
async def block_test(dut):
    # Clock generation
    clock = Clock(dut.clk, 10, units="ns")  # 100 MHz clock
    cocotb.fork(clock.start())

    # Initialize inputs
    dut.rst.value = 1  # Assert reset
    dut.weight_en.value = 0
    dut.compute.value = 0
    dut.inp_north.value = 0
    dut.inp_west.value = 0
    dut.weight_in.value = 0

    # Wait for a few clock cycles
    await Timer(20, units="ns")

    # Deassert reset and set initial test values
    dut.rst.value = 0
    dut.weight_en.value = 1
    dut.weight_in.value = BinaryValue("01000001010100000000000000000000")  # Sample weight
    dut.inp_west.value = BinaryValue("01000000000000000000000000000000")    # Sample activation

    # Wait for the weight to be loaded
    await Timer(10, units="ns")
    dut.weight_en.value = 0

    # Start computation
    dut.compute.value = 1
    
    await Timer(10, units="ns")
    assert dut.outp_east.value == BinaryValue("01000000000000000000000000000000"), "Mismatch in outp_east"
    assert dut.outp_south.value == BinaryValue("01000001110100000000000000000000"), "Mismatch in outp_south"


    # Finish simulation
    # (Cocotb automatically closes the simulation after the test completes)
