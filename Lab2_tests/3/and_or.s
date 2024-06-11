# test and & or
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: and & or"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   and     $t0, $gp, $gp
        and     $t1, $gp, $sp
        and     $t2, $a2, $sp
        and     $t3, $t1, $t2
        and     $0, $gp, $gp
        or      $s0, $gp, $gp
        or      $s1, $gp, $sp
        or      $s2, $a2, $sp
        or      $s3, $s1, $s2
        or      $0, $gp, $gp