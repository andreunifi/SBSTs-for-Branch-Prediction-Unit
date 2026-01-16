.section .text
.global test1
.type test1, @function

test1:
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


    # You can write your code here 

# 	  # ----------------------------
#     # BPU Stress Patterns (RV32E-safe)
#     # ----------------------------
#     li s0, 0               # counter 0
#     li s1, 16              # loop limit

# train_taken:
#     addi s0, s0, 1
#     beq  s0, s0, train_taken  # always taken
#     nop

#     li s0, 0
# train_not_taken:
#     addi s0, s0, 1
#     bne  s0, s0, train_not_taken  # never taken
#     nop

#     # Alternating branches on same PC
#     li s0, 0               # counter
# alt_loop:
#     addi s0, s0, 1
#     andi s3, s0, 1         # use gp (x3) as temp
#     beq  s3, x0, taken_path
#     nop
#     j not_taken_path

# taken_path:
#     nop
#     blt s0, s1, alt_loop
#     j end_alt

# not_taken_path:
#     nop
#     blt s0, s1, alt_loop

# end_alt:
#     nop

#     # Optional: store PC/branch result for observation
#     auipc x3, 0            # x3 = PC
#     sw x3, 0(sp)           # store to stack


    li a0, 0xCAFECAFE    # return value



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