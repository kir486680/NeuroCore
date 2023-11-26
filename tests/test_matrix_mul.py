import cocotb
from cocotb.triggers import RisingEdge
from cocotb.binary import BinaryValue
from utils import float_to_float16, print_matrix
from cocotb.clock import Clock

@cocotb.test()
async def test_get_block(dut):
    # Set up the initial conditions
    clock = Clock(dut.clk, 20, units="ns")  # 50 MHz clock
    cocotb.fork(clock.start())
    #assume we are working here with matrix 2x5
    buffer_size = 10
    J = 2
    K= 2
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    #we can also get the a module called block_get. To do that we just print 
    
    dut.rst.value = 0
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    # # Initialize the buffer with sequential values
    for i in range(buffer_size):
        dut.matrix_A[i].value = BinaryValue(value=float_to_float16(i), n_bits=16)
    for i in range(buffer_size):
        dut.matrix_B[i].value = BinaryValue(value=float_to_float16(i), n_bits=16)
    await RisingEdge(dut.clk)
    print("Initialized data")
    print_matrix(dut.matrix_A, 2, 5, "Matrix A")
    print_matrix(dut.matrix_B, 5, 2, "Matrix B")
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print_matrix(dut.block_get_A.buffer, 2, 5, "Input to block_get_A")
    print_matrix(dut.block_get_A.block, J, K, "Output of block_get_A")
    print_matrix(dut.block_a, J, K, "Block A")
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print_matrix(dut.block_get_A.block, J, K, "Output of block_get_A")
    print_matrix(dut.block_b, J, K, "Block B")
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)