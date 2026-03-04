##############################################################################
# sbst7.S  --  RASPredictor TDF coverage + PtrMux wraparound + icpred
#
# ROOT CAUSE ANALYSIS (from cvw_coverage_hierarchical.sff):
#   - RAS memory bits 1-31: 37.5% ND (3/8 faults each) -> TDF-F not covered
#     The 3 ND faults per cell are the 1->0 transition (TDF-F) faults because
#     sbst1-6 only PUSH then POP sequentially, never alternating:
#     push(bit=1) -> pop -> push(bit=0 same slot) -> pop
#   - PtrMux: 21.88% ND + 25% UU -> pointer wraparound not exercised
#     Need: push exactly 16 (full), push 17th (wrap to 0), pop 17 times
#   - icpred: 12.24% ND -> JALR with computed targets not varied enough
#
# PHASE 1: RAS TDF-F coverage
#   Alternating push/pop sequence: writes 1 to a bit, pops, writes 0 to
#   same RAS slot, pops. This exercises the 1->0 transition in each cell.
#
# PHASE 2: PtrMux full wraparound
#   Push 17 calls (overflow 16-entry RAS), pop 17 times.
#   Exercises pointer 15->0 wrap (push overflow) and 0->15 wrap (pop underflow).
#
# PHASE 3: icpred - JALR with many distinct computed targets
#   Uses a jump table via JALR to exercise indirect call predictor cells.
#
# PHASE 4: RAS interleaved write pattern
#   Fills all 16 RAS entries with alternating bit patterns (0xAAAAAAAA and
#   0x55555555 relative to base), forces TDF-R and TDF-F on all bit positions.
#
# SIGNATURE: a0 = s11 (XOR accumulator)
##############################################################################

.section .text
.global test7
.type   test7, @function

test7:
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

    li    s11, 0                # global signature

    #=========================================================================
    # PHASE 1: RAS TDF-F / TDF-R coverage via alternating push/pop
    #
    # Pattern: call A (push addr_A, bit N=1), ret (pop addr_A),
    #          call B (push addr_B, bit N=0 in same RAS slot), ret (pop addr_B)
    #
    # This writes 1->0 to the same RAS entry, detecting TDF-F.
    # We repeat this for 32 pairs covering all 16 RAS slots twice.
    #=========================================================================

    # Pair 0: call_hi1 (returns to next instr with specific bit pattern),
    #         then call_lo1 (different pattern into same RAS slot 0)
    call  p1_call_a0        # push: RAS[0] = &p1_ret_a0
p1_ret_a0:
    xor   s11, s11, ra
    call  p1_call_b0        # push: RAS[0] = &p1_ret_b0 (overwrites after pop)
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

    #=========================================================================
    # PHASE 2: PtrMux full wraparound
    #
    # Push 17 entries into the 16-entry RAS → forces ptr 15 -> 0 (overflow).
    # Then pop 17 times → forces ptr 0 -> 15 (underflow).
    # This exercises both PtrMux wrap conditions that are currently UU.
    #=========================================================================

    call  p2_push17_start

    # After 17 nested returns, we come back here.
    xor   s11, s11, ra

    #=========================================================================
    # PHASE 3: icpred - JALR with many computed targets (jump table)
    #
    # Each JALR uses a different base register value, exercising different
    # cells of the indirect call predictor BTB-like structure.
    #=========================================================================
    la    t0, jtable          # base of jump table
    li    s5, 0
    li    s7, 16              # 16 entries in jump table

p3_loop:
    slli  t1, s5, 2           # offset = index * 4
    add   t2, t0, t1          # &jtable[i]
    lw    t3, 0(t2)           # target address
    jalr  ra, t3, 0           # indirect call -> exercises icpred
    xor   s11, s11, a0        # accumulate return value
    addi  s5, s5, 1
    blt   s5, s7, p3_loop

    #=========================================================================
    # PHASE 4: RAS interleaved write - fills all 16 slots with addresses
    # whose bits alternate 0/1 at each position.
    # We use a 16-deep nested call that unwinds back automatically.
    #=========================================================================

    call  p4_nest16

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
# PHASE 1 stubs: 16 pairs (a=diverse bit pattern, b=complementary pattern)
# Each pair is placed in its own section so linker maps them to different
# addresses, ensuring each return address has a distinct bit pattern.
#=============================================================================

