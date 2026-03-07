##############################################################################
# sbst3.S  --  RAS Predictor (10 entries, RAS_SIZE = 10)
#
# Phase 1: 10-deep chain in .ras_walk_t3
# Phase 2: 10-deep chain in .ras_fill_t3
# Phase 3: RAS overflow/underflow (11 pushes)
# Phase 4: verifies RAS is NOT pushed (jalr rd=x0)
# Phase 5: Forced mismatch pairs
# Phase 6: alternating push/pop pairs (TDF-F / TDF-R)
# Phase 7: RAS upper-bit SA-0 + TDF-F for high bits
#
##############################################################################

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

    li    s11, 0    # accumulator

    
    # 1: 10-deep chain (return addresses 0x80008xxx)
    jal   ra, chain0_site_0

    # HPM counters after Phase 1
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09
    xor   s11, s11, t3
    xor   s11, s11, t4
    xor   s11, s11, t5
    xor   s11, s11, t6
    xor   s11, s11, s2
    xor   s11, s11, s3
    xor   s11, s11, s4
    xor   s11, s11, s5

    # 2: 10-deep chain, (return addresses in 0x80040xxx)
    jal   ra, chain1_site_0

    # HPM counters after Phase 2
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09
    xor   s11, s11, t3
    xor   s11, s11, t4
    xor   s11, s11, t5
    xor   s11, s11, t6
    xor   s11, s11, s2
    xor   s11, s11, s3
    xor   s11, s11, s4
    xor   s11, s11, s5

    # CSR mscratch
    csrw  mscratch, s3
    csrr  t0, mscratch
    xor   s11, s11, t0
    slli  s3, s3, 1
    addi  s5, s5, 1
    li    s7, 32
    csrw  mscratch, zero

    # 3: RAS overflow + underflow
    # 11 nested calls overflow the 10-entry RAS (ptr wraps 9->0)
    # 11 nested rets then underflow (ptr wraps 0->9)
    call  p7_push11_start
    xor   s11, s11, ra

    # HPM counters after Phase 3
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09
    xor   s11, s11, t3
    xor   s11, s11, t4
    xor   s11, s11, t5
    xor   s11, s11, t6
    xor   s11, s11, s2
    xor   s11, s11, s3
    xor   s11, s11, s4
    xor   s11, s11, s5

    # 4: JALR rd=x0 - RAS must not be pushed
    la    t0, jalr_tgtA
    jalr  x0, t0, 0     # Way to push on RAS

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

    # HPM counters after Phase 4
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09
    xor   s11, s11, t3
    xor   s11, s11, t4
    xor   s11, s11, t5
    xor   s11, s11, t6
    xor   s11, s11, s2
    xor   s11, s11, s3
    xor   s11, s11, s4
    xor   s11, s11, s5

    # 5: Forced mismatch - exercises mismatch comparator
    jal   ra, mm_leaf0
    la    ra, mm_dst0
    ret

mm_poison0: 
    addi s11, s11, 0x1FF

mm_dst0:
    addi s11, s11, 0x101
    jal   ra, mm_leaf1
    la    ra, mm_dst1
    ret
mm_poison1: 
    addi s11, s11, 0x1FF

mm_dst1:
    addi s11, s11, 0x102
    jal   ra, mm_leaf2
    la    ra, mm_dst2
    ret

mm_poison2: 
    addi s11, s11, 0x1FF

mm_dst2:
    addi s11, s11, 0x103
    jal   ra, mm_leaf3
    la    ra, mm_dst3
    ret

mm_poison3:
    addi s11, s11, 0x1FF
mm_dst3:
    addi s11, s11, 0x104

    # HPM counters after Phase 5
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09
    xor   s11, s11, t3
    xor   s11, s11, t4
    xor   s11, s11, t5
    xor   s11, s11, t6
    xor   s11, s11, s2
    xor   s11, s11, s3
    xor   s11, s11, s4
    xor   s11, s11, s5

    # 6: TDF-F / TDF-R - alternating push/pop pairs
    # For each pair i (0 through 9)
    call  p6_call_a0

p6_ret_a0:              # RAS[0] = &p6_ret_aI  (bit pattern A)
    xor   s11, s11, ra  # ra = &p6_ret_aI after ret
    call  p6_call_b0

p6_ret_b0:              # RAS[0] = &p6_ret_bI  (bit pattern B)
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
    xor   s11, s11, ra  # After 10 pairs every RAS entry has been written with both patterns

    # HPM counters after Phase 6
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09
    xor   s11, s11, t3
    xor   s11, s11, t4
    xor   s11, s11, t5
    xor   s11, s11, t6
    xor   s11, s11, s2
    xor   s11, s11, s3
    xor   s11, s11, s4
    xor   s11, s11, s5

    # 7: RAS upper-bit SA-0 + TDF-F for bits 16 through 25
    # For each bit in 16..25:

    # bit 16 (0x80010000)
    call  hi_b16_n1         # Step 1: 10-deep chain placed
    xor   s11, s11, a0
    # Step 2: 10 distinct low-addr leaf calls
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
    call  hi_b16_n1         # Step 3: fill again with the hi chain
    xor   s11, s11, a0

    # bit 17 (0x80020000)
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

    # bit 18 (0x80040000)
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

    # bit 19 (0x80080000)
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

    # bit 20 (0x80100000)
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

    # bit 21 (0x80200000)
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

    # bit 22 (0x80400000)
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

    # bit 23 (0x80800000)
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

    # bit 24 (0x81000000)
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

    # bit 25 (0x82000000)
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

    # HPM counters after Phase 7
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09
    xor   s11, s11, t3
    xor   s11, s11, t4
    xor   s11, s11, t5
    xor   s11, s11, t6
    xor   s11, s11, s2
    xor   s11, s11, s3
    xor   s11, s11, s4
    xor   s11, s11, s5

    # return accumulated signature
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


