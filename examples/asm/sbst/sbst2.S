.section .text
.global test2
.type test2, @function

test2:
	# ABI prologue
	addi sp, sp, -112     # allocate 112 bytes on the stack
	sw ra, 104(sp)        # save return address
	sw s0, 96(sp)         # save callee-saved registers
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
	addi s0, sp, 112     # set up s0 to point to start of stack frame

    #March+ section
    li a0, 1
    call W0_SITE0_ascending
    li a0, 1
    call W1_SITE0_ascending
    li a0, 1
    call W0_SITE7_descending



    # 1. BTB Thrash Test 
    #64 Unique Jumps to fill the Branch Target Buffer
    j btb_00
btb_00: j btb_01
btb_01: j btb_02
btb_02: j btb_03
btb_03: j btb_04
btb_04: j btb_05
btb_05: j btb_06
btb_06: j btb_07
btb_07: j btb_08
btb_08: j btb_09
btb_09: j btb_10
btb_10: j btb_11
btb_11: j btb_12
btb_12: j btb_13
btb_13: j btb_14
btb_14: j btb_15
btb_15: j btb_16
btb_16: j btb_17
btb_17: j btb_18
btb_18: j btb_19
btb_19: j btb_20
btb_20: j btb_21
btb_21: j btb_22
btb_22: j btb_23
btb_23: j btb_24
btb_24: j btb_25
btb_25: j btb_26
btb_26: j btb_27
btb_27: j btb_28
btb_28: j btb_29
btb_29: j btb_30
btb_30: j btb_31
btb_31: j btb_32
btb_32: j btb_33
btb_33: j btb_34
btb_34: j btb_35
btb_35: j btb_36
btb_36: j btb_37
btb_37: j btb_38
btb_38: j btb_39
btb_39: j btb_40
btb_40: j btb_41
btb_41: j btb_42
btb_42: j btb_43
btb_43: j btb_44
btb_44: j btb_45
btb_45: j btb_46
btb_46: j btb_47
btb_47: j btb_48
btb_48: j btb_49
btb_49: j btb_50
btb_50: j btb_51
btb_51: j btb_52
btb_52: j btb_53
btb_53: j btb_54
btb_54: j btb_55
btb_55: j btb_56
btb_56: j btb_57
btb_57: j btb_58
btb_58: j btb_59
btb_59: j btb_60
btb_60: j btb_61
btb_61: j btb_62
btb_62: j btb_63
btb_63: 
    nop

    #2: BTB stress test with branches of all types (Taken)   

    li t0, 10
    li t1, 20
    li t2, -5      

    csrr t3,cycle   
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2 ,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09
    
    # BEQ (Taken)
    beq t0, t0, b_beq
    j test_end
b_beq:

    csrr t3,cycle   
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # BNE (Taken)
    bne t0, t1, b_bne
    j test_end
b_bne:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # BLT 
    blt t0, t1, b_blt
    j test_end
b_blt:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # BGE 
    bge t0, t0, b_bge
    j test_end
b_bge:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    csrr s5 ,0xB09

    # BLTU 
    bltu t0, t2, b_bltu
    j test_end
b_bltu:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08

    # BGEU 
    bgeu t2, t0, b_bgeu
    j test_end
b_bgeu:
    csrr t3,cycle    #
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08



    # 3. Dense Branching 
    # Rapid-fire control instructions to stress BPU condition logic
    li t0, 0
    beq t0, zero, db_1
    nop
db_1:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    bne t0, t1, db_2
    nop
db_2:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    blt t0, t1, db_3
    nop
db_3:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    nop

    # 4. Recursive deep calls
    #Qui ho create una chain di chiamate ricorsive per testare se ci sono problemi nel tipo di istruzione 
    #letta
    li a0, 0
    li a1, 32           # Depth 32
    jal ra, recursive_deep
    j jalr_test

recursive_deep:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08


    addi sp, sp, -4
    sw ra, 0(sp)
    addi a0, a0, 1
    bge a0, a1, recursive_base
    jal ra, recursive_deep
recursive_base:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

    # 5. JALR Misprediction, come nei loop
jalr_test:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08


    li t0, 0
    li t1, 6
    li t2, 5
jalr_loop:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08

    la t3, target_A
    blt t0, t2, do_jump
    la t3, target_B     # Switch target on last iteration
do_jump:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08

    la t3, target_B     # Switch target on last iteration


    jalr x0, t3, 0

target_A:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08

    addi t0, t0, 1
    blt t0, t1, jalr_loop
    j test_end

target_B:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
    nop

    # -------------------------------------------------------------------------
    # Epilogue
    # -------------------------------------------------------------------------

	li t0,4  
test_end:
    csrr t3,cycle    # Prevent optimization removal
    csrr t4,time
    csrr t5 ,0xB04
    csrr t6 ,0xB05
    csrr s2,0xB06
    csrr s3 ,0xB07
    csrr s4 ,0xB08
	nop
	addi t0,t0,-1
	bnez t0,test_end

        # Read the HPM CSRs into temporary registers
    csrr t5, 0xB04     # HPM0
    csrr t6, 0xB05     # HPM1
    csrr s2, 0xB06     # HPM2
    csrr s3, 0xB07     # HPM3
    csrr s4, 0xB08     # HPM4

    # Combine them into a single signature (sum example)
    add t5, t5, t6     # t5 = t5 + t6
    add t5, t5, s2     # t5 = t5 + s2
    add t5, t5, s3     # t5 = t5 + s3
    add t5, t5, s4     # t5 = t5 + s4

    csrr t5, hpmcounter4
    csrr t6, hpmcounter5
    csrr s2, hpmcounter6
    csrr s3, hpmcounter7
    csrr s4, hpmcounter8

    mv a0, t5 #signature= somma di tutte i valori degli HPM


    # ABI epilogue
	lw s11, 8(sp)        # restore callee-saved registers
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
	lw ra, 104(sp)       # restore return address
	addi sp, sp, 112     # deallocate stack space
	jr ra                # return to caller



# READ/WRITE VARIABLES

.section .data

# READ-ONLY VARIABLES

.section .rodata

.section .w0_entry0, "ax", @progbits
W0_SITE0_ascending:
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        ret

    .section .w1_entry0, "ax", @progbits
W1_SITE0_ascending: bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        bnez a0, .+4
        ret

    .section .w0d_entry7, "ax", @progbits
W0_SITE7_descending: j W0_SITE6_descending
    nop

    .section .w0d_entry6, "ax", @progbits
W0_SITE6_descending: j W0_SITE5_descending
    nop

    .section .w0d_entry5, "ax", @progbits
W0_SITE5_descending: j W0_SITE4_descending
    nop

    .section .w0d_entry4, "ax", @progbits
W0_SITE4_descending: j W0_SITE3_descending
    nop

    .section .w0d_entry3, "ax", @progbits
W0_SITE3_descending: j W0_SITE2_descending
    nop

    .section .w0d_entry2, "ax", @progbits
W0_SITE2_descending: j W0_SITE1_descending
    nop

    .section .w0d_entry1, "ax", @progbits
W0_SITE1_descending: j W0_SITE0_descending
    nop

    .section .w0d_entry0, "ax", @progbits
W0_SITE0_descending: j .+4
    ret
