#!/bin/bash

# EDA Workflow Script

set -e  # Exit on error

echo "Step 0: Setup tools"
source eda_tools_setup

echo ""
echo "Step 1: Navigate to examples/asm/sbst"
cd examples/asm/sbst

echo ""
echo "Step 2: Compile the program"
make clean || true
make

echo ""
echo "Step 3: Navigate back to \${WALLY} directory"
cd ../../..

echo ""
echo "Step 4: Run simulation"
wsim --elf ./examples/asm/sbst/sbst.elf --define +define+GATE_LEVEL=1 --sim questa --tb testbench --vcd syn_polito_rv32e_bpu --gate

echo ""
echo "Step 5: Navigate to zoix"
cd zoix

echo ""
echo "Step 6: Run fault simulation"
./zoix_cvw.sh syn_polito_rv32e_bpu questa

echo ""
echo "Workflow completed successfully!"
