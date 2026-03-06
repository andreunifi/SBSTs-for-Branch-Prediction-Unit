##############################################################################
# sbst678.S  --  Single merged SBST function: test678
#
# All code from sbst6/sbst7/sbst8 inlined into one function.
# No inter-function calls; internal calls to section-placed stubs are the
# actual test vectors (they must stay as CALL/RET to exercise the RAS/icpred).
#
# Layout
# ──────
#   .text   test678 (single function, full ABI prologue/epilogue)
#   .text   p2_push17_start  ─┐  helpers called from within test678;
#   .text   p4_nest16         │  kept in .text so their return addresses
#   .text   lo_leaf_bN_K …    │  carry low-address bit patterns
#   .text   hi_shared_leaf   ─┘
#
#   ── MEMORY SECTIONS (at end, placed by linker script) ──────────────
#   .sbst6_hi        high-address section: RAS deep-recursive fill +
#                    BHT misprediction loops + AUIPC
#   .p1a0/.p1b0 …   alternating-push stub pairs   (sbst7 phase 1)
#   .p2_1 … .p2_17  17-deep call chain             (sbst7 phase 2)
#   .data            jtable                         (sbst7 phase 3)
#   .jt0  … .jt15   JALR leaf targets              (sbst7 phase 3)
#   .p4_1 … .p4_16  16-deep nested call chain      (sbst7 phase 4)
#   .hi_b16…b25     per-bit 16-deep hi-addr chains (sbst8)
#   .hi_combo_lo/hi  combo hi-addr chains           (sbst8)
#
# Register map inside test678
# ───────────────────────────
#   s0   frame pointer (sp+112)
#   s1   hpmcounter4 snapshot  (sbst6 CSR section)
#   s2   hpmcounter5 snapshot  (sbst6 CSR section)
#   s3   walking-1 bit / CSR loop (sbst6 CSR section)
#   s5   loop index             (sbst6 CSR + sbst7 p3)
#   s7   loop limit             (sbst6 CSR + sbst7 p3)
#   s8   trampoline RA for hi-section jump (sbst6)
#   s9   saved/restored inside .sbst6_hi itself
#   s11  combined XOR signature accumulator (throughout)
##############################################################################

.section .text
.global test678
.type   test678, @function

test678:
    # ── ABI prologue ──────────────────────────────────────────────────────
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

    li    s11, 0xB5DE0000          # signature seed (sbst6 origin)

    #=========================================================================
    # ▌RAS PREDICTOR STIMULATION
    #=========================================================================

    # ── RAS/BHT 1: sbst6 high-address section ──────────────────────────────
    #    Phase 0 inside .sbst6_hi: 24-deep recursive fill with BASE_HI
    #    bits[31:17] set → SA-0 on those RAS bits becomes detectable (TDF-F).
    #    Phases 1-6: BNE/BEQ/BGE/BLT/BGEU/BLTU misprediction loops.
    #    Phase 7: AUIPC/LUI from high address (PC adder upper-bit coverage).
    #    Entry via J (not CALL) so the pushed RAS entry stays in .sbst6_hi.

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    la    s8, test678_after_hi     # trampoline return address
    j     sbst6_hi_start           # jump — does not push onto RAS
test678_after_hi:

    # ── RAS 2: sbst7 phase 1 — alternating push/pop (TDF-F / TDF-R) ────────
    #    For each of the 16 RAS slots: CALL A (bit N=1), ret, CALL B
    #    (bit N=0 same slot), ret → exercises 1→0 and 0→1 transitions.

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    call  p1_call_a0
p1_ret_a0:
    xor   s11, s11, ra
    call  p1_call_b0
p1_ret_b0:
    xor   s11, s11, ra

    call  p1_call_a1
p1_ret_a1:
    xor   s11, s11, ra
    call  p1_call_b1
p1_ret_b1:
    xor   s11, s11, ra

    call  p1_call_a2
p1_ret_a2:
    xor   s11, s11, ra
    call  p1_call_b2
p1_ret_b2:
    xor   s11, s11, ra

    call  p1_call_a3
p1_ret_a3:
    xor   s11, s11, ra
    call  p1_call_b3
p1_ret_b3:
    xor   s11, s11, ra

    call  p1_call_a4
p1_ret_a4:
    xor   s11, s11, ra
    call  p1_call_b4
p1_ret_b4:
    xor   s11, s11, ra

    call  p1_call_a5
p1_ret_a5:
    xor   s11, s11, ra
    call  p1_call_b5
p1_ret_b5:
    xor   s11, s11, ra

    call  p1_call_a6
p1_ret_a6:
    xor   s11, s11, ra
    call  p1_call_b6
p1_ret_b6:
    xor   s11, s11, ra

    call  p1_call_a7
p1_ret_a7:
    xor   s11, s11, ra
    call  p1_call_b7
p1_ret_b7:
    xor   s11, s11, ra

    call  p1_call_a8
p1_ret_a8:
    xor   s11, s11, ra
    call  p1_call_b8
p1_ret_b8:
    xor   s11, s11, ra

    call  p1_call_a9
p1_ret_a9:
    xor   s11, s11, ra
    call  p1_call_b9
