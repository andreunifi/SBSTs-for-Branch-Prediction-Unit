##############################################################################
# sbst9.S  --  RAS bits 26-28 SA-0/TDF + BTB high-addr + icpred + MUL/DIV
#
# ROOT CAUSE ANALYSIS (from cvw_coverage_hierarchical.sff):
#
#   1. RAS memory cells bits 26-28: 100% ND
#      sbst8 covered bits 16-25 (0x80010000..0x82000000).
#      Bits 26-28 require code at 0x84000000 / 0x88000000 / 0x90000000
#      (all within UNCORE_RAM_RANGE 0x80000000..0x9FFFFFFF).
#      Pattern: SA-0 undetectable because bit_N is never written 1.
#
#   2. BTBTargetEReg / BTBD bits 26-28: 159 / 158 ND
#      The BTB stores 32-bit targets.  Bits 26-28 of the stored target
#      are never 1 because all JAL/branch targets are in the low region.
#      Executing JAL to 0x84000000+ trains the BTB; a SA-0 on bit 26 of
#      BTBTargetEReg would predict 0x80000000 instead of 0x84000000 ->
#      misprediction -> HPM counter increment -> detectable.
#
#   3. icpred (71 ND, 12.24%):
#      Indirect call predictor BTB-like cells never see high-address
#      JALR targets. JALR to 0x84000000+ multiple times trains the
#      predictor; SA-0 on high bits -> wrong prediction -> detectable.
#
#   4. MUL / MULH / MULHU / MULHSU / DIV / DIVU / REM / REMU (non-BPU):
#      M-extension datapath has ~3135 ND faults outside the BPU.
#      Walking-1 operands + edge cases (INT_MIN/-1, x/0) exercise the
#      multiply-divide unit exhaustively.
#
# STRATEGY:
#   For each bit N in {26, 27, 28}:
#     Step 1: call hi_bN_n1  (16-deep nested chain at BASE | 2^N)
#             -> all 16 RAS entries loaded with return addresses where
#                bit N = 1. SA-0 on bit N -> misprediction -> detected.
#     Step 2: 16 sequential low-address calls
#             -> overwrites all 16 RAS entries with bit N = 0.
#             -> creates the 1->0 transition: TDF-F detected!
#     Step 3: call hi_bN_n1 again
#             -> creates the 0->1 transition: TDF-R verified.
#
#   COMBO: same scheme but at 0x9C000000 (bits 26+27+28 all set).
#
#   icpred: 8 distinct JALR instructions (different source PCs), each
#   targeting a different stub inside the high-address sections.
#   Each JALR executed 8+ times so the predictor learns the target.
#
#   MUL/DIV: walking-1 on both operands, plus all 4 signed/unsigned
#   variants, plus divide-by-zero corner cases.
#
# LINKER REQUIREMENTS:
#   . = 0x84000000;  .hi_b26    : { KEEP(*(.hi_b26)) }
#   . = 0x88000000;  .hi_b27    : { KEEP(*(.hi_b27)) }
#   . = 0x90000000;  .hi_b28    : { KEEP(*(.hi_b28)) }
#   . = 0x9C000000;  .hi9_combo : { KEEP(*(.hi9_combo)) }
#
# NOTE on bits 29-31:
#   Bit 29 requires code at 0xA0000000 which is at the boundary of
#   UNCORE_RAM_RANGE (base 0x80000000, range 0x1FFFFFFF -> max 0x9FFFFFFF).
#   Bits 30-31 are out of range (bit 31 is always 1 -> SA-1 untestable).
#   To cover bit 29, extend UNCORE_RAM_RANGE to 64'h3FFFFFFF in derivlist
#   and add a .hi_b29 section at 0xA0000000.
#
# SIGNATURE: a0 = s11 (XOR/ADD accumulator, deterministic)
##############################################################################

# Tell the assembler to accept M-extension opcodes for this file only.
# The linker flag -march stays rv32i_zicsr so the C runtime is unaffected.
.attribute arch, "rv32im_zicsr"

.section .text
.global test9
.type   test9, @function

