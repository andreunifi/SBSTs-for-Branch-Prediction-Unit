# =============================================================================
# sbst.S - SBST (Software-Based Self-Test) for bpred.sv
# =============================================================================
#
# Target module : src/ifu/bpred/bpred.sv
# Fault models  : SAF (stuck-at faults) and TDF (transition delay faults)
# Tool          : ZOIX fault injection (recursive on bpred_bpred.**, excl. BTB)
#
# This SBST exercises every major signal and logic path in the branch predictor
# top-level module (bpred.sv) to maximize fault coverage under ZOIX. Each
# section documents which bpred.sv signals/muxes it targets.
#
# Key bpred.sv structures exercised:
#   1.  Direction predictor (BPDirF[1:0], satCounter2 states 00-11)
#   2.  BPPCSrcF = (BPBranchF & BPDirF[1]) | BPJumpF
#   3.  PC mux chain: pcmuxbp, pcmux0, pcmux1, pccorrectemux
#   4.  Misprediction detection: BPWrongE, BPWrongM
#   5.  Instruction class: IClassM = {CallM, ReturnM, JumpM, BranchM}
#   6.  IClassWrongM / BPReturnWrongD (icpred)
#   7.  RAS: push (CallE), pop (BPReturnF), overflow, repair
#   8.  Pipeline registers (flopenrc instances)
#   9.  NextValidPCE mux (INSTR_CLASS_PRED path)
#   10. ZIHPM performance counter signals (BPDirWrongM, BTAWrongM, etc.)
# =============================================================================

.section .text
.global test1
.type test1, @function

test1:
	# ABI prologue
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

	# Signature accumulator – every taken path adds a unique prime so the
	# final value is a deterministic fingerprint of the executed path.
	li s11, 0x5B000000

	# =================================================================
	# SECTION 1 – Direction Predictor State-Machine (satCounter2)
	# Targets: BPDirF[1:0], BPDirWrongE, NewBPDirE/M
	# Exercise all 4 states (00,01,10,11) and all 8 transitions
	# =================================================================

	li t0, 0
	li t1, 1

	# 1a – Drive counter toward 00 with not-taken branches
	beq t0, t1, sec1_nt1          # NT (0 != 1)
	nop
sec1_nt1:
	addi s11, s11, 1
	beq t0, t1, sec1_nt2          # NT
	nop
sec1_nt2:
	addi s11, s11, 2

	# 1b – Walk counter 00->01->10->11 with taken branches
	beq t0, t0, sec1_tk1          # T
	nop
sec1_tk1:
	addi s11, s11, 3
	beq t0, t0, sec1_tk2          # T
	nop
sec1_tk2:
	addi s11, s11, 5
	beq t0, t0, sec1_tk3          # T
	nop
sec1_tk3:
	addi s11, s11, 7

	# 1c – Walk counter 11->10->01 with not-taken branches
	beq t0, t1, sec1_nt3          # NT
	nop
sec1_nt3:
	addi s11, s11, 11
	beq t0, t1, sec1_nt4          # NT
	nop
sec1_nt4:
	addi s11, s11, 13

	# 1d – Rapid T/NT alternation for TDF on BPDirF[1]
	beq t0, t0, sec1_alt1         # T
	nop
sec1_alt1:
	addi s11, s11, 17
	beq t0, t1, sec1_alt2         # NT
	nop
sec1_alt2:
	addi s11, s11, 19
	beq t0, t0, sec1_alt3         # T
	nop
sec1_alt3:
	addi s11, s11, 23
	beq t0, t1, sec1_alt4         # NT
	nop
sec1_alt4:
	addi s11, s11, 29

	# =================================================================
	# SECTION 2 – BPPCSrcF toggle
	# BPPCSrcF = (BPBranchF & BPDirF[1]) | BPJumpF
	# =================================================================

	# 2a – Sequential ALU (BPBranchF=0, BPJumpF=0 -> BPPCSrcF=0)
	add s11, s11, t0
	addi s11, s11, 31
	xor t2, t0, t1
	or  t3, t0, t1
	and t4, t0, t1

	# 2b – Jump (BPJumpF=1 -> BPPCSrcF=1)
	j sec2_jmp1
	nop
sec2_jmp1:
	addi s11, s11, 37

	# 2c – Branch NT then T to toggle BPPCSrcF
	beq t0, t1, sec2_src0         # NT -> BPPCSrcF=0
	nop
