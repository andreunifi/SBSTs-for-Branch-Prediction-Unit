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

    #========================================
    # PHASE 4: ALU WALKING-1 TEST
    # Exercises every bit of the 32-bit IEU datapath.
    # s3 = 2^i (walking-1), iterates i = 0..31
    #========================================
    li   s3, 1          # walking bit
    li   s5, 0          # loop counter
    li   s7, 32

alu_walk_loop:
    # -- Arithmetic --
    add  t0, s3, zero        # identity
    add  t1, s3, s3          # carry from bit-i into bit-(i+1)
    sub  t2, zero, s3        # negate: -2^i (borrow chain test)
    sub  t3, s3, s3          # self-sub = 0

    # -- Bitwise --
    and  t4, s3, s3          # identity
    or   t5, s3, zero        # identity
    xor  t6, s3, zero        # identity
    xor  a5, s3, s3          # zero

    # -- Signed compare --
    slt  a6, zero, s3        # 1 for bits 0-30, 0 for bit 31 (negative)
    slt  a7, s3,  zero       # 0 for bits 0-30, 1 for bit 31

    # -- Unsigned compare --
    sltu t0, zero, s3        # always 1 (s3 != 0)
    sltu t1, s3,  zero       # always 0

    # -- Immediate ADD extremes --
    addi t2, s3, 2047
    addi t3, s3, -2048

    # -- Immediate AND/OR/XOR --
    andi t4, s3, -1          # s3 (all 1s mask)
    ori  t5, s3,  0          # s3
    xori t6, s3, -1          # ~s3

    # -- Immediate SLT --
    slti  a5, s3, 1          # 1 only if s3 < 1 (signed) = bit 31
    sltiu a6, s3, 2          # 1 only if s3 < 2 (unsigned) = iteration 0 (s3=1)

    xor  s11, s11, t2
    xor  s11, s11, t3
    xor  s11, s11, t6
    xor  s11, s11, a5
    xor  s11, s11, a6

    slli s3, s3, 1           # advance walking-1
    addi s5, s5, 1
    blt  s5, s7, alu_walk_loop

    # Boundary / corner cases for adder
    li   t0, 0x7FFFFFFF
    addi t1, t0,  1          # overflow from positive to negative
    li   t2, 0x80000000
    sub  t3, zero, t2        # INT_MIN negate (overflow)
    add  t4, t0,  t0         # 0xFFFFFFFE
    xor  s11, s11, t1
    xor  s11, s11, t3
    xor  s11, s11, t4

    # Alternating pattern
    li   t0, 0xAAAAAAAA
    li   t1, 0x55555555
    and  t2, t0, t1          # 0 (no common bits)
    or   t3, t0, t1          # 0xFFFFFFFF
    xor  t4, t0, t1          # 0xFFFFFFFF
    add  t5, t0, t1          # 0xFFFFFFFF (no carry between alternating)
    xor  s11, s11, t2
    xor  s11, s11, t3
    xor  s11, s11, t5

    #========================================
    # PHASE 5: SHIFT COMPREHENSIVE TEST
    # Tests SLL/SRL/SRA for all shift amounts 0..31
    # Two patterns: negative (DEADBEEF) and positive (12345678)
    #========================================
    li   s5, 0