p1_ret_b9:
    xor   s11, s11, ra

    call  p1_call_a10
p1_ret_a10:
    xor   s11, s11, ra
    call  p1_call_b10
p1_ret_b10:
    xor   s11, s11, ra

    call  p1_call_a11
p1_ret_a11:
    xor   s11, s11, ra
    call  p1_call_b11
p1_ret_b11:
    xor   s11, s11, ra

    call  p1_call_a12
p1_ret_a12:
    xor   s11, s11, ra
    call  p1_call_b12
p1_ret_b12:
    xor   s11, s11, ra

    call  p1_call_a13
p1_ret_a13:
    xor   s11, s11, ra
    call  p1_call_b13
p1_ret_b13:
    xor   s11, s11, ra

    call  p1_call_a14
p1_ret_a14:
    xor   s11, s11, ra
    call  p1_call_b14
p1_ret_b14:
    xor   s11, s11, ra

    call  p1_call_a15
p1_ret_a15:
    xor   s11, s11, ra
    call  p1_call_b15
p1_ret_b15:
    xor   s11, s11, ra

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # ── RAS 3: sbst7 phase 2 — PtrMux full wraparound ──────────────────────
    #    Push 17 entries into the 16-entry RAS → ptr 15→0 (overflow).
    #    Pop 17 times → ptr 0→15 (underflow).
    call  p2_push17_start
    xor   s11, s11, ra


    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # ── RAS 4: sbst7 phase 4 — 16-deep interleaved write ───────────────────
    #    Each level in its own section so bits 4-15 of RA vary; leaf
    #    accumulates return addresses into a0 as the chain unwinds.
    call  p4_nest16
    xor   s11, s11, a0


    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # ── RAS 5: sbst8 — per-bit high-address TDF-F + SA-0 (bits 16-25) ──────
    #    For each bit N: fill all 16 RAS entries with that bit=1 (hi chain),
    #    overwrite with bit=0 (lo stubs → TDF-F), fill again with 1 (SA-0).

    # bit 16 (0x80010000)
    call  hi_b16_n1             # step 1: fill RAS with bit 16=1
    xor   s11, s11, a0
    call  lo_leaf_b16_0
    call  lo_leaf_b16_1
    call  lo_leaf_b16_2
    call  lo_leaf_b16_3
    call  lo_leaf_b16_4
    call  lo_leaf_b16_5
    call  lo_leaf_b16_6
    call  lo_leaf_b16_7
    call  lo_leaf_b16_8
    call  lo_leaf_b16_9
    call  lo_leaf_b16_10
    call  lo_leaf_b16_11
    call  lo_leaf_b16_12
    call  lo_leaf_b16_13
    call  lo_leaf_b16_14
    call  lo_leaf_b16_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b16_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # bit 17 (0x80020000)
    call  hi_b17_n1             # step 1: fill RAS with bit 17=1
    xor   s11, s11, a0
    call  lo_leaf_b17_0
    call  lo_leaf_b17_1
    call  lo_leaf_b17_2
    call  lo_leaf_b17_3
    call  lo_leaf_b17_4
    call  lo_leaf_b17_5
    call  lo_leaf_b17_6
    call  lo_leaf_b17_7
    call  lo_leaf_b17_8
    call  lo_leaf_b17_9
    call  lo_leaf_b17_10
    call  lo_leaf_b17_11
    call  lo_leaf_b17_12
    call  lo_leaf_b17_13
    call  lo_leaf_b17_14
    call  lo_leaf_b17_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b17_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # bit 18 (0x80040000)
    call  hi_b18_n1             # step 1: fill RAS with bit 18=1
    xor   s11, s11, a0
    call  lo_leaf_b18_0
    call  lo_leaf_b18_1
    call  lo_leaf_b18_2
    call  lo_leaf_b18_3
    call  lo_leaf_b18_4
    call  lo_leaf_b18_5
    call  lo_leaf_b18_6
    call  lo_leaf_b18_7
    call  lo_leaf_b18_8
    call  lo_leaf_b18_9
    call  lo_leaf_b18_10
    call  lo_leaf_b18_11
    call  lo_leaf_b18_12
    call  lo_leaf_b18_13
    call  lo_leaf_b18_14
    call  lo_leaf_b18_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b18_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # bit 19 (0x80080000)
    call  hi_b19_n1             # step 1: fill RAS with bit 19=1
    xor   s11, s11, a0
    call  lo_leaf_b19_0
    call  lo_leaf_b19_1
    call  lo_leaf_b19_2
    call  lo_leaf_b19_3
    call  lo_leaf_b19_4
    call  lo_leaf_b19_5
    call  lo_leaf_b19_6
    call  lo_leaf_b19_7
    call  lo_leaf_b19_8
    call  lo_leaf_b19_9
    call  lo_leaf_b19_10
    call  lo_leaf_b19_11
    call  lo_leaf_b19_12
    call  lo_leaf_b19_13
    call  lo_leaf_b19_14
    call  lo_leaf_b19_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b19_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # bit 20 (0x80100000)
    call  hi_b20_n1             # step 1: fill RAS with bit 20=1
    xor   s11, s11, a0
    call  lo_leaf_b20_0
    call  lo_leaf_b20_1
    call  lo_leaf_b20_2
    call  lo_leaf_b20_3
    call  lo_leaf_b20_4
    call  lo_leaf_b20_5
    call  lo_leaf_b20_6
    call  lo_leaf_b20_7
    call  lo_leaf_b20_8
    call  lo_leaf_b20_9
    call  lo_leaf_b20_10
    call  lo_leaf_b20_11
    call  lo_leaf_b20_12
    call  lo_leaf_b20_13
    call  lo_leaf_b20_14
    call  lo_leaf_b20_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b20_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # bit 21 (0x80200000)
    call  hi_b21_n1             # step 1: fill RAS with bit 21=1
    xor   s11, s11, a0
    call  lo_leaf_b21_0
    call  lo_leaf_b21_1
    call  lo_leaf_b21_2
    call  lo_leaf_b21_3
    call  lo_leaf_b21_4
    call  lo_leaf_b21_5
    call  lo_leaf_b21_6
    call  lo_leaf_b21_7
    call  lo_leaf_b21_8
    call  lo_leaf_b21_9
    call  lo_leaf_b21_10
    call  lo_leaf_b21_11
    call  lo_leaf_b21_12
    call  lo_leaf_b21_13
    call  lo_leaf_b21_14
    call  lo_leaf_b21_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b21_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0


    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # bit 22 (0x80400000)
    call  hi_b22_n1             # step 1: fill RAS with bit 22=1
    xor   s11, s11, a0
    call  lo_leaf_b22_0
    call  lo_leaf_b22_1
    call  lo_leaf_b22_2
    call  lo_leaf_b22_3
    call  lo_leaf_b22_4
    call  lo_leaf_b22_5
    call  lo_leaf_b22_6
    call  lo_leaf_b22_7
    call  lo_leaf_b22_8
    call  lo_leaf_b22_9
    call  lo_leaf_b22_10
    call  lo_leaf_b22_11
    call  lo_leaf_b22_12
    call  lo_leaf_b22_13
    call  lo_leaf_b22_14
    call  lo_leaf_b22_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b22_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    # bit 23 (0x80800000)
    call  hi_b23_n1             # step 1: fill RAS with bit 23=1
    xor   s11, s11, a0
    call  lo_leaf_b23_0
    call  lo_leaf_b23_1
    call  lo_leaf_b23_2
    call  lo_leaf_b23_3
    call  lo_leaf_b23_4
    call  lo_leaf_b23_5
    call  lo_leaf_b23_6
    call  lo_leaf_b23_7
    call  lo_leaf_b23_8
    call  lo_leaf_b23_9
    call  lo_leaf_b23_10
    call  lo_leaf_b23_11
    call  lo_leaf_b23_12
    call  lo_leaf_b23_13
    call  lo_leaf_b23_14
    call  lo_leaf_b23_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b23_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    # bit 24 (0x81000000)
    call  hi_b24_n1             # step 1: fill RAS with bit 24=1
    xor   s11, s11, a0
    call  lo_leaf_b24_0
    call  lo_leaf_b24_1
    call  lo_leaf_b24_2
    call  lo_leaf_b24_3
    call  lo_leaf_b24_4
    call  lo_leaf_b24_5
    call  lo_leaf_b24_6
    call  lo_leaf_b24_7
    call  lo_leaf_b24_8
    call  lo_leaf_b24_9
    call  lo_leaf_b24_10
    call  lo_leaf_b24_11
    call  lo_leaf_b24_12
    call  lo_leaf_b24_13
    call  lo_leaf_b24_14
    call  lo_leaf_b24_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b24_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    # bit 25 (0x82000000)
    call  hi_b25_n1             # step 1: fill RAS with bit 25=1
    xor   s11, s11, a0
    call  lo_leaf_b25_0
    call  lo_leaf_b25_1
    call  lo_leaf_b25_2
    call  lo_leaf_b25_3
    call  lo_leaf_b25_4
    call  lo_leaf_b25_5
    call  lo_leaf_b25_6
    call  lo_leaf_b25_7
    call  lo_leaf_b25_8
    call  lo_leaf_b25_9
    call  lo_leaf_b25_10
    call  lo_leaf_b25_11
    call  lo_leaf_b25_12
    call  lo_leaf_b25_13
    call  lo_leaf_b25_14
    call  lo_leaf_b25_15
    xor   s11, s11, ra          # step 2: 1→0 transition detected
    call  hi_b25_n1             # step 3: re-verify SA-0
    xor   s11, s11, a0

    # combo-lo: bits 16+17+18+19 (0x800F0000)
    call  hi_combo_lo_n1
    xor   s11, s11, a0

    # combo-hi: bits 20+21+22+23 (0x80F00000)
    call  hi_combo_hi_n1
    xor   s11, s11, a0

    #=========================================================================
    # ▌CSR / HPM STIMULATION  (sbst6)
    #=========================================================================

    # ── Walking-1 on mscratch (32 iterations, covers CSR decoder bits) ──────
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

    # ── mhpmevent16..31 walking-1 (CSR address bits [4:0]) ──────────────────
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
    # clear all
    csrw 0x330, zero
    csrw 0x331, zero
    csrw 0x332, zero
    csrw 0x333, zero
    csrw 0x334, zero
    csrw 0x335, zero
    csrw 0x336, zero
    csrw 0x337, zero
    csrw 0x338, zero
    csrw 0x339, zero
    csrw 0x33A, zero
    csrw 0x33B, zero
    csrw 0x33C, zero
    csrw 0x33D, zero
    csrw 0x33E, zero
    csrw 0x33F, zero

    # ── HPM delta (branch mispredictions counted across hi-section) ─────────
    csrr  t5, hpmcounter4
    csrr  t6, hpmcounter5
    sub   t5, t5, s1
    sub   t6, t6, s2
    add   s11, s11, t5
    add   s11, s11, t6

    #=========================================================================
    # ▌INDIRECT CALL PREDICTOR (icpred)  —  sbst7 phase 3
    #=========================================================================

    # ── JALR with 16 distinct computed targets (jump table) ─────────────────
    #    Each JALR uses a different base register value, exercising different
    #    cells of the indirect call predictor BTB-like structure.
    la    t0, jtable
    li    s5, 0
    li    s7, 16
