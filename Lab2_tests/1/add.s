# test add
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: add"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   add     $t0, $0, $0     # t0 = 0
        add     $t1, $0, $gp    # t1 = gp
        add     $t2, $t1, $gp   # t2 = 2 * gp
        add     $t3, $gp, $t2   # t3 = 3 * gp
        add     $t4, $t2, $t2   # t4 = 4 * gp
        add     $t5, $t4, $t1   # t5 = 5 * gp
        add     $t6, $t4, $t2   # t6 = 6 * gp
        add     $t7, $t4, $t3   # t7 = 7 * gp
        add     $0, $0, $0
        add     $0, $t0, $t1
