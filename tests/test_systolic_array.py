import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
from cocotb.binary import BinaryValue
from utils import float_to_float16, print_matrix, binary_to_float16

@cocotb.test()
async def systolic_array_test(dut):
    # Clock generation
    clock = Clock(dut.clk, 20, units="ns")  # 50 MHz clock
    cocotb.start_soon(clock.start())

    # Initialize Inputs
    dut.rst.value = 1

    ROWS = 2
    COLS = 2
    a_size = ROWS * COLS

    # Reset the system
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    for i in range(a_size):
        dut.block_a[i].value = BinaryValue(value=float_to_float16(i+1), n_bits=16)
    for i in range(a_size):
            dut.block_b[i].value = BinaryValue(value=float_to_float16(i+1), n_bits=16)
    await RisingEdge(dut.clk)
    print_matrix(dut.block_a, ROWS, COLS, "Matrix a after initialization")
    print_matrix(dut.block_b, ROWS, COLS, "Matrix a after initialization")
    for i in range(ROWS):
        for j in range((COLS + ROWS) -1):
            # Calculate the flattened index
            index = i * (COLS + ROWS) + j
            # Access the element using the flattened index
            val = dut.shift_registers[index].value
            print(f"Shift register[{i}][{j}] (Flattened index {index}) = {val}")
    await RisingEdge(dut.clk)
    dut.load = 1
    await RisingEdge(dut.clk)
    dut.load = 0
    dut.start = 1
    await RisingEdge(dut.clk)
    #cycle 1 
    print("Cycle 0")
    for i in range(ROWS):
        for j in range((COLS + ROWS) -1):
            # Calculate the flattened index
            index = i * (COLS + ROWS) + j
            # Access the element using the flattened index
            val = dut.shift_registers[index].value
            print(f"Shift register[{i}][{j}] (Flattened index {index}) = {val}")
    print("P1", dut.P1.inp_west.value, dut.P1.inp_north.value, dut.P1.outp_east.value, dut.P1.outp_south.value)
    print("P2", dut.P2.inp_west.value, dut.P2.inp_north.value, dut.P2.outp_east.value, dut.P2.outp_south.value)
    print("P3", dut.P3.inp_west.value, dut.P3.inp_north.value, dut.P3.outp_east.value, dut.P3.outp_south.value)
    print("P4", dut.P4.inp_west.value, dut.P4.inp_north.value, dut.P4.outp_east.value, dut.P4.outp_south.value)
    print(dut.P1.weight)
    print(dut.P1.inp_west)
    await RisingEdge(dut.clk)
    print("Cycle 1")
    print(dut.P1.outp_east)
    for i in range(ROWS):
        for j in range((COLS + ROWS) -1):
            # Calculate the flattened index
            index = i * (COLS + ROWS) + j
            # Access the element using the flattened index
            val = dut.shift_registers[index].value
            print(f"Shift register[{i}][{j}] (Flattened index {index}) = {val}")
    print("P1", dut.P1.inp_west.value, dut.P1.inp_north.value, dut.P1.outp_east.value, dut.P1.outp_south.value)
    print("P2", dut.P2.inp_west.value, dut.P2.inp_north.value, dut.P2.outp_east.value, dut.P2.outp_south.value)
    print("P3", dut.P3.inp_west.value, dut.P3.inp_north.value, dut.P3.outp_east.value, dut.P3.outp_south.value)
    print("P4", dut.P4.inp_west.value, dut.P4.inp_north.value, dut.P4.outp_east.value, dut.P4.outp_south.value)
    await RisingEdge(dut.clk)
    print("Cycle 3")
    print("P1", dut.P1.inp_west.value, dut.P1.inp_north.value, dut.P1.outp_east.value, dut.P1.outp_south.value)
    print("P2", dut.P2.inp_west.value, dut.P2.inp_north.value, dut.P2.outp_east.value, dut.P2.outp_south.value)
    print("P3", dut.P3.inp_west.value, dut.P3.inp_north.value, dut.P3.outp_east.value, dut.P3.outp_south.value)
    print("P4", dut.P4.inp_west.value, dut.P4.inp_north.value, dut.P4.outp_east.value, dut.P4.outp_south.value)
    # printing the last row of the north_south_wires
    for i in range(COLS):
        val = dut.north_south_wires_last_row[i].value
        val = binary_to_float16(val)
        print(f"North-South last row wire[{i}] = {val}")
    await RisingEdge(dut.clk)
    print("Cycle 4")
    print("P1", dut.P1.inp_west.value, dut.P1.inp_north.value, dut.P1.outp_east.value, dut.P1.outp_south.value)
    print("P2", dut.P2.inp_west.value, dut.P2.inp_north.value, dut.P2.outp_east.value, dut.P2.outp_south.value)
    print("P3", dut.P3.inp_west.value, dut.P3.inp_north.value, dut.P3.outp_east.value, dut.P3.outp_south.value)
    print("P4", dut.P4.inp_west.value, dut.P4.inp_north.value, dut.P4.outp_east.value, dut.P4.outp_south.value)
    for i in range(COLS):
        val = dut.north_south_wires_last_row[i].value
        val = binary_to_float16(val)
        print(f"North-South last row wire[{i}] = {val}")
    await RisingEdge(dut.clk)
    print("Cycle 5")
    for i in range(COLS):
        val = dut.north_south_wires_last_row[i].value
        val = binary_to_float16(val)
        print(f"North-South last row wire[{i}] = {val}")
    for i in range(ROWS + ROWS -1):
        for j in range(COLS):
            # Calculate the flattened index
            index = i * COLS + j
   
            # Access the element using the flattened index
            val = dut.shift_registers_last_row[index].value
            print(f"Shift last_row register[{i}][{j}] (Flattened index {index}) = {val}")
    await RisingEdge(dut.clk)
    print("Cycle 6")
    print(dut.counter.value)
    for i in range(ROWS + ROWS -1):
        for j in range(COLS):
            # Calculate the flattened index
            index = i * COLS + j
   
            # Access the element using the flattened index
            val = dut.shift_registers_last_row[index].value
            print(f"Shift last_row register[{i}][{j}] (Flattened index {index}) = {val}")
    print_matrix(dut.block_result, ROWS, COLS, "Matrix a after initialization")
    await RisingEdge(dut.clk)
    #Now we have the result and the counter is back to 0
    print_matrix(dut.block_result, ROWS, COLS, "Matrix a after initialization")

    print(dut.counter.value)
    print(dut.block_multiply_done.value)