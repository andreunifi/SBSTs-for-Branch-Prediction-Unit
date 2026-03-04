# =============================================================================
# sbst4.S  —  MATS++ BTB March Test
# =============================================================================
#
# Derivative: syn_polito_rv32e
#   BTB_SIZE   = 3  → 8 entries, indexed by PC[4:2]
#   BPRED_TYPE = BP_TWOBIT  (2-bit saturating counter)
#   BPRED_SIZE = 3  → 8 BHT entries
#
# Strategy:
#   8 dedicated branch sections, each 8 bytes, placed at a 64-byte-aligned
#   base address so that branch i sits at BASE + i*8, giving PC[4:2] = i.
#   This lets us write/read any specific BTB entry deterministically.
#
#   The condition register is a0 (x10):
#     a0 == 0  →  bnez NOT taken  (write0 / read0)
#     a0 != 0  →  bnez TAKEN      (write1 / read1)
#
#   Each site is:
#       bnez a0, .+4    # branch under test
#       ret             # both taken (+4) and fall-through land here → return
#
#   MATS++ phases (2-bit counter needs 3 repetitions to guarantee saturation):
#     Phase 1  ↑(w0)     : i=0..7 → drive site_i NT × 3  (→ STRONGLY_NT)
#     Phase 2  ↑(r0,w1)  : i=0..7 → drive site_i NT × 1  (read0, verify SN)
#                                    drive site_i T  × 3  (write1 → STRONGLY_T)
#     Phase 3  ↓(r1,w0)  : i=7..0 → drive site_i T  × 1  (read1, verify ST)
#                                    drive site_i NT × 3  (write0 → STRONGLY_NT)
#
#   Mispredictions counted via mhpmcounter4 (CSR 0xB04).
#   Return value a0 = total misprediction delta across all 3 phases.
#   Golden value = 0 if BTB and BHT work correctly with no aliasing.
#   (Run once on golden RTL to capture actual golden for GOLDEN_SIGNATURES.)
#
# Register allocation (full RV32I, E_SUPPORTED=0):
#   a0      = branch condition (0=NT, ≠0=T) / return value
#   a1      = misprediction counter snapshot
#   a2      = misprediction accumulator (total across phases)
#   a3      = per-phase delta
#   ra      = link register (saved/restored)
#   s0–s1   = callee-saved scratch (saved/restored)
#
# =============================================================================

# ---------------------------------------------------------------------------
# Macro: snapshot mhpmcounter4 into register rd
# ---------------------------------------------------------------------------
.macro SNAP_MISP rd
    csrr    \rd, 0xB04
.endm

# ---------------------------------------------------------------------------
# Macro: call a branch site with condition cond (0=NT, nonzero=T), n times
#   CALL_SITE  site_label, cond_value, count_reg, tmp_reg
#   count_reg  must be a writable reg holding the iteration count
# ---------------------------------------------------------------------------
# (We unroll manually below for clarity and precise PC control)

# =============================================================================
# BRANCH SITES  —  8 slots × 8 bytes, must be at a 64-byte-aligned address.
# The linker script must place .jumpsite0 at a 64-byte-aligned address.
# Subsequent sites follow at +8, +16, … +56 automatically.
# =============================================================================

    .section .jumpsite0, "ax", @progbits
    .align  6                       # 64-byte alignment for the whole block
SITE0:                              # PC[4:2] = 000  →  BTB entry 0
    bnez    a0, .+4
    ret

    .section .jumpsite1, "ax", @progbits
    .align  3                       # 8-byte alignment within the block
SITE1:                              # PC[4:2] = 001  →  BTB entry 1
    bnez    a0, .+4
    ret

    .section .jumpsite2, "ax", @progbits
    .align  3
SITE2:                              # PC[4:2] = 010  →  BTB entry 2
    bnez    a0, .+4
    ret

    .section .jumpsite3, "ax", @progbits
    .align  3
