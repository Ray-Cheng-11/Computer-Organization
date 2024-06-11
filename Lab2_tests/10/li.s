# test li (lui & ori)
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: li (lui & ori)"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   li      $t0, 114514
        li      $t1, 1919810
        li      $0, 0xff114514
        li      $a0, 0x80000000 # MIN
        li      $a1, -1
        li      $a2, 1
        li      $a3, 0x7fffffff # MAX
