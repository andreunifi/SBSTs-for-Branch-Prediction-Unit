##############################################################################
# sbst5.S  --  Full RASPredictor + BTB + IEUAdrWReg + forwarding
#
# Original phases 1-5 kept intact.
# [NEW] Phase 6: EX->EX forwarding chain for all ALU operations
# [NEW] Phase 7: Shift-amount forwarding (shift amount from register result)
# [NEW] Phase 8: mepc/mtval/mscratch write walking-1 (new CSR address bits)
##############################################################################

.section .text
.global test5
.type   test5, @function

test5:
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

    li    s11, 0xBA5E0000
    csrr  s1, hpmcounter4
    csrr  s2, hpmcounter5

    # ===========================================================
    # PHASE 1: Deep recursive RAS fill (16 levels)
    # ===========================================================
    li    a0, 0;  li a1, 16
    call  ras_t5_deep

    # ===========================================================
    # PHASE 2: RAS walking-1 on bits [14:2]
    # ===========================================================
    la    s10, test5_ras_done
    j     ras_t5_walk

test5_ras_done:
    xor   s11, s11, ra

    # ===========================================================
    # PHASE 3: BTB target walking-1 on bits [14:2]
    # ===========================================================
    la s9, btb5_b2_r1;   jal x0, btb_stub_bit2
btb5_b2_r1:
    la s9, btb5_b2_r2;   jal x0, btb_stub_bit2
btb5_b2_r2:
    la s9, btb5_b3_r1;   jal x0, btb_stub_bit3
btb5_b3_r1:
    la s9, btb5_b3_r2;   jal x0, btb_stub_bit3
btb5_b3_r2:
    la s9, btb5_b4_r1;   jal x0, btb_stub_bit4
btb5_b4_r1:
    la s9, btb5_b4_r2;   jal x0, btb_stub_bit4
btb5_b4_r2:
    la s9, btb5_b5_r1;   jal x0, btb_stub_bit5
btb5_b5_r1:
    la s9, btb5_b5_r2;   jal x0, btb_stub_bit5
btb5_b5_r2:
    la s9, btb5_b6_r1;   jal x0, btb_stub_bit6
btb5_b6_r1:
    la s9, btb5_b6_r2;   jal x0, btb_stub_bit6
btb5_b6_r2:
    la s9, btb5_b7_r1;   jal x0, btb_stub_bit7
btb5_b7_r1:
    la s9, btb5_b7_r2;   jal x0, btb_stub_bit7
btb5_b7_r2:
    la s9, btb5_b8_r1;   jal x0, btb_stub_bit8
btb5_b8_r1:
    la s9, btb5_b8_r2;   jal x0, btb_stub_bit8
btb5_b8_r2:
    la s9, btb5_b9_r1;   jal x0, btb_stub_bit9
btb5_b9_r1:
    la s9, btb5_b9_r2;   jal x0, btb_stub_bit9
btb5_b9_r2:
    la s9, btb5_b10_r1;  jal x0, btb_stub_bit10
btb5_b10_r1:
    la s9, btb5_b10_r2;  jal x0, btb_stub_bit10
btb5_b10_r2:
    la s9, btb5_b11_r1;  jal x0, btb_stub_bit11
btb5_b11_r1:
    la s9, btb5_b11_r2;  jal x0, btb_stub_bit11
btb5_b11_r2:
    la s9, btb5_b12_r1;  jal x0, btb_stub_bit12
btb5_b12_r1:
    la s9, btb5_b12_r2;  jal x0, btb_stub_bit12
btb5_b12_r2:
    la s9, btb5_b13_r1;  jal x0, btb_stub_bit13
btb5_b13_r1:
    la s9, btb5_b13_r2;  jal x0, btb_stub_bit13
btb5_b13_r2:
    la s9, btb5_b14_r1;  jal x0, btb_stub_bit14
btb5_b14_r1:
    la s9, btb5_b14_r2;  jal x0, btb_stub_bit14
btb5_b14_r2:

    # ===========================================================
    # PHASE 4: JALR walking-1 on bits [14:2] of IEUAdrWReg
    # ===========================================================
    la t0, btb_stub_bit2
    la s9, jalr5_b2_r1;  jalr x0, t0, 0
jalr5_b2_r1:
    la s9, jalr5_b2_r2;  jalr x0, t0, 0
jalr5_b2_r2:
    la t0, btb_stub_bit3
    la s9, jalr5_b3_r1;  jalr x0, t0, 0
jalr5_b3_r1:
    la s9, jalr5_b3_r2;  jalr x0, t0, 0
jalr5_b3_r2:
    la t0, btb_stub_bit4
    la s9, jalr5_b4_r1;  jalr x0, t0, 0
jalr5_b4_r1:
    la s9, jalr5_b4_r2;  jalr x0, t0, 0
