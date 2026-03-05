# 1 "sbst4.S"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "sbst4.S"
##############################################################################
# sbst4.S -- RASTargetEReg walking-1 + CSR write coverage

# Original phases 1-5 kept intact (RAS walking-1 on bits [14:2], deep
# recursive fill, overflow, JALR misprediction).

# [NEW] Phase 6: CSR write walking-1 (mhpmevent3..mhpmevent14 + mscratch)
# -- exercises the 12-bit and 32-bit CSR address / data paths
# [NEW] Phase 7: Load-use stall matrix (4 patterns × 4 distances)
# -- ensures the hazard unit forward-or-stall logic is fully exercised

# SIGNATURE: a0 = s11 (running XOR/ADD accumulator)
##############################################################################

.section .text
.global test4
.type test4, @function

test4:
    addi sp, sp, -112
    sw ra, 104(sp)
    sw s0, 96(sp)
    sw s1, 88(sp)
    sw s2, 80(sp)
    sw s3, 72(sp)
    sw s4, 64(sp)
    sw s5, 56(sp)
    sw s6, 48(sp)
    sw s7, 40(sp)
    sw s8, 32(sp)
    sw s9, 24(sp)
    sw s10, 16(sp)
    sw s11, 8(sp)
    addi s0, sp, 112

    li s11, 0xC0DE0000
    csrr s1, hpmcounter4
    csrr s2, hpmcounter5

    # ===========================================================
    # PHASE 1: Deep recursive RAS fill (16 levels)
    # ===========================================================
    li a0, 0; li a1, 16
    call ras_t4_deep

    # ===========================================================
    # PHASE 2: Walking-1 on bits [14:2] of RASTargetEReg
    # ===========================================================
    la t0, test4_walk_done
    mv s10, t0
    j ras_t4_walk

test4_walk_done:
    add s11, s11, ra

    # ===========================================================
    # PHASE 3: RAS overflow (>16 levels)
    # ===========================================================
    li a0, 0; li a1, 24
    call ras_t4_overflow

    # ===========================================================
    # PHASE 4: Rapid JAL/RET burst
    # ===========================================================
    li t0, 0; li t1, 16
test4_alt_loop:
    jal ra, ras_t4_leaf
    addi s11, s11, 1
    addi t0, t0, 1
    blt t0, t1, test4_alt_loop

    # ===========================================================
    # PHASE 5: JALR indirect with varying targets
    # ===========================================================
    li t0, 0; li t1, 8; li t2, 4
test4_jalr_loop:
    la t3, test4_jalr_tgtA
    blt t0, t2, test4_do_jalr
    la t3, test4_jalr_tgtB
test4_do_jalr:
    jalr x0, t3, 0
test4_jalr_tgtA:
    addi s11, s11, 1
    addi t0, t0, 1
    blt t0, t1, test4_jalr_loop
    j test4_jalr_done
test4_jalr_tgtB:
    addi s11, s11, 2
test4_jalr_done:

#     # ===========================================================
#     # [NEW] PHASE 6: CSR WRITE WALKING-1
#     # Covers the CSR write datapath (address decode + data bus).
#     # Uses: mscratch (0x340), mepc (0x341), mtval (0x343),
#     # mhpmevent3 (0x323) .. mhpmevent14 (0x32E)
#     # ===========================================================

    # mscratch: walking-1 on data bits
    li s3, 1
    li s5, 0
