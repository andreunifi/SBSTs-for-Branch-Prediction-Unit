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
  
  . = ALIGN(64);
  .w0_entry0 : { KEEP(*(.w0_entry0)) }  

  . = ALIGN(64);
  .w0d_entry0 : { KEEP(*(.w0d_entry0)) }
  .w0d_entry2 : ALIGN(8) { KEEP(*(.w0d_entry2)) }
  .w0d_entry4 : ALIGN(8) { KEEP(*(.w0d_entry4)) }
  .w0d_entry6 : ALIGN(8) { KEEP(*(.w0d_entry6)) }
  . += 4;
  .w0d_entry1 : { KEEP(*(.w0d_entry1)) }
  .w0d_entry3 : { KEEP(*(.w0d_entry3)) }
  .w0d_entry5 : { KEEP(*(.w0d_entry5)) }
  .w0d_entry7 : { KEEP(*(.w0d_entry7)) }

  .ras_low  : { KEEP(*(.ras_low))  }





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
  .ras_walk_t3 : { KEEP(*(.ras_walk_t3)) }

  . = 0x80028000;
  .btb_walk_t5 : { KEEP(*(.btb_walk_t5)) }

    . = 0x80040000;
  .ras_fill_t3 : { KEEP(*(.ras_fill_t3)) }

  
  /* ---- TEST3 Phase 6 ---- */
  .p6a0 : { KEEP(*(.p6a0)) }
  .p6b0 : { KEEP(*(.p6b0)) }
  .p6a1 : { KEEP(*(.p6a1)) }
  .p6b1 : { KEEP(*(.p6b1)) }
  .p6a2 : { KEEP(*(.p6a2)) }
  .p6b2 : { KEEP(*(.p6b2)) }
  .p6a3 : { KEEP(*(.p6a3)) }
  .p6b3 : { KEEP(*(.p6b3)) }
  .p6a4 : { KEEP(*(.p6a4)) }
  .p6b4 : { KEEP(*(.p6b4)) }
  .p6a5 : { KEEP(*(.p6a5)) }
  .p6b5 : { KEEP(*(.p6b5)) }
  .p6a6 : { KEEP(*(.p6a6)) }
  .p6b6 : { KEEP(*(.p6b6)) }
  .p6a7 : { KEEP(*(.p6a7)) }
  .p6b7 : { KEEP(*(.p6b7)) }
  .p6a8 : { KEEP(*(.p6a8)) }
  .p6b8 : { KEEP(*(.p6b8)) }
  .p6a9 : { KEEP(*(.p6a9)) }
  .p6b9 : { KEEP(*(.p6b9)) }

/*Sbst3.S phase 3*/
  .p7_1  : { KEEP(*(.p7_1))  }
  .p7_2  : { KEEP(*(.p7_2))  }
  .p7_3  : { KEEP(*(.p7_3))  }
  .p7_4  : { KEEP(*(.p7_4))  }
  .p7_5  : { KEEP(*(.p7_5))  }
  .p7_6  : { KEEP(*(.p7_6))  }
  .p7_7  : { KEEP(*(.p7_7))  }
  .p7_8  : { KEEP(*(.p7_8))  }
  .p7_9  : { KEEP(*(.p7_9))  }
  .p7_10 : { KEEP(*(.p7_10)) }
  .p7_11 : { KEEP(*(.p7_11)) }



  . = 0x80011000;
  .hi_b16 : { KEEP(*(.hi_b16)) }
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
  
  .data : { __data_start = .; *(.data*) __data_end = .; }
  .sdata : { __global_pointer$ = . + 0x800; *(.srodata*) *(.sdata*) }
  .sbss : { PROVIDE(__bss_start = . ); *(.sbss*) *(.scommon) }
  .bss : { *(.bss) PROVIDE(__bss_end = . ); }
  .stack : ALIGN(16) { PROVIDE(__stack_start = .); . = __stack_size; PROVIDE(_sp = .); PROVIDE(__stack_end = .); }
  .tdata : { _tdata_begin = .; *(.tdata) _tdata_end = .; }
  .tbss : { *(.tbss) _tbss_end = .; }
  _end = .;

  .ras_high : { KEEP(*(.ras_high)) }

 . = 0x87FFFE00; 
  .w1_entry0 : { KEEP(*(.w1_entry0)) }

  .w1_entry1 : 
  ALIGN(8)
  { KEEP(*(.w1_entry1)) }

  .w1_entry2 : 
  ALIGN(8)
  { KEEP(*(.w1_entry2)) }

  .w1_entry3 : 
  ALIGN(8)
  { KEEP(*(.w1_entry3)) }

  .w1_entry4 :
  ALIGN(8)
  { KEEP(*(.w1_entry4)) }

  .w1_entry5 :
  ALIGN(8)
  { KEEP(*(.w1_entry5)) }

  .w1_entry6 : 
  ALIGN(8)
  { KEEP(*(.w1_entry6)) }

  .w1_entry7 :
  ALIGN(8)
  { KEEP(*(.w1_entry7)) }

  .w1_entry8 :
  ALIGN(8)
  { KEEP(*(.w1_entry8)) }

  .w1_entry9 :
  ALIGN(8)
  { KEEP(*(.w1_entry9)) }
  
}
