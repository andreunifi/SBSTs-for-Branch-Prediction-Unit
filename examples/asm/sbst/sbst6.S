##############################################################################
# sbst6.S  --  pcmuxBPWrongInvalidateFlush + RAS upper-bit activation
#
# CRITICAL NEW ADDITION (addresses 4,108 ND faults in RASPredictor):
#
#   SA-0 faults on bits [31:15] of RAS memory cells are ND because all
#   call sites in sbst1-5 are in the low address region (bits[31:15]=const).
#   The .sbst6_hi section is placed at a HIGH virtual address (bits[31:17]
#   are set by the linker).
#
#   NEW in this version: a deep recursive call chain INSIDE .sbst6_hi pushes
#   return addresses with bits[31:17] SET onto the RAS.  This converts SA-0
#   on those bits from ND to DD (write 1 → stuck-at-0 gives 0 → mismatch
#   → misprediction → HPM increment).
#
# Original 6 BHT misprediction loops (BNE/BEQ/BGE/BLT/BGEU/BLTU) kept.
# [NEW] deep recursive fill inside .sbst6_hi
# [NEW] CSR walking-1 on mhpmevent registers (new address bits)
# [NEW] LUI/AUIPC from inside high-address section
##############################################################################

.section .text
.global test6
.type   test6, @function

test6:
    addi  sp,  sp, -112
    sw    ra,  104(sp)
    sw    s0,   96(sp)
    sw    s1,   88(sp)
    sw    s2,   80(sp)
    sw    s3,   72(sp)
    sw    s4,   64(sp)
    sw    s5,   56(sp)
    sw    s6,   48(sp)
    sw    s7,   40(sp)
    sw    s8,   32(sp)
    sw    s9,   24(sp)
    sw    s10,  16(sp)
    sw    s11,   8(sp)
    addi  s0,  sp, 112

    li    s11, 0xB5DE0000
    csrr  s1, hpmcounter4
    csrr  s2, hpmcounter5

    # Enter the high-address section via J (does not push RAS)
    la    s8, test6_after_hi
    j     sbst6_hi_start

test6_after_hi:

    # ===========================================================
    # [NEW] CSR WALKING-1: high-numbered mhpmevent registers
    # These cover CSR address decoder bits [5:0] beyond what sbst4/5 hit
    # ===========================================================
    li   s3, 1
    li   s5, 0
csr6_loop:
    csrw  mscratch, s3
    csrr  t0, mscratch
    xor   s11, s11, t0
    slli  s3, s3, 1
    addi  s5, s5, 1
    li    s7, 32
    blt   s5, s7, csr6_loop
    csrw  mscratch, zero

    # mhpmevent16..31 (walking-1 on CSR address bits [4:0])
    li t0, 0xABCD1234
    csrw 0x330, t0;  csrr t1, 0x330;  xor s11, s11, t1
    csrw 0x331, t0;  csrr t1, 0x331;  xor s11, s11, t1
    csrw 0x332, t0;  csrr t1, 0x332;  xor s11, s11, t1
    csrw 0x333, t0;  csrr t1, 0x333;  xor s11, s11, t1
    csrw 0x334, t0;  csrr t1, 0x334;  xor s11, s11, t1
    csrw 0x335, t0;  csrr t1, 0x335;  xor s11, s11, t1
    csrw 0x336, t0;  csrr t1, 0x336;  xor s11, s11, t1
    csrw 0x337, t0;  csrr t1, 0x337;  xor s11, s11, t1
    csrw 0x338, t0;  csrr t1, 0x338;  xor s11, s11, t1
    csrw 0x339, t0;  csrr t1, 0x339;  xor s11, s11, t1
    csrw 0x33A, t0;  csrr t1, 0x33A;  xor s11, s11, t1
    csrw 0x33B, t0;  csrr t1, 0x33B;  xor s11, s11, t1
    csrw 0x33C, t0;  csrr t1, 0x33C;  xor s11, s11, t1
    csrw 0x33D, t0;  csrr t1, 0x33D;  xor s11, s11, t1
    csrw 0x33E, t0;  csrr t1, 0x33E;  xor s11, s11, t1
    csrw 0x33F, t0;  csrr t1, 0x33F;  xor s11, s11, t1
    # Clear all
    csrw 0x330, zero;  csrw 0x331, zero;  csrw 0x332, zero;  csrw 0x333, zero
    csrw 0x334, zero;  csrw 0x335, zero;  csrw 0x336, zero;  csrw 0x337, zero
    csrw 0x338, zero;  csrw 0x339, zero;  csrw 0x33A, zero;  csrw 0x33B, zero
    csrw 0x33C, zero;  csrw 0x33D, zero;  csrw 0x33E, zero;  csrw 0x33F, zero

    # Signature: HPM delta
    csrr  t5, hpmcounter4
    csrr  t6, hpmcounter5
    sub   t5, t5, s1
    sub   t6, t6, s2
    add   s11, s11, t5
    add   s11, s11, t6

    mv    a0, s11

    lw    s11,   8(sp)
    lw    s10,  16(sp)
    lw    s9,   24(sp)
    lw    s8,   32(sp)
    lw    s7,   40(sp)
    lw    s6,   48(sp)
    lw    s5,   56(sp)
    lw    s4,   64(sp)
    lw    s3,   72(sp)
    lw    s2,   80(sp)
    lw    s1,   88(sp)
    lw    s0,   96(sp)
    lw    ra,  104(sp)
    addi  sp,  sp, 112
    jr    ra


