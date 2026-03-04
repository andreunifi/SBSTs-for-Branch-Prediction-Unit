##############################################################################
# sbst2.S  --  BTB stress + branch-type coverage + load/store + CSR writes
#
# Phase 1 : BTB sled (64 unique JALs to thrash the 8-entry BTB)
# Phase 2 : All six branch-condition types (BEQ/BNE/BLT/BGE/BLTU/BGEU)
# Phase 3 : Dense branching to stress Fetch-Queue buffering
# Phase 4 : Cache-line boundary jump
# Phase 5 : Deep RAS recursion (depth 32, overflows 8-entry RAS)
# Phase 6 : JALR target switch (misprediction via computed target)
# Phase 7 : [NEW] Byte / halfword load-store with walking-1 data
# Phase 8 : [NEW] CSR write walking-1 (mscratch; exercises CSR datapath)
# Phase 9 : [NEW] Multi-cycle dependency chain
#
# SIGNATURE: a0 = HPM misprediction delta XOR data signature
##############################################################################

.section .text
.global test2
.type test2, @function

test2:
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

    # HPM baseline
    csrr s1, hpmcounter4
    csrr s2, hpmcounter5
    li   s11, 0                     # data signature

    # -------------------------------------------------------------------------
    # 1. BTB Thrash Sled -- 64 unique unconditional jumps
    # -------------------------------------------------------------------------
    j btb_00
btb_00: j btb_01
btb_01: j btb_02
btb_02: j btb_03
btb_03: j btb_04
btb_04: j btb_05
btb_05: j btb_06
btb_06: j btb_07
btb_07: j btb_08
btb_08: j btb_09
btb_09: j btb_10
btb_10: j btb_11
btb_11: j btb_12
btb_12: j btb_13
btb_13: j btb_14
btb_14: j btb_15
btb_15: j btb_16
btb_16: j btb_17
btb_17: j btb_18
btb_18: j btb_19
btb_19: j btb_20
btb_20: j btb_21
btb_21: j btb_22
btb_22: j btb_23
btb_23: j btb_24
btb_24: j btb_25
btb_25: j btb_26
btb_26: j btb_27
btb_27: j btb_28
btb_28: j btb_29
btb_29: j btb_30
btb_30: j btb_31
btb_31: j btb_32
btb_32: j btb_33
btb_33: j btb_34
btb_34: j btb_35
btb_35: j btb_36
btb_36: j btb_37
btb_37: j btb_38
btb_38: j btb_39
btb_39: j btb_40
btb_40: j btb_41
btb_41: j btb_42
btb_42: j btb_43
btb_43: j btb_44
btb_44: j btb_45
btb_45: j btb_46
btb_46: j btb_47
btb_47: j btb_48
btb_48: j btb_49
btb_49: j btb_50
btb_50: j btb_51
btb_51: j btb_52
btb_52: j btb_53
btb_53: j btb_54
btb_54: j btb_55
btb_55: j btb_56
btb_56: j btb_57
btb_57: j btb_58
btb_58: j btb_59
btb_59: j btb_60
btb_60: j btb_61
btb_61: j btb_62
btb_62: j btb_63
btb_63: nop

    # -------------------------------------------------------------------------
    # 2. All six branch-condition types (Taken paths, exercise comparator)
    # -------------------------------------------------------------------------
    li t0, 10
    li t1, 20
    li t2, -5           # large unsigned value

    # BEQ taken
    beq t0, t0, b_beq
    j test_end
b_beq:
    add s11, s11, t0

    # BNE taken
    bne t0, t1, b_bne
    j test_end
b_bne:
    add s11, s11, t1

    # BLT taken (10 < 20 signed)
    blt t0, t1, b_blt
    j test_end
b_blt:
    add s11, s11, t0

    # BGE taken (10 >= 10)
    bge t0, t0, b_bge
    j test_end
b_bge:
    add s11, s11, t0

    # BLTU taken (10 < MAXUINT unsigned)
    bltu t0, t2, b_bltu
    j test_end
b_bltu:
    add s11, s11, t2

    # BGEU taken (MAXUINT >= 10 unsigned)
    bgeu t2, t0, b_bgeu
    j test_end
b_bgeu:
    add s11, s11, t2

    # -------------------------------------------------------------------------
    # 3. Dense branching -- many rapid control-flow changes
    # -------------------------------------------------------------------------
    li t0, 0
    beq t0, zero, db_1
    nop
db_1:
    add s11, s11, t0
    bne t0, t1, db_2
    nop
db_2:
    xor s11, s11, t1
    blt t0, t1, db_3
    nop
db_3:
    xor s11, s11, t0

    # -------------------------------------------------------------------------
    # 4. Cache-line boundary jump
    # -------------------------------------------------------------------------
    .balign 64
    nop; nop; nop; nop
    nop; nop; nop; nop
    nop; nop; nop; nop
    nop; nop; nop
    j boundary_target
    nop; nop
