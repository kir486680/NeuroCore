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
    for i in range(4):
        dut.matrix_C[i].value = BinaryValue(value=float_to_float16(0), n_bits=16)
    await RisingEdge(dut.clk)
    print("Initialized data")
    print_matrix(dut.matrix_A, 2, 5, "Matrix A")
    print_matrix(dut.matrix_B, 5, 2, "Matrix B")
    print("Current state", dut.state.value)
    print("i,l,r", dut.i.value, dut.l.value, dut.r.value) 
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print_matrix(dut.block_get_A.buffer, 2, 5, "Input to block_get_A")
    print_matrix(dut.block_get_A.block, J, K, "Output of block_get_A")
    print_matrix(dut.block_a, J, K, "Block A") #it was not able to update yet here
    print_matrix(dut.block_b, J, K, "Block B") #it was not able to update yet here
    await RisingEdge(dut.clk)
    print_matrix(dut.block_a, J, K, "Block A")
    print_matrix(dut.block_b, J, K, "Block B")
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print("Start of add", dut.block_add.start.value)
    #print_matrix(dut.block_add.buffer_temp, J, K, "Input to block_add")
    #print_matrix(dut.block_add.multiplied_block, J, K, "Input to block_add")
    print_matrix(dut.block_add.buffer_result, 2,2, "Matrix C") 
    for i in range(8):
        await RisingEdge(dut.clk)
        print("Counter", dut.systolic_array.counter.value)

    print_matrix(dut.mul_result, J, K, "Matrix a after mult")
    print_matrix(dut.block_add.buffer_temp, 2,2, "Buffer Temp")
    await RisingEdge(dut.clk)
    #should be in the state of block_add
    print("Current state", dut.state.value)
    print_matrix(dut.block_add.buffer_temp, 2,2, "Buffer Temp")
    print_matrix(dut.matrix_C, 2,2, "Matrix C")
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print_matrix(dut.block_add.multiplied_block, 2,2, "Multiplied Result")
    print(dut.add_block.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print_matrix(dut.matrix_res, J, K, "Resultant Matrix")
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)

    #here we should be going back to get block
    print("-------------------------")
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print("i,l,r", dut.i.value, dut.l.value, dut.r.value) 
    print("Next state", dut.next_state.value) 
    print_matrix(dut.block_a, J, K, "Block A")
    print_matrix(dut.block_b, J, K, "Block B")
    print("Get BLocks", dut.get_block_a.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print("i,l,r", dut.i.value, dut.l.value, dut.r.value) 
    print("Next state", dut.next_state.value) 
    print_matrix(dut.block_a, J, K, "Block A")
    print_matrix(dut.block_b, J, K, "Block B")
    print("Get BLocks", dut.get_block_a.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)    
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value) 
    print("i,l,r", dut.i.value, dut.l.value, dut.r.value) 
    print("Next state", dut.next_state.value) 
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value) 
    print("i,l,r", dut.i.value, dut.l.value, dut.r.value) 
    print("Next state", dut.next_state.value) 
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    for i in range(8):
        await RisingEdge(dut.clk)
        print("Counter", dut.systolic_array.counter.value) 
    print_matrix(dut.mul_result, J, K, "Matrix a after mult")
    print_matrix(dut.matrix_C, J, K, "matrix C")
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    await RisingEdge(dut.clk)
    print("Current state", dut.state.value)
    print_matrix(dut.matrix_C, J, K, "Resultant Matrix")

    