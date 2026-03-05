##############################################################################
# sbst3.S  --  Functional signature test (all paths through the IEU)
#
# Keeps the original BTB/branch/RAS/JALR structure from sbst2 but with
# signature accumulation. Adds:
#   - Byte / halfword load-store with signature
#   - CSR write / read-back with signature
#   - Diverse ALU operations (neg, not, slt corner cases)
#   - Store-address walking (different offset bits)
#
# SIGNATURE: a0 = s11 at end (deterministic XOR/ADD chain)
##############################################################################

.section .text
.global test3
.type test3, @function

test3:
    addi sp, sp, -112
    sw ra,  104(sp)
    sw s0,   96(sp)
    sw s1,   88(sp)
    sw s2,   80(sp)
    sw s3,   72(sp)
    sw s4,   64(sp)
    sw s5,   56(sp)
    sw s6,   48(sp)
    sw s7,   40(sp)
    sw s8,   32(sp)
    sw s9,   24(sp)
    sw s10,  16(sp)
    sw s11,   8(sp)
    addi s0, sp, 112

    li s11, 0x12345678

    # ---- BTB sled (same 64-jump chain, adds to signature) ----
    j btb_00
btb_00: addi s11, s11, 1;    j btb_01
btb_01: addi s11, s11, 2;    j btb_02
btb_02: addi s11, s11, 3;    j btb_03
btb_03: addi s11, s11, 5;    j btb_04
btb_04: addi s11, s11, 7;    j btb_05
btb_05: addi s11, s11, 11;   j btb_06
btb_06: addi s11, s11, 13;   j btb_07
btb_07: addi s11, s11, 17;   j btb_08
btb_08: addi s11, s11, 19;   j btb_09
btb_09: addi s11, s11, 23;   j btb_10
btb_10: addi s11, s11, 29;   j btb_11
btb_11: addi s11, s11, 31;   j btb_12
btb_12: addi s11, s11, 37;   j btb_13
btb_13: addi s11, s11, 41;   j btb_14
btb_14: addi s11, s11, 43;   j btb_15
btb_15: addi s11, s11, 47;   j btb_16
btb_16: addi s11, s11, 53;   j btb_17
btb_17: addi s11, s11, 59;   j btb_18
btb_18: addi s11, s11, 61;   j btb_19
btb_19: addi s11, s11, 67;   j btb_20
btb_20: addi s11, s11, 71;   j btb_21
btb_21: addi s11, s11, 73;   j btb_22
btb_22: addi s11, s11, 79;   j btb_23
btb_23: addi s11, s11, 83;   j btb_24
btb_24: addi s11, s11, 89;   j btb_25
btb_25: addi s11, s11, 97;   j btb_26
btb_26: addi s11, s11, 101;  j btb_27
btb_27: addi s11, s11, 103;  j btb_28
btb_28: addi s11, s11, 107;  j btb_29
btb_29: addi s11, s11, 109;  j btb_30
btb_30: addi s11, s11, 113;  j btb_31
btb_31: addi s11, s11, 127;  j btb_32
btb_32: addi s11, s11, 131;  j btb_33
btb_33: addi s11, s11, 137;  j btb_34
btb_34: addi s11, s11, 139;  j btb_35
btb_35: addi s11, s11, 149;  j btb_36
btb_36: addi s11, s11, 151;  j btb_37
btb_37: addi s11, s11, 157;  j btb_38
btb_38: addi s11, s11, 163;  j btb_39
btb_39: addi s11, s11, 167;  j btb_40
btb_40: addi s11, s11, 173;  j btb_41
btb_41: addi s11, s11, 179;  j btb_42
btb_42: addi s11, s11, 181;  j btb_43
btb_43: addi s11, s11, 191;  j btb_44
btb_44: addi s11, s11, 193;  j btb_45
btb_45: addi s11, s11, 197;  j btb_46
btb_46: addi s11, s11, 199;  j btb_47
btb_47: addi s11, s11, 211;  j btb_48
btb_48: addi s11, s11, 223;  j btb_49
btb_49: addi s11, s11, 227;  j btb_50
btb_50: addi s11, s11, 229;  j btb_51
btb_51: addi s11, s11, 233;  j btb_52
btb_52: addi s11, s11, 239;  j btb_53
btb_53: addi s11, s11, 241;  j btb_54
btb_54: addi s11, s11, 251;  j btb_55
btb_55: addi s11, s11, 257;  j btb_56
btb_56: addi s11, s11, 263;  j btb_57
btb_57: addi s11, s11, 269;  j btb_58
btb_58: addi s11, s11, 271;  j btb_59
btb_59: addi s11, s11, 277;  j btb_60
btb_60: addi s11, s11, 281;  j btb_61
btb_61: addi s11, s11, 283;  j btb_62
btb_62: addi s11, s11, 293;  j btb_63
btb_63: addi s11, s11, 307
    nop

    # ---- All branch types (same as sbst2, but with sig update) ----
    li t0, 10;  li t1, 20;  li t2, -5

    beq t0, t0, b_beq;  addi s11, s11, 311;  j test_end
b_beq: addi s11, s11, 313

    bne t0, t1, b_bne;  addi s11, s11, 317;  j test_end
b_bne: addi s11, s11, 331

    blt t0, t1, b_blt;  addi s11, s11, 337;  j test_end
b_blt: addi s11, s11, 347

    bge t0, t0, b_bge;  addi s11, s11, 349;  j test_end
