# =============================================================================
# ras_march.S  —  RAS Predictor MATS march test
# 
#
# Mats+ up(w0) down(r0)  up(w1) down(r1)  up(w0) down(r0)
#
#
# =============================================================================
#Ho dovuto spezzare i march element, leggo poppando e scrivo pushando
.section .text
.global test4
.type   test4, @function

test4:
    addi  sp,  sp, -32
    sw    ra,  28(sp)
    sw    s0,  24(sp)
    sw    s1,  20(sp)
    sw    s2,  16(sp)
    sw    s11, 12(sp)

    li    s11, 0

    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09

    call  w0_fun0
w0_ret:
    sub   s2, s1, s0
    add   s11, s11, s2                # expect 0

     # HPM counters after Phase 1
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09

    call  w1_fun0
w1_ret:
     # HPM counters after Phase 1
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09

    sub   s2, s1, s0
    add   s11, s11, s2                # expect 0

     # HPM counters after Phase 1
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09

    call  w0b_fun0
w0b_ret:

     # HPM counters after Phase 1
    csrr  t3, cycle
    csrr  t4, time
    csrr  t5, 0xB04
    csrr  t6, 0xB05
    csrr  s2, 0xB06
    csrr  s3, 0xB07
    csrr  s4, 0xB08
    csrr  s5, 0xB09

    sub   s2, s1, s0
    add   s11, s11, s2                # expect 0

    mv    a0, s11                     # return total delta (expect 0)

    lw    s11, 12(sp)
    lw    s2,  16(sp)
    lw    s1,  20(sp)
    lw    s0,  24(sp)
    lw    ra,  28(sp)
    addi  sp,  sp, 32
    ret



#.ras_low settato dal linker in 0x80002104 
.section .ras_low, "ax", @progbits
.align 2

#w0 Ascending 
w0_fun0:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun1
w0_fun0_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun2
w0_fun1_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun3
w0_fun2_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun4
w0_fun3_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun5
w0_fun4_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun6
w0_fun5_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun7
w0_fun6_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_fun8
w0_fun7_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_fun8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0_leaf
w0_fun8_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0_leaf:
    ret


#w0b, seconda passata di scrittura 0 del march
w0b_fun0:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun1
w0b_fun0_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun2
w0b_fun1_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun3
w0b_fun2_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun4
w0b_fun3_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun5
w0b_fun4_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun6
w0b_fun5_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun7
w0b_fun6_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_fun8
w0b_fun7_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_fun8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w0b_leaf
w0b_fun8_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w0b_leaf:
    ret


#.ras_high zone, settata a 0x80f01050 dal linker
.section .ras_high, "ax", @progbits
.align 2

#w1 chain
w1_fun0:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun1
w1_fun0_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun1:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun2
w1_fun1_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun2:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun3
w1_fun2_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun3:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun4
w1_fun3_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun4:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun5
w1_fun4_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun5:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun6
w1_fun5_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun6:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun7
w1_fun6_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun7:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_fun8
w1_fun7_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_fun8:
    addi  sp, sp, -4
    sw    ra, 0(sp)
    jal   ra, w1_leaf
w1_fun8_ret:
    lw    ra, 0(sp)
    addi  sp, sp, 4
    ret

w1_leaf:
    ret