sec2_src0:
	addi s11, s11, 41
	beq t0, t0, sec2_src1         # T  -> BPPCSrcF=1
	nop
sec2_src1:
	addi s11, s11, 43

	# =================================================================
	# SECTION 3 – PC Mux Chain
	# pcmuxbp  : mux2(BPBTAF, RASPCF, BPReturnF)
	# pcmux0   : mux2(PCPlus2or4F, BPPCF, BPPCSrcF)
	# pcmux1   : mux2(PC0NextF, PCCorrectE, BPWrongE)
	# pccorrectemux : mux2(PCLinkE, IEUAdrE, PCSrcE)
	# =================================================================

	# 3a – pcmuxbp sel=0 (BPBTAF path, normal jump)
	j sec3_btb
	nop
sec3_btb:
	addi s11, s11, 47

	# 3b – pcmuxbp sel=1 (RASPCF path, call+return)
	jal ra, sec3_ras_fn
	addi s11, s11, 53
	j sec3_ras_done
sec3_ras_fn:
	addi s11, s11, 59
	ret
sec3_ras_done:

	# 3c – pcmux0 sel=0 (sequential, BPPCSrcF=0)
	nop
	addi s11, s11, 61
	nop

	# 3d – pcmux0 sel=1 (predicted taken branch)
	beq t0, t0, sec3_pcmux0_tk
	nop
sec3_pcmux0_tk:
	addi s11, s11, 67

	# 3e – pcmux1 sel=0 (correct prediction, BPWrongE=0)
	beq t0, t0, sec3_corr1
	nop
sec3_corr1:
	addi s11, s11, 71
	beq t0, t0, sec3_corr2
	nop
sec3_corr2:
	addi s11, s11, 73

	# 3f – pcmux1 sel=1 (misprediction, BPWrongE=1)
	beq t0, t1, sec3_misp1        # NT when predictor expects T
	nop
sec3_misp1:
	addi s11, s11, 79

	# 3g – pccorrectemux sel=0 (PCSrcE=0, branch NT -> PCLinkE)
	bne t0, t0, sec3_pce0
	nop
sec3_pce0:
	addi s11, s11, 83

	# 3h – pccorrectemux sel=1 (PCSrcE=1, branch T -> IEUAdrE)
	beq t0, t0, sec3_pce1
	nop
sec3_pce1:
	addi s11, s11, 89

	# =================================================================
	# SECTION 4 – Instruction Class Coverage
	# IClassM = {CallM, ReturnM, JumpM, BranchM}
	# =================================================================

	# 4a – BranchM=1
	beq t0, t0, sec4_br
	nop
sec4_br:
	addi s11, s11, 97

	# 4b – JumpM=1 (jal x0)
	j sec4_jmp
	nop
sec4_jmp:
	addi s11, s11, 101

	# 4c – CallM=1 (jal ra)
	jal ra, sec4_call_fn
	addi s11, s11, 103
	j sec4_call_done
sec4_call_fn:
	addi s11, s11, 107
	ret
sec4_call_done:

	# 4d – ReturnM=1 (jalr x0, ra) – explicit pair
	jal ra, sec4_ret_fn
	addi s11, s11, 109
	j sec4_ret_done
sec4_ret_fn:
	nop
	jr ra
sec4_ret_done:

	# 4e – Call/return via alternate link register x5
	la t3, sec4_x5_tgt
	jalr x5, t3, 0                # CallM=1 (rd=x5)
	addi s11, s11, 113
	j sec4_x5_done
sec4_x5_tgt:
	addi s11, s11, 127
	jalr x0, x5, 0                # ReturnM=1 (rs1=x5)
sec4_x5_done:

	# 4f – Rapid class toggling (branch->jump->call->ret->branch) for TDF
	beq t0, t0, sec4_tog1
	nop
sec4_tog1:
	addi s11, s11, 131
	j sec4_tog2
	nop
sec4_tog2:
	addi s11, s11, 137
	jal ra, sec4_tog3
	j sec4_tog4
sec4_tog3:
	ret
sec4_tog4:
	addi s11, s11, 139
	bne t0, t1, sec4_tog5         # NT
	nop
sec4_tog5:
	addi s11, s11, 149

	# =================================================================
	# SECTION 5 – All Branch Comparator Types
	# Affects PCSrcE which feeds pccorrectemux in bpred.sv
	# =================================================================

	li t0, 10
	li t1, 20
	li t2, -5                     # 0xFFFFFFFB

	# Taken variants
	li t3, 10
	beq t0, t3, sec5_beq_tk
	addi s11, s11, 151