# ==================================================================
# .sbst6_hi  --  high-address section
#
# LINKER SCRIPT REQUIREMENT (unchanged from original):
#   .sbst6_hi : ALIGN(131072) { *(.sbst6_hi) }
#   Must be placed at BASE_HI where BASE_HI[31:17] != 0.
#
# CRITICAL NEW CONTENT:
#   ras_hi_deep: recursive call chain (depth 24) whose return addresses
#   all reside within .sbst6_hi (= BASE_HI + small_offset).
#   BASE_HI[31:17] != 0 by the linker constraint, so every pushed
#   return address has those upper bits set → SA-0 on bits[31:17] of
#   RAS memory cells becomes detectable (write 1 → misprediction on SA-0).
# ==================================================================
.section .sbst6_hi, "ax", @progbits
.balign 131072

sbst6_hi_start:

    # ===========================================================
    # PHASE 0 (NEW): Deep recursive fill from HIGH address
    # Pushes return addresses with BASE_HI[31:17] set onto the RAS.
    # s8 is preserved across calls (callee-saved).
    # ===========================================================
    addi  sp, sp, -8
    sw    s8, 4(sp)
    sw    s9, 0(sp)

    li    a0, 0
    li    a1, 24                # > RAS depth (covers overflow as bonus)
    call  ras_hi_deep           # ← return address is in .sbst6_hi

    lw    s9, 0(sp)
    lw    s8, 4(sp)
    addi  sp, sp, 8

    # ===========================================================
    # PHASE 1: BNE misprediction (TAKEN 5x then NOT-TAKEN)
    # ===========================================================
    li    t3, 6
sbst6_bne_loop:
    addi  t3, t3, -1
    bne   t3, x0, sbst6_bne_loop   # MISPREDICT #1

    # ===========================================================
    # PHASE 2: BEQ misprediction (NOT-TAKEN 5x then TAKEN)
    # ===========================================================
    li    t3, 6
sbst6_beq_loop:
    addi  t3, t3, -1
    beq   t3, x0, sbst6_beq_taken
    j     sbst6_beq_loop
sbst6_beq_taken:                    # MISPREDICT #2

    # ===========================================================
    # PHASE 3: BGE misprediction
    # ===========================================================
    li    t3, 7
sbst6_bge_loop:
    addi  t3, t3, -1
    bge   t3, x0, sbst6_bge_loop   # MISPREDICT #3

    # ===========================================================
    # PHASE 4: BLT misprediction
    # ===========================================================
    li    t3, 6;  li t4, 1
sbst6_blt_loop:
    addi  t3, t3, -1
    blt   t3, t4, sbst6_blt_taken
    j     sbst6_blt_loop
sbst6_blt_taken:                    # MISPREDICT #4

    # ===========================================================
    # PHASE 5: BGEU misprediction
    # ===========================================================
    li    t3, 6
sbst6_bgeu_loop:
    addi  t3, t3, -1
    bgeu  x0, t3, sbst6_bgeu_taken
    j     sbst6_bgeu_loop
sbst6_bgeu_taken:                   # MISPREDICT #5

    # ===========================================================
    # PHASE 6: BLTU misprediction
    # ===========================================================
    li    t3, 6;  li t4, 1
sbst6_bltu_loop:
    addi  t3, t3, -1
    bltu  t3, t4, sbst6_bltu_taken
    j     sbst6_bltu_loop
sbst6_bltu_taken:                   # MISPREDICT #6

    # ===========================================================
    # (NEW) PHASE 7: LUI/AUIPC from high address
    # The AUIPC result has BASE_HI[31:17] set → exercises PC adder
    # with high upper bits.
    # ===========================================================
    auipc t0, 0x00001;  xor s11, s11, t0
    auipc t0, 0x00010;  xor s11, s11, t0
    auipc t0, 0x00100;  xor s11, s11, t0
    lui   t0, 0xFFFFF;  xor s11, s11, t0   # all-1 upper immediate

    # Return to test6
    jr    s8

# ------------------------------------------------------------------
# ras_hi_deep: recursive fill inside .sbst6_hi
# All call sites are in this section → return addresses carry BASE_HI
# upper bits → activates SA-0 on those bits in RAS memory cells.
# a0 = counter, a1 = max depth
# ------------------------------------------------------------------
ras_hi_deep:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    addi  a0, a0, 1
    bge   a0, a1, ras_hi_base
    call  ras_hi_deep           # ← pushed return address in .sbst6_hi
ras_hi_base:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret                         # ← pops return address pushed above