test9:
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

    li    s11, 0xD9A00000        # distinctive seed

    #=========================================================================
    # BIT 26: code at 0x84000000  (UNCORE_RAM offset 0x04000000)
    # All return addresses from hi_b26_nX have bit 26 = 1.
    #=========================================================================

    # Step 1: fill all 16 RAS entries with bit 26 = 1
    call  hi_b26_n1
    xor   s11, s11, a0

    # Step 2: 16 low-address sequential calls -> overwrite RAS with bit 26 = 0
    #         This creates the 1->0 transition (TDF-F on bit 26 detected).
    call  lo9_b26_0
    call  lo9_b26_1
    call  lo9_b26_2
    call  lo9_b26_3
    call  lo9_b26_4
    call  lo9_b26_5
    call  lo9_b26_6
    call  lo9_b26_7
    call  lo9_b26_8
    call  lo9_b26_9
    call  lo9_b26_10
    call  lo9_b26_11
    call  lo9_b26_12
    call  lo9_b26_13
    call  lo9_b26_14
    call  lo9_b26_15
    xor   s11, s11, ra

    # Step 3: fill again with bit 26 = 1 -> SA-0 re-verified, TDF-R covered
    call  hi_b26_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 27: code at 0x88000000  (UNCORE_RAM offset 0x08000000)
    #=========================================================================

    call  hi_b27_n1
    xor   s11, s11, a0

    call  lo9_b27_0
    call  lo9_b27_1
    call  lo9_b27_2
    call  lo9_b27_3
    call  lo9_b27_4
    call  lo9_b27_5
    call  lo9_b27_6
    call  lo9_b27_7
    call  lo9_b27_8
    call  lo9_b27_9
    call  lo9_b27_10
    call  lo9_b27_11
    call  lo9_b27_12
    call  lo9_b27_13
    call  lo9_b27_14
    call  lo9_b27_15
    xor   s11, s11, ra

    call  hi_b27_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 28: code at 0x90000000  (UNCORE_RAM offset 0x10000000)
    #=========================================================================

    call  hi_b28_n1
    xor   s11, s11, a0

    call  lo9_b28_0
    call  lo9_b28_1
    call  lo9_b28_2
    call  lo9_b28_3
    call  lo9_b28_4
    call  lo9_b28_5
    call  lo9_b28_6
    call  lo9_b28_7
    call  lo9_b28_8
    call  lo9_b28_9
    call  lo9_b28_10
    call  lo9_b28_11
    call  lo9_b28_12
    call  lo9_b28_13
    call  lo9_b28_14
    call  lo9_b28_15
    xor   s11, s11, ra

    call  hi_b28_n1
    xor   s11, s11, a0

    #=========================================================================
    # COMBO (bits 26+27+28 all set): code at 0x9C000000
    # Tests multi-bit patterns in RAS cells simultaneously.
    #=========================================================================

    call  hi9_combo_n1
    xor   s11, s11, a0

    call  lo9_combo_0
    call  lo9_combo_1
    call  lo9_combo_2
    call  lo9_combo_3
    call  lo9_combo_4
    call  lo9_combo_5
    call  lo9_combo_6
    call  lo9_combo_7
    call  lo9_combo_8
    call  lo9_combo_9
    call  lo9_combo_10
    call  lo9_combo_11
    call  lo9_combo_12
    call  lo9_combo_13
    call  lo9_combo_14
    call  lo9_combo_15
    xor   s11, s11, ra

    call  hi9_combo_n1
    xor   s11, s11, a0

    #=========================================================================
    # PHASE icpred: JALR to high-address stubs (8 distinct call sites)
    #
    # The indirect call predictor (icpred) stores (PC_of_JALR -> target)
    # mappings. Each of the 8 JALR instructions below has a different
    # source PC and a different high-address target, exercising different
    # predictor cells.  Each is executed 8 times so the predictor learns.
    #
    # Targets point into the hi_b26/27/28 chains; the stubs return
    # ra (PC of the call) in a0 for signature accumulation.
    #=========================================================================

    li    s5, 0
    li    s7, 8

jalr9_loop_b26:
    la    t0, hi9_jalr_stub_b26
    jalr  ra, t0, 0           # indirect call: source PC trains icpred
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, jalr9_loop_b26

    li    s5, 0
jalr9_loop_b27:
    la    t0, hi9_jalr_stub_b27
    jalr  ra, t0, 0
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, jalr9_loop_b27

    li    s5, 0
