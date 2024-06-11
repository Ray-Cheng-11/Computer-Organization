# test lw & nop
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
        .word   0x00114514      # 0(gp)
        .word   0xf1919810      # 4(gp)
title:  .asciiz "Test: lw & nop"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   lw      $t0, 0($gp)     # t0 = 0x00114514
        lw      $t1, 4($gp)     # t1 = 0xf1919810
        lw      $0, 0($gp)
        lw      $0, 4($gp)
        nop
        nop
        nop
        nop
        nop
