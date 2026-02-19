sbst.objdump: sbst.elf
	/opt/cvw_toolchain/bin/riscv64-unknown-elf-objdump -D sbst.elf > sbst.objdump
	/opt/cvw_toolchain/bin/riscv64-unknown-elf-objdump -D sbst.elf > sbst.objdump

sbst.elf: sbst1.S sbst2.S sbst3.S main.c crt0.s tests.h Makefile vectors.S
	/opt/cvw_toolchain/bin/riscv64-unknown-elf-gcc -o sbst.elf -march=rv32i_zihpm -mabi=ilp32 -mcmodel=medany \
	    -nostartfiles -T../../link/link_sbst.ld  sbst1.S sbst2.S sbst3.S main.c crt0.s vectors.S 

clean:
	rm -f sbst.elf sbst.objdump