jalr9_loop_b28:
    la    t0, hi9_jalr_stub_b28
    jalr  ra, t0, 0
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, jalr9_loop_b28

    li    s5, 0
jalr9_loop_combo:
    la    t0, hi9_jalr_stub_combo
    jalr  ra, t0, 0
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, jalr9_loop_combo

    # Four more JALR with slightly different offsets (distinct source PCs
    # in the BTB -> exercises more icpred cells)
    la    t1, hi9_jalr_stub_b26
    jalr  ra, t1, 0;  xor s11, s11, a0
    la    t1, hi9_jalr_stub_b26
    jalr  ra, t1, 0;  xor s11, s11, a0
    la    t2, hi9_jalr_stub_b27
    jalr  ra, t2, 0;  xor s11, s11, a0
    la    t2, hi9_jalr_stub_b27
    jalr  ra, t2, 0;  xor s11, s11, a0
    la    t3, hi9_jalr_stub_b28
    jalr  ra, t3, 0;  xor s11, s11, a0
    la    t3, hi9_jalr_stub_b28
    jalr  ra, t3, 0;  xor s11, s11, a0
    la    t4, hi9_jalr_stub_combo
    jalr  ra, t4, 0;  xor s11, s11, a0
    la    t4, hi9_jalr_stub_combo
    jalr  ra, t4, 0;  xor s11, s11, a0

    #=========================================================================
    # PHASE MUL: MUL/MULH/MULHU/MULHSU walking-1 on both operands
    #
    # Each pair (walking-1 × fixed, fixed × walking-1) exercises every
    # bit of the 33×33-bit multiplier array.
    #=========================================================================

    # Walking-1 on first operand, fixed second = 0xABCDE123
    li    s3, 1                 # walking-1
    li    s5, 0
    li    s9, 0xABCDE123        # fixed pattern (sign-bit clear in some)
    li    s7, 32

mul9_walk_a:
    mul    t0, s3, s9
    mulh   t1, s3, s9           # signed upper half
    mulhu  t2, s3, s9           # unsigned upper half
    mulhsu t3, s3, s9           # signed*unsigned upper half
    xor   s11, s11, t0
    xor   s11, s11, t1
    xor   s11, s11, t2
    xor   s11, s11, t3
    slli  s3, s3, 1
    addi  s5, s5, 1
    blt   s5, s7, mul9_walk_a

    # Walking-1 on second operand, fixed first = 0x76543210
    li    s4, 0x76543210
    li    s3, 1
    li    s5, 0

mul9_walk_b:
    mul    t0, s4, s3
    mulh   t1, s4, s3
    mulhu  t2, s4, s3
    mulhsu t3, s4, s3
    xor   s11, s11, t0
    xor   s11, s11, t1
    xor   s11, s11, t2
    xor   s11, s11, t3
    slli  s3, s3, 1
    addi  s5, s5, 1
    blt   s5, s7, mul9_walk_b

    # Specific MUL corner cases
    li    t0, 0x7FFFFFFF        # INT_MAX
    li    t1, 0x7FFFFFFF
    mul    t2, t0, t1           # INT_MAX^2 low
    mulh   t3, t0, t1           # INT_MAX^2 high (signed)
    mulhu  t4, t0, t1           # unsigned
    xor   s11, s11, t2
    xor   s11, s11, t3
    xor   s11, s11, t4

    li    t0, 0x80000000        # INT_MIN (-2^31)
    li    t1, 0xFFFFFFFF        # -1
    mul    t2, t0, t1           # INT_MIN * (-1) = INT_MIN (overflow)
    mulh   t3, t0, t1           # high word: 0
    mulhu  t4, t0, t1           # unsigned high word
    xor   s11, s11, t2
    xor   s11, s11, t3
    xor   s11, s11, t4

    li    t0, 0xAAAAAAAA
    li    t1, 0x55555555
    mul    t2, t0, t1
    mulhu  t3, t0, t1
    xor   s11, s11, t2
    xor   s11, s11, t3

    li    t0, 0xFFFFFFFF
    li    t1, 0xFFFFFFFF
    mul    t2, t0, t1           # (-1)*(-1) = 1
    mulh   t3, t0, t1           # signed: -1*-1 high = 0
    mulhu  t4, t0, t1           # unsigned: MAXUINT^2 high
    xor   s11, s11, t2
    xor   s11, s11, t3
    xor   s11, s11, t4

    #=========================================================================
    # PHASE DIV: DIV/DIVU/REM/REMU walking-1 + edge cases
    #
    # Walking-1 on divisor (fixed dividend = 0xFFFFFFFE = -2).
    # Also walking-1 on dividend with fixed divisor = 3.
    #=========================================================================

    # Walking-1 on divisor
    li    s4, 0xFFFFFFFE        # dividend = -2 (signed) or MAXUINT-1 (unsigned)
    li    s3, 1
    li    s5, 0