p3_loop:
    slli  t1, s5, 2
    add   t2, t0, t1
    lw    t3, 0(t2)
    jalr  ra, t3, 0
    xor   s11, s11, a0
    addi  s5, s5, 1
    blt   s5, s7, p3_loop

    mv    a0, s11

    # ── ABI epilogue ──────────────────────────────────────────────────────
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
    ret


#=============================================================================
# TEXT-SECTION HELPERS
# Kept in .text so their return addresses carry normal (low) bit patterns.
#=============================================================================

p2_push17_start:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p2_d1
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

p4_nest16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n1
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

# ── sbst8 low-address leaf stubs (bit=0 overwrite phase) ────────────────────
.align 2
lo_leaf_b16_0: ret
.align 2
lo_leaf_b16_1: ret
.align 2
lo_leaf_b16_2: ret
.align 2
lo_leaf_b16_3: ret
.align 2
lo_leaf_b16_4: ret
.align 2
lo_leaf_b16_5: ret
.align 2
lo_leaf_b16_6: ret
.align 2
lo_leaf_b16_7: ret
.align 2
lo_leaf_b16_8: ret
.align 2
lo_leaf_b16_9: ret
.align 2
lo_leaf_b16_10: ret
.align 2
lo_leaf_b16_11: ret
.align 2
lo_leaf_b16_12: ret
.align 2
lo_leaf_b16_13: ret
.align 2
lo_leaf_b16_14: ret
.align 2
lo_leaf_b16_15: ret
.align 2
lo_leaf_b17_0: ret
.align 2
lo_leaf_b17_1: ret
.align 2
lo_leaf_b17_2: ret
.align 2
lo_leaf_b17_3: ret
.align 2
lo_leaf_b17_4: ret
.align 2
lo_leaf_b17_5: ret
.align 2
lo_leaf_b17_6: ret
.align 2
lo_leaf_b17_7: ret
.align 2
lo_leaf_b17_8: ret
.align 2
lo_leaf_b17_9: ret
.align 2
lo_leaf_b17_10: ret
.align 2
lo_leaf_b17_11: ret
.align 2
lo_leaf_b17_12: ret
.align 2
lo_leaf_b17_13: ret
.align 2
lo_leaf_b17_14: ret
.align 2
lo_leaf_b17_15: ret
.align 2
lo_leaf_b18_0: ret
.align 2
lo_leaf_b18_1: ret
.align 2
lo_leaf_b18_2: ret
.align 2
lo_leaf_b18_3: ret
.align 2
lo_leaf_b18_4: ret
.align 2
lo_leaf_b18_5: ret
.align 2
lo_leaf_b18_6: ret
.align 2
lo_leaf_b18_7: ret
.align 2
lo_leaf_b18_8: ret
.align 2
lo_leaf_b18_9: ret
.align 2
lo_leaf_b18_10: ret
.align 2
lo_leaf_b18_11: ret
.align 2
lo_leaf_b18_12: ret
.align 2
lo_leaf_b18_13: ret
.align 2
lo_leaf_b18_14: ret
.align 2
lo_leaf_b18_15: ret
.align 2
lo_leaf_b19_0: ret
.align 2
lo_leaf_b19_1: ret
.align 2
lo_leaf_b19_2: ret
.align 2
lo_leaf_b19_3: ret
.align 2
lo_leaf_b19_4: ret
.align 2
lo_leaf_b19_5: ret
.align 2
lo_leaf_b19_6: ret
.align 2
lo_leaf_b19_7: ret
.align 2
lo_leaf_b19_8: ret
.align 2
lo_leaf_b19_9: ret
.align 2
lo_leaf_b19_10: ret
.align 2
lo_leaf_b19_11: ret
.align 2
lo_leaf_b19_12: ret
.align 2
lo_leaf_b19_13: ret
.align 2
lo_leaf_b19_14: ret
.align 2
lo_leaf_b19_15: ret
.align 2
lo_leaf_b20_0: ret
.align 2
lo_leaf_b20_1: ret
.align 2
lo_leaf_b20_2: ret
.align 2
lo_leaf_b20_3: ret
.align 2
lo_leaf_b20_4: ret
.align 2
lo_leaf_b20_5: ret
.align 2
lo_leaf_b20_6: ret
.align 2
lo_leaf_b20_7: ret
.align 2
lo_leaf_b20_8: ret
.align 2
lo_leaf_b20_9: ret
.align 2
lo_leaf_b20_10: ret
.align 2
lo_leaf_b20_11: ret
.align 2
lo_leaf_b20_12: ret
.align 2
lo_leaf_b20_13: ret
.align 2
lo_leaf_b20_14: ret
.align 2
lo_leaf_b20_15: ret
.align 2
lo_leaf_b21_0: ret
.align 2
lo_leaf_b21_1: ret
.align 2
lo_leaf_b21_2: ret
.align 2
lo_leaf_b21_3: ret
.align 2
lo_leaf_b21_4: ret
.align 2
lo_leaf_b21_5: ret
.align 2
lo_leaf_b21_6: ret
.align 2
lo_leaf_b21_7: ret
.align 2
lo_leaf_b21_8: ret
.align 2
lo_leaf_b21_9: ret
.align 2
lo_leaf_b21_10: ret
.align 2
lo_leaf_b21_11: ret
.align 2
lo_leaf_b21_12: ret
.align 2
lo_leaf_b21_13: ret
.align 2
lo_leaf_b21_14: ret
.align 2
lo_leaf_b21_15: ret
.align 2
lo_leaf_b22_0: ret
.align 2
lo_leaf_b22_1: ret
.align 2
lo_leaf_b22_2: ret
.align 2
lo_leaf_b22_3: ret
.align 2
lo_leaf_b22_4: ret
.align 2
lo_leaf_b22_5: ret
.align 2
lo_leaf_b22_6: ret
.align 2
lo_leaf_b22_7: ret
.align 2
lo_leaf_b22_8: ret
.align 2
lo_leaf_b22_9: ret
.align 2
lo_leaf_b22_10: ret
.align 2
lo_leaf_b22_11: ret
.align 2
lo_leaf_b22_12: ret
.align 2
lo_leaf_b22_13: ret
.align 2
lo_leaf_b22_14: ret
.align 2
lo_leaf_b22_15: ret
.align 2
lo_leaf_b23_0: ret
.align 2
lo_leaf_b23_1: ret
.align 2
lo_leaf_b23_2: ret
.align 2
lo_leaf_b23_3: ret
.align 2
lo_leaf_b23_4: ret
.align 2
lo_leaf_b23_5: ret
.align 2
lo_leaf_b23_6: ret
.align 2
lo_leaf_b23_7: ret
.align 2
lo_leaf_b23_8: ret
.align 2
lo_leaf_b23_9: ret
.align 2
lo_leaf_b23_10: ret
.align 2
lo_leaf_b23_11: ret
.align 2
lo_leaf_b23_12: ret
.align 2
lo_leaf_b23_13: ret
.align 2
lo_leaf_b23_14: ret
.align 2
lo_leaf_b23_15: ret
.align 2
lo_leaf_b24_0: ret
.align 2
lo_leaf_b24_1: ret
.align 2
lo_leaf_b24_2: ret
.align 2
lo_leaf_b24_3: ret
.align 2
lo_leaf_b24_4: ret
.align 2
lo_leaf_b24_5: ret
.align 2
lo_leaf_b24_6: ret
.align 2
lo_leaf_b24_7: ret
.align 2
lo_leaf_b24_8: ret
.align 2
lo_leaf_b24_9: ret
.align 2
lo_leaf_b24_10: ret
.align 2
lo_leaf_b24_11: ret
.align 2
lo_leaf_b24_12: ret
.align 2
lo_leaf_b24_13: ret
.align 2
lo_leaf_b24_14: ret
.align 2
lo_leaf_b24_15: ret
.align 2
lo_leaf_b25_0: ret
.align 2
lo_leaf_b25_1: ret
.align 2
lo_leaf_b25_2: ret
.align 2
lo_leaf_b25_3: ret
.align 2
lo_leaf_b25_4: ret
.align 2
lo_leaf_b25_5: ret
.align 2
lo_leaf_b25_6: ret
.align 2
lo_leaf_b25_7: ret
.align 2
lo_leaf_b25_8: ret
.align 2
lo_leaf_b25_9: ret
.align 2
lo_leaf_b25_10: ret
.align 2
lo_leaf_b25_11: ret
.align 2
lo_leaf_b25_12: ret
.align 2
lo_leaf_b25_13: ret
.align 2
lo_leaf_b25_14: ret
.align 2
lo_leaf_b25_15: ret