.section .p1a0,"ax",@progbits
.align 2
p1_call_a0: ret

.section .p1b0,"ax",@progbits
.align 4          # 4-byte offset from a0 -> bit 2 changes
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

#=============================================================================
# PHASE 2: 17-deep nested call to overflow 16-entry RAS
# Each level pushes its return address; at depth 17 we unwind.
# The .p2_N sections are spread apart so addresses vary in bits 4-11.
#=============================================================================

.section .text
p2_push17_start:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p2_d1
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

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
p2_d10: addi sp,sp,-4; sw ra,0(sp); call p2_d11; lw ra,0(sp); addi sp,sp,4; ret
.section .p2_11,"ax",@progbits
.align 2
p2_d11: addi sp,sp,-4; sw ra,0(sp); call p2_d12; lw ra,0(sp); addi sp,sp,4; ret
.section .p2_12,"ax",@progbits
.align 2
p2_d12: addi sp,sp,-4; sw ra,0(sp); call p2_d13; lw ra,0(sp); addi sp,sp,4; ret
.section .p2_13,"ax",@progbits
.align 2
p2_d13: addi sp,sp,-4; sw ra,0(sp); call p2_d14; lw ra,0(sp); addi sp,sp,4; ret
.section .p2_14,"ax",@progbits
.align 2
p2_d14: addi sp,sp,-4; sw ra,0(sp); call p2_d15; lw ra,0(sp); addi sp,sp,4; ret
.section .p2_15,"ax",@progbits
.align 2
p2_d15: addi sp,sp,-4; sw ra,0(sp); call p2_d16; lw ra,0(sp); addi sp,sp,4; ret
.section .p2_16,"ax",@progbits
.align 2
p2_d16: addi sp,sp,-4; sw ra,0(sp); call p2_d17; lw ra,0(sp); addi sp,sp,4; ret
.section .p2_17,"ax",@progbits
.align 2
p2_d17: ret                 # leaf: unwind starts here (ptr 0->-1 wraps to 15)

#=============================================================================
# PHASE 3: jump table (16 entries -> 16 simple leaf functions)
#=============================================================================

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
jt_leaf0:  li a0, 0x13579BDF; ret
.section .jt1,"ax",@progbits
.align 2
jt_leaf1:  li a0, 0x2468ACE0; ret
.section .jt2,"ax",@progbits
.align 2
jt_leaf2:  li a0, 0xFDB97531; ret
.section .jt3,"ax",@progbits
.align 2
jt_leaf3:  li a0, 0xECA86420; ret
.section .jt4,"ax",@progbits
.align 2
jt_leaf4:  li a0, 0x0F0F0F0F; ret
.section .jt5,"ax",@progbits
.align 2
jt_leaf5:  li a0, 0xF0F0F0F0; ret
.section .jt6,"ax",@progbits
.align 2
jt_leaf6:  li a0, 0x00FF00FF; ret
.section .jt7,"ax",@progbits
.align 2
jt_leaf7:  li a0, 0xFF00FF00; ret
.section .jt8,"ax",@progbits
.align 2
jt_leaf8:  li a0, 0x0000FFFF; ret
.section .jt9,"ax",@progbits
.align 2
jt_leaf9:  li a0, 0xFFFF0000; ret
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

#=============================================================================
# PHASE 4: 16-deep nested call, each level in its own section
# Leaf accumulates return addresses into a0 as it unwinds.
# Sections spread across address space so bits 4-15 of RA vary.
#=============================================================================

.section .text
p4_nest16:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p4_n1
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

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
    # leaf: return address XOR chain starts here
    mv    a0, ra
    ret
