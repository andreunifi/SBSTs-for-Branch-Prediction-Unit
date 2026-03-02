/*======================================================================*/
/* Proxy kernel linker script                                           */
/*======================================================================*/
/* This is the linker script used when building the proxy kernel. */

/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entries in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)


__stack_size = 0x00400;
/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/


SECTIONS
{

  /* text: test code section */
  . = 0x80000000;
  .text.init : { KEEP(*(.text.init)) }

  . = ALIGN(0x1000);
  .tohost : { *(.tohost) }

  /* interrupt vectors */
  .vectors :
  {
    PROVIDE(__vector_start = .);
    KEEP(*(.vectors));
  } 


  .text : { *(.text) }


   /* ---- Jump stubs go AFTER all growing sections ---- */
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

  . = 0x800070F8;
  .jumpend : { KEEP(*(.jumpend)) }

. = ALIGN(64);
JUMPSITES_BASE = .;
.jumpsite0 : { *(.jumpsite0) }
.jumpsite1 : { *(.jumpsite1) }
.jumpsite2 : { *(.jumpsite2) }
.jumpsite3 : { *(.jumpsite3) }
.jumpsite4 : { *(.jumpsite4) }
.jumpsite5 : { *(.jumpsite5) }
.jumpsite6 : { *(.jumpsite6) }
.jumpsite7 : { *(.jumpsite7) }

  /* data segment */
  /* .data : { *(.data) } */
  .data :
    {
      __data_start = .;
      *(.data*)
      __data_end = .;
    }

  .sdata : {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }

  /* bss segment */
  .sbss : {
    PROVIDE(__bss_start = . );
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }
  .bss : { *(.bss) 
  PROVIDE(__bss_end = . );
  }


  /* stack: we should consider putting this further to the top of the address
    space */
  .stack         : ALIGN(16) /* this is a requirement of the ABI(?) */
  {
   PROVIDE(__stack_start = .);
   . = __stack_size;
   PROVIDE(_sp = .);
   PROVIDE(__stack_end = .);
  } 

  /* thread-local data segment */
  .tdata :
  {
    _tdata_begin = .;
    *(.tdata)
    _tdata_end = .;
  }
  .tbss :
  {
    *(.tbss)
    _tbss_end = .;
  }

  /* End of uninitialized data segment */
  _end = .;
}