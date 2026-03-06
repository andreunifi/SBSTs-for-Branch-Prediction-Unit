# =============================================================================
# sbst3_RAS_enhanced.S  —  RAS (Return Address Stack) Predictor SBST
#                          10-entry RAS variant
# =============================================================================
#
# TARGET FAULTS (original):
#   RASStack[i][31:0]  — 10 entries * 32 data bits = 320 FFs
#   RASPtr[3:0]        — pointer increment/wrap logic
#   RASPush/RASPop     — control signal correctness
#   Mismatch detection — pipeline flush on wrong prediction
#
# NEW FAULT TARGETS (merged from sbst6/7/8):
#   [from sbst7 Phase 1] TDF-F / TDF-R on RAS data bits:
#     Alternating push/pop pairs write 1->0 to the same RAS slot,
#     exercising falling-edge transition faults on every data bit.
#   [from sbst7 Phase 2] PtrMux full wraparound:
#     Push 11 (= depth+1) entries into a 10-entry RAS, forcing ptr 9->0
#     overflow wrap; then unwind 11 times, forcing ptr 0->9 underflow wrap.
#   [from sbst8 / sbst6] RAS upper-bit SA-0 + TDF-F on bits 16..25:
#     For each bit N in {16..25}: fill all 10 RAS slots with return
#     addresses having bit N=1 (deep chain placed at 0x80000000|2^N),
#     then overwrite with 10 low-addr calls (bit N=0, TDF-F detected),
#     then fill with 1 again (SA-0 re-verified).  Bits 14/17 are already
#     covered by the original phase 1/2 chain sections.
#
# =============================================================================
# STRUCTURE OVERVIEW
# =============================================================================
#
# PHASE 1 — 10-deep chain in .ras_walk_t3 (addresses ~0x80008xxx)
# PHASE 2 — 10-deep chain in .ras_fill_t3 (addresses ~0x80040xxx)
# PHASE 3 — RAS overflow: 11 pushes into 10-entry RAS
# PHASE 4 — JALR rd=x0 (non-push): verifies RAS is NOT pushed
# PHASE 5 — Forced mismatch pairs (comparator coverage)
# PHASE 6 — [NEW] TDF-F / TDF-R: alternating push/pop pairs, 10 pairs
# PHASE 7 — [NEW] PtrMux wraparound: 11-deep nested call (overflow+underflow)
# PHASE 8 — [NEW] RAS upper-bit SA-0 + TDF-F for bits 16..25 (one chain/bit)
#
# =============================================================================
# SITE LAYOUT for phases 1/2 (28 bytes each):
#
#   [+0]  addi  sp, sp, -4
#   [+4]  sw    ra, 0(sp)
#   [+8]  jal   ra, next_site
#   [+12] lw    ra, 0(sp)       <- landing pad
#   [+16] addi  sp, sp, 4
#   [+20] addi  s11, s11, P_N   <- unique prime
#   [+24] ret
# =============================================================================

.section .text
.global test3
.type   test3, @function

test3:
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
    addi  s0, sp, 112

    li    s11, 0                    # accumulator

    # ==========================================================
    # PHASE 1: 10-deep chain, return addresses in ~0x80008xxx
    # ==========================================================
    jal   ra, chain0_site_0
    # s11 += sum of first 10 primes (2+3+5+7+11+13+17+19+23+29 = 129)

    # ==========================================================
    # PHASE 2: 10-deep chain, return addresses in ~0x80040xxx
    # bits[17:14] differ from phase 1
    # ==========================================================
    jal   ra, chain1_site_0
    # s11 += 129

    # ==========================================================
    # PHASE 3: RAS overflow — 11 pushes into 10-entry RAS
    # ==========================================================
    li    s1, 0
    li    s2, 11
ov_loop:
    jal   ra, ras_ov_leaf
ov_ret:
    xor   s11, s11, ra
    addi  s1, s1, 1
    blt   s1, s2, ov_loop

    jal   ra, ras_ptr_probe
ptr_probe_land:
    addi  s11, s11, 0x55

    # ==========================================================
    # PHASE 4: JALR rd=x0 — RAS must NOT be pushed
    # ==========================================================
    la    t0, jalr_tgtA
    jalr  x0, t0, 0
jalr_tgtA:
    addi  s11, s11, 0x11

    la    t0, jalr_tgtB
    jalr  x0, t0, 0
