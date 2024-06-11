# test sub
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: sub"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   sub     $t1, $a2, $sp   # t1 = 0x7fffff7c - 0x7fffff74 = 8
        sub     $t0, $0, $t1    # t0 = -8
        sub     $t2, $t1, $t0   # t2 = t1 - t0 = 8 - (-8) = 16
        sub     $t3, $t2, $t0   # t3 = t2 - t0 = 16 - (-8) = 24
        sub     $t4, $0, $t2    # t4 = 0 - t2 = 0 - (16) = -16
        sub     $t4, $t2, $t4   # t4 = t2 - t4 = 16 - (-16) = 32
        sub     $t5, $t4, $t0   # t5 = t4 - t0 = 32 - (-8) = 40
        sub     $t5, $t5, $t3   # t5 = t5 - t3 = 40 - 24 = 16
        sub     $0, $0, $0
        sub     $0, $t0, $t1