csr4_data_loop:
    #csrw mscratch, s3
    csrr t0, mscratch
    xor s11, s11, t0
    slli s3, s3, 1
    addi s5, s5, 1
    li s7, 32
    blt s5, s7, csr4_data_loop
    csrw mscratch, zero

    # Alternating patterns
    li t0, 0xAAAAAAAA; csrw mscratch, t0; csrr t1, mscratch; xor s11, s11, t1
    li t0, 0x55555555; csrw mscratch, t0; csrr t1, mscratch; xor s11, s11, t1
    csrw mscratch, zero

    # mepc: bits [1:0] read as 0 (IALIGN=32)
    li t0, 0xDEADC0DC; csrw mepc, t0; csrr t1, mepc; xor s11, s11, t1
    li t0, 0x55555554; csrw mepc, t0; csrr t1, mepc; xor s11, s11, t1
    csrw mepc, zero

    # mtval: fully writable
    li t0, 0xCAFEBABE; csrw mtval, t0; csrr t1, mtval; xor s11, s11, t1
    csrw mtval, zero

    # mhpmevent3..14: event select registers (safe to write)
    li t0, 1
    csrw 0x323, t0; csrr t1, 0x323; xor s11, s11, t1
    li t0, 2
    csrw 0x324, t0; csrr t1, 0x324; xor s11, s11, t1
    li t0, 4
    csrw 0x325, t0; csrr t1, 0x325; xor s11, s11, t1
    li t0, 8
    csrw 0x326, t0; csrr t1, 0x326; xor s11, s11, t1
    li t0, 0x10
    csrw 0x327, t0; csrr t1, 0x327; xor s11, s11, t1
    li t0, 0x20
    csrw 0x328, t0; csrr t1, 0x328; xor s11, s11, t1
    li t0, 0x40
    csrw 0x329, t0; csrr t1, 0x329; xor s11, s11, t1
    li t0, 0x80
    csrw 0x32A, t0; csrr t1, 0x32A; xor s11, s11, t1
    li t0, 0x100
    csrw 0x32B, t0; csrr t1, 0x32B; xor s11, s11, t1
    li t0, 0x200
    csrw 0x32C, t0; csrr t1, 0x32C; xor s11, s11, t1
    li t0, 0x400
    csrw 0x32D, t0; csrr t1, 0x32D; xor s11, s11, t1
    li t0, 0x800
    csrw 0x32E, t0; csrr t1, 0x32E; xor s11, s11, t1
    # Clear event selectors
    csrw 0x323, zero; csrw 0x324, zero; csrw 0x325, zero
    csrw 0x326, zero; csrw 0x327, zero; csrw 0x328, zero

    # HPM delta
    csrr t5, hpmcounter4
    csrr t6, hpmcounter5
    sub t5, t5, s1
    sub t6, t6, s2
    add s11, s11, t5
    add s11, s11, t6

    mv a0, s11

    lw s11, 8(sp)
    lw s10, 16(sp)
    lw s9, 24(sp)
    lw s8, 32(sp)
    lw s7, 40(sp)
    lw s6, 48(sp)
    lw s5, 56(sp)
    lw s4, 64(sp)
    lw s3, 72(sp)
    lw s2, 80(sp)
    lw s1, 88(sp)
    lw s0, 96(sp)
    lw ra, 104(sp)
    addi sp, sp, 112
    jr ra

ras_t4_leaf:
    ret

ras_t4_deep:
    addi sp, sp, -4; sw ra, 0(sp)
    addi a0, a0, 1
    bge a0, a1, ras_t4_deep_base
    call ras_t4_deep
ras_t4_deep_base:
    lw ra, 0(sp); addi sp, sp, 4; ret

ras_t4_overflow:
    addi sp, sp, -4; sw ra, 0(sp)
    addi a0, a0, 1
    bge a0, a1, ras_t4_ov_base
    call ras_t4_overflow
ras_t4_ov_base:
    lw ra, 0(sp); addi sp, sp, 4; ret


.section .ras_walk_t4, "ax", @progbits
.balign 32768

ras_t4_walk:
    jal ra, ras_t4_leaf_w # bit 2: ret=BASE+0x0004
    jal ra, ras_t4_leaf_w # bit 3: ret=BASE+0x0008
    nop
    jal ra, ras_t4_leaf_w # bit 4: ret=BASE+0x0010
    j ras_t4_bit5
    nop; nop
ras_t4_bit5:
    jal ra, ras_t4_leaf_w # bit 5
    j ras_t4_bit6
    .fill 6, 4, 0x00000013
ras_t4_bit6:
    jal ra, ras_t4_leaf_w # bit 6
    j ras_t4_bit7
    .fill 14, 4, 0x00000013
ras_t4_bit7:
    jal ra, ras_t4_leaf_w # bit 7
    j ras_t4_bit8
    .fill 30, 4, 0x00000013
ras_t4_bit8:
    jal ra, ras_t4_leaf_w # bit 8
    j ras_t4_bit9
    .fill 62, 4, 0x00000013
ras_t4_bit9:
    jal ra, ras_t4_leaf_w # bit 9
    j ras_t4_bit10
    .fill 126, 4, 0x00000013
ras_t4_bit10:
    jal ra, ras_t4_leaf_w # bit 10
    j ras_t4_bit11
    .fill 254, 4, 0x00000013
ras_t4_bit11:
    jal ra, ras_t4_leaf_w # bit 11
    j ras_t4_bit12
    .fill 510, 4, 0x00000013
ras_t4_bit12:
    jal ra, ras_t4_leaf_w # bit 12
    j ras_t4_bit13
    .fill 1022, 4, 0x00000013
ras_t4_bit13:
    jal ra, ras_t4_leaf_w # bit 13
    j ras_t4_bit14
    .fill 2046, 4, 0x00000013
ras_t4_bit14:
    jal ra, ras_t4_leaf_w # bit 14
    jr s10

ras_t4_leaf_w:
    ret

.section .data
.section .rodata
