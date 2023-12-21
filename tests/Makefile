# Makefile for running Cocotb tests

SIM ?= icarus

# Verilog source files
VERILOG_SOURCES = ../src/define.v \
                  ../src/fadd.v \
                  ../src/fmul.v \
                  ../src/block_get.v \
                  ../src/block_add.v \
                  ../src/main.v \
                  ../src/block.v \
                  ../src/systolic_array.v\
                  ../src/matrix_mul.v

# You will have to create separate test rules for each module
#TOPLEVEL_LANG = verilog
#TOPLEVEL = block_add
MODULE = test_block_add
TOPLEVEL = matrix_mul
MODULE = test_matrix_mul

include $(shell cocotb-config --makefiles)/Makefile.sim

# You can create custom rules for running individual tests, e.g.,
# test_fadd: MODULE=test_fadd TOPLEVEL=fadd $(shell cocotb-config --makefiles)/Makefile.sim