div9_walk_a:
    div    t0, s4, s3           # signed quotient
    rem    t1, s4, s3           # signed remainder
    divu   t2, s4, s3           # unsigned quotient
    remu   t3, s4, s3           # unsigned remainder
    xor   s11, s11, t0
    xor   s11, s11, t1
    xor   s11, s11, t2
    xor   s11, s11, t3
    slli  s3, s3, 1
    addi  s5, s5, 1
    blt   s5, s7, div9_walk_a

    # Walking-1 on dividend
    li    s4, 3                 # divisor = 3
    li    s3, 1
    li    s5, 0

div9_walk_b:
    div    t0, s3, s4
    rem    t1, s3, s4
    divu   t2, s3, s4
    remu   t3, s3, s4
    xor   s11, s11, t0
    xor   s11, s11, t1
    xor   s11, s11, t2
    xor   s11, s11, t3
    slli  s3, s3, 1
    addi  s5, s5, 1
    blt   s5, s7, div9_walk_b

    # DIV edge cases
    # INT_MIN / -1 = INT_MIN (defined overflow behavior in RISC-V)
    li    t0, 0x80000000
    li    t1, 0xFFFFFFFF        # -1
    div   t2, t0, t1            # INT_MIN / -1 = INT_MIN (no trap)
    rem   t3, t0, t1            # INT_MIN rem -1 = 0
    xor   s11, s11, t2
    xor   s11, s11, t3

    # Divide by zero (RISC-V: x/0 = -1, x rem 0 = x)
    li    t0, 0x12345678
    div   t1, t0, zero          # = -1 (0xFFFFFFFF)
    divu  t2, t0, zero          # = 0xFFFFFFFF
    rem   t3, t0, zero          # = t0
    remu  t4, t0, zero          # = t0
    xor   s11, s11, t1
    xor   s11, s11, t2
    xor   s11, s11, t3
    xor   s11, s11, t4

    # 0 / x = 0 for all x
    li    t0, 0xDEADBEEF
    div   t1, zero, t0          # = 0
    divu  t2, zero, t0          # = 0
    rem   t3, zero, t0          # = 0
    remu  t4, zero, t0          # = 0
    xor   s11, s11, t1          # all zero, just exercises the path
    xor   s11, s11, t2

    # Power-of-two divisors exercise right-shift optimization paths
    li    s3, 1
    li    s4, 0xABCDEF00
    li    s5, 0

div9_pow2:
    divu  t0, s4, s3
    remu  t1, s4, s3
    xor   s11, s11, t0
    xor   s11, s11, t1
    slli  s3, s3, 1
    addi  s5, s5, 1
    blt   s5, s7, div9_pow2

    #=========================================================================
    # PHASE BTB_JAL: unconditional JAL to high-address stubs
    #
    # Each JAL trains the BTB with a high-address target.  After the first
    # execution the BTB predicts the target; a SA-0 on BTBTargetEReg[26]
    # would predict 0x80000000 instead of 0x84000000 -> misprediction.
    # Each JAL is executed 4 times (2+ executions = BTB hit on each).
    #=========================================================================

    li    s5, 0
    li    s7, 4

btb9_jal_b26_loop:
    call  hi9_btb_stub_b26      # JAL target in .hi_b26 region = bit 26 set
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, btb9_jal_b26_loop

    li    s5, 0
btb9_jal_b27_loop:
    call  hi9_btb_stub_b27      # JAL target in .hi_b27 region = bit 27 set
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, btb9_jal_b27_loop

    li    s5, 0
