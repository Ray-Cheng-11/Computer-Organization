# test lw & sw
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
        .word   0x00114514      # 0(gp)
        .word   0xf1919810      # 4(gp)
title:  .asciiz "Test: lw & sw (swap)"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   lw      $t0, 0($gp)     # t0 = 0x00114514
        lw      $t1, 4($gp)     # t1 = 0xf1919810
        lw      $0, 0($gp)
        lw      $0, 4($gp)
        nop
        sw      $t0, 4($gp)     # swap 0(gp) and 4(gp)
        sw      $t1, 0($gp)
        sw      $0, 8($gp)      # cover out title
        sw      $fp, 12($gp)
