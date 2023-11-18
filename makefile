# Define directories
SRC_DIR := src 
TB_DIR := tb
BUILD_DIR := build

# Search for all Verilog source files in the source directory. Wildcard is used in makefile to match filenames with a pattern
SRCS := $(wildcard $(SRC_DIR)/*.v)

# Search for all Verilog testbench files in the testbench directory
TBS := $(wildcard $(TB_DIR)/*_tb.v)

# Target for each testbench is to build an executable VVP file
#This line would take each filename in TBS, which contains the testbench files found by wildcard, strip off the tb/ directory and _tb.v suffix, and then replace them with the build/ directory and .vvp suffix. So if TBS contains tb/adder_tb.v, TARGETS would contain build/adder.vvp.
TARGETS := $(patsubst $(TB_DIR)/%_tb.v, $(BUILD_DIR)/%.vvp, $(TBS))

.PHONY: all test clean # this line tells make that these targets are not files, but rather commands. This is to avoid a conflict if a file named all, test, or clean exists in the directory. If this line is not included, make will not run the commands if a file with the same name exists.

# Default target
all: $(TARGETS)

# Rule to create a VVP file from a testbench file
#$^ in this case are the source files and the corresponding testbench files
#The $@ is the target, which is the VVP file
$(BUILD_DIR)/%.vvp: $(TB_DIR)/%_tb.v $(SRCS)
	@mkdir -p $(BUILD_DIR)
	iverilog -o $@ $^/block.v

# Rule to run all simulations. 
test: $(TARGETS)
	@for target in $^ ; do \
		echo "Running simulation for $$target..."; \
		vvp $$target; \
	done

# Clean up the build directory
clean:
	rm -rf $(BUILD_DIR)

# Help menu
help:
	@echo "Usage:"
	@echo "  make         # Compile all testbenches"
	@echo "  make test    # Run all simulations"
	@echo "  make clean   # Remove build directory"
