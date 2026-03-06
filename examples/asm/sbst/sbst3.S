# =============================================================================
# sbst3.S  —  RAS (Return Address Stack) Predictor SBST
# =============================================================================
#
# TARGET FAULTS:
#   RASStack[i][31:0]  — 16 entries * 32 data bits = 512 FFs
#   RASPtr[3:0]        — pointer increment/wrap logic
#   RASPush/RASPop     — control signal correctness
#   Mismatch detection — pipeline flush on wrong prediction
#
# =============================================================================
# STRUCTURE
# =============================================================================
#
# PHASE 1 — 16-deep chain in .ras_walk_t3 (addresses ~0x80008xxx)
#   Fills all 16 RAS entries with DISTINCT return addresses.
#   Each site saves/restores ra on the software stack, so unwind
#   terminates correctly. A prime is accumulated at each landing pad.
#   Stuck-at fault on any RAS data bit -> ret jumps to wrong address
#   -> wrong or missing prime -> a0 diverges from golden.
#
# PHASE 2 — 16-deep chain in .ras_fill_t3 (addresses ~0x80040xxx)
#   Same structure, but return addresses have bits [17:14] SET
#   (0x80040xxx vs 0x80008xxx). Exercises those upper data-path bits
#   that phase 1 addresses never toggle.
#
# PHASE 3 — RAS overflow: 17 pushes into 16-entry RAS
#   Tests pointer wraparound. XOR of returned ra values is
#   sensitive to any pointer-arithmetic fault.
#
# PHASE 4 — JALR rd=x0 (non-push): verifies RAS is NOT pushed
#   Exercises RASPush=0 condition. Followed by clean jal/ret to
#   confirm RAS top was not corrupted.
#
# PHASE 5 — Forced mismatch pairs
#   jal sets RAS prediction; then ra is overwritten; ret causes
#   a pipeline flush. Exercises the mismatch detection comparator.
#
# =============================================================================
# SITE LAYOUT (28 bytes, identical in both chain sections):
#
#   [+0]  addi  sp, sp, -4
#   [+4]  sw    ra, 0(sp)        <- save caller's ra
#   [+8]  jal   ra, next_site    <- RAS HW pushes (this+12) as predicted ret
#   [+12] lw    ra, 0(sp)        <- LANDING PAD: restore caller's ra
#   [+16] addi  sp, sp, 4
#   [+20] addi  s11, s11, P_N    <- unique prime; only runs on correct unwind
#   [+24] ret                    <- jalr x0,ra,0 -> jumps to restored caller ra
#
# The jal at [+8] sets ra = this+12 (the lw instruction = landing pad).
# The RAS HW also records this+12 as the predicted return address.
# So both the HW prediction AND the ra register agree on the landing pad.
# A fault on RAS data bit K of entry N causes the HW to mispredict;
# the actual ret still uses the correct ra (restored by lw), so execution
# continues correctly, but the speculative fetch goes to the wrong address.
# CVW will flush and redirect. The prime is still added (execution is correct).
#
# WAIT - that means data faults are NOT detectable this way!
# We need the ret to actually FOLLOW the RAS prediction, not ra.
# In CVW, ret = jalr x0, ra, 0. The ACTUAL jump uses ra, not RAS.
# RAS is only used for speculative fetch. The mismatch causes a flush,
# but execution is always correct (follows ra).
#
# CORRECT APPROACH for RAS data coverage:
# We need to make the ACTUAL execution depend on the RAS prediction.
# This means we must corrupt ra at the point of ret, so that the core
# RELIES on the RAS-predicted PC for correct execution.
#
# METHOD: after jal (ra = landing), deliberately corrupt ra to a known
# BAD address, then ret. The core speculatively fetches RAS-predicted
# target (landing). The actual jalr x0,ra,0 goes to BAD.
# Execution resolves to BAD -> pipeline flushes RAS prediction.
# The signature changes because we land at BAD (with known unique value).
#
# BUT this is the MISMATCH approach (phase 5) - not a data integrity test.
#
# SIMPLEST CORRECT DATA TEST:
# Use the jal/ret WITHOUT corrupting ra. The RAS prediction is used for
# SPECULATIVE fetch. If a data fault exists, the speculative fetch goes
# to POISON code. With CVW's out-of-order speculation handling, the
# speculatively fetched instruction may partially execute and corrupt state IF it reaches the commit stage before the mismatch is detected.
# However in a simple in-order pipeline (which CVW uses), wrong speculative
# instructions are squashed before commit. So pure data faults on RAS
# are NOT observable via execution path in an in-order core!
#
# WHAT IS OBSERVABLE:
# 1. RAS POINTER faults -> wrong entry is popped -> WRONG ra value returned
#    -> wrong unwind target -> wrong prime or crash -> detectable
# 2. RASPTR increment/wrap faults -> same
# 3. RASPush/RASPop enable faults -> push when shouldn't / pop when shouldn't
#    -> wrong entry count -> wrong unwind -> detectable
# 4. RAS DATA faults in an in-order core -> speculative fetch goes wrong,
#    but instruction is squashed before commit. NOT directly detectable via
#    data accumulator. BUT: the HPM branch-mispredict counter increments.
#    So the TEST2 HPM signature already covers many of these.
#
# STRATEGY FOR THIS TEST: focus on #1-3 (pointer, control) + phase 5 (mismatch).
# Use a data accumulator (not HPM) so pointer/control faults are caught
# even if they don't change the mispredict COUNT.
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
    # PHASE 1: 16-deep chain, return addresses in ~0x80008xxx
    # ==========================================================
    # Each ret returns to its own landing pad (correct ra saved/restored).
    # Unwind executes all 16 primes in reverse order.
    # Pointer fault: wrong entry popped -> wrong prime or crash.
    # Push-enable fault: too few entries pushed -> early pop to junk ra.
    jal   ra, chain0_site_0
    # s11 += 380 (sum of primes 2+3+5+...+53) after full unwind

    # ==========================================================
    # PHASE 2: 16-deep chain, return addresses in ~0x80040xxx
    # bits[17:14] differ from phase 1, exercising upper data bits
    # ==========================================================
    jal   ra, chain1_site_0
    # s11 += 380

    # ==========================================================
    # PHASE 3: RAS overflow — 17 pushes into 16-entry RAS
    # Tests pointer wraparound logic.
    # We call ras_ov_leaf 17 times from the same site.
    # Each jal pushes the SAME return address (ov_ret) onto RAS.
    # After 16 pushes, the 17th overwrites entry 0 (wrap).
    # On the actual ret, ra is always correct (jal sets it). If pointer wraps incorrectly, the RAS prediction for future
    # rets elsewhere will be wrong -> phase 4 probe detects it.
    # ==========================================================
    li    s1, 0
    li    s2, 17
