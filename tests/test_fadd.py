import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue

@cocotb.test()
async def fmul_tb(dut):
    """ Test for floating point addition """

    # Define the bit width
    BIT_W = 32

    # Initialize Inputs
    dut.a_in.value = 0
    dut.b_in.value = 0

    # Wait 100 ns for global reset to finish
    await Timer(10, units='ns')

    # Test two positive. 6 +7 = 13
    dut.a_in.value = BinaryValue("01000000110000000000000000000000")  
    dut.b_in.value = BinaryValue("01000000111000000000000000000000")  
    await Timer(1, units='ns')
    assert dut.result.value == BinaryValue("01000001010100000000000000000000") 
    await Timer(9, units='ns')

    # Test one positive, and one negative number. 16 -5 = 11
    dut.a_in.value = BinaryValue("01000001100000000000000000000000")  
    dut.b_in.value = BinaryValue("11000000101000000000000000000000")  
    await Timer(1, units='ns')
    assert dut.result.value == BinaryValue("01000001001100000000000000000000") 
    await Timer(9, units='ns')

    # Test one positive, and one negative number. 0.25 + 0.3 = 0.55
    dut.a_in.value = BinaryValue("00111110100000000000000000000000")  
    dut.b_in.value = BinaryValue("00111110100110011001100110011010") 
    await Timer(1, units='ns')
    assert dut.result.value == BinaryValue("00111111000011001100110011001101") 
    await Timer(9, units='ns')

    dut.a_in.value = BinaryValue("00000000000000000000000000000000") 
    dut.b_in.value = BinaryValue("00000000000000000000000000000000")  
    await Timer(1, units='ns')
    assert dut.result.value == BinaryValue("00000000000000000000000000000000") 
    await Timer(9, units='ns')

    dut.a_in.value = BinaryValue("11111111111111111111111111111111")  
    dut.b_in.value = BinaryValue("11111111111111111111111111111111")  
    await Timer(10, units='ns')

    # Finish the simulation
    dut._log.info("Test completed")