.align 2
lo_leaf_combo_lo_0: ret
.align 2
lo_leaf_combo_lo_1: ret
.align 2
lo_leaf_combo_lo_2: ret
.align 2
lo_leaf_combo_lo_3: ret
.align 2
lo_leaf_combo_lo_4: ret
.align 2
lo_leaf_combo_lo_5: ret
.align 2
lo_leaf_combo_lo_6: ret
.align 2
lo_leaf_combo_lo_7: ret
.align 2
lo_leaf_combo_lo_8: ret
.align 2
lo_leaf_combo_lo_9: ret
.align 2
lo_leaf_combo_lo_10: ret
.align 2
lo_leaf_combo_lo_11: ret
.align 2
lo_leaf_combo_lo_12: ret
.align 2
lo_leaf_combo_lo_13: ret
.align 2
lo_leaf_combo_lo_14: ret
.align 2
lo_leaf_combo_lo_15: ret
.align 2
lo_leaf_combo_hi_0: ret
.align 2
lo_leaf_combo_hi_1: ret
.align 2
lo_leaf_combo_hi_2: ret
.align 2
lo_leaf_combo_hi_3: ret
.align 2
lo_leaf_combo_hi_4: ret
.align 2
lo_leaf_combo_hi_5: ret
.align 2
lo_leaf_combo_hi_6: ret
.align 2
lo_leaf_combo_hi_7: ret
.align 2
lo_leaf_combo_hi_8: ret
.align 2
lo_leaf_combo_hi_9: ret
.align 2
lo_leaf_combo_hi_10: ret
.align 2
lo_leaf_combo_hi_11: ret
.align 2
lo_leaf_combo_hi_12: ret
.align 2
lo_leaf_combo_hi_13: ret
.align 2
lo_leaf_combo_hi_14: ret
.align 2
lo_leaf_combo_hi_15: ret