jalr_tgtB:
    addi  s11, s11, 0x22

    la    t0, jalr_tgtC
    jalr  x0, t0, 0
jalr_tgtC:
    addi  s11, s11, 0x33

    la    t0, jalr_tgtD
    jalr  x0, t0, 0
jalr_tgtD:
    addi  s11, s11, 0x44

    jal   ra, ras_jalr_probe
jalr_probe_land:
    addi  s11, s11, 0x77

    # ==========================================================
    # PHASE 5: Forced mismatch — exercises mismatch comparator
    # ==========================================================
    jal   ra, mm_leaf0
    la    ra, mm_dst0
    ret
mm_poison0: addi s11, s11, 0x1FF
mm_dst0:    addi s11, s11, 0x101

    jal   ra, mm_leaf1
    la    ra, mm_dst1
    ret
mm_poison1: addi s11, s11, 0x1FF
mm_dst1:    addi s11, s11, 0x102

    jal   ra, mm_leaf2
    la    ra, mm_dst2
    ret
mm_poison2: addi s11, s11, 0x1FF
mm_dst2:    addi s11, s11, 0x103

    jal   ra, mm_leaf3
    la    ra, mm_dst3
    ret
mm_poison3: addi s11, s11, 0x1FF
mm_dst3:    addi s11, s11, 0x104

    # ==========================================================
    # PHASE 6: [NEW] TDF-F / TDF-R — alternating push/pop pairs
    #
    # For each pair i (0..9):
    #   call p6_call_aI  -> RAS[0] = &p6_ret_aI  (bit pattern A)
    #   xor  s11, s11, ra              (ra = &p6_ret_aI after ret)
    #   call p6_call_bI  -> RAS[0] = &p6_ret_bI  (bit pattern B, different bits)
    #   xor  s11, s11, ra
    #
    # p6_call_aI is placed at .align 2, p6_call_bI at .align 4 in its own
    # section so bit 2 (and possibly higher) differs between the two landing
    # pads. This guarantees the same RAS slot sees a 1->0 transition on at
    # least one bit (TDF-F) and 0->1 on another (TDF-R) on every pair.
    #
    # After 10 pairs every RAS entry has been written with both patterns.
    # ==========================================================

    call  p6_call_a0
p6_ret_a0:
    xor   s11, s11, ra
    call  p6_call_b0
p6_ret_b0:
    xor   s11, s11, ra

    call  p6_call_a1
p6_ret_a1:
    xor   s11, s11, ra
    call  p6_call_b1
p6_ret_b1:
    xor   s11, s11, ra

    call  p6_call_a2
p6_ret_a2:
    xor   s11, s11, ra
    call  p6_call_b2
p6_ret_b2:
    xor   s11, s11, ra

    call  p6_call_a3
p6_ret_a3:
    xor   s11, s11, ra
    call  p6_call_b3
p6_ret_b3:
    xor   s11, s11, ra

    call  p6_call_a4
p6_ret_a4:
    xor   s11, s11, ra
    call  p6_call_b4
p6_ret_b4:
    xor   s11, s11, ra

    call  p6_call_a5
p6_ret_a5:
    xor   s11, s11, ra
    call  p6_call_b5
p6_ret_b5:
    xor   s11, s11, ra

    call  p6_call_a6
p6_ret_a6:
    xor   s11, s11, ra
    call  p6_call_b6
p6_ret_b6:
    xor   s11, s11, ra

    call  p6_call_a7
p6_ret_a7:
    xor   s11, s11, ra
    call  p6_call_b7
p6_ret_b7:
    xor   s11, s11, ra

    call  p6_call_a8
p6_ret_a8:
    xor   s11, s11, ra
    call  p6_call_b8
p6_ret_b8:
    xor   s11, s11, ra

    call  p6_call_a9
p6_ret_a9:
    xor   s11, s11, ra
    call  p6_call_b9