jalr5_b4_r2:
    la t0, btb_stub_bit5
    la s9, jalr5_b5_r1;  jalr x0, t0, 0
jalr5_b5_r1:
    la s9, jalr5_b5_r2;  jalr x0, t0, 0
jalr5_b5_r2:
    la t0, btb_stub_bit6
    la s9, jalr5_b6_r1;  jalr x0, t0, 0
jalr5_b6_r1:
    la s9, jalr5_b6_r2;  jalr x0, t0, 0
jalr5_b6_r2:
    la t0, btb_stub_bit7
    la s9, jalr5_b7_r1;  jalr x0, t0, 0
jalr5_b7_r1:
    la s9, jalr5_b7_r2;  jalr x0, t0, 0
jalr5_b7_r2:
    la t0, btb_stub_bit8
    la s9, jalr5_b8_r1;  jalr x0, t0, 0
jalr5_b8_r1:
    la s9, jalr5_b8_r2;  jalr x0, t0, 0
jalr5_b8_r2:
    la t0, btb_stub_bit9
    la s9, jalr5_b9_r1;  jalr x0, t0, 0
jalr5_b9_r1:
    la s9, jalr5_b9_r2;  jalr x0, t0, 0
jalr5_b9_r2:
    la t0, btb_stub_bit10
    la s9, jalr5_b10_r1; jalr x0, t0, 0
jalr5_b10_r1:
    la s9, jalr5_b10_r2; jalr x0, t0, 0
jalr5_b10_r2:
    la t0, btb_stub_bit11
    la s9, jalr5_b11_r1; jalr x0, t0, 0
jalr5_b11_r1:
    la s9, jalr5_b11_r2; jalr x0, t0, 0
jalr5_b11_r2:
    la t0, btb_stub_bit12
    la s9, jalr5_b12_r1; jalr x0, t0, 0
jalr5_b12_r1:
    la s9, jalr5_b12_r2; jalr x0, t0, 0
jalr5_b12_r2:
    la t0, btb_stub_bit13
    la s9, jalr5_b13_r1; jalr x0, t0, 0
jalr5_b13_r1:
    la s9, jalr5_b13_r2; jalr x0, t0, 0
jalr5_b13_r2:
    la t0, btb_stub_bit14
    la s9, jalr5_b14_r1; jalr x0, t0, 0
jalr5_b14_r1:
    la s9, jalr5_b14_r2; jalr x0, t0, 0
jalr5_b14_r2:

    # ===========================================================
    # PHASE 5: RAS overflow (20 levels)
    # ===========================================================
    li    a0, 0;  li a1, 20
    call  ras_t5_overflow

    # ===========================================================
    # [NEW] PHASE 6: EX->EX FORWARDING CHAIN
    # Every ALU op type back-to-back to exercise all forward paths
    # ===========================================================
    li   t0, 0x13572468
    add  t1, t0, t0             # t1 = 2*t0
    sub  t2, t1, t0             # t2 = t0  (EX->EX sub)
    and  t3, t1, t2             # EX->EX and
    or   t4, t2, t3             # EX->EX or
    xor  t5, t4, t3             # EX->EX xor
    slt  t6, t0, t1             # EX->EX slt (compare forwarded)
    sltu a5, t2, t1             # EX->EX sltu
    add  a6, t5, t6             # EX->EX add from slt result
    xor  s11, s11, t1
    xor  s11, s11, t5
    xor  s11, s11, a6

    # ===========================================================
    # [NEW] PHASE 7: SHIFT-AMOUNT FORWARDING
    # Shift amount comes from forwarded ALU result (tests shift-amount mux)
    # ===========================================================
    li   t0, 0xDEADBEEF
    li   t1, 3
    add  t2, t1, t1             # t2 = 6  (forwarded)
    sll  t3, t0, t2             # shift by forwarded value 6
    srl  t4, t0, t2             # EX->EX on t2
    sra  t5, t0, t2             # EX->EX on t2
    add  t6, t3, t4
    xor  s11, s11, t3
    xor  s11, s11, t5
    xor  s11, s11, t6

    # All 32 shift amounts driven through forwarding
    li   s3, 0
sh5_loop:
    add  t0, s3, zero           # forward: shift_amount = s3
    sll  t1, t6, t0             # use forwarded shift amount
    srl  t2, t6, t0
    sra  t3, t6, t0
    xor  s11, s11, t1
    xor  s11, s11, t2
    xor  s11, s11, t3
    addi s3, s3, 1
    li   s7, 32
    blt  s3, s7, sh5_loop

    # ===========================================================
    # [NEW] PHASE 8: CSR WRITE / READ-BACK (new address bits)
    # mhpmevent15..20 exercises higher CSR address bits
    # ===========================================================
    li   t0, 0xDEADC0DE
    csrw 0x32F, t0;  csrr t1, 0x32F;  xor s11, s11, t1   # mhpmevent16
    li   t0, 0xBEEFBEEF
    csrw 0x330, t0;  csrr t1, 0x330;  xor s11, s11, t1   # mhpmevent17
    li   t0, 0xCAFEBABE
    csrw 0x331, t0;  csrr t1, 0x331;  xor s11, s11, t1   # mhpmevent18
    # Clear
    csrw 0x32F, zero;  csrw 0x330, zero;  csrw 0x331, zero

    # mcountinhibit: inhibit bits for counters (walking-1 on low 5 bits)
    li   t0, 1
    li   s5, 0