# ── hi_shared_leaf: innermost target of all sbst8 hi chains ────────────────
# Placed in .text (low address); the CALLER's return address (in .hi_bN)
# is what carries the high-address bit pattern onto the RAS.
.align 2
hi_shared_leaf:
    mv    a0, ra
    ret


##############################################################################
# ══ MEMORY SECTIONS ══════════════════════════════════════════════════════════
# Placed by the linker script at specific addresses.
# Each section must satisfy its own ALIGN / base-address constraint.
##############################################################################

# ── .sbst6_hi : ALIGN(131072), BASE_HI[31:17] != 0 ─────────────────────────
.section .sbst6_hi, "ax", @progbits
.balign 131072

sbst6_hi_start:

    # Phase 0: deep recursive RAS fill from high address
    # Pushes return addresses with BASE_HI[31:17] set → SA-0 detectable.
    addi  sp, sp, -8
    sw    s8, 4(sp)            # preserve trampoline RA
    sw    s9, 0(sp)
    li    a0, 0
    li    a1, 24               # depth > RAS size (exercises overflow too)
    call  ras_hi_deep          # return address is inside .sbst6_hi
    lw    s9, 0(sp)
    lw    s8, 4(sp)
    addi  sp, sp, 8

    # Phase 1: BNE misprediction (TAKEN 5x then NOT-TAKEN)
    li    t3, 6