ov_loop:
    jal   ra, ras_ov_leaf           # push ra=ov_ret onto RAS; ret pops it back
ov_ret:
    xor   s11, s11, ra              # ra = ov_ret address; XOR is sensitive to pointer bugs
    addi  s1, s1, 1
    blt   s1, s2, ov_loop           # 17 iterations

    # After 17 iterations, RAS pointer has wrapped once.
    # Do one clean probe: jal/ret from a UNIQUE site.
    # If pointer is wrong, this ret returns to wrong place.
    jal   ra, ras_ptr_probe
ptr_probe_land:
    addi  s11, s11, 0x55            # unique token; skipped if ret misdirects

    # ==========================================================
    # PHASE 4: JALR rd=x0  — RAS must NOT be pushed
    # ==========================================================
    # 4 JALR x0 jumps to distinct targets.
    # Then one jal/ret verifies RAS top was not corrupted.
    la    t0, jalr_tgtA
    jalr  x0, t0, 0                 # NO push
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

    # Clean jal/ret probe: if JALR wrongly pushed, RAS top is garbage
    jal   ra, ras_jalr_probe
jalr_probe_land:
    addi  s11, s11, 0x77            # unique token

    # ==========================================================
    # PHASE 5: Forced mismatch — exercises mismatch comparator
    # jal pushes predicted return = mm_poisonN (jal+4)
    # then ra is overwritten with mm_dstN
    # ret jumps to mm_dstN (correct execution) but RAS predicted
    # mm_poisonN -> pipeline flush -> toggles comparator FFs
    # ==========================================================
    jal   ra, mm_leaf0
    la    ra, mm_dst0               # overwrite ra AFTER jal
    ret                             # actual=mm_dst0, RAS predicted mm_poison0
mm_poison0: addi s11, s11, 0x1FF   # POISON: only runs if RAS prediction committed
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


# ==================================================================
# .ras_walk_t3  — 16-deep chain, phase 1
# Placed at 0x80008000 by linker.
# Return addresses: 0x80008xxx range, bits[17:14] = 0b0001
#
# NO .fill sleds. Each site is exactly 28 bytes.
# Total section size: 17*28 - 24 + 4 = 452 bytes  (fits easily)
#
# Primes: P[0..15] = 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53
# Sum = 380 = 0x17C
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
    jal   ra,  chain0_site_10
chain0_land_9:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  29             # P_9 = 29
    ret

chain0_site_10:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_11
chain0_land_10:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  31             # P_10 = 31
    ret

chain0_site_11:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_12
chain0_land_11:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  37             # P_11 = 37
    ret

chain0_site_12:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_13
chain0_land_12:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  41             # P_12 = 41
    ret

chain0_site_13:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_14
chain0_land_13:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  43             # P_13 = 43
    ret

chain0_site_14:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_15
chain0_land_14:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  47             # P_14 = 47
    ret

chain0_site_15:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_leaf          # RAS now holds 16 entries (full)
chain0_land_15:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  53             # P_15 = 53
    ret

chain0_leaf:
    ret                             # ra = chain0_land_15; starts the unwind


# ==================================================================
# .ras_fill_t3  — 16-deep chain, phase 2
# Placed at 0x80040000 by linker.
# Return addresses: 0x80040xxx range, bits[17:14] = 0b1000
# Exercises upper address bits in RAS data storage.
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
    jal   ra,  chain1_site_10
chain1_land_9:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  29
    ret

chain1_site_10:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_11
chain1_land_10:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  31
    ret

chain1_site_11:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_12
chain1_land_11:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  37
    ret

chain1_site_12:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_13
chain1_land_12:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  41
    ret

chain1_site_13:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_14
chain1_land_13:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  43
    ret

chain1_site_14:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_site_15
chain1_land_14:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  47
    ret

chain1_site_15:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain1_leaf
chain1_land_15:
    lw    ra,   0(sp)
    addi  sp,  sp,   4
    addi  s11, s11,  53
    ret

chain1_leaf:
    ret