cinh_loop:
    csrw 0x320, t0             # mcountinhibit
    csrr t1, 0x320
    xor  s11, s11, t1
    slli t0, t0, 1
    addi s5, s5, 1
    li   s7, 5
    blt  s5, s7, cinh_loop
    csrw 0x320, zero           # clear inhibit

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

ras_t5_deep:
    addi  sp, sp, -4;  sw ra, 0(sp)
    addi  a0, a0, 1
    bge   a0, a1, ras_t5_deep_base
    call  ras_t5_deep
ras_t5_deep_base:
    lw    ra, 0(sp);  addi sp, sp, 4;  ret

ras_t5_overflow:
    addi  sp, sp, -4;  sw ra, 0(sp)
    addi  a0, a0, 1
    bge   a0, a1, ras_t5_ov_base
    call  ras_t5_overflow
ras_t5_ov_base:
    lw    ra, 0(sp);  addi sp, sp, 4;  ret


.section .ras_walk_t5, "ax", @progbits
.balign 32768

ras_t5_walk:
    jal   ra, ras_t5_leaf_w         # bit  2
    jal   ra, ras_t5_leaf_w         # bit  3
    nop
    jal   ra, ras_t5_leaf_w         # bit  4
    j     ras_t5_w5;  .fill 2, 4, 0x00000013
ras_t5_w5:
    jal   ra, ras_t5_leaf_w         # bit  5
    j     ras_t5_w6;  .fill 6, 4, 0x00000013
ras_t5_w6:
    jal   ra, ras_t5_leaf_w         # bit  6
    j     ras_t5_w7;  .fill 14, 4, 0x00000013
ras_t5_w7:
    jal   ra, ras_t5_leaf_w         # bit  7
    j     ras_t5_w8;  .fill 30, 4, 0x00000013
ras_t5_w8:
    jal   ra, ras_t5_leaf_w         # bit  8
    j     ras_t5_w9;  .fill 62, 4, 0x00000013
ras_t5_w9:
    jal   ra, ras_t5_leaf_w         # bit  9
    j     ras_t5_w10; .fill 126, 4, 0x00000013
ras_t5_w10:
    jal   ra, ras_t5_leaf_w         # bit 10
    j     ras_t5_w11; .fill 254, 4, 0x00000013
ras_t5_w11:
    jal   ra, ras_t5_leaf_w         # bit 11
    j     ras_t5_w12; .fill 510, 4, 0x00000013
ras_t5_w12:
    jal   ra, ras_t5_leaf_w         # bit 12
    j     ras_t5_w13; .fill 1022, 4, 0x00000013
ras_t5_w13:
    jal   ra, ras_t5_leaf_w         # bit 13
    j     ras_t5_w14; .fill 2046, 4, 0x00000013
ras_t5_w14:
    jal   ra, ras_t5_leaf_w         # bit 14
    jr    s10

ras_t5_leaf_w:
    ret


.section .btb_walk_t5, "ax", @progbits
.balign 32768
    .fill 1, 4, 0x00000013
btb_stub_bit2:  jr s9
btb_stub_bit3:  jr s9
    .fill 1, 4, 0x00000013
btb_stub_bit4:  jr s9          # 0x0010
    .fill 3, 4, 0x00000013
btb_stub_bit5:  jr s9          # 0x0020
    .fill 7, 4, 0x00000013
btb_stub_bit6:  jr s9          # 0x0040
    .fill 15, 4, 0x00000013
btb_stub_bit7:  jr s9          # 0x0080
    .fill 31, 4, 0x00000013
btb_stub_bit8:  jr s9          # 0x0100
    .fill 63, 4, 0x00000013
btb_stub_bit9:  jr s9          # 0x0200
    .fill 127, 4, 0x00000013
btb_stub_bit10: jr s9          # 0x0400
    .fill 255, 4, 0x00000013
btb_stub_bit11: jr s9          # 0x0800
    .fill 511, 4, 0x00000013
btb_stub_bit12: jr s9          # 0x1000
    .fill 1023, 4, 0x00000013
btb_stub_bit13: jr s9          # 0x2000
    .fill 2047, 4, 0x00000013
btb_stub_bit14: jr s9          # 0x4000
