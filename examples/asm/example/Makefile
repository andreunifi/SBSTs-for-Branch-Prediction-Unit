example.objdump: example
	/opt/cvw_toolchain/bin/riscv64-unknown-elf-objdump -D example > example.objdump

example: example.S Makefile
	/opt/cvw_toolchain/bin/riscv64-unknown-elf-gcc -o example -march=rv32i -mabi=ilp32 -mcmodel=medany \
	    -nostartfiles -T../../link/link.ld  example.S

clean:
	rm -f example example.objdump
