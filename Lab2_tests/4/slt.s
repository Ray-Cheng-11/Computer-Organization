# test slt
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: slt (a0 = 0x80000000, a1 = -1, a2 = 1, a3 = 0x7fffffff)"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   
        # li      $a0, 0x80000000 # MIN
        # li      $a1, -1
        # li      $a2, 1
        # li      $a3, 0x7fffffff # MAX
        slt     $t1, $a1, $a2   # -1 < 1
        slt     $t2, $0, $a1    # 0 < -1
        slt     $t3, $0, $a2    # 0 < 1
        slt     $t4, $a0, $a2   # MIN < 1
        slt     $t5, $a2, $a0   # 1 < MIN
        slt     $t6, $a3, $a1   # MAX < -1
        slt     $t7, $a1, $a3   # -1 < MAX
        slt     $t8, $a0, $a3   # MIN < MAX
        slt     $t9, $a3, $a0   # MAX < MIN