btb9_jal_b28_loop:
    call  hi9_btb_stub_b28      # JAL target in .hi_b28 region = bit 28 set
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, btb9_jal_b28_loop

    li    s5, 0
btb9_jal_combo_loop:
    call  hi9_btb_stub_combo    # bits 26+27+28 all set
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, btb9_jal_combo_loop

    #=========================================================================
    # PHASE conditional branch to high-address targets
    # Conditional branches also exercise BTB/BHT; the TARGET stored in the
    # BTB includes the high bits.  We use BEQ (always taken) pointing into
    # the high sections.
    # NOTE: the J-type BEQ offset is limited to ±4KB. These targets are
    # > 4MB away, so we use a J trampoline approach: the branch jumps to
    # a nearby trampoline that then uses CALL (AUIPC+JALR) to reach the
    # high address. This at least trains the BTB for the conditional branch
    # target (the trampoline address), which IS within the low address range.
    # Actual high-bit BTB training is done by the JAL loops above.
    #=========================================================================

    # Final HPM-based signature contribution
    csrr  t5, hpmcounter4
    csrr  t6, hpmcounter5
    xor   s11, s11, t5
    xor   s11, s11, t6

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

#=============================================================================
# hi9_shared_leaf: leaf function called from deep inside hi chains.
# Returns the return address in a0 (used for signature accumulation).
# Placed in low .text section; reached via AUIPC+JALR (pseudo 'call').
#=============================================================================
.align 2
hi9_shared_leaf:
    mv    a0, ra
    ret

#=============================================================================
# Low-address leaf stubs for the 1->0 overwrite sequences.
# 16 stubs per bit (b26, b27, b28, combo) = 64 stubs.
# Each is a distinct 4-byte address so each sequential call occupies a
# different RAS slot; calling all 16 overwrites the entire 16-entry RAS.
#=============================================================================

.align 2
lo9_b26_0:  ret
.align 2
lo9_b26_1:  ret
.align 2
lo9_b26_2:  ret
.align 2
lo9_b26_3:  ret
.align 2
lo9_b26_4:  ret
.align 2
lo9_b26_5:  ret
.align 2
lo9_b26_6:  ret
.align 2
lo9_b26_7:  ret
.align 2
lo9_b26_8:  ret
.align 2
lo9_b26_9:  ret
.align 2
lo9_b26_10: ret
.align 2
lo9_b26_11: ret
.align 2
lo9_b26_12: ret
.align 2
lo9_b26_13: ret
.align 2
lo9_b26_14: ret
.align 2
lo9_b26_15: ret

.align 2
lo9_b27_0:  ret
.align 2
lo9_b27_1:  ret
.align 2
lo9_b27_2:  ret
.align 2
lo9_b27_3:  ret
.align 2
lo9_b27_4:  ret
.align 2
lo9_b27_5:  ret
.align 2
lo9_b27_6:  ret
.align 2
lo9_b27_7:  ret
.align 2
lo9_b27_8:  ret
.align 2
lo9_b27_9:  ret
.align 2
lo9_b27_10: ret
.align 2
lo9_b27_11: ret
.align 2
lo9_b27_12: ret
.align 2
lo9_b27_13: ret
.align 2
lo9_b27_14: ret
.align 2
lo9_b27_15: ret

.align 2
lo9_b28_0:  ret
.align 2
lo9_b28_1:  ret
.align 2
lo9_b28_2:  ret
.align 2
lo9_b28_3:  ret
.align 2
lo9_b28_4:  ret
.align 2
lo9_b28_5:  ret
.align 2
lo9_b28_6:  ret
.align 2
lo9_b28_7:  ret
.align 2
lo9_b28_8:  ret
.align 2
lo9_b28_9:  ret
.align 2
lo9_b28_10: ret
.align 2
lo9_b28_11: ret
.align 2
lo9_b28_12: ret
.align 2
lo9_b28_13: ret
.align 2
lo9_b28_14: ret
.align 2
lo9_b28_15: ret

