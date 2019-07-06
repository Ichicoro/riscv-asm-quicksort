.equ _SYS_EX, 93
.equ _SYS_WR, 64

.global _start

.include "itoa.S"

.section .rodata
    testarray: .byte 5,1,3,7,8,10,6
    num: .byte 12
    arrsize: .byte 7

.section .data
    str: .string ""

.section .text
_start:
    nop
    jal ra, printarray

    # STOP EXECUTIONS
    li a7, _SYS_EX
	ecall



# printarray(a0: array address, a1: array length)
printarray: 
    # save ra in stack
    addi sp, sp, -8
    sd ra, 0(sp)

    # save saved registers to stack and setup loop variables
    addi sp, sp, -16
    sd s11, 0(sp)                   # -- butto s11 nello stack!
    sd s10, 8(sp)                   # -- butto s10 nello stack!
    addi t1, zero, 0                # t1 = 0
    mv s11, a0                      # s11 = *testarray
    addi s10, a1, 0                 # s10 = length(testarray)

    addi sp, sp, -8                 # -- butto s9 nello stack!
    sd s9, 0(sp)
    printarray_loop:
        addi sp, sp, -8
        sd t1, 0(sp)                # -- butto t1 nello stack!
        
        # chiamo num_len e salvo il risultato in s9 (dopo aver salvato i contenuti precedenti nello stack)
        lb a0, 0(s11)
        jal ra, num_len
        
        mv s9, a0   # sposto il risultato di num_len in s9
        
        # chiamo itoa per avere una stringa col numero
        ld a1, 0(s11)
        la a0, str
        jal ra, itoa
        # e salvo i risultati


        # chiamo print
        mv a1, a0       # stringa
        li a0, 0        # uhhh
        mv a2, s9       # lunghezza della stringa
        li a7, _SYS_WR 
        ecall


        ld t1, 0(sp)                # -- tiro fuori t1 dallo stack!
        addi sp, sp, 8
        addi t1, t1, 1
    bne s10, t1, printarray_loop
    
    ld s9, 0(sp)                    # -- riprendo s9 dallo stack!
    addi sp, sp, 8

    ld s11, 0(sp)                   # -- riprendo s11 dallo stack!
    ld s10, 8(sp)                   # -- riprendo s10 dallo stack!
    addi sp, sp, 16

    #return back to start
    ld ra, 0(sp)
    addi sp, sp, 8
    ret

    
