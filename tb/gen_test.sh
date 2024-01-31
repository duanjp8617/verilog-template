#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Must specify 1 file name"
    exit -1
else
    if [ -d ./$1_test ]; then
        echo "Testbench $1_test already exists"
        exit -1
    fi

    if ! which iverilog >/dev/null; then
        echo "iverilog is not installed"
        exit -1
    fi

    if ! which vvp >/dev/null; then
        echo "vvp is not installed"
        exit -1
    fi

    if ! which cocotb-config >/dev/null; then
        echo "cocotb-config is not installed"
        exit -1
    fi
fi

COCOTB_LIB_DIR=$(cocotb-config --lib-dir)
COCOTB_LIB_NAME=$(cocotb-config --lib-name vpi icarus)

mkdir -p $1_test

# the makefile template
read -d '\n' MAKEFILE << 'EndOfText'
# the icarus compiler and runtime
ICARUS_COMP = iverilog
ICARUS_RUNTIME = vvp

# verilator
VERILATOR_COMP = verilator

# can be queried with: cocotb-config --lib-dir
COCOTB_LIB_DIR = %%%1

# can be quried with: cocotb-config --lib-name vpi icarus
COCOTB_LIB_NAME = %%%2

# the build directory
SIM_BUILD = sim_build
OBJ_DIR = obj_dir

# the icarus compiler flags
ICARUS_COMP_FLAGS = -o $(SIM_BUILD)/sim.vvp -f $(SIM_BUILD)/cmds.f -g2012

# the dut source files
DUT = %%%3
TOPLEVEL = $(DUT)
MODULE = $(DUT)_test
VERILOG_SOURCES += ../../rtl/$(DUT).v

# configurable compile parameters:
# To set the module parameter, use the following command to make:
# make EXTRA_ARGS="-P <module_name>.<param_name>=<value>"
# Remove the sim_build directory before make.
EXTRA_ARGS ?=

# configurable parameters:
COCOTB_HDL_TIMEUNIT ?= 1ns
COCOTB_HDL_TIMEPRECISION ?= 1ps

TESTCASE ?=

test: $(SIM_BUILD)/sim.vvp
	rm -f results.xml
	MODULE=$(MODULE) TESTCASE=$(TESTCASE) TOPLEVEL=$(TOPLEVEL) TOPLEVEL_LANG=verilog $(ICARUS_RUNTIME) -M $(COCOTB_LIB_DIR) -m $(COCOTB_LIB_NAME) $(SIM_BUILD)/sim.vvp

$(SIM_BUILD)/sim.vvp: $(SIM_BUILD)/.tmp $(VERILOG_SOURCES)
	@echo "+timescale+$(COCOTB_HDL_TIMEUNIT)/$(COCOTB_HDL_TIMEPRECISION)" > $(SIM_BUILD)/cmds.f
	$(ICARUS_COMP) $(ICARUS_COMP_FLAGS) $(EXTRA_ARGS) $(VERILOG_SOURCES)

$(SIM_BUILD)/.tmp:
	mkdir -p $(SIM_BUILD) && touch $@

syntax: 
	$(VERILATOR_COMP) -cc $(VERILOG_SOURCES)

clean:
	rm -rf __pycache__ $(SIM_BUILD) $(OBJ_DIR) results.xml
EndOfText

(echo "$MAKEFILE" | sed "s:%%%1:$COCOTB_LIB_DIR:g; s:%%%2:$COCOTB_LIB_NAME:g; s:%%%3:$1:g") >> $1_test/Makefile

read -d '\n' PYTHON << 'EndOfText'
import cocotb

from cocotb.triggers import Timer

@cocotb.test()
async def test_method(dut):
    pass
EndOfText

echo "$PYTHON" >> $1_test/$1_test.py