p6_ret_b9:
    xor   s11, s11, ra

    # ==========================================================
    # PHASE 7: [NEW] PtrMux full wraparound
    #
    # 11 nested calls overflow the 10-entry RAS (ptr wraps 9->0).
    # The 11 nested rets then underflow (ptr wraps 0->9).
    # Both PtrMux edge transitions are exercised.
    # ==========================================================
    call  p7_push11_start
    xor   s11, s11, ra

    # ==========================================================
    # PHASE 8: [NEW] RAS upper-bit SA-0 + TDF-F for bits 16..25
    #
    # For each bit N in {16..25}:
    #   Step 1: 10-deep chain placed at 0x80000000|(1<<N)
    #           -> all 10 RAS slots loaded with RA having bit N=1
    #           -> detects SA-0 on bit N (write 1, check no mismatch)
    #   Step 2: 10 distinct low-addr leaf calls
    #           -> overwrites all 10 RAS slots with bit N=0
    #           -> creates the 1->0 transition: TDF-F detected
    #   Step 3: fill again with the hi chain
    #           -> SA-0 re-confirmed
    #
    # The hi_bNN chains accumulate XOR of RA values into a0.
    # ==========================================================

    # --- bit 16 (0x80010000) ---
    call  hi_b16_n1
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
    xor   s11, s11, ra
    call  hi_b16_n1
    xor   s11, s11, a0

    # --- bit 17 (0x80020000) ---
    call  hi_b17_n1
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
    xor   s11, s11, ra
    call  hi_b17_n1
    xor   s11, s11, a0

    # --- bit 18 (0x80040000) ---
    call  hi_b18_n1
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
    xor   s11, s11, ra
    call  hi_b18_n1
    xor   s11, s11, a0

    # --- bit 19 (0x80080000) ---
    call  hi_b19_n1
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
    xor   s11, s11, ra
    call  hi_b19_n1
    xor   s11, s11, a0

    # --- bit 20 (0x80100000) ---
    call  hi_b20_n1
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
    xor   s11, s11, ra
    call  hi_b20_n1
    xor   s11, s11, a0

    # --- bit 21 (0x80200000) ---
    call  hi_b21_n1
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
    xor   s11, s11, ra
    call  hi_b21_n1
    xor   s11, s11, a0

    # --- bit 22 (0x80400000) ---
    call  hi_b22_n1
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
    xor   s11, s11, ra
    call  hi_b22_n1
    xor   s11, s11, a0

    # --- bit 23 (0x80800000) ---
    call  hi_b23_n1
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
    xor   s11, s11, ra
    call  hi_b23_n1
    xor   s11, s11, a0

    # --- bit 24 (0x81000000) ---
    call  hi_b24_n1
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
    xor   s11, s11, ra
    call  hi_b24_n1
    xor   s11, s11, a0

    # --- bit 25 (0x82000000) ---
    call  hi_b25_n1
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
    xor   s11, s11, ra
    call  hi_b25_n1
    xor   s11, s11, a0

    # ----------------------------------------------------------
    mv    a0, s11                   # return accumulated signature

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

# ------------------------------------------------------------------
# Simple leaf stubs (in .text, close to test body)
# ------------------------------------------------------------------
ras_ov_leaf:        ret
ras_ptr_probe:      ret
ras_jalr_probe:     ret
mm_leaf0:           ret
mm_leaf1:           ret
mm_leaf2:           ret
mm_leaf3:           ret

# ------------------------------------------------------------------
# [NEW] PHASE 6 leaf stubs — placed in dedicated sections so the
# assembler/linker maps a- and b-variants to addresses that differ
# in bit 2 (and naturally in higher bits across sections).
# ------------------------------------------------------------------
.section .p6a0,"ax",@progbits
.align 2
p6_call_a0: ret

.section .p6b0,"ax",@progbits
.align 4             # guarantees bit 2 differs vs a0
p6_call_b0: ret

.section .p6a1,"ax",@progbits
.align 2
p6_call_a1: ret

.section .p6b1,"ax",@progbits
.align 4
p6_call_b1: ret

.section .p6a2,"ax",@progbits
.align 2
p6_call_a2: ret

.section .p6b2,"ax",@progbits
.align 4
p6_call_b2: ret

.section .p6a3,"ax",@progbits
.align 2
p6_call_a3: ret

.section .p6b3,"ax",@progbits
.align 4
p6_call_b3: ret

.section .p6a4,"ax",@progbits
.align 2
p6_call_a4: ret

.section .p6b4,"ax",@progbits
.align 4
p6_call_b4: ret

.section .p6a5,"ax",@progbits
.align 2
p6_call_a5: ret