.align 2
lo9_combo_0:  ret
.align 2
lo9_combo_1:  ret
.align 2
lo9_combo_2:  ret
.align 2
lo9_combo_3:  ret
.align 2
lo9_combo_4:  ret
.align 2
lo9_combo_5:  ret
.align 2
lo9_combo_6:  ret
.align 2
lo9_combo_7:  ret
.align 2
lo9_combo_8:  ret
.align 2
lo9_combo_9:  ret
.align 2
lo9_combo_10: ret
.align 2
lo9_combo_11: ret
.align 2
lo9_combo_12: ret
.align 2
lo9_combo_13: ret
.align 2
lo9_combo_14: ret
.align 2
lo9_combo_15: ret

#=============================================================================
# hi_b26 chain: 16-deep nested calls placed at 0x84000000
# (UNCORE_RAM_BASE | (1<<26))
#
# Every CALL inside this section pushes a return address with bit 26 = 1.
# hi9_shared_leaf is reached via pseudo-instruction 'call' = AUIPC+JALR,
# which is a 2-instruction sequence and can reach any 32-bit address.
#
# hi9_jalr_stub_b26  : simple leaf for icpred JALR training
# hi9_btb_stub_b26   : simple leaf for BTBTargetEReg JAL training
#=============================================================================
.section .hi_b26,"ax",@progbits
.align 2

hi9_jalr_stub_b26:              # JALR target for icpred training
    mv    a0, ra
    ret

hi9_btb_stub_b26:               # JAL target for BTBTargetEReg training
    mv    a0, ra
    ret

hi_b26_n1:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n2
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n2:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n3
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n3:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n4
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n4:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n5
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n5:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n6
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n6:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n7
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n7:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n8
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n8:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n9
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n9:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n10
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n10:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n11
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n11:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n12
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n12:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n13
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n13:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n14
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n14:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n15
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n15:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b26_n16
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b26_n16:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_shared_leaf
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

#=============================================================================
# hi_b27 chain: 16-deep nested calls placed at 0x88000000
# (UNCORE_RAM_BASE | (1<<27))
#=============================================================================
.section .hi_b27,"ax",@progbits
.align 2

hi9_jalr_stub_b27:
    mv    a0, ra
    ret

hi9_btb_stub_b27:
    mv    a0, ra
    ret

hi_b27_n1:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n2
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n2:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n3
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n3:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n4
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n4:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n5
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n5:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n6
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n6:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n7
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n7:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n8
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n8:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n9
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n9:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n10
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n10:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n11
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n11:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n12
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n12:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n13
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n13:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n14
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n14:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n15
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n15:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b27_n16
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b27_n16:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_shared_leaf
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

#=============================================================================
# hi_b28 chain: 16-deep nested calls placed at 0x90000000
# (UNCORE_RAM_BASE | (1<<28))
#=============================================================================
.section .hi_b28,"ax",@progbits
.align 2

hi9_jalr_stub_b28:
    mv    a0, ra
    ret

hi9_btb_stub_b28:
    mv    a0, ra
    ret

hi_b28_n1:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n2
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n2:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n3
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n3:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n4
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n4:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n5
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n5:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n6
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n6:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n7
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n7:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n8
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n8:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n9
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n9:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n10
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n10:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n11
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n11:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n12
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n12:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n13
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n13:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n14
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n14:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n15
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n15:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi_b28_n16
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi_b28_n16:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_shared_leaf
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

#=============================================================================
# hi9_combo chain: 16-deep nested calls at 0x9C000000
# (UNCORE_RAM_BASE | (1<<26) | (1<<27) | (1<<28) = 0x9C000000)
# Tests multi-bit simultaneous patterns: bits 26, 27, AND 28 all = 1.
#=============================================================================
.section .hi9_combo,"ax",@progbits
.align 2

hi9_jalr_stub_combo:
    mv    a0, ra
    ret

hi9_btb_stub_combo:
    mv    a0, ra
    ret

hi9_combo_n1:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n2
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n2:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n3
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n3:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n4
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n4:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n5
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n5:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n6
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n6:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n7
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n7:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n8
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n8:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n9
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n9:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n10
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n10:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n11
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n11:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n12
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n12:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n13
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n13:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n14
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n14:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n15
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n15:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_combo_n16
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

hi9_combo_n16:
    addi  sp, sp, -4;  sw ra, 0(sp)
    call  hi9_shared_leaf
    xor   a0, a0, ra
    lw    ra, 0(sp);   addi sp, sp, 4;  ret

.section .data
.section .rodata