sbst6_bne_loop:
    addi  t3, t3, -1
    bne   t3, x0, sbst6_bne_loop

    # Phase 2: BEQ misprediction (NOT-TAKEN 5x then TAKEN)
    li    t3, 6
sbst6_beq_loop:
    addi  t3, t3, -1
    beq   t3, x0, sbst6_beq_taken
    j     sbst6_beq_loop
sbst6_beq_taken:

    # Phase 3: BGE misprediction
    li    t3, 7
sbst6_bge_loop:
    addi  t3, t3, -1
    bge   t3, x0, sbst6_bge_loop

    # Phase 4: BLT misprediction
    li    t3, 6;  li t4, 1
sbst6_blt_loop:
    addi  t3, t3, -1
    blt   t3, t4, sbst6_blt_taken
    j     sbst6_blt_loop
sbst6_blt_taken:

    # Phase 5: BGEU misprediction
    li    t3, 6
sbst6_bgeu_loop:
    addi  t3, t3, -1
    bgeu  x0, t3, sbst6_bgeu_taken
    j     sbst6_bgeu_loop
sbst6_bgeu_taken:

    # Phase 6: BLTU misprediction
    li    t3, 6;  li t4, 1
sbst6_bltu_loop:
    addi  t3, t3, -1
    bltu  t3, t4, sbst6_bltu_taken
    j     sbst6_bltu_loop
sbst6_bltu_taken:

    # Phase 7: AUIPC/LUI from high address (PC adder upper-bit coverage)
    auipc t0, 0x00001;  xor s11, s11, t0
    auipc t0, 0x00010;  xor s11, s11, t0
    auipc t0, 0x00100;  xor s11, s11, t0
    lui   t0, 0xFFFFF;  xor s11, s11, t0

    jr    s8                   # return to test678_after_hi

ras_hi_deep:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    addi  a0, a0, 1
    bge   a0, a1, ras_hi_base
    call  ras_hi_deep
ras_hi_base:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

# ── sbst7 phase 1 stubs: 16 pairs in distinct sections ──────────────────────
# .align 4 on b-stubs shifts their address vs a-stubs so bit 2 differs,
# creating the 0/1 contrast that exercises TDF-F on each RAS cell.
.section .p1a0,"ax",@progbits
.align 2
p1_call_a0: ret

