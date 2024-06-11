# test j
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: j"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   or      $t0, $0, $gp
        j       exit
        or      $t1, $0, $gp
        or      $t2, $0, $gp
        nop
        nop
        nop
exit:   or      $t3, $0, $gp
        nop
