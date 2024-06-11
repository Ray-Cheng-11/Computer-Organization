# test sw & nop
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
        .word   0x00114514      # 0(gp)
        .word   0xf1919810      # 4(gp)
title:  .asciiz "Test: sw & nop"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   sw      $sp, 0($gp)
        sw      $a2, 4($gp)
        sw      $0, 8($gp)      # cover out title
        sw      $fp, 12($gp)
        nop
        nop
        nop
        nop
        nop