.section .p1b0,"ax",@progbits
.align 4
p1_call_b0: ret

.section .p1a1,"ax",@progbits
.align 2
p1_call_a1: ret

.section .p1b1,"ax",@progbits
.align 4
p1_call_b1: ret

.section .p1a2,"ax",@progbits
.align 2
p1_call_a2: ret

.section .p1b2,"ax",@progbits
.align 4
p1_call_b2: ret

.section .p1a3,"ax",@progbits
.align 2
p1_call_a3: ret

.section .p1b3,"ax",@progbits
.align 4
p1_call_b3: ret

.section .p1a4,"ax",@progbits
.align 2
p1_call_a4: ret

.section .p1b4,"ax",@progbits
.align 4
p1_call_b4: ret

.section .p1a5,"ax",@progbits
.align 2
p1_call_a5: ret

.section .p1b5,"ax",@progbits
.align 4
p1_call_b5: ret

.section .p1a6,"ax",@progbits
.align 2
p1_call_a6: ret

.section .p1b6,"ax",@progbits
.align 4
p1_call_b6: ret

.section .p1a7,"ax",@progbits
.align 2
p1_call_a7: ret

.section .p1b7,"ax",@progbits
.align 4
p1_call_b7: ret

.section .p1a8,"ax",@progbits
.align 2
p1_call_a8: ret

.section .p1b8,"ax",@progbits
.align 4
p1_call_b8: ret

.section .p1a9,"ax",@progbits
.align 2
p1_call_a9: ret

.section .p1b9,"ax",@progbits
.align 4
p1_call_b9: ret

.section .p1a10,"ax",@progbits
.align 2
p1_call_a10: ret

.section .p1b10,"ax",@progbits
.align 4
p1_call_b10: ret

.section .p1a11,"ax",@progbits
.align 2
p1_call_a11: ret

.section .p1b11,"ax",@progbits
.align 4
p1_call_b11: ret

.section .p1a12,"ax",@progbits
.align 2
p1_call_a12: ret

.section .p1b12,"ax",@progbits
.align 4
p1_call_b12: ret

.section .p1a13,"ax",@progbits
.align 2
p1_call_a13: ret

.section .p1b13,"ax",@progbits
.align 4
p1_call_b13: ret

.section .p1a14,"ax",@progbits
.align 2
p1_call_a14: ret

.section .p1b14,"ax",@progbits
.align 4
p1_call_b14: ret

.section .p1a15,"ax",@progbits
.align 2
p1_call_a15: ret

.section .p1b15,"ax",@progbits
.align 4
p1_call_b15: ret

# ── sbst7 phase 2: 17-deep call chain (overflow 16-entry RAS) ───────────────
.section .text
# (p2_push17_start already in .text above)
.section .p2_1,"ax",@progbits
.align 2
p2_d1:  addi sp,sp,-4; sw ra,0(sp); call p2_d2; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_2,"ax",@progbits
.align 2
p2_d2:  addi sp,sp,-4; sw ra,0(sp); call p2_d3; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_3,"ax",@progbits
.align 2
p2_d3:  addi sp,sp,-4; sw ra,0(sp); call p2_d4; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_4,"ax",@progbits
.align 2
p2_d4:  addi sp,sp,-4; sw ra,0(sp); call p2_d5; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_5,"ax",@progbits
.align 2
p2_d5:  addi sp,sp,-4; sw ra,0(sp); call p2_d6; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_6,"ax",@progbits
.align 2
p2_d6:  addi sp,sp,-4; sw ra,0(sp); call p2_d7; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_7,"ax",@progbits
.align 2
p2_d7:  addi sp,sp,-4; sw ra,0(sp); call p2_d8; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_8,"ax",@progbits
.align 2
p2_d8:  addi sp,sp,-4; sw ra,0(sp); call p2_d9; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_9,"ax",@progbits
.align 2
p2_d9:  addi sp,sp,-4; sw ra,0(sp); call p2_d10; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_10,"ax",@progbits
.align 2
p2_d10:  addi sp,sp,-4; sw ra,0(sp); call p2_d11; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_11,"ax",@progbits
.align 2
p2_d11:  addi sp,sp,-4; sw ra,0(sp); call p2_d12; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_12,"ax",@progbits
.align 2
p2_d12:  addi sp,sp,-4; sw ra,0(sp); call p2_d13; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_13,"ax",@progbits
.align 2
p2_d13:  addi sp,sp,-4; sw ra,0(sp); call p2_d14; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_14,"ax",@progbits
.align 2
p2_d14:  addi sp,sp,-4; sw ra,0(sp); call p2_d15; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_15,"ax",@progbits
.align 2
p2_d15:  addi sp,sp,-4; sw ra,0(sp); call p2_d16; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_16,"ax",@progbits
.align 2
p2_d16:  addi sp,sp,-4; sw ra,0(sp); call p2_d17; lw ra,0(sp); addi sp,sp,4; ret

.section .p2_17,"ax",@progbits
.align 2
p2_d17:  ret   # leaf: unwind begins here (ptr 0→-1 wraps to 15)