sec5_beq_tk:
	addi s11, s11, 157

	bne t0, t1, sec5_bne_tk
	addi s11, s11, 163
sec5_bne_tk:
	addi s11, s11, 167

	blt t0, t1, sec5_blt_tk       # 10 < 20
	addi s11, s11, 173
sec5_blt_tk:
	addi s11, s11, 179

	bge t0, t0, sec5_bge_tk       # 10 >= 10
	addi s11, s11, 181
sec5_bge_tk:
	addi s11, s11, 191

	bltu t0, t2, sec5_bltu_tk     # 10 <u 0xFFFFFFFB
	addi s11, s11, 193
sec5_bltu_tk:
	addi s11, s11, 197

	bgeu t2, t0, sec5_bgeu_tk     # 0xFFFFFFFB >=u 10
	addi s11, s11, 199
sec5_bgeu_tk:
	addi s11, s11, 211

	# Not-taken variants (toggle PCSrcE=0)
	bne t0, t0, sec5_beq_nt
	nop
sec5_beq_nt:
	addi s11, s11, 223
	beq t0, t1, sec5_bne_nt
	nop
sec5_bne_nt:
	addi s11, s11, 227
	bge t0, t1, sec5_blt_nt       # 10 >= 20 false
	nop
sec5_blt_nt:
	addi s11, s11, 229
	blt t1, t0, sec5_bge_nt       # 20 < 10 false
	nop
sec5_bge_nt:
	addi s11, s11, 233
	bgeu t0, t2, sec5_bltu_nt     # 10 >=u 0xFFFFFFFB false
	nop
sec5_bltu_nt:
	addi s11, s11, 239
	bltu t2, t0, sec5_bgeu_nt     # 0xFFFFFFFB <u 10 false
	nop
sec5_bgeu_nt:
	addi s11, s11, 241

	# =================================================================
	# SECTION 6 – RAS (Return Address Stack) Coverage
	# Targets: RASPCF, PopF, PushE, RepairD, CounterEn, Ptr
	# =================================================================

	# 6a – Simple call/return (push then pop)
	jal ra, sec6_simple
	addi s11, s11, 251
	j sec6_nested_start
sec6_simple:
	addi s11, s11, 257
	ret
sec6_nested_start:

	# 6b – Nested calls (exercise RAS depth)
	jal ra, sec6_d1
	addi s11, s11, 263
	j sec6_overflow

sec6_d1:
	addi sp, sp, -4
	sw ra, 0(sp)
	addi s11, s11, 269
	jal ra, sec6_d2
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

sec6_d2:
	addi sp, sp, -4
	sw ra, 0(sp)
	addi s11, s11, 271
	jal ra, sec6_d3
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

sec6_d3:
	addi sp, sp, -4
	sw ra, 0(sp)
	addi s11, s11, 277
	jal ra, sec6_d4
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

sec6_d4:
	addi s11, s11, 281
	ret

sec6_overflow:
	# 6c – Recursive calls to overflow RAS (depth > RAS_SIZE)
	li a0, 0
	li a1, 16
	jal ra, sec6_rec
	addi s11, s11, 283
	j sec7_start

sec6_rec:
	addi sp, sp, -4
	sw ra, 0(sp)
	addi a0, a0, 1
	add s11, s11, a0
	bge a0, a1, sec6_rec_base
	jal ra, sec6_rec
sec6_rec_base:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

	# =================================================================
	# SECTION 7 – Misprediction Detection
	# Targets: BPWrongE, BPWrongM, BPDirWrongE
	# Train predictor then force opposite direction
	# =================================================================
sec7_start:
	li t0, 0
	li t1, 1

	# 7a – Train to "taken" (saturate counter to 11)
	beq t0, t0, sec7_trn_tk1
	nop
sec7_trn_tk1:
	addi s11, s11, 293
	beq t0, t0, sec7_trn_tk2
	nop
sec7_trn_tk2:
	addi s11, s11, 307
	beq t0, t0, sec7_trn_tk3
	nop
sec7_trn_tk3:
	addi s11, s11, 311

	# 7b – Force NT misprediction (BPWrongE=1, BPDirWrongE=1)
	beq t0, t1, sec7_mis_nt1
	nop
sec7_mis_nt1:
	addi s11, s11, 313
	beq t0, t1, sec7_mis_nt2
	nop