.section .p6b5,"ax",@progbits
.align 4
p6_call_b5: ret

.section .p6a6,"ax",@progbits
.align 2
p6_call_a6: ret

.section .p6b6,"ax",@progbits
.align 4
p6_call_b6: ret

.section .p6a7,"ax",@progbits
.align 2
p6_call_a7: ret

.section .p6b7,"ax",@progbits
.align 4
p6_call_b7: ret

.section .p6a8,"ax",@progbits
.align 2
p6_call_a8: ret

.section .p6b8,"ax",@progbits
.align 4
p6_call_b8: ret

.section .p6a9,"ax",@progbits
.align 2
p6_call_a9: ret

.section .p6b9,"ax",@progbits
.align 4
p6_call_b9: ret

# ------------------------------------------------------------------
# [NEW] PHASE 7: 11-deep nested call (overflow + underflow of 10-entry RAS)
# Each level in its own section so return addresses vary in bits 4..11.
# ------------------------------------------------------------------
.section .text
p7_push11_start:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p7_d1
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p7_1,"ax",@progbits
.align 2
p7_d1: addi sp,sp,-4; sw ra,0(sp); call p7_d2;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_2,"ax",@progbits
.align 2
p7_d2: addi sp,sp,-4; sw ra,0(sp); call p7_d3;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_3,"ax",@progbits
.align 2
p7_d3: addi sp,sp,-4; sw ra,0(sp); call p7_d4;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_4,"ax",@progbits
.align 2
p7_d4: addi sp,sp,-4; sw ra,0(sp); call p7_d5;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_5,"ax",@progbits
.align 2
p7_d5: addi sp,sp,-4; sw ra,0(sp); call p7_d6;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_6,"ax",@progbits
.align 2
p7_d6: addi sp,sp,-4; sw ra,0(sp); call p7_d7;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_7,"ax",@progbits
.align 2
p7_d7: addi sp,sp,-4; sw ra,0(sp); call p7_d8;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_8,"ax",@progbits
.align 2
p7_d8: addi sp,sp,-4; sw ra,0(sp); call p7_d9;  lw ra,0(sp); addi sp,sp,4; ret
.section .p7_9,"ax",@progbits
.align 2
p7_d9: addi sp,sp,-4; sw ra,0(sp); call p7_d10; lw ra,0(sp); addi sp,sp,4; ret
.section .p7_10,"ax",@progbits
.align 2
p7_d10: addi sp,sp,-4; sw ra,0(sp); call p7_d11; lw ra,0(sp); addi sp,sp,4; ret
.section .p7_11,"ax",@progbits
.align 2
p7_d11: ret    # leaf: unwind starts here (11th push -> ptr wrapped 9->0)


# ==================================================================
# .ras_walk_t3  — 10-deep chain, phase 1
# Placed at 0x80008000 by linker.
# Return addresses: 0x80008xxx range, bits[17:14] = 0b0001
# ==================================================================
.section .ras_walk_t3, "ax", @progbits
.align 2

chain0_site_0:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_1
chain0_land_0:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  2              # P_0 = 2
    ret

chain0_site_1:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_2
chain0_land_1:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  3              # P_1 = 3
    ret

chain0_site_2:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_3
chain0_land_2:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  5              # P_2 = 5
    ret

chain0_site_3:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_4
chain0_land_3:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  7              # P_3 = 7
    ret

chain0_site_4:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_5
chain0_land_4:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  11             # P_4 = 11
    ret

chain0_site_5:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_6
chain0_land_5:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  13             # P_5 = 13
    ret

chain0_site_6:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_7
chain0_land_6:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  17             # P_6 = 17
    ret

chain0_site_7:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_8
chain0_land_7:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  19             # P_7 = 19
    ret

chain0_site_8:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_9
chain0_land_8:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  23             # P_8 = 23
    ret

chain0_site_9:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_leaf          # RAS now holds 10 entries (full)
chain0_land_9:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  29             # P_9 = 29
    ret

chain0_leaf:
    ret                             # ra = chain0_land_9; starts the unwind


# ==================================================================
# .ras_fill_t3  — 10-deep chain, phase 2
# Placed at 0x80040000 by linker.
# Return addresses: 0x80040xxx range, bits[17:14] = 0b1000
# ==================================================================
.section .ras_fill_t3, "ax", @progbits
.align 2

chain1_site_0:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_1
chain1_land_0:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  2
    ret

chain1_site_1:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_2
chain1_land_1:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  3
    ret

chain1_site_2:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_3
chain1_land_2:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  5
    ret

chain1_site_3:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_4
chain1_land_3:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  7
    ret

chain1_site_4:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_5
chain1_land_4:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  11
    ret

chain1_site_5:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_6
chain1_land_5:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  13
    ret

chain1_site_6:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_7
chain1_land_6:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  17
    ret

chain1_site_7:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_8
chain1_land_7:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  19
    ret

chain1_site_8:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_9
chain1_land_8:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  23
    ret

chain1_site_9:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_leaf
chain1_land_9:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  29
    ret

chain1_leaf:
    ret


# ==================================================================
# [NEW] PHASE 8 — high-address chains + low-address cleanup leaves
#
# Each hi_bNN section is placed by the linker at 0x80000000|(1<<NN).
# The 10-deep nested call pushes 10 return addresses all having bit N=1.
# hi_bNN_n1 accumulates the XOR of all RA values into a0 and returns it.
# The shared leaf hi_shared_leaf is a plain ret.
#
# Low-address leaves (lo_leaf_bNN_K, K=0..9) are simple ret stubs in
# .text; each has its own label so return addresses pushed for them are
# distinct (important for RAS tag-bit coverage).
# ==================================================================

# ---------- shared leaf (ret target for all deep chains) ----------
.section .text
hi_shared_leaf: ret

# ---------- low-address cleanup leaves (10 per bit) ----------

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

# ==================================================================
# [NEW] hi_bNN deep chains — each placed in its own named section
# so the linker script can position it at 0x80000000|(1<<NN).
#
# All chains are 10 levels deep (matching the 10-entry RAS).
# Pattern at each level:
#   push ra; call next; xor a0, a0, ra; pop ra; ret
# The leaf (level 10) initialises a0 = ra (first XOR seed).
#
# NOTE: the call instruction inside hi_bNN_nK sits at address
#   0x80000000|(1<<NN) + small_offset
# so the pushed return address has bit NN guaranteed = 1.
# ==================================================================

# ---- bit 16: placed at 0x80011000 (linker: .hi_b16) ----
.section .hi_b16,"ax",@progbits
.align 2
hi_b16_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b16_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b16_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 17: placed at 0x80022000 (linker: .hi_b17) ----
.section .hi_b17,"ax",@progbits
.align 2
hi_b17_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b17_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b17_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 18: placed at 0x80070000 (linker: .hi_b18) ----
.section .hi_b18,"ax",@progbits
.align 2
hi_b18_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b18_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b18_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 19: placed at 0x80080000 (linker: .hi_b19) ----
.section .hi_b19,"ax",@progbits
.align 2
hi_b19_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b19_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b19_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 20: placed at 0x80100000 (linker: .hi_b20) ----
.section .hi_b20,"ax",@progbits
.align 2
hi_b20_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b20_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b20_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 21: placed at 0x80200000 (linker: .hi_b21) ----
.section .hi_b21,"ax",@progbits
.align 2
hi_b21_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b21_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b21_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 22: placed at 0x80400000 (linker: .hi_b22) ----
.section .hi_b22,"ax",@progbits
.align 2
hi_b22_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b22_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b22_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 23: placed at 0x80800000 (linker: .hi_b23) ----
.section .hi_b23,"ax",@progbits
.align 2
hi_b23_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b23_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b23_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 24: placed at 0x81000000 (linker: .hi_b24) ----
.section .hi_b24,"ax",@progbits
.align 2
hi_b24_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b24_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b24_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret

# ---- bit 25: placed at 0x82000000 (linker: .hi_b25) ----
.section .hi_b25,"ax",@progbits
.align 2
hi_b25_n1:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n2;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n2:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n3;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n3:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n4;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n4:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n5;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n5:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n6;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n6:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n7;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n7:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n8;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n8:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n9;  xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n9:
    addi sp,sp,-4; sw ra,0(sp); call hi_b25_n10; xor a0,a0,ra; lw ra,0(sp); addi sp,sp,4; ret
hi_b25_n10:
    addi sp,sp,-4; sw ra,0(sp); call hi_shared_leaf; mv a0,ra; lw ra,0(sp); addi sp,sp,4; ret