.equ _SYS_EX, 93
.equ _SYS_WR, 64

.global _start

.include "itoa.S"

.section .rodata
    num: .byte 12
    arrsize: .byte 7
    whitespace: .string " "

.section .data
    str: .string ""
    testarray: .byte 5,1,3,7,8,10,6

.section .text
_start:
    # la a0, testarray
    # lb a1, arrsize
    # jal ra, printarray

    la a1, testarray
    addi a2, zero, 0
    lb a3, arrsize
    jal ra, quicksort

    la a0, testarray
    lb a1, arrsize
    jal ra, printarray

    # STOP EXECUTIONS
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


# quicksort(*arr, lo, hi)
# arr -> a1
# lo -> a2
# hi -> a3
quicksort:
    bge a2, a3, quicksort_exit # if (lo >= hi) we just return
    
    # save in stack
    addi sp, sp, -32
    sd ra, 0(sp)
    sd s10, 8(sp)       # s10 is going to hold lo
    sd s11, 16(sp)      # s11 is going to hold hi
    sd s9, 24(sp)       # s9 is going to hold the pivot

    # hold lo and hi
    mv s10, a2          # s10 <- lo
    mv s11, a3          # s11 <- hi

    # chiamo partition
    jal ra, partition
    # ebreak

    # save the pivot on s9
    mv s9, a0

    # s9 = pivot
    # s10 = lo
    # s11 = hi

    # recursively call quicksort on both subarrays
    mv a2, s10          # lo = lo
    mv a3, s9           # hi = pivot
    jal ra, quicksort

    # ebreak

    mv a2, s9           # lo = pivot
    mv a3, s11          # hi = hi
    jal ra, quicksort

    # load from stack
    ld ra, 0(sp)
    ld s10, 8(sp)
    ld s11, 16(sp)
    ld s9, 24(sp)
    addi sp, sp, 32
quicksort_exit:
    ret



# partition(*arr, lo, hi) -> pivot
# arr -> a1
# lo -> a2
# hi -> a3
# pivot <- a0 (return value)
partition:
    beq a2, a3, partition_bail

    # save ra in stack
    addi sp, sp, -24
    sd ra, 0(sp)
    sd s10, 8(sp)
    sd s11, 16(sp)

    # used = t0, t1, t2, .., .., t5, t6

    mv t0, a3 # init pivot to a3 (hi)

    addi t2, a2, -1     # (i) index of the smaller element => t2 = low - 1
    mv t6, a2           # t6 = j = low
    addi t5, a3, -1     # t5 = high-1

    partition_forloop:
    bgt t6, t5, partition_forloop_end # if t6 > t5 then partition_forloop_end
        add s11, a1, t6         # s11 = *arr[j]  <---- interessante
        lb t1, 0(s11)           # t1 = *(s11)
        
        bgt t1, t0, partition_forloop_inner_skip
            addi t2, t2, 1      # i++
            add s10, a1, t2     # s10 = *arr[t2] = *arr[i]
            lb t3, 0(s10)       # t3 = *(s10)
            sb t3, 0(s11)       # arr[j] = t3
            sb t1, 0(s10)       # arr
        partition_forloop_inner_skip:
        
        addi t6, t6, 1  # j++
    j partition_forloop
    partition_forloop_end:    
    
    addi a0, t2, 1      # return i+1
    # ebreak

    # load ra from stack
    ld ra, 0(sp)
    ld s10, 8(sp)
    ld s11, 16(sp)
    addi sp, sp, 24
partition_bail:
    ret
