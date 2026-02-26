.section .text
.global test1
.type test1, @function

.data
A:      .word 0
B:      .word 1

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


    # Initialize R1 (x10) to value A (0)
    la x11, A
    lw x10, 0(x11)
    
    #========================================
    # PHASE 1: Initialize all counters to 11
    #========================================
    # Execute 3*N Taken branches to saturate all counters to state 11
    # Order doesn't matter in this phase
    
    # Set R2 (x12) to A (0) so branches will be Taken (beq will match)
    lw x12, 0(x11)
    
    # Access each BHT line 3 times with Taken branches
    call JUMPTK0
    call JUMPTK0
    call JUMPTK0
    
    call JUMPTK1
    call JUMPTK1
    call JUMPTK1
    
    call JUMPTK2
    call JUMPTK2
    call JUMPTK2
    
    call JUMPTK3
    call JUMPTK3
    call JUMPTK3
    
    call JUMPTK4
    call JUMPTK4
    call JUMPTK4
    
    call JUMPTK5
    call JUMPTK5
    call JUMPTK5
    
    call JUMPTK6
    call JUMPTK6
    call JUMPTK6
    
    call JUMPTK7
    call JUMPTK7
    call JUMPTK7
    
    #========================================
    # PHASE 2: Move all counters from 11 to 00
    #========================================
    # Execute 4*N Not Taken branches in descending order
    # Each line: 2 mispredictions (11->10, 10->01) + 2 correct predictions (01->00, 00->00)
    
    # Set R2 (x12) to B (1) so branches will be Not Taken
    la x11, B
    lw x12, 0(x11)
    
    # Access lines in DESCENDING order (7 down to 0)
    call JUMPTK7
    call JUMPTK7
    call JUMPTK7
    call JUMPTK7
    
    call JUMPTK6
    call JUMPTK6
    call JUMPTK6
    call JUMPTK6
    
    call JUMPTK5
    call JUMPTK5
    call JUMPTK5
    call JUMPTK5
    
    call JUMPTK4
    call JUMPTK4
    call JUMPTK4
    call JUMPTK4
    
    call JUMPTK3
    call JUMPTK3
    call JUMPTK3
    call JUMPTK3
    
    call JUMPTK2
    call JUMPTK2
    call JUMPTK2
    call JUMPTK2
    
    call JUMPTK1
    call JUMPTK1
    call JUMPTK1
    call JUMPTK1
    
    call JUMPTK0
    call JUMPTK0
    call JUMPTK0
    call JUMPTK0
    
    #========================================
    # PHASE 3: Move all counters from 00 to 11
    #========================================
    # Execute 4*N Taken branches in ascending order
    # Each line: 2 mispredictions (00->01, 01->10) + 2 correct predictions (10->11, 11->11)
    
    # Set R2 (x12) back to A (0) so branches will be Taken
    la x11, A
    lw x12, 0(x11)
    
    # Access lines in ASCENDING order (0 up to 7)
    call JUMPTK0
    call JUMPTK0
    call JUMPTK0
    call JUMPTK0
    
    call JUMPTK1
    call JUMPTK1
    call JUMPTK1
    call JUMPTK1
    
    call JUMPTK2
    call JUMPTK2
    call JUMPTK2
    call JUMPTK2
    
    call JUMPTK3
    call JUMPTK3
    call JUMPTK3
    call JUMPTK3
    
    call JUMPTK4
    call JUMPTK4
    call JUMPTK4
    call JUMPTK4
    
    call JUMPTK5
    call JUMPTK5
    call JUMPTK5
    call JUMPTK5
    
    call JUMPTK6
    call JUMPTK6
    call JUMPTK6
    call JUMPTK6
    
    call JUMPTK7
    call JUMPTK7
    call JUMPTK7
    call JUMPTK7

END:




    mv a0, t5 
    #li a0, 0xCAFECAFE    # return value



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

#Procedures. Todo: align them 
    .section .jumptk0, "ax", @progbits   # 'a'=allocatable, 'x'=executable
    .align 2 
JUMPTK0:
    beq x10, x12, TK0
    nop
TK0:
    ret

    .section .jumptk1, "ax", @progbits   # 'a'=allocatable, 'x'=executable
    .align 2 
JUMPTK1:
    beq x10, x12, TK1
    nop
TK1:
    ret

    .section .jumptk2, "ax", @progbits   # 'a'=allocatable, 'x'=executable
    .align 2 
JUMPTK2:
    beq x10, x12, TK2
    nop
TK2:
    ret

    .section .jumptk3, "ax", @progbits   # 'a'=allocatable, 'x'=executable
    .align 2 
JUMPTK3:
    beq x10, x12, TK3
    nop
TK3:
    ret

   .section .jumptk4, "ax", @progbits   # 'a'=allocatable, 'x'=executable
   .align 2 
JUMPTK4:
    beq x10, x12, TK4
    nop
TK4:
    ret

  .section .jumptk5, "ax", @progbits   # 'a'=allocatable, 'x'=executable
   .align 2 
JUMPTK5:
    beq x10, x12, TK5
    nop
TK5:
    ret

  .section .jumptk6, "ax", @progbits   # 'a'=allocatable, 'x'=executable
   .align 2 
JUMPTK6:
    beq x10, x12, TK6
    nop
TK6:
    ret
  .section .jumptk7, "ax", @progbits   # 'a'=allocatable, 'x'=executable
   .align 2 
JUMPTK7:
    beq x10, x12, TK7
    nop
TK7:
    ret