# ── sbst7 phase 3: jump table ───────────────────────────────────────────────
.section .data
.align 2
jtable:
    .word jt_leaf0
    .word jt_leaf1
    .word jt_leaf2
    .word jt_leaf3
    .word jt_leaf4
    .word jt_leaf5
    .word jt_leaf6
    .word jt_leaf7
    .word jt_leaf8
    .word jt_leaf9
    .word jt_leaf10
    .word jt_leaf11
    .word jt_leaf12
    .word jt_leaf13
    .word jt_leaf14
    .word jt_leaf15

.section .jt0,"ax",@progbits
.align 2
jt_leaf0: li a0, 0x13579BDF; ret

.section .jt1,"ax",@progbits
.align 2
jt_leaf1: li a0, 0x2468ACE0; ret

.section .jt2,"ax",@progbits
.align 2
jt_leaf2: li a0, 0xFDB97531; ret

.section .jt3,"ax",@progbits
.align 2
jt_leaf3: li a0, 0xECA86420; ret

.section .jt4,"ax",@progbits
.align 2
jt_leaf4: li a0, 0x0F0F0F0F; ret

.section .jt5,"ax",@progbits
.align 2
jt_leaf5: li a0, 0xF0F0F0F0; ret

.section .jt6,"ax",@progbits
.align 2
jt_leaf6: li a0, 0x00FF00FF; ret

.section .jt7,"ax",@progbits
.align 2
jt_leaf7: li a0, 0xFF00FF00; ret

.section .jt8,"ax",@progbits
.align 2
jt_leaf8: li a0, 0x0000FFFF; ret

.section .jt9,"ax",@progbits
.align 2
jt_leaf9: li a0, 0xFFFF0000; ret

.section .jt10,"ax",@progbits
.align 2
jt_leaf10: li a0, 0x12345678; ret

.section .jt11,"ax",@progbits
.align 2
jt_leaf11: li a0, 0x87654321; ret

.section .jt12,"ax",@progbits
.align 2
jt_leaf12: li a0, 0xDEADBEEF; ret

.section .jt13,"ax",@progbits
.align 2
jt_leaf13: li a0, 0xCAFEBABE; ret

.section .jt14,"ax",@progbits
.align 2
jt_leaf14: li a0, 0xA5A5A5A5; ret

.section .jt15,"ax",@progbits
.align 2
jt_leaf15: li a0, 0x5A5A5A5A; ret

# ── sbst7 phase 4: 16-deep nested call, each level in own section ───────────
# (p4_nest16 entry point already in .text above)
.section .p4_1,"ax",@progbits
.align 2
p4_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n2
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_2,"ax",@progbits
.align 2
p4_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n3
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_3,"ax",@progbits
.align 2
p4_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n4
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_4,"ax",@progbits
.align 2
p4_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n5
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_5,"ax",@progbits
.align 2
p4_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n6
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_6,"ax",@progbits
.align 2
p4_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n7
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_7,"ax",@progbits
.align 2
p4_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n8
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_8,"ax",@progbits
.align 2
p4_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n9
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_9,"ax",@progbits
.align 2
p4_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n10
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_10,"ax",@progbits
.align 2
p4_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n11
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_11,"ax",@progbits
.align 2
p4_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n12
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_12,"ax",@progbits
.align 2
p4_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n13
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_13,"ax",@progbits
.align 2
p4_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n14
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_14,"ax",@progbits
.align 2
p4_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n15
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_15,"ax",@progbits
.align 2
p4_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n16
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p4_16,"ax",@progbits
.align 2
p4_n16:
    mv    a0, ra   # leaf: start XOR chain
    ret

# ── sbst8 high-address chains ────────────────────────────────────────────────
# Each chain is in its own section placed by the linker at 0x80000000|2^N.
# Every CALL inside pushes a return address with bit N=1 onto the RAS.

.section .hi_b16,"ax",@progbits
.align 2

hi_b16_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b16_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b17,"ax",@progbits
.align 2

hi_b17_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b17_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b18,"ax",@progbits
.align 2

hi_b18_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b18_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b19,"ax",@progbits
.align 2

hi_b19_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b19_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b20,"ax",@progbits
.align 2

hi_b20_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b20_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b21,"ax",@progbits
.align 2

hi_b21_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b21_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b22,"ax",@progbits
.align 2

hi_b22_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b22_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b23,"ax",@progbits
.align 2

hi_b23_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b23_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b24,"ax",@progbits
.align 2

hi_b24_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b24_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_b25,"ax",@progbits
.align 2

hi_b25_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_b25_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_combo_lo,"ax",@progbits
.align 2

hi_combo_lo_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_lo_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_lo_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret

.section .hi_combo_hi,"ax",@progbits
.align 2

hi_combo_hi_n1:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n2; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n2:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n3; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n3:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n4; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n4:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n5; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n5:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n6; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n6:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n7; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n7:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n8; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n8:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n9; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n9:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n10:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n11; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n11:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n12; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n12:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n13; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n13:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n14; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n14:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n15; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n15:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_combo_hi_n16; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_combo_hi_n16:
    addi  sp, sp, -4; sw ra, 0(sp); call hi_shared_leaf; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret