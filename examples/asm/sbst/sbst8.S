##############################################################################
# sbst8.S  --  RAS high-address TDF-F + SA-0 coverage for bits 16-25
#
# ROOT CAUSE: bits 16-31 of RAS memory cells have 3/8 faults ND because
#   all existing code is at 0x8000xxxx where bits 16-31 are always 0.
#   The fault model cannot detect:
#     - SA-0 on bits 16+  (stuck-at-0: undetectable if we never write 1)
#     - TDF-F on bits 16+ (1->0 transition: impossible if bit never goes to 1)
#
# STRATEGY:
#   For each bit N (16..25):
#   1. Call hi_bN_n1 (a 16-deep nested chain placed at 0x80000000|2^N)
#      -> all 16 RAS entries get loaded with return addresses having bit N=1
#   2. After chain unwinds, do 16 sequential low-address calls
#      -> overwrites all 16 RAS entries with bit N=0
#      -> creates the 1->0 transition: TDF-F detected!
#   3. Call chain again -> writes 1 again: SA-0 re-verified
#
# The CALL instruction inside hi_bN_nK is at 0x80000000|2^N|offset,
# so the return address pushed to the RAS has bit N = 1 guaranteed.
#
# SIGNATURE: a0 = s11 (XOR accumulator)
##############################################################################

.section .text
.global test8
.type   test8, @function

test8:
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

    li    s11, 0                # global signature accumulator

    #=========================================================================
    # BIT 16: 0x80000000 | (1<<16) = 0x80010000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 16=1
    call  hi_b16_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 16=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b16_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 17: 0x80000000 | (1<<17) = 0x80020000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 17=1
    call  hi_b17_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 17=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b17_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 18: 0x80000000 | (1<<18) = 0x80040000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 18=1
    call  hi_b18_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 18=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b18_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 19: 0x80000000 | (1<<19) = 0x80080000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 19=1
    call  hi_b19_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 19=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b19_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 20: 0x80000000 | (1<<20) = 0x80100000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 20=1
    call  hi_b20_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 20=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b20_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 21: 0x80000000 | (1<<21) = 0x80200000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 21=1
    call  hi_b21_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 21=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b21_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 22: 0x80000000 | (1<<22) = 0x80400000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 22=1
    call  hi_b22_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 22=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b22_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 23: 0x80000000 | (1<<23) = 0x80800000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 23=1
    call  hi_b23_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 23=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b23_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 24: 0x80000000 | (1<<24) = 0x81000000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 24=1
    call  hi_b24_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 24=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b24_n1
    xor   s11, s11, a0

    #=========================================================================
    # BIT 25: 0x80000000 | (1<<25) = 0x82000000
    #=========================================================================
    # Step 1: fill all 16 RAS entries with bit 25=1
    call  hi_b25_n1
    xor   s11, s11, a0

    # Step 2: 16 low-addr sequential calls -> overwrites RAS with bit 25=0
    # This creates the 1->0 transition (TDF-F detected)

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
    xor   s11, s11, ra

    # Step 3: fill again with 1 -> re-verifies SA-0
    call  hi_b25_n1
    xor   s11, s11, a0

    #=========================================================================
    # COMBO LOW: bits 16+17+18+19 all set (address 0x800F0000)
    #=========================================================================
    call  hi_combo_lo_n1
    xor   s11, s11, a0

    #=========================================================================
    # COMBO HIGH: bits 20+21+22+23 all set (address 0x80F00000)
    #=========================================================================
    call  hi_combo_hi_n1
    xor   s11, s11, a0

    mv    a0, s11

    lw    s11,  8(sp)
    lw    s10, 16(sp)
    lw    s9,  24(sp)
    lw    s8,  32(sp)
    lw    s7,  40(sp)
    lw    s6,  48(sp)
    lw    s5,  56(sp)
    lw    s4,  64(sp)
    lw    s3,  72(sp)
    lw    s2,  80(sp)
    lw    s1,  88(sp)
    lw    s0,  96(sp)
    lw    ra,  104(sp)
    addi  sp,  sp, 112
    ret

#=============================================================================
# Low-address leaf stubs for step 2 (one per bit per slot to keep addresses
# distinct so they exercise different RAS tag bits too)
#=============================================================================

.align 2
lo_leaf_b16_0:
    ret

.align 2
lo_leaf_b16_1:
    ret

.align 2
lo_leaf_b16_2:
    ret

.align 2
lo_leaf_b16_3:
    ret

.align 2
lo_leaf_b16_4:
    ret

.align 2
lo_leaf_b16_5:
    ret

.align 2
lo_leaf_b16_6:
    ret

.align 2
lo_leaf_b16_7:
    ret

.align 2
lo_leaf_b16_8:
    ret

