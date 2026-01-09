sbst.objdump: sbst.elf
	/opt/cvw_toolchain/bin/riscv64-unknown-elf-objdump -D sbst.elf > sbst.objdump

sbst.elf: sbst.S main.c crt0.s tests.h Makefile vectors.S
	/opt/cvw_toolchain/bin/riscv64-unknown-elf-gcc -o sbst.elf -march=rv32i_zicsr -mabi=ilp32 -mcmodel=medany \
	    -nostartfiles -T../../link/link_sbst.ld  sbst.S main.c crt0.s vectors.S

clean:
	rm -f sbst.elf sbst.objdump


extended: sbst.S main.c crt0.s tests.h Makefile vectors.S
		/opt/cvw_toolchain/bin/riscv32-unknown-elf-gcc -o sbst.elf -march=rv32i_zicsr -mabi=ilp32 -mcmodel=medany \
	    -nostartfiles -T../../link/link_sbst.ld  sbst.S main.c crt0.s vectors.S