sec7_mis_nt2:
	addi s11, s11, 317

	# 7c – Train to "not taken" (saturate counter to 00)
	beq t0, t1, sec7_trn_nt1
	nop
sec7_trn_nt1:
	addi s11, s11, 331
	beq t0, t1, sec7_trn_nt2
	nop
sec7_trn_nt2:
	addi s11, s11, 337
	beq t0, t1, sec7_trn_nt3
	nop
sec7_trn_nt3:
	addi s11, s11, 347

	# 7d – Force T misprediction (BPWrongE=1)
	beq t0, t0, sec7_mis_tk1
	nop
sec7_mis_tk1:
	addi s11, s11, 349

	# =================================================================
	# SECTION 8 – IClassWrongM / BTB Class Thrash
	# Targets: IClassWrongM, IClassWrongD, BPReturnWrongD
	# Rapid jumps create and invalidate BTB class entries
	# =================================================================

	j sec8_j1
sec8_j1:
	addi s11, s11, 353
	j sec8_j2
sec8_j2:
	addi s11, s11, 359
	j sec8_j3
sec8_j3:
	addi s11, s11, 367
	j sec8_j4
sec8_j4:
	addi s11, s11, 373

	# =================================================================
	# SECTION 9 – JALR Target Misprediction (BPBTAWrongM)
	# Alternate JALR target between two addresses
	# =================================================================

	li t0, 0
	li t1, 4

sec9_loop:
	la t3, sec9_tgt_a
	andi t4, t0, 1
	beq t4, zero, sec9_use_a
	la t3, sec9_tgt_b
sec9_use_a:
	jalr x0, t3, 0

sec9_tgt_a:
	addi s11, s11, 379
	addi t0, t0, 1
	blt t0, t1, sec9_loop
	j sec9_done

sec9_tgt_b:
	addi s11, s11, 383
	addi t0, t0, 1
	blt t0, t1, sec9_loop

sec9_done:
	addi s11, s11, 389

	# =================================================================
	# SECTION 10 – NextValidPCE Mux
	# NextValidPCE = BPWrongM ? PCF : PCE (INSTR_CLASS_PRED path)
	# =================================================================

	# Correct prediction -> BPWrongM=0 -> NextValidPCE=PCE
	beq t0, t0, sec10_corr
	nop
sec10_corr:
	addi s11, s11, 397

	# Misprediction -> BPWrongM=1 -> NextValidPCE=PCF
	li t0, 0
	li t1, 1
	beq t0, t1, sec10_misp
	nop
sec10_misp:
	addi s11, s11, 401

	# =================================================================
	# SECTION 11 – Pipeline Register Stress
	# Back-to-back branches toggle PCSrcE/M, BPWrongE/M every cycle
	# =================================================================

	li t0, 0
	li t1, 5
sec11_loop:
	beq t0, t0, sec11_tk
	nop
sec11_tk:
	addi s11, s11, 409
	beq t0, t1, sec11_nt
	nop
sec11_nt:
	addi s11, s11, 419
	addi t0, t0, 1
	blt t0, t1, sec11_loop

	# Dense jumps followed by call/return
	j sec11_dj1
sec11_dj1:
	j sec11_dj2
sec11_dj2:
	j sec11_dj3
sec11_dj3:
	j sec11_dj4
sec11_dj4:
	addi s11, s11, 421
	jal ra, sec11_call
	j sec11_end
sec11_call:
	addi s11, s11, 431
	ret
sec11_end:
	addi s11, s11, 433

	# =================================================================
	# SECTION 12 – HPM Counter Observability
	# Read ZIHPM counters so ZOIX can strobe performance signals
	# =================================================================

	csrr t3, cycle
	csrr t4, time
	csrr t5, 0xB04            # hpmcounter4 (class mispredictions)
	csrr t6, 0xB05            # hpmcounter5 (BTB target wrong)
	csrr s2, 0xB06            # hpmcounter6 (RAS target wrong)
	csrr s3, 0xB07            # hpmcounter7 (direction wrong)
	csrr s4, 0xB08            # hpmcounter8 (BP wrong)
	csrr s5, 0xB09            # hpmcounter9

	# =================================================================
	# Signature output
	# =================================================================

	mv a0, s11

	# ABI epilogue
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


# READ/WRITE VARIABLES

.section .data

# READ-ONLY VARIABLES

.section .rodata