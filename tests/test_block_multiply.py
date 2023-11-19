import cocotb
import numpy as np
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb.binary import BinaryValue

def float_to_float16(value):
    # Convert Python float to numpy float16
    float16 = np.float16(value)
    # Convert to binary string and strip the '0b' prefix
    return format(np.float16(float16).view(np.uint16), '016b')

@cocotb.test()
async def systolic_array_test(dut):
    # Clock generation
    clock = Clock(dut.clk, 20, units="ns")  # 50 MHz clock
    cocotb.fork(clock.start())


    # Reset
    dut.rst.value = 1
    dut.start.value = 0
    dut.load_enable.value = 0
    dut.inp_a.value = BinaryValue(value=0, bits=16)
    dut.inp_b.value = BinaryValue(value=0, bits=16)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Start the loading process
    dut.start.value = 1
    await RisingEdge(dut.clk)
    dut.start.value = 0

    for i in range(10):
        dut.load_enable.value = 1
        dut.inp_a.value = BinaryValue(value=float_to_float16(i), bits=16)
        dut.inp_b.value = BinaryValue(value=float_to_float16(i), bits=16)
        await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    buffer_A_contents = [dut.buffer_A[i].value for i in range(10)]  # should be 0-9
    buffer_B_contents = [dut.buffer_B[i].value for i in range(10)]

    assert buffer_A_contents == [BinaryValue(value=float_to_float16(i), bits=16) for i in range(10)]
    assert buffer_B_contents == [BinaryValue(value=float_to_float16(i), bits=16) for i in range(10)]

    print("Contents of buffer_A:", buffer_A_contents)
    print("Contents of buffer_B:", buffer_B_contents)