.align 2
lo_leaf_b16_9:
    ret

.align 2
lo_leaf_b16_10:
    ret

.align 2
lo_leaf_b16_11:
    ret

.align 2
lo_leaf_b16_12:
    ret

.align 2
lo_leaf_b16_13:
    ret

.align 2
lo_leaf_b16_14:
    ret

.align 2
lo_leaf_b16_15:
    ret

.align 2
lo_leaf_b17_0:
    ret

.align 2
lo_leaf_b17_1:
    ret

.align 2
lo_leaf_b17_2:
    ret

.align 2
lo_leaf_b17_3:
    ret

.align 2
lo_leaf_b17_4:
    ret

.align 2
lo_leaf_b17_5:
    ret

.align 2
lo_leaf_b17_6:
    ret

.align 2
lo_leaf_b17_7:
    ret

.align 2
lo_leaf_b17_8:
    ret

.align 2
lo_leaf_b17_9:
    ret

.align 2
lo_leaf_b17_10:
    ret

.align 2
lo_leaf_b17_11:
    ret

.align 2
lo_leaf_b17_12:
    ret

.align 2
lo_leaf_b17_13:
    ret

.align 2
lo_leaf_b17_14:
    ret

.align 2
lo_leaf_b17_15:
    ret

.align 2
lo_leaf_b18_0:
    ret

.align 2
lo_leaf_b18_1:
    ret

.align 2
lo_leaf_b18_2:
    ret

.align 2
lo_leaf_b18_3:
    ret

.align 2
lo_leaf_b18_4:
    ret

.align 2
lo_leaf_b18_5:
    ret

.align 2
lo_leaf_b18_6:
    ret

.align 2
lo_leaf_b18_7:
    ret

.align 2
lo_leaf_b18_8:
    ret

.align 2
lo_leaf_b18_9:
    ret

.align 2
lo_leaf_b18_10:
    ret

.align 2
lo_leaf_b18_11:
    ret

.align 2
lo_leaf_b18_12:
    ret

.align 2
lo_leaf_b18_13:
    ret

.align 2
lo_leaf_b18_14:
    ret

.align 2
lo_leaf_b18_15:
    ret

.align 2
lo_leaf_b19_0:
    ret

.align 2
lo_leaf_b19_1:
    ret

.align 2
lo_leaf_b19_2:
    ret

.align 2
lo_leaf_b19_3:
    ret

.align 2
lo_leaf_b19_4:
    ret

.align 2
lo_leaf_b19_5:
    ret

.align 2
lo_leaf_b19_6:
    ret

.align 2
lo_leaf_b19_7:
    ret

.align 2
lo_leaf_b19_8:
    ret

.align 2
lo_leaf_b19_9:
    ret

.align 2
lo_leaf_b19_10:
    ret

.align 2
lo_leaf_b19_11:
    ret

.align 2
lo_leaf_b19_12:
    ret

.align 2
lo_leaf_b19_13:
    ret

.align 2
lo_leaf_b19_14:
    ret

.align 2
lo_leaf_b19_15:
    ret

.align 2
lo_leaf_b20_0:
    ret

.align 2
lo_leaf_b20_1:
    ret

.align 2
lo_leaf_b20_2:
    ret

.align 2
lo_leaf_b20_3:
    ret

.align 2
lo_leaf_b20_4:
    ret

.align 2
lo_leaf_b20_5:
    ret

.align 2
lo_leaf_b20_6:
    ret

.align 2
lo_leaf_b20_7:
    ret

.align 2
lo_leaf_b20_8:
    ret

.align 2
lo_leaf_b20_9:
    ret

.align 2
lo_leaf_b20_10:
    ret

.align 2
lo_leaf_b20_11:
    ret

.align 2
lo_leaf_b20_12:
    ret

.align 2
lo_leaf_b20_13:
    ret

.align 2
lo_leaf_b20_14:
    ret

.align 2
lo_leaf_b20_15:
    ret

.align 2
lo_leaf_b21_0:
    ret

.align 2
lo_leaf_b21_1:
    ret

.align 2
lo_leaf_b21_2:
    ret

.align 2
lo_leaf_b21_3:
    ret

.align 2
lo_leaf_b21_4:
    ret

.align 2
lo_leaf_b21_5:
    ret

.align 2
lo_leaf_b21_6:
    ret

.align 2
lo_leaf_b21_7:
    ret

.align 2
lo_leaf_b21_8:
    ret

.align 2
lo_leaf_b21_9:
    ret

.align 2
lo_leaf_b21_10:
    ret

.align 2
lo_leaf_b21_11:
    ret

.align 2
lo_leaf_b21_12:
    ret

.align 2
lo_leaf_b21_13:
    ret

.align 2
lo_leaf_b21_14:
    ret

.align 2
lo_leaf_b21_15:
    ret

.align 2
lo_leaf_b22_0:
    ret

.align 2
lo_leaf_b22_1:
    ret

.align 2
lo_leaf_b22_2:
    ret

.align 2
lo_leaf_b22_3:
    ret

.align 2
lo_leaf_b22_4:
    ret

.align 2
lo_leaf_b22_5:
    ret

.align 2
lo_leaf_b22_6:
    ret

.align 2
lo_leaf_b22_7:
    ret

.align 2
lo_leaf_b22_8:
    ret

.align 2
lo_leaf_b22_9:
    ret

.align 2
lo_leaf_b22_10:
    ret

.align 2
lo_leaf_b22_11:
    ret

.align 2
lo_leaf_b22_12:
    ret

.align 2
lo_leaf_b22_13:
    ret

.align 2
lo_leaf_b22_14:
    ret

.align 2
lo_leaf_b22_15:
    ret

.align 2
lo_leaf_b23_0:
    ret

.align 2
lo_leaf_b23_1:
    ret

.align 2
lo_leaf_b23_2:
    ret

.align 2
lo_leaf_b23_3:
    ret

.align 2
lo_leaf_b23_4:
    ret

.align 2
lo_leaf_b23_5:
    ret

.align 2
lo_leaf_b23_6:
    ret

.align 2
lo_leaf_b23_7:
    ret

.align 2
lo_leaf_b23_8:
    ret

.align 2
lo_leaf_b23_9:
    ret

.align 2
lo_leaf_b23_10:
    ret

.align 2
lo_leaf_b23_11:
    ret

.align 2
lo_leaf_b23_12:
    ret

.align 2
lo_leaf_b23_13:
    ret

.align 2
lo_leaf_b23_14:
    ret

.align 2
lo_leaf_b23_15:
    ret

.align 2
lo_leaf_b24_0:
    ret

.align 2
lo_leaf_b24_1:
    ret

.align 2
lo_leaf_b24_2:
    ret

.align 2
lo_leaf_b24_3:
    ret

.align 2
lo_leaf_b24_4:
    ret

.align 2
lo_leaf_b24_5:
    ret

.align 2
lo_leaf_b24_6:
    ret

.align 2
lo_leaf_b24_7:
    ret

.align 2
lo_leaf_b24_8:
    ret

.align 2
lo_leaf_b24_9:
    ret

.align 2
lo_leaf_b24_10:
    ret

.align 2
lo_leaf_b24_11:
    ret

.align 2
lo_leaf_b24_12:
    ret

.align 2
lo_leaf_b24_13:
    ret

.align 2
lo_leaf_b24_14:
    ret

.align 2
lo_leaf_b24_15:
    ret

.align 2
lo_leaf_b25_0:
    ret

.align 2
lo_leaf_b25_1:
    ret

.align 2
lo_leaf_b25_2:
    ret

.align 2
lo_leaf_b25_3:
    ret

.align 2
lo_leaf_b25_4:
    ret

.align 2
lo_leaf_b25_5:
    ret

.align 2
lo_leaf_b25_6:
    ret

.align 2
lo_leaf_b25_7:
    ret

.align 2
lo_leaf_b25_8:
    ret

.align 2
lo_leaf_b25_9:
    ret

.align 2
lo_leaf_b25_10:
    ret

.align 2
lo_leaf_b25_11:
    ret

.align 2
lo_leaf_b25_12:
    ret

.align 2
lo_leaf_b25_13:
    ret

.align 2
lo_leaf_b25_14:
    ret

.align 2
lo_leaf_b25_15:
    ret

.align 2
lo_leaf_combo_lo_0:
    ret

.align 2
lo_leaf_combo_lo_1:
    ret

.align 2
lo_leaf_combo_lo_2:
    ret

.align 2
lo_leaf_combo_lo_3:
    ret

.align 2
lo_leaf_combo_lo_4:
    ret

.align 2
lo_leaf_combo_lo_5:
    ret

.align 2
lo_leaf_combo_lo_6:
    ret

.align 2
lo_leaf_combo_lo_7:
    ret

.align 2
lo_leaf_combo_lo_8:
    ret

.align 2
lo_leaf_combo_lo_9:
    ret

.align 2
lo_leaf_combo_lo_10:
    ret

.align 2
lo_leaf_combo_lo_11:
    ret

.align 2
lo_leaf_combo_lo_12:
    ret

.align 2
lo_leaf_combo_lo_13:
    ret

.align 2
lo_leaf_combo_lo_14:
    ret

.align 2
lo_leaf_combo_lo_15:
    ret

.align 2
lo_leaf_combo_hi_0:
    ret

.align 2
lo_leaf_combo_hi_1:
    ret

.align 2
lo_leaf_combo_hi_2:
    ret

.align 2
lo_leaf_combo_hi_3:
    ret

.align 2
lo_leaf_combo_hi_4:
    ret

.align 2
lo_leaf_combo_hi_5:
    ret

.align 2
lo_leaf_combo_hi_6:
    ret

.align 2
lo_leaf_combo_hi_7:
    ret

.align 2
lo_leaf_combo_hi_8:
    ret

.align 2
lo_leaf_combo_hi_9:
    ret

.align 2
lo_leaf_combo_hi_10:
    ret

.align 2
lo_leaf_combo_hi_11:
    ret

.align 2
lo_leaf_combo_hi_12:
    ret

.align 2
lo_leaf_combo_hi_13:
    ret

.align 2
lo_leaf_combo_hi_14:
    ret

.align 2
lo_leaf_combo_hi_15:
    ret

#=============================================================================
# Shared leaf: used by all high-address chains as the innermost call target.
# Placed in .text (low address), but that's fine: what matters for TDF-F
# is the return address of the CALLER (inside the hi_bN section), not the
# address of the leaf itself.
#=============================================================================
.align 2
hi_shared_leaf:
    mv    a0, ra        # return the return-address as a value for signature
    ret

#=============================================================================
# B16 chain: 16-deep nested calls at 0x80010000
# All CALL instructions here push return addresses with bit 16 = 1.
#=============================================================================
.section .hi_b16,"ax",@progbits
.align 2

hi_b16_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b16_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b16_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B17 chain: 16-deep nested calls at 0x80020000
# All CALL instructions here push return addresses with bit 17 = 1.
#=============================================================================
.section .hi_b17,"ax",@progbits
.align 2

hi_b17_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b17_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b17_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B18 chain: 16-deep nested calls at 0x80040000
# All CALL instructions here push return addresses with bit 18 = 1.
#=============================================================================
.section .hi_b18,"ax",@progbits
.align 2

hi_b18_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b18_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b18_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B19 chain: 16-deep nested calls at 0x80080000
# All CALL instructions here push return addresses with bit 19 = 1.
#=============================================================================
.section .hi_b19,"ax",@progbits
.align 2

hi_b19_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b19_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b19_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B20 chain: 16-deep nested calls at 0x80100000
# All CALL instructions here push return addresses with bit 20 = 1.
#=============================================================================
.section .hi_b20,"ax",@progbits
.align 2

hi_b20_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b20_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b20_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B21 chain: 16-deep nested calls at 0x80200000
# All CALL instructions here push return addresses with bit 21 = 1.
#=============================================================================
.section .hi_b21,"ax",@progbits
.align 2

hi_b21_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b21_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b21_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B22 chain: 16-deep nested calls at 0x80400000
# All CALL instructions here push return addresses with bit 22 = 1.
#=============================================================================
.section .hi_b22,"ax",@progbits
.align 2

hi_b22_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b22_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b22_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B23 chain: 16-deep nested calls at 0x80800000
# All CALL instructions here push return addresses with bit 23 = 1.
#=============================================================================
.section .hi_b23,"ax",@progbits
.align 2

hi_b23_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b23_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b23_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B24 chain: 16-deep nested calls at 0x81000000
# All CALL instructions here push return addresses with bit 24 = 1.
#=============================================================================
.section .hi_b24,"ax",@progbits
.align 2

hi_b24_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b24_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b24_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# B25 chain: 16-deep nested calls at 0x82000000
# All CALL instructions here push return addresses with bit 25 = 1.
#=============================================================================
.section .hi_b25,"ax",@progbits
.align 2

hi_b25_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n2
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n3
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n4
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n5
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n6
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n7
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n8
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n9
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n10
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n11
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n12
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n13
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n14
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n15
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_b25_n16
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_b25_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra    # accumulate RA into signature
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# COMBO_LO chain: 16-deep at 0x800F0000 (bits 16+17+18+19 all set)
#=============================================================================
.section .hi_combo_lo,"ax",@progbits
.align 2

hi_combo_lo_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n2
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n3
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n4
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n5
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n6
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n7
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n8
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n9
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n10
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n11
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n12
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n13
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n14
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n15
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_lo_n16
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_lo_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

#=============================================================================
# COMBO_HI chain: 16-deep at 0x80F00000 (bits 20+21+22+23 all set)
#=============================================================================
.section .hi_combo_hi,"ax",@progbits
.align 2

hi_combo_hi_n1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n2
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n3
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n4
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n5
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n6
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n7
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n8
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n9
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n9:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n10
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n10:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n11
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n11:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n12
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n12:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n13
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n13:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n14
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n14:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n15
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n15:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_combo_hi_n16
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

hi_combo_hi_n16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  hi_shared_leaf
    xor   a0, a0, ra
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret
