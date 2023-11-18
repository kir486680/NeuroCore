import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb.binary import BinaryValue

@cocotb.test()
async def systolic_array_test(dut):
    # Clock generation
    clock = Clock(dut.clk, 20, units="ns")  # 50 MHz clock
    cocotb.fork(clock.start())

    # Initialize Inputs
    dut.rst.value = 1
    dut.compute.value = 0
    dut.weight_en.value = 0

    # Reset the system
    await Timer(100, units="ns")
    dut.rst.value = 0
    
    # Load the weight matrix
    dut.weight_en.value = 1
    dut.inp_weight0.value = BinaryValue("00111111100000000000000000000000")  # 1
    dut.inp_weight1.value = BinaryValue("01000000000000000000000000000000")  # 2
    dut.inp_weight2.value = BinaryValue("01000000010000000000000000000000")  # 3
    dut.inp_weight3.value = BinaryValue("01000000100000000000000000000000")  # 4
    dut.inp_weight4.value = BinaryValue("01000000101000000000000000000000")  # 5
    dut.inp_weight5.value = BinaryValue("01000000110000000000000000000000")  # 6
    dut.inp_weight6.value = BinaryValue("01000000111000000000000000000000")  # 7
    dut.inp_weight7.value = BinaryValue("01000001000000000000000000000000")  # 8
    dut.inp_weight8.value = BinaryValue("01000001000100000000000000000000")  # 9
    await Timer(20, units="ns")
    dut.weight_en.value = 0  # Disable weight loading

    # Input activation matrix
    dut.inp_west0.value = BinaryValue("00111111100000000000000000000000")  # 1
    dut.inp_west3.value = BinaryValue("00000000000000000000000000000000")  # 0
    dut.inp_west6.value = BinaryValue("00000000000000000000000000000000")  # 0
    dut.compute.value = 1  # Start computation
    await Timer(20, units="ns")

    # Continuing the input activation matrix sequence
    dut.inp_west0.value = BinaryValue("01000000100000000000000000000000")
    dut.inp_west3.value = BinaryValue("01000000000000000000000000000000")
    dut.inp_west6.value = BinaryValue("00000000000000000000000000000000")
    await Timer(20, units="ns")

    dut.inp_west0.value = BinaryValue("01000000111000000000000000000000")
    dut.inp_west3.value = BinaryValue("01000000101000000000000000000000")
    dut.inp_west6.value = BinaryValue("01000000010000000000000000000000")
    await Timer(20, units="ns")

    dut.inp_west0.value = BinaryValue("00000000000000000000000000000000")
    dut.inp_west3.value = BinaryValue("01000001000000000000000000000000")
    dut.inp_west6.value = BinaryValue("01000000110000000000000000000000")
    await Timer(20, units="ns")

    dut.inp_west0.value = BinaryValue("00000000000000000000000000000000")
    dut.inp_west3.value = BinaryValue("00000000000000000000000000000000")
    dut.inp_west6.value = BinaryValue("01000001000100000000000000000000")
    await Timer(20, units="ns")

    # Observe the output for a few cycles
    # Note: Need additional logic to read out the final results from the array
    # This can involve checking the output signals of the systolic array
    # For example: assert dut.output_signal.value == expected_value, "Mismatch in output"
    await Timer(100, units="ns")

    # Stop computation
    dut.compute.value = 0
    await Timer(20, units="ns")