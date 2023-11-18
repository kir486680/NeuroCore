import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue

@cocotb.test()
async def fmul_tb(dut):
    """ Test for floating point multiplication """

    # Define the bit width
    BIT_W = 32

    # Initialize Inputs
    dut.a_in.value = 0
    dut.b_in.value = 0

    # Wait 100 ns for global reset to finish
    await Timer(10, units='ns')

    # Apply test cases
    dut.a_in.value = BinaryValue("01000000110000000000000000000000")  # Replace with actual test data
    dut.b_in.value = BinaryValue("01000000111000000000000000000000")  # Replace with actual test data
    await Timer(10, units='ns')

    # Add more test cases as needed

    # Finish the simulation
    dut._log.info("Test completed")
