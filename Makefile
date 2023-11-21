# Variables
VENV_NAME ?= venv
VENV_ACTIVATE = . $(VENV_NAME)/bin/activate
PYTHON = python3

# Default target
all: env test

# Create a virtual environment
env:
	@test -d $(VENV_NAME) || virtualenv -p $(PYTHON) $(VENV_NAME)
	@$(VENV_ACTIVATE) && pip install -r requirements.txt

# Run Cocotb tests
test: env
	@echo "Running Cocotb tests..."
	@$(VENV_ACTIVATE) && make -C tests

# Clean up
clean:
	rm -rf $(VENV_NAME)
	make -C tests clean

# Helper targets
.PHONY: all env test clean