# Stubs for sections 4 and 5
ras_jalr_probe:     ret
mm_leaf0:           ret
mm_leaf1:           ret
mm_leaf2:           ret
mm_leaf3:           ret


# Section 6 stubs
# placed in dedicated sections so the assembler/linker maps a- and b-variants to addresses that differ in bit 2
.section .p6a0,"ax", @progbits
.align 2
p6_call_a0: ret

.section .p6b0,"ax", @progbits
.align 4        # guarantees bit 2 differs vs a0
p6_call_b0: ret

.section .p6a1,"ax", @progbits
.align 2
p6_call_a1: ret

.section .p6b1,"ax", @progbits
.align 4
p6_call_b1: ret

.section .p6a2,"ax", @progbits
.align 2
p6_call_a2: ret

.section .p6b2,"ax", @progbits
.align 4
p6_call_b2: ret

.section .p6a3,"ax", @progbits
.align 2
p6_call_a3: ret

.section .p6b3,"ax", @progbits
.align 4
p6_call_b3: ret

.section .p6a4,"ax", @progbits
.align 2
p6_call_a4: ret

.section .p6b4,"ax", @progbits
.align 4
p6_call_b4: ret

.section .p6a5,"ax", @progbits
.align 2
p6_call_a5: ret

.section .p6b5,"ax", @progbits
.align 4
p6_call_b5: ret

.section .p6a6,"ax", @progbits
.align 2
p6_call_a6: ret

.section .p6b6,"ax", @progbits
.align 4
p6_call_b6: ret

.section .p6a7,"ax", @progbits
.align 2
p6_call_a7: ret

.section .p6b7,"ax", @progbits
.align 4
p6_call_b7: ret

.section .p6a8,"ax", @progbits
.align 2
p6_call_a8: ret

.section .p6b8,"ax", @progbits
.align 4
p6_call_b8: ret

.section .p6a9,"ax", @progbits
.align 2
p6_call_a9: ret

.section .p6b9,"ax", @progbits
.align 4
p6_call_b9: ret


# Section 3: overflow + underflow of 10-entry RAS
.section .text
p7_push11_start:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    call  p7_d1
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

.section .p7_1,"ax", @progbits
.align 2
p7_d1:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d2
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_2,"ax", @progbits
.align 2
p7_d2:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d3
    lw ra,0(sp)
    addi sp,sp,4
    ret
    
.section .p7_3,"ax", @progbits
.align 2
p7_d3:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d4
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_4,"ax", @progbits
.align 2
p7_d4:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d5
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_5,"ax", @progbits
.align 2
p7_d5:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d6
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_6,"ax", @progbits
.align 2
p7_d6:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d7
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_7,"ax", @progbits
.align 2
p7_d7:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d8
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_8,"ax", @progbits
.align 2
p7_d8:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d9
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_9,"ax", @progbits
.align 2
p7_d9:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d10
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_10,"ax", @progbits
.align 2
p7_d10:
    addi sp,sp,-4
    sw ra,0(sp)
    call p7_d11
    lw ra,0(sp)
    addi sp,sp,4
    ret

.section .p7_11,"ax", @progbits
.align 2
p7_d11: ret    # leaf: unwind starts here (11th push -> ptr wrapped 9->0)


# Section 1: .ras_walk_t3
.section .ras_walk_t3, "ax", @progbits
.align 2

chain0_site_0:
    addi  sp,  sp,  -4
    sw    ra,   0(sp)
    jal   ra,  chain0_site_1
chain0_land_0:
    lw    ra,   0(sp)               # landing pad
    addi  sp,  sp,   4
    addi  s11, s11,  2              # P_0 = 2 (unique prime)
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


# Section 2: .ras_fill_t3
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


# Section 7: high-address chains + low-address cleanup leaves
.section .text
hi_shared_leaf: ret

# low-address leaves (10 per bit)
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

# hi_b chains

# bit 16: placed at 0x80011000
.section .hi_b16,"ax", @progbits
.align 2
hi_b16_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n2
    xor a0,a0,ra    # initializies a0 = ra (first XOR seed)
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n3
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b16_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b16_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 17: placed at 0x80022000
.section .hi_b17,"ax", @progbits
.align 2
hi_b17_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b17_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b17_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 18: placed at 0x80070000
.section .hi_b18,"ax", @progbits
.align 2
hi_b18_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b18_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b18_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 19: placed at 0x80080000
.section .hi_b19,"ax", @progbits
.align 2
hi_b19_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b19_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b19_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 20: placed at 0x80100000
.section .hi_b20,"ax", @progbits
.align 2
hi_b20_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b20_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b20_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 21: placed at 0x80200000
.section .hi_b21,"ax", @progbits
.align 2
hi_b21_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b21_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b21_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 22: placed at 0x80400000
.section .hi_b22,"ax", @progbits
.align 2
hi_b22_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b22_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b22_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 23: placed at 0x80800000
.section .hi_b23,"ax", @progbits
.align 2
hi_b23_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b23_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b23_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 24: placed at 0x81000000
.section .hi_b24,"ax", @progbits
.align 2
hi_b24_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b24_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b24_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret

# bit 25: placed at 0x82000000
.section .hi_b25,"ax", @progbits
.align 2
hi_b25_n1:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n2
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n2:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n3
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n3:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n4
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n4:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n5
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n5:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n6
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n6:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n7
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n7:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n8
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n8:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n9
     xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n9:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_b25_n10
    xor a0,a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret
hi_b25_n10:
    addi sp,sp,-4
    sw ra,0(sp)
    call hi_shared_leaf
    mv a0,ra
    lw ra,0(sp)
    addi sp,sp,4
    ret