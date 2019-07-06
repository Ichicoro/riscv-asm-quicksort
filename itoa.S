.equ _SYS_READ, 63     
.equ _SYS_WRITE, 64     
.equ _SYS_EXIT, 93

.section .bss
.section .rodata
.section .data

    buffer : .string ""

.section .text

## STRING I/O  ######################

read:   
        li  a0, 1         #where to read FROM
        li  a7, _SYS_READ
        ecall
        ret

print:  
        li  a0, 0           #where to write
        li  a7, _SYS_WRITE
        ecall
        ret

## POW10 ########################### a0 := exponent ## return 10^exp in a0

pow10:  
        li  t0, 10
        li  t1, 0 #counter
        li  t2, 1 #result buffer

pow_lp:  
        bge     t1, a0, pow_end
        mul     t2, t2, t0
        addi    t1, t1, 1
        beq     zero, zero, pow_lp

pow_end: 
        mv  a0, t2
        ret

## NUM_LEN ########################### a0 := number ## return digits count in a0

num_len:
        addi    sp, sp, -8
        sd      ra, 0(sp)
        
        mv      t0, a0 #buffer
        li      t1, 0  #counter

nl_loop:
        ble     t0, zero, nl_end
        li      t2, 10
        div     t0, t0, t2
        addi    t1, t1, 1
        beq     zero, zero, nl_loop

nl_end: 
        mv      a0, t1
        ld      ra, 0(sp)
        addi    sp, sp, 8
        ret
        
## PARSEINT ########################### a0 := target address, a1 := source number ## returns string address in a0

itoa:
        addi    sp, sp, -16
        sd      ra, 8(sp)
        sd      a0, 0(sp)

        mv      a0, a1
        jal     ra, num_len
        mv      t3, a0      #digits count

        ld      a0, 0(sp)
        addi    sp, sp, 8

        li      t0, 0  #counter
        mv      t1, a1 #buffer
        li      t2, 0  #current char

itoa_lp:
        ble     t1, zero, itoa_end #branch if buffer <= 0
        bge     t0, t3, itoa_end   #branch if counter >= digits_count

        addi    sp, sp, -32
        sd      t1, 0(sp)
        sd      t0, 8(sp)
        sd      t3, 16(sp)
        sd      a0, 24(sp)

        sub     a0, t3, t0  #calculate 10^(digits_count - 1 - counter)
        addi    a0, a0, -1  #|
        jal     ra, pow10   #|

        ld      t1, 0(sp)
        ld      t0, 8(sp)
        ld      t3, 16(sp)
        addi    sp, sp, 24

        div     t2, t1, a0  #t2 = buffer / 10^(digits_count - 1 - counter) = digit to store
        remu    t1, t1, a0  #buffer = buffer % (10^(d-1-counter))

        ld      a0, 0(sp)
        addi    sp, sp, 8

        addi    t2, t2, '0' #t2 = actual char to store
        add     t4, a0, t0  #t4 = where to store char
        sb      t2, 0(t4)   #store char

        addi    t0, t0, 1
        beq     zero, zero, itoa_lp

itoa_end:
        mv      a0, t0
        ld      ra, 0(sp)
        addi    sp, sp, 8
        ret