b_bge: addi s11, s11, 353

    bltu t0, t2, b_bltu; addi s11, s11, 359; j test_end
b_bltu: addi s11, s11, 367

    bgeu t2, t0, b_bgeu; addi s11, s11, 373; j test_end
b_bgeu: addi s11, s11, 379

    li t0, 0
    beq t0, zero, db_1; addi s11, s11, 383
db_1: addi s11, s11, 389
    bne t0, t1, db_2;   addi s11, s11, 397
db_2: addi s11, s11, 401
    blt t0, t1, db_3;   addi s11, s11, 409
db_3: addi s11, s11, 419
    nop

    .balign 64
    nop; nop; nop; nop; nop; nop; nop
    nop; nop; nop; nop; nop; nop; nop; nop
    j boundary_target
    addi s11, s11, 421
boundary_target: addi s11, s11, 431

    li a0, 0;  li a1, 32
    jal ra, recursive_deep3
    addi s11, s11, 433
    j jalr_test3

recursive_deep3:
    addi sp, sp, -4;  sw ra, 0(sp)
    addi a0, a0, 1;   add s11, s11, a0
    bge  a0, a1, rb3
    jal  ra, recursive_deep3
rb3: lw ra, 0(sp);  addi sp, sp, 4;  ret

jalr_test3:
    li t0, 0;  li t1, 6;  li t2, 5
jl3:
    la t3, ta3
    blt t0, t2, dj3
    la t3, tb3
dj3: jalr x0, t3, 0

ta3:
    addi s11, s11, 439
    addi t0, t0, 1
    blt  t0, t1, jl3
    j    te3
tb3:
    addi s11, s11, 443

    # ===========================================================
    # [NEW] BYTE / HALFWORD LOAD-STORE WITH SIGNATURE
    # Uses stack scratch area; full sign/zero-extension matrix
    # ===========================================================
te3:
    addi s3, sp, -32            # 32-byte scratch below frame
    li   s4, 1
    li   s5, 0
    li   s6, 32

lsw3_loop:
    # Byte
    sb   s4, 0(s3)
    lb   t0, 0(s3)
    lbu  t1, 0(s3)
    add  s11, s11, t0
    xor  s11, s11, t1

    # Halfword
    sh   s4, 4(s3)
    lh   t2, 4(s3)
    lhu  t3, 4(s3)
    add  s11, s11, t2
    xor  s11, s11, t3

    # Word
    sw   s4, 8(s3)
    lw   t4, 8(s3)
    add  s11, s11, t4

    # Load-use hazard
    sw   s4, 12(s3)
    lw   t5, 12(s3)
    add  t6, t5, s4
    xor  s11, s11, t6

    slli s4, s4, 1
    addi s5, s5, 1
    blt  s5, s6, lsw3_loop

    # ===========================================================
    # [NEW] CSR WRITE / READ-BACK SIGNATURE
    # Exercises CSR file write datapath with diverse patterns
    # ===========================================================
    li   s4, 1
    li   s5, 0

csr3_loop:
    csrw mscratch, s4           # write 2^i
    csrr t0, mscratch           # read back
    add  s11, s11, t0           # fold into signature

    csrrs t1, mscratch, s4      # CSRRS: set bits
    csrrc t2, mscratch, s4      # CSRRC: clear bits
    xor  s11, s11, t1
    xor  s11, s11, t2

    slli s4, s4, 1
    addi s5, s5, 1
    li   s7, 32
    blt  s5, s7, csr3_loop

    csrw mscratch, zero

    # ===========================================================
    # [NEW] DIVERSE ALU: neg, not, add-carry, SUB corner cases
    # ===========================================================
    li   t0, 0x12345678
    sub  t1, zero, t0           # negate
    xori t2, t0, -1             # bitwise not
    add  t3, t0, t1             # t0 + (-t0) = 0
    add  t4, t2, t0             # ~t0 + t0 = -1
    slt  t5, t1, zero           # 1 (t1 is negative)
    sltu t6, zero, t0           # 1 (t0 > 0 unsigned)
    add  s11, s11, t1
    xor  s11, s11, t2
    add  s11, s11, t3
    xor  s11, s11, t4
    add  s11, s11, t5
    xor  s11, s11, t6

    # Store/load at different address offsets to exercise addr adder bits
    addi s3, sp, -64
    li   t0, 0xDEADBEEF
    sw   t0, 0(s3);   sw t0, 4(s3);   sw t0, 8(s3);   sw t0, 12(s3)
    sw   t0, 16(s3);  sw t0, 20(s3);  sw t0, 24(s3);  sw t0, 28(s3)
    lw   t1,  0(s3);  lw t2,  8(s3);  lw t3, 16(s3);  lw t4, 24(s3)
    xor  s11, s11, t1
    xor  s11, s11, t2
    xor  s11, s11, t3
    xor  s11, s11, t4

test_end:
    mv a0, s11

    lw s11,  8(sp)
    lw s10, 16(sp)
    lw s9,  24(sp)
    lw s8,  32(sp)
    lw s7,  40(sp)
    lw s6,  48(sp)
    lw s5,  56(sp)
    lw s4,  64(sp)
    lw s3,  72(sp)
    lw s2,  80(sp)
    lw s1,  88(sp)
    lw s0,  96(sp)
    lw ra, 104(sp)
    addi sp, sp, 112
    jr   ra

.section .data
.section .rodata
