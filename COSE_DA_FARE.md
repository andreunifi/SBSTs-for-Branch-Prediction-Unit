-[x] Derivs done
    -[x] modified syn_polito_rv32e_cached_assignment since it was causing hanging during synthesis. Check Telegram for the correct deriv
-[x] Riscv-64bits toolchain Installed and working
-[x] SBST compiled with provided toolchain (check Makefile inside examples/asm/sbst)
-[x] Simulation Working: Rember to always run source setup.sh and export LIBRARY_SIM_PATH
-[x] Working synthesis achieved: unless NECESSARY, avoid to run synthesis again. Remeber to move the NandGateOpens library to the gate/syn_polito_rv32e_cached_assignment folder before running synthesis, the simlink for techlibray.sv is broken
-[] Fault list modification: for now, no BPU-specific signals are added to the fault list. 
    -[] Add TDF faults to riscv_core and BPU
-[] Add additional strobe points to improve fault coverage
-[] Rewrite SBST.s to achieve higher fault coverage: PAY ATTENTION that if a non-supported risc32e instruction, or register is used, the core simulation will hang.
-[] Modify crt0.s for SBST initializion
-[] Report 
# Fault list 10/01/26
    #SAF    
        NA [0,1] {PORT "wallypipelinedcore_gate.**"}
    #TDF
        #NA [R,F] {PORT "riscv_core.ex_stage_i_alu_i.**"}
        #NA [R,F] {PORT "riscv_core.ex_stage_i_mult_i.**"}
        #NA [R,F] {PORT "riscv_core.**"}
