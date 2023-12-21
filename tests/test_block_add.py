import cocotb
from cocotb.triggers import RisingEdge
from cocotb.binary import BinaryValue
from utils import float_to_float16, binary_to_float16, print_matrix
from cocotb.clock import Clock


@cocotb.test()
async def test_get_block(dut):
    # Set up the initial conditions
    clock = Clock(dut.clk, 20, units="ns")  # 50 MHz clock
    cocotb.fork(clock.start())
    buffer_size = 4
    buffer_row_len = 2
    J = 2
    K= 2
    dut.rst.value = 1
    await RisingEdge(dut.clk)

    dut.rst.value = 0
    await RisingEdge(dut.clk)
    for i in range(J*K):
            dut.multiplied_block[i].value = BinaryValue(value=float_to_float16(i+1), n_bits=16)
    
    
    # Initialize the buffer with sequential values
    for i in range(buffer_size):
        dut.buffer_temp[i].value = BinaryValue(value=float_to_float16(i), n_bits=16)

    # Define the start row and column for the block to be read
    start_row = 0
    start_col = 0
    dut.start_row.value = start_row
    dut.start_col.value = start_col
    dut.start.value = 1
    #this is important. Need to wait for two clock cycles before reading the block. If only use one, the result gonna be xxxxx..
    await RisingEdge(dut.clk)
    dut.start.value = 0
    print("Done", dut.block_add_done.value)
    print_matrix(dut.multiplied_block, J, K, "multiplied_block")
    print_matrix(dut.buffer_temp, buffer_size/buffer_row_len, buffer_row_len, "buffer_temp")
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    print("Done", dut.block_add_done.value)
    await RisingEdge(dut.clk)
    print("Done", dut.block_add_done.value)
    print_matrix(dut.buffer_result, 2, 2, "added result")
    # Check the block values
    # for i in range(buffer_size):
    #     print(dut.buffer_result[i].value)
    #     original_val_idx = (start_row + i) * num_col + start_col + j
    #     original_val = dut.buffer[original_val_idx].value
    #     block_val_idx = i * K + j
    #     block_val = dut.block[block_val_idx].value
    #     assert block_val == original_val