# Makefile for running Cocotb tests

SIM ?= icarus

# Verilog source files
VERILOG_SOURCES = ../src/define.v \
                  ../src/get_block.v\
                  ../src/block_multiply.v \
                  ../src/fadd.v \
                  ../src/fmul.v \
                  ../src/block.v \
                  ../src/systolic_array.v

# You will have to create separate test rules for each module
TOPLEVEL_LANG = verilog
TOPLEVEL = get_block
MODULE = test_get_block


include $(shell cocotb-config --makefiles)/Makefile.sim

# You can create custom rules for running individual tests, e.g.,
# test_fadd: MODULE=test_fadd TOPLEVEL=fadd $(shell cocotb-config --makefiles)/Makefile.sim