shift_loop:
    li   t0, 0xDEADBEEF      # pattern with bit31=1 (tests sign extension of SRA)
    sll  t1, t0, s5
    srl  t2, t0, s5
    sra  t3, t0, s5          # sign-extends for all amounts when bit31=1
    xor  s11, s11, t1
    xor  s11, s11, t2
    xor  s11, s11, t3

    li   t0, 0x12345678      # pattern with bit31=0
    sll  t4, t0, s5
    srl  t5, t0, s5
    sra  t6, t0, s5          # no sign-extension
    xor  s11, s11, t4
    xor  s11, s11, t5
    xor  s11, s11, t6

    addi s5, s5, 1
    li   s7, 32
    blt  s5, s7, shift_loop

    # Immediate shift sample (key amounts)
    li   t0, 0xA5A5A5A5
    slli t1, t0,  1;  slli t2, t0,  8;  slli t3, t0, 15;  slli t4, t0, 23;  slli t5, t0, 31
    srli t6, t0,  1;  srli a5, t0,  8;  srli a6, t0, 15;  srli a7, t0, 23;  srli t1, t0, 31
    srai t2, t0,  1;  srai t3, t0,  8;  srai t4, t0, 15;  srai t5, t0, 23;  srai t6, t0, 31
    xor  s11, s11, t1
    xor  s11, s11, t2

    #========================================
    # PHASE 6: LUI / AUIPC WALKING-1 ON BITS[31:12]
    # Exercises upper-immediate decode and PC-adder in fetch unit
    #========================================
    lui  t0, 0x00001;  xor s11, s11, t0   # bit 12
    lui  t0, 0x00002;  xor s11, s11, t0   # bit 13
    lui  t0, 0x00004;  xor s11, s11, t0   # bit 14
    lui  t0, 0x00008;  xor s11, s11, t0   # bit 15
    lui  t0, 0x00010;  xor s11, s11, t0   # bit 16
    lui  t0, 0x00020;  xor s11, s11, t0   # bit 17
    lui  t0, 0x00040;  xor s11, s11, t0   # bit 18
    lui  t0, 0x00080;  xor s11, s11, t0   # bit 19
    lui  t0, 0x00100;  xor s11, s11, t0   # bit 20
    lui  t0, 0x00200;  xor s11, s11, t0   # bit 21
    lui  t0, 0x00400;  xor s11, s11, t0   # bit 22
    lui  t0, 0x00800;  xor s11, s11, t0   # bit 23
    lui  t0, 0x01000;  xor s11, s11, t0   # bit 24
    lui  t0, 0x02000;  xor s11, s11, t0   # bit 25
    lui  t0, 0x04000;  xor s11, s11, t0   # bit 26
    lui  t0, 0x08000;  xor s11, s11, t0   # bit 27
    lui  t0, 0x10000;  xor s11, s11, t0   # bit 28
    lui  t0, 0x20000;  xor s11, s11, t0   # bit 29
    lui  t0, 0x40000;  xor s11, s11, t0   # bit 30
    lui  t0, 0x80000;  xor s11, s11, t0   # bit 31
    lui  t0, 0xFFFFF;  xor s11, s11, t0   # all upper bits
    lui  t0, 0xAAAAA;  xor s11, s11, t0
    lui  t0, 0x55555;  xor s11, s11, t0
    auipc t0, 0x00001; xor s11, s11, t0
    auipc t0, 0x00010; xor s11, s11, t0
    auipc t0, 0x00100; xor s11, s11, t0

    #========================================
    # PHASE 7: LOAD/STORE WALKING-1 TEST
    # Tests SW/LW, SB/LB/LBU, SH/LH/LHU
    # with walking-1 data pattern (32 iterations)
    #========================================
    la   t0, ls_scratch1
    li   s3, 1
    li   s5, 0
    li   s7, 32

ls1_loop:
    # Word
    sw   s3, 0(t0)
    lw   t1, 0(t0)              # full 32-bit round-trip

    # Byte (sign-extending vs zero-extending)
    sb   s3, 4(t0)
    lb   t2, 4(t0)              # sign-extended
    lbu  t3, 4(t0)              # zero-extended (t2 != t3 for bit 7)

    # Halfword
    sh   s3, 8(t0)
    lh   t4, 8(t0)              # sign-extended
    lhu  t5, 8(t0)              # zero-extended (t4 != t5 for bit 15)

    # Load-use hazard: use load result in the immediately following instruction
    sw   s3, 12(t0)
    lw   t6, 12(t0)
    add  a5, t6, s3             # RAW: reads t6 one cycle after load
    sub  a6, a5, s3             # chain

    xor  s11, s11, t1
    xor  s11, s11, t2
    xor  s11, s11, t3
    xor  s11, s11, t4
    xor  s11, s11, t5
    xor  s11, s11, a5
    xor  s11, s11, a6

    slli s3, s3, 1
    addi s5, s5, 1
    blt  s5, s7, ls1_loop

    # Store/load with negative offsets (different address-adder path)
    la   t0, ls_scratch1
    addi t0, t0, 32             # point to middle of scratch area
    li   t1, 0xDEADBEEF
    sw   t1, -4(t0);   lw t2, -4(t0)
    sw   t1, -8(t0);   lw t3, -8(t0)
    xor  s11, s11, t2
    xor  s11, s11, t3

    #========================================
    # PHASE 8: DATA FORWARDING CHAINS
    # EX->EX and MEM->EX RAW hazards
    #========================================
    li   t0, 0x01234567
    add  t1, t0, t0             # t1 = 2*t0 (reads t0 from prev stage)
    add  t2, t1, t0             # EX->EX on t1
    add  t3, t2, t1             # EX->EX on t2
    sub  t4, t3, t2             # EX->EX on t3
    and  t5, t3, t4             # EX->EX on t4
    or   t6, t5, t4             # EX->EX on t5
    xor  a5, t6, t5             # EX->EX on t6
    sll  a6, t1, t4             # shift amount from forwarded result (mod 32)
    srl  a7, t2, a6             # double-forwarded shift

    xor  s11, s11, t1
    xor  s11, s11, t3
    xor  s11, s11, a5
    xor  s11, s11, a7

    # Immediate-operand forwarding (forwarding bypasses immediate mux)
    li   t0, 0xABCD0000
    addi t1, t0, 0x123          # forward from li result
    addi t2, t1, -1             # forward from addi result
    andi t3, t2, 0x7FF          # forward from addi
    xor  s11, s11, t3

    mv   a0, s11                # return accumulated signature

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
