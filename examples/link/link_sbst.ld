OUTPUT_ARCH( "riscv" )
ENTRY(_start)
__stack_size = 0x00400;
SECTIONS
{
  . = 0x80000000;
  .text.init : { KEEP(*(.text.init)) }
  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }
  .vectors : { PROVIDE(__vector_start = .); KEEP(*(.vectors)); }
  .text : { *(.text) }
  . = 0x80006820;
  .jumptk0 : { KEEP(*(.jumptk0)) }
  . = 0x80006864;
  .jumptk1 : { KEEP(*(.jumptk1)) }
  . = 0x800068A8;
  .jumptk2 : { KEEP(*(.jumptk2)) }
  . = 0x800068EC;
  .jumptk3 : { KEEP(*(.jumptk3)) }
  . = 0x80006930;
  .jumptk4 : { KEEP(*(.jumptk4)) }
  . = 0x80006974;
  .jumptk5 : { KEEP(*(.jumptk5)) }
  . = 0x800069B8;
  .jumptk6 : { KEEP(*(.jumptk6)) }
  . = 0x800069FC;
  .jumptk7 : { KEEP(*(.jumptk7)) }
  . = 0x80008000;
  .ras_walk_t4 : { KEEP(*(.ras_walk_t4)) }
  . = 0x80018000;
  .ras_walk_t5 : { KEEP(*(.ras_walk_t5)) }
  . = 0x80028000;
  .btb_walk_t5 : { KEEP(*(.btb_walk_t5)) }
  . = 0x80040000;
  .sbst6_hi : { KEEP(*(.sbst6_hi)) }
  . = 0x80062000;
  .p1a0 : { KEEP(*(.p1a0)) }
  .p1b0 : { KEEP(*(.p1b0)) }
  .p1a1 : { KEEP(*(.p1a1)) }
  .p1b1 : { KEEP(*(.p1b1)) }
  .p1a2 : { KEEP(*(.p1a2)) }
  .p1b2 : { KEEP(*(.p1b2)) }
  .p1a3 : { KEEP(*(.p1a3)) }
  .p1b3 : { KEEP(*(.p1b3)) }
  .p1a4 : { KEEP(*(.p1a4)) }
  .p1b4 : { KEEP(*(.p1b4)) }
  .p1a5 : { KEEP(*(.p1a5)) }
  .p1b5 : { KEEP(*(.p1b5)) }
  .p1a6 : { KEEP(*(.p1a6)) }
  .p1b6 : { KEEP(*(.p1b6)) }
  .p1a7 : { KEEP(*(.p1a7)) }
  .p1b7 : { KEEP(*(.p1b7)) }
  .p1a8 : { KEEP(*(.p1a8)) }
  .p1b8 : { KEEP(*(.p1b8)) }
  .p1a9 : { KEEP(*(.p1a9)) }
  .p1b9 : { KEEP(*(.p1b9)) }
  .p1a10 : { KEEP(*(.p1a10)) }
  .p1b10 : { KEEP(*(.p1b10)) }
  .p1a11 : { KEEP(*(.p1a11)) }
  .p1b11 : { KEEP(*(.p1b11)) }
  .p1a12 : { KEEP(*(.p1a12)) }
  .p1b12 : { KEEP(*(.p1b12)) }
  .p1a13 : { KEEP(*(.p1a13)) }
  .p1b13 : { KEEP(*(.p1b13)) }
  .p1a14 : { KEEP(*(.p1a14)) }
  .p1b14 : { KEEP(*(.p1b14)) }
  .p1a15 : { KEEP(*(.p1a15)) }
  .p1b15 : { KEEP(*(.p1b15)) }
  .p2_1 : { KEEP(*(.p2_1)) }
  .p2_2 : { KEEP(*(.p2_2)) }
  .p2_3 : { KEEP(*(.p2_3)) }
  .p2_4 : { KEEP(*(.p2_4)) }
  .p2_5 : { KEEP(*(.p2_5)) }
  .p2_6 : { KEEP(*(.p2_6)) }
  .p2_7 : { KEEP(*(.p2_7)) }
  .p2_8 : { KEEP(*(.p2_8)) }
  .p2_9 : { KEEP(*(.p2_9)) }
  .p2_10 : { KEEP(*(.p2_10)) }
  .p2_11 : { KEEP(*(.p2_11)) }
  .p2_12 : { KEEP(*(.p2_12)) }
  .p2_13 : { KEEP(*(.p2_13)) }
  .p2_14 : { KEEP(*(.p2_14)) }
  .p2_15 : { KEEP(*(.p2_15)) }
  .p2_16 : { KEEP(*(.p2_16)) }
  .p2_17 : { KEEP(*(.p2_17)) }
  .p4_1 : { KEEP(*(.p4_1)) }
  .p4_2 : { KEEP(*(.p4_2)) }
  .p4_3 : { KEEP(*(.p4_3)) }
  .p4_4 : { KEEP(*(.p4_4)) }
  .p4_5 : { KEEP(*(.p4_5)) }
  .p4_6 : { KEEP(*(.p4_6)) }
  .p4_7 : { KEEP(*(.p4_7)) }
  .p4_8 : { KEEP(*(.p4_8)) }
  .p4_9 : { KEEP(*(.p4_9)) }
  .p4_10 : { KEEP(*(.p4_10)) }
  .p4_11 : { KEEP(*(.p4_11)) }
  .p4_12 : { KEEP(*(.p4_12)) }
  .p4_13 : { KEEP(*(.p4_13)) }
  .p4_14 : { KEEP(*(.p4_14)) }
  .p4_15 : { KEEP(*(.p4_15)) }
  .p4_16 : { KEEP(*(.p4_16)) }
  .jt0 : { KEEP(*(.jt0)) }
  .jt1 : { KEEP(*(.jt1)) }
  .jt2 : { KEEP(*(.jt2)) }
  .jt3 : { KEEP(*(.jt3)) }
  .jt4 : { KEEP(*(.jt4)) }
  .jt5 : { KEEP(*(.jt5)) }
  .jt6 : { KEEP(*(.jt6)) }
  .jt7 : { KEEP(*(.jt7)) }
  .jt8 : { KEEP(*(.jt8)) }
  .jt9 : { KEEP(*(.jt9)) }
  .jt10 : { KEEP(*(.jt10)) }
  .jt11 : { KEEP(*(.jt11)) }
  .jt12 : { KEEP(*(.jt12)) }
  .jt13 : { KEEP(*(.jt13)) }
  .jt14 : { KEEP(*(.jt14)) }
  .jt15 : { KEEP(*(.jt15)) }
  . = 0x80011000;
  .hi_b16 : { KEEP(*(.hi_b16)) }
  /* newlib stubs ~13KB; gap to .hi_b17 = 68KB; distance from .vectors ~80KB < 1MB JAL range */
  .text_libs : { *(.text.*) }
  . = 0x80022000;
  .hi_b17 : { KEEP(*(.hi_b17)) }
  . = 0x80070000;
  .hi_b18 : { KEEP(*(.hi_b18)) }
  . = 0x80080000;
  .hi_b19 : { KEEP(*(.hi_b19)) }
  . = 0x80100000;
  .hi_b20 : { KEEP(*(.hi_b20)) }
  . = 0x80200000;
  .hi_b21 : { KEEP(*(.hi_b21)) }
  . = 0x80400000;
  .hi_b22 : { KEEP(*(.hi_b22)) }
  . = 0x80800000;
  .hi_b23 : { KEEP(*(.hi_b23)) }
  . = 0x81000000;
  .hi_b24 : { KEEP(*(.hi_b24)) }
  . = 0x82000000;
  .hi_b25 : { KEEP(*(.hi_b25)) }
  /* UNCORE_RAM_RANGE=0x07FFFFFF -> max addr 0x87FFFFFF (128MB)          */
  /* Bits 27-31 unreachable; use 4 pages of bit-26 for RAS/BTB coverage.  */
  . = 0x84000000;  .hi_b26    : { KEEP(*(.hi_b26)) }    /* bit 26 page 1 */
  . = 0x85000000;  .hi_b27    : { KEEP(*(.hi_b27)) }    /* bit 26 page 2 */
  . = 0x86000000;  .hi_b28    : { KEEP(*(.hi_b28)) }    /* bit 26 page 3 */
  . = 0x87000000;  .hi9_combo : { KEEP(*(.hi9_combo)) } /* bit 26 page 4 */

  . = 0x800F0000;
  .hi_combo_lo : { KEEP(*(.hi_combo_lo)) }
  . = 0x80F00000;
  .hi_combo_hi : { KEEP(*(.hi_combo_hi)) }
  .data : { __data_start = .; *(.data*) __data_end = .; }
  .sdata : { __global_pointer$ = . + 0x800; *(.srodata*) *(.sdata*) }
  .sbss : { PROVIDE(__bss_start = . ); *(.sbss*) *(.scommon) }
  .bss : { *(.bss) PROVIDE(__bss_end = . ); }
  .stack : ALIGN(16) { PROVIDE(__stack_start = .); . = __stack_size; PROVIDE(_sp = .); PROVIDE(__stack_end = .); }
  .tdata : { _tdata_begin = .; *(.tdata) _tdata_end = .; }
  .tbss : { *(.tbss) _tbss_end = .; }
  _end = .;
}