boundary_target:
    add s11, s11, t1

    # -------------------------------------------------------------------------
    # 5. Deep RAS recursion (depth 32 > 8-entry RAS)
    # -------------------------------------------------------------------------
    li a0, 0
    li a1, 32
    jal ra, recursive_deep
    j jalr_test

recursive_deep:
    addi sp, sp, -4
    sw   ra, 0(sp)
    addi a0, a0, 1
    add  s11, s11, a0
    bge  a0, a1, recursive_base
    jal  ra, recursive_deep
recursive_base:
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

    # -------------------------------------------------------------------------
    # 6. JALR misprediction via switching target
    # -------------------------------------------------------------------------
jalr_test:
    li t0, 0
    li t1, 6
    li t2, 5
jalr_loop:
    la t3, target_A
    blt t0, t2, do_jump
    la t3, target_B
do_jump:
    la t3, target_B
    jalr x0, t3, 0

target_A:
    addi s11, s11, 1
    addi t0, t0, 1
    blt  t0, t1, jalr_loop
    j    lsw_test

target_B:
    addi s11, s11, 2

    # -------------------------------------------------------------------------
    # 7. [NEW] BYTE / HALFWORD LOAD-STORE WALKING-1
    # Tests sign/zero-extension paths and narrow-write datapaths in LSU.
    # Scratch area on stack (16 bytes).
    # -------------------------------------------------------------------------
lsw_test:
    addi s3, sp, -16            # use top 16 bytes of stack as scratch
    # (stack has extra room; s3 points just below current frame)
    li   s4, 1                  # walking-1
    li   s5, 0                  # loop counter
    li   s7, 32

lsw_loop:
    # Byte operations
    sb   s4, 0(s3)
    lb   t0, 0(s3)              # sign-extended
    lbu  t1, 0(s3)              # zero-extended
    xor  s11, s11, t0
    xor  s11, s11, t1

    # Halfword operations
    sh   s4, 4(s3)
    lh   t2, 4(s3)              # sign-extended
    lhu  t3, 4(s3)              # zero-extended
    xor  s11, s11, t2
    xor  s11, s11, t3

    # Word (full-width)
    sw   s4, 8(s3)
    lw   t4, 8(s3)
    xor  s11, s11, t4

    # Load-use hazard: immediately use loaded value
    sw   s4, 12(s3)
    lw   t5, 12(s3)
    add  t6, t5, s4             # use t5 one cycle after load (load-use stall)
    xor  s11, s11, t6

    slli s4, s4, 1
    addi s5, s5, 1
    blt  s5, s7, lsw_loop

    # -------------------------------------------------------------------------
    # 8. [NEW] CSR WRITE WALKING-1 (mscratch)
    # Each write drives a different bit through the CSR write datapath.
    # -------------------------------------------------------------------------
    li   s4, 1
    li   s5, 0

csr_walk_loop:
    csrw mscratch, s4           # write 2^i to mscratch
    csrr t0, mscratch           # read back; SA fault → t0 != s4
    xor  s11, s11, t0

    csrrs t1, mscratch, s4      # set bits
    csrrc t2, mscratch, s4      # clear bits
    xor  s11, s11, t1
    xor  s11, s11, t2

    slli s4, s4, 1
    addi s5, s5, 1
    li   s7, 32
    blt  s5, s7, csr_walk_loop

    # Write alternating patterns to mscratch
    li   t0, 0xAAAAAAAA
    csrw mscratch, t0;  csrr t1, mscratch;  xor s11, s11, t1
    li   t0, 0x55555555
    csrw mscratch, t0;  csrr t1, mscratch;  xor s11, s11, t1
    li   t0, 0xFFFFFFFF
    csrw mscratch, t0;  csrr t1, mscratch;  xor s11, s11, t1
    csrw mscratch, zero                     # restore

    # -------------------------------------------------------------------------
    # 9. [NEW] Multi-cycle ALU dependency chain
    # Exercises EX->EX forwarding with arithmetic diversity
    # -------------------------------------------------------------------------
    li   t0, 0x12345678
    add  t1, t0, t0
    sub  t2, t1, t0
    and  t3, t1, t2
    or   t4, t3, t2
    xor  t5, t4, t3
    sll  t6, t5, t3             # shift by forwarded value (low bits)
    srl  a5, t6, t5
    sra  a6, a5, t4
    xor  s11, s11, t1
    xor  s11, s11, t5
    xor  s11, s11, a6

    li t0, 4
test_end:
    nop
    addi t0, t0, -1
    bnez t0, test_end

    # Final signature: HPM delta XOR data
    csrr t5, hpmcounter4
    csrr t6, hpmcounter5
    sub  t5, t5, s1
    sub  t6, t6, s2
    xor  s11, s11, t5
    xor  s11, s11, t6

    mv   a0, s11

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

.section .data
.section .rodata
