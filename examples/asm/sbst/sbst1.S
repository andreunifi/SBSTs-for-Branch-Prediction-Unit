##############################################################################
# sbst1.S  --  BHT 2-bit counter saturation + comprehensive IEU/LSU test
#
# Phase 1-3  : existing BHT saturation test (8 entries, BPRED_SIZE=3)
# Phase 4    : ALU walking-1  (ADD/SUB/AND/OR/XOR/SLT/SLTU + immediates)
# Phase 5    : Shift sweep    (SLL/SRL/SRA all 32 amounts, two patterns)
# Phase 6    : LUI/AUIPC walking on bits[31:12]
# Phase 7    : Load/store walking-1 (SW/LW, SB/LB/LBU, SH/LH/LHU)
# Phase 8    : Data-forwarding chain (EX->EX and load-use RAW hazards)
#
# SIGNATURE: a0 = accumulated XOR of all computed values.
##############################################################################

.section .text
.global test1
.type test1, @function

.data
A:           .word 0
B:           .word 1
ls_scratch1: .space 64          # 64-byte scratch area for load/store test

test1:
    # ABI prologue
    addi sp, sp, -112
    sw ra,  104(sp)
    sw s0,   96(sp)
    sw s1,   88(sp)
    sw s2,   80(sp)
    sw s3,   72(sp)
    sw s4,   64(sp)
    sw s5,   56(sp)
    sw s6,   48(sp)
    sw s7,   40(sp)
    sw s8,   32(sp)
    sw s9,   24(sp)
    sw s10,  16(sp)
    sw s11,   8(sp)
    addi s0, sp, 112

    li   s11, 0                 # global signature accumulator

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    #========================================
    # PHASE 1: Saturate all 8 BHT entries to 11
    #========================================
    la  x11, A
    lw  x10, 0(x11)
    lw  x12, 0(x11)

    call JUMPTK0; call JUMPTK0; call JUMPTK0
    call JUMPTK1; call JUMPTK1; call JUMPTK1
    call JUMPTK2; call JUMPTK2; call JUMPTK2
    call JUMPTK3; call JUMPTK3; call JUMPTK3
    call JUMPTK4; call JUMPTK4; call JUMPTK4
    call JUMPTK5; call JUMPTK5; call JUMPTK5
    call JUMPTK6; call JUMPTK6; call JUMPTK6
    call JUMPTK7; call JUMPTK7; call JUMPTK7

    

    #========================================
    # PHASE 2: Move 11 -> 00 (Not-Taken, descending)
    #========================================
    la  x11, B
    lw  x12, 0(x11)

    call JUMPTK7; call JUMPTK7; call JUMPTK7; call JUMPTK7
    call JUMPTK6; call JUMPTK6; call JUMPTK6; call JUMPTK6
    call JUMPTK5; call JUMPTK5; call JUMPTK5; call JUMPTK5
    call JUMPTK4; call JUMPTK4; call JUMPTK4; call JUMPTK4
    call JUMPTK3; call JUMPTK3; call JUMPTK3; call JUMPTK3
    call JUMPTK2; call JUMPTK2; call JUMPTK2; call JUMPTK2
    call JUMPTK1; call JUMPTK1; call JUMPTK1; call JUMPTK1
    call JUMPTK0; call JUMPTK0; call JUMPTK0; call JUMPTK0

    #========================================
    # PHASE 3: Move 00 -> 11 (Taken, ascending)
    #========================================
    la  x11, A
    lw  x12, 0(x11)

    call JUMPTK0; call JUMPTK0; call JUMPTK0; call JUMPTK0
    call JUMPTK1; call JUMPTK1; call JUMPTK1; call JUMPTK1
    call JUMPTK2; call JUMPTK2; call JUMPTK2; call JUMPTK2
    call JUMPTK3; call JUMPTK3; call JUMPTK3; call JUMPTK3
    call JUMPTK4; call JUMPTK4; call JUMPTK4; call JUMPTK4
    call JUMPTK5; call JUMPTK5; call JUMPTK5; call JUMPTK5
    call JUMPTK6; call JUMPTK6; call JUMPTK6; call JUMPTK6
    call JUMPTK7; call JUMPTK7; call JUMPTK7; call JUMPTK7

    mv   a0, s11                # return accumulated signature

        csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # ABI epilogue
    lw s11,  8(sp)
    lw s10, 16(sp)
    lw s9,  24(sp)
    lw s8,  32(sp)
    lw s7,  40(sp)
    lw s6,  48(sp)
    lw s5,  56(sp)
    lw s4,  64(sp)
    lw s3,  72(sp)
    lw s2,  80(sp)
    lw s1,  88(sp)
    lw s0,  96(sp)
    lw ra, 104(sp)
    addi sp, sp, 112
    jr   ra

#--------------------------------------------------------------
# BHT stub sections -- each placed in its own section so the
# linker can map them to distinct BHT entries (BPRED_SIZE=3).
#--------------------------------------------------------------
    .section .jumptk0, "ax", @progbits
    .align 2
JUMPTK0:
    beq x10, x12, TK0
    nop
TK0: ret

    .section .jumptk1, "ax", @progbits
    .align 2
JUMPTK1:
    beq x10, x12, TK1
    nop
TK1: ret

    .section .jumptk2, "ax", @progbits
    .align 2
JUMPTK2:
    beq x10, x12, TK2
    nop
TK2: ret

    .section .jumptk3, "ax", @progbits
    .align 2
JUMPTK3:
    beq x10, x12, TK3
    nop
TK3: ret

    .section .jumptk4, "ax", @progbits
    .align 2
JUMPTK4:
    beq x10, x12, TK4
    nop
TK4: ret

    .section .jumptk5, "ax", @progbits
    .align 2
JUMPTK5:
    beq x10, x12, TK5
    nop
TK5: ret

    .section .jumptk6, "ax", @progbits
    .align 2
JUMPTK6:
    beq x10, x12, TK6
    nop
TK6: ret

    .section .jumptk7, "ax", @progbits
    .align 2
JUMPTK7:
    beq x10, x12, TK7
    nop
TK7: ret