SITE3:                              # PC[4:2] = 011  →  BTB entry 3
    bnez    a0, .+4
    ret

    .section .jumpsite4, "ax", @progbits
    .align  3
SITE4:                              # PC[4:2] = 100  →  BTB entry 4
    bnez    a0, .+4
    ret

    .section .jumpsite5, "ax", @progbits
    .align  3
SITE5:                              # PC[4:2] = 101  →  BTB entry 5
    bnez    a0, .+4
    ret

    .section .jumpsite6, "ax", @progbits
    .align  3
SITE6:                              # PC[4:2] = 110  →  BTB entry 6
    bnez    a0, .+4
    ret

    .section .jumpsite7, "ax", @progbits
    .align  3
SITE7:                              # PC[4:2] = 111  →  BTB entry 7
    bnez    a0, .+4
    ret

    .section .jumpsite_test, "ax", @progbits
SITE_END:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    ret

    .section .write1, "ax", @progbits
SITE_WRITE1:
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    ret

    .section .write0, "ax", @progbits
SITE_WRITE0:
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    bnez    a0, .+4
    ret



# =============================================================================
# MAIN TEST BODY
# =============================================================================

    .section .text
    .align  2
    .global test4
    .type   test4, @function

test4:
    # ----- prologue -----
    addi    sp, sp, -16
    sw      ra,  12(sp)
    sw      s0,   8(sp)
    sw      s1,   4(sp)
    sw      s2,   0(sp)

    li      a2, 0           # a2 = total misprediction accumulator

    # =========================================================================
    # PHASE 1  ↑(w0)  —  ascending, write0 (NOT-TAKEN × 3 per entry)
    # Goal: drive all 8 BHT entries to STRONGLY_NOT_TAKEN state
    # =========================================================================

    SNAP_MISP s0            # snapshot before phase 1

    # --- entry 0 ---
    li      a0, 0           # a0=0 → NOT-TAKEN
    call    SITE0
    call    SITE0
    call    SITE0
    # --- entry 1 ---
    call    SITE1
    call    SITE1
    call    SITE1
    # --- entry 2 ---
    call    SITE2
    call    SITE2
    call    SITE2
    # --- entry 3 ---
    call    SITE3
    call    SITE3
    call    SITE3
    # --- entry 4 ---
    call    SITE4
    call    SITE4
    call    SITE4
    # --- entry 5 ---
    call    SITE5
    call    SITE5
    call    SITE5
    # --- entry 6 ---
    call    SITE6
    call    SITE6
    call    SITE6
    # --- entry 7 ---
    call    SITE7
    call    SITE7
    call    SITE7

    SNAP_MISP s1            # snapshot after phase 1
    sub     a3, s1, s0      # delta (may be non-zero from cold start)
    add     a2, a2, a3      # accumulate

    # =========================================================================
    # PHASE 2  ↑(r0, w1)  —  ascending
    #   r0: execute NOT-TAKEN × 1  (predictor should be SN → no misprediction)
    #   w1: execute TAKEN     × 3  (drive to STRONGLY_TAKEN)
    # =========================================================================

    SNAP_MISP s0            # snapshot before phase 2

    # --- entry 0: r0 ---
    li      a0, 0           # NOT-TAKEN → read0
    call    SITE0
    # --- entry 0: w1 ---
    li      a0, 1           # TAKEN → write1
    call    SITE0
    call    SITE0
    call    SITE0

    # --- entry 1: r0 ---
    li      a0, 0
    call    SITE1
    # --- entry 1: w1 ---
    li      a0, 1
    call    SITE1
    call    SITE1
    call    SITE1

    # --- entry 2: r0 ---
    li      a0, 0
    call    SITE2
    # --- entry 2: w1 ---
    li      a0, 1
    call    SITE2
    call    SITE2
    call    SITE2

    # --- entry 3: r0 ---
    li      a0, 0
    call    SITE3
    # --- entry 3: w1 ---
    li      a0, 1
    call    SITE3
    call    SITE3
    call    SITE3

    # --- entry 4: r0 ---
    li      a0, 0
    call    SITE4
    # --- entry 4: w1 ---
    li      a0, 1
    call    SITE4
    call    SITE4
    call    SITE4

    # --- entry 5: r0 ---
    li      a0, 0
    call    SITE5
    # --- entry 5: w1 ---
    li      a0, 1
    call    SITE5
    call    SITE5
    call    SITE5

    # --- entry 6: r0 ---
    li      a0, 0
    call    SITE6
    # --- entry 6: w1 ---
    li      a0, 1
    call    SITE6
    call    SITE6
    call    SITE6

    # --- entry 7: r0 ---
    li      a0, 0
    call    SITE7
    # --- entry 7: w1 ---
    li      a0, 1
    call    SITE7
    call    SITE7
    call    SITE7

    SNAP_MISP s1            # snapshot after phase 2
    sub     a3, s1, s0
    add     a2, a2, a3

    # =========================================================================
    # PHASE 3  ↓(r1, w0)  —  descending (entry 7 down to 0)
    #   r1: execute TAKEN     × 1  (predictor should be ST → no misprediction)
    #   w0: execute NOT-TAKEN × 3  (drive back to STRONGLY_NOT_TAKEN)
    # =========================================================================

    SNAP_MISP s0            # snapshot before phase 3

    # --- entry 7: r1 ---
    li      a0, 1           # TAKEN → read1
    call    SITE7
    # --- entry 7: w0 ---
    li      a0, 0           # NOT-TAKEN → write0
    call    SITE7
    call    SITE7
    call    SITE7

    # --- entry 6: r1 ---
    li      a0, 1
    call    SITE6
    # --- entry 6: w0 ---
    li      a0, 0
    call    SITE6
    call    SITE6
    call    SITE6

    # --- entry 5: r1 ---
    li      a0, 1
    call    SITE5
    # --- entry 5: w0 ---
    li      a0, 0
    call    SITE5
    call    SITE5
    call    SITE5

    # --- entry 4: r1 ---
    li      a0, 1
    call    SITE4
    # --- entry 4: w0 ---
    li      a0, 0
    call    SITE4
    call    SITE4
    call    SITE4

    # --- entry 3: r1 ---
    li      a0, 1
    call    SITE3
    # --- entry 3: w0 ---
    li      a0, 0
    call    SITE3
    call    SITE3
    call    SITE3

    # --- entry 2: r1 ---
    li      a0, 1
    call    SITE2
    # --- entry 2: w0 ---
    li      a0, 0
    call    SITE2
    call    SITE2
    call    SITE2

    # --- entry 1: r1 ---
    li      a0, 1
    call    SITE1
    # --- entry 1: w0 ---
    li      a0, 0
    call    SITE1
    call    SITE1
    call    SITE1

    # --- entry 0: r1 ---
    li      a0, 1
    call    SITE0
    # --- entry 0: w0 ---
    li      a0, 0
    call    SITE0
    call    SITE0
    call    SITE0

    SNAP_MISP s1            # snapshot after phase 3
    sub     a3, s1, s0
    add     a2, a2, a3


    #CALL   SITE_END             # ensure all branches complete before final snapshot


    SNAP_MISP s0            # snapshot before phase 3

    li     a0, 0    
    call   SITE_WRITE0           # ensure all branches complete before reading counter

    SNAP_MISP s0            # snapshot before phase 3


    li     a0, 1
    call   SITE_WRITE1

    SNAP_MISP s0            # snapshot before phase 3


    li     a0, 0
    call   SITE_WRITE0

    SNAP_MISP s0            # snapshot before phase 3


    # ----- return total misprediction delta -----
    mv      a0, a2

    # ----- epilogue -----
    lw      s2,   0(sp)
    lw      s1,   4(sp)
    lw      s0,   8(sp)
    lw      ra,  12(sp)
    addi    sp, sp, 16
    ret

    .size   test4, .-test4