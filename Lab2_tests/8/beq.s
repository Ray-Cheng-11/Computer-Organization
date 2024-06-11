# test beq
        .data   0x10008000      # start of Dynamic Data (pointed by $gp)
title:  .asciiz "Test: beq (for-loop sum form 0 to 15)"
        .text   0x00400000      # start of Text (pointed by PC), 
main:   
        # li      $a0, 16         # N = 16
        # li      $a1, 1          # const 1
        add     $t0, $0, $0     # i: t0 = 0
        add     $t1, $0, $0     # c: t1 = 0
loop:   bge     $t0, $a0, exit	# if i >= N exit (bge -> slt & beq)
        add     $t1, $t1, $t0   # c += i
        add     $t0, $t0, $a1   # i++
        beq     $0, $0, loop
exit:   nop
        nop
