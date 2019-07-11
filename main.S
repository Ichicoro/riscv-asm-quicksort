.equ _SYS_EX, 93
.equ _SYS_WR, 64

.global _start

.include "quicksort.S"
.include "itoa.S"

.section .rodata
    num: .byte 12
    arrsize: .byte 7
    whitespace: .string " "

.section .data
    testarray: .byte 5,1,3,7,8,10,6
    str: .string ""

.section .text
_start:
    la a1, testarray
    addi a2, zero, 0
    lb a3, arrsize
    addi a3, a3, -1
    jal ra, quicksort

    la a0, testarray
    lb a1, arrsize
    jal ra, printarray

    # STOP EXECUTION
    li a7, _SYS_EX
	ecall


# printarray(a0: array address, a1: array length)
printarray: 
    addi sp, sp, -48
    sd ra, 0(sp)
    sd s11, 8(sp)                   # -- push s11 in the stack!
    sd s10, 16(sp)                  # -- push s10 in the stack!
    sd s9, 24(sp)                   # -- push s9 in the stack!
    sd s8, 32(sp)                   # -- push s8 in the stack!
    sd s7, 40(sp)                   # -- push s7 in the stack!

    mv s11, a0                      # s11 = *testarray
    mv s10, a1                      # s10 = length(testarray)

    add s7, s11, zero

    printarray_loop:
        add s7, s8, s11     # s7 = *s11+index = location of current number
        
        # use itoa on *s11+index to get an address with a printable string
        lb a1, 0(s7)
        la a0, str
        jal ra, itoa

        # print the number at *s11+index
        mv a2, a0       # lunghezza della stringa
        la a1, str      # stringa
        li a0, 0
        li a7, _SYS_WR 
        ecall

        # print out whitespace
        addi a2, zero, 1
        la a1, whitespace
        li a0, 0
        li a7, _SYS_WR
        ecall

        # increment the loop counter
        addi s8, s8, 1
    bne s10, s8, printarray_loop

    ld ra, 0(sp)
    ld s11, 8(sp)                   # -- pop back s11 from the stack
    ld s10, 16(sp)                  # -- pop back s10 from the stack
    ld s9, 24(sp)                   # -- pop back s9 from the stack
    ld s8, 32(sp)                   # -- pop back s8 from the stack
    ld s7, 40(sp)                   # -- pop back s7 from the stack
    addi sp, sp, 48
    ret
