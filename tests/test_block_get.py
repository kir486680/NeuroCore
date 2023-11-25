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

    dut.rst.value = 0
    await RisingEdge(dut.clk)
    print_matrix(dut.buffer, 2, 5, "Initial Buffer")
    # # Initialize the buffer with sequential values
    for i in range(buffer_size):
        dut.buffer[i].value = BinaryValue(value=float_to_float16(i), n_bits=16)
    print("Initialized data")
    # Define the start row and column for the block to be read
    start_row = 0
    start_col = 0
    num_col = 5
    dut.start_row.value = start_row
    dut.start_col.value = start_col
    dut.num_cols.value = num_col
    dut.matrix_len.value = buffer_size
    dut.start.value = 1
    #this is important. Need to wait for two clock cycles before reading the block. If only use one, the result gonna be xxxxx..
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.start.value = 0
    #lets now print the data in the buffer 
    print_matrix(dut.buffer, 2, 5, "Buffer after initialization")
    print_matrix(dut.block, J, K, "Block")
    print("Done", dut.block_get_done.value)
    await RisingEdge(dut.clk)
    
    # Check the block values
    for i in range(J):
        for j in range(K):
            original_val_idx = (start_row + i) * num_col + start_col + j
            original_val = dut.buffer[original_val_idx].value
            block_val_idx = i * K + j
            block_val = dut.block[block_val_idx].value
            assert block_val == original_val
    dut.start.value = 0
    await RisingEdge(dut.clk)
    print("Done", dut.block_get_done.value)
            
