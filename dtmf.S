#include "gpio_defs.h"



.global dtmf_init
.global dtmf_read_number_blocking



.text

@ -------------------------

@ in: r0 = pin0
dtmf_init:
    push {r4-r5, lr}

    @ r4 = pin0 - 1
    sub r4, r0, #1
    @ r5 = offset
    mov r5, #5

    @ for offset <- [5..1]
    dtmf_init_loop:
        @ gpio_set_function(pin0 - 1 + offset, GPIO_FUNCTION_IN)
        add r0, r4, r5
        ldr r1, =GPIO_FUNCTION_IN
        bl gpio_set_function

        @ gpio_set_pull(pin0 - 1 + offset, GPIO_PULL_NONE)
        add r0, r4, r5
        ldr r1, =GPIO_PULL_NONE
        bl gpio_set_pull

        @ if --offset != 0; loop
        subs r5, r5, #1
        bne dtmf_init_loop
    
    pop {r4-r5, pc}



@ -------------------------

@ in: r0 = pin0
dtmf_wait:
    push {r4, lr}

    @ r4 = data ready pin (pin4)
    add r4, r0, #4

    dtmf_wait_loop_high:
        @ r0 = gpio_read(data ready)
        mov r0, r4
        bl gpio_read
        @ if data ready; loop
        cmp r0, #0
        beq dtmf_wait_loop_high

    dtmf_wait_loop_low:
        @ r0 = gpio_read(data ready)
        mov r0, r4
        bl gpio_read
        @ if not data ready; loop
        cmp r0, #0
        bne dtmf_wait_loop_low

    pop {r4, pc}



@ -------------------------

@ in: r0 = pin0
@ out: r0 = dtmf code
dtmf_read:
    push {r4-r6, lr}

    # r4 = pin0 - 1
    sub r4, r0, #1
    @ r5 = offset
    mov r5, #4
    @ r6 = output
    mov r6, #0

    @ for offset <- [4..1]
    dtmf_read_loop:
        @ r0 = gpio_read(pin0 - 1 + offset)
        add r0, r4, r5
        bl gpio_read
        
        @ output |= gpio << offset
        cmp r0, #0
        moveq r0, #0
        movne r0, #1
        orr r6, r6, r0, lsl r5
        
        @ if --offset != 0; loop
        subs r5, r5, #1
        bne dtmf_read_loop

    @ return output >> 1
    mov r0, r6, lsr #1

    pop {r4-r6, pc}



@ -------------------------

@ in: r0 = pin0
@ out: r0 = dtmf code
dtmf_read_blocking:
    push {r0, lr}
    bl dtmf_wait
    pop {r0, lr}
    b dtmf_read



@ -------------------------

@ in: r0 = pin0
@ out: r0 = entered number
dtmf_read_number_blocking:
    push {r4-r5, lr}

    @ r4 = output
    mov r4, #0

    @ r5 = pin0
    mov r5, r0

    dtmf_read_number_blocking_loop:
        @ r0 = digit = dtmf_read_blocking(pin0)
        mov r0, r5
        bl dtmf_read_blocking

        @ dtmf code 10 = # (confirm)
        cmp r0, #12
        beq dtmf_read_number_blocking_confirm

        @ dtmf code 10 = digit 0
        cmp r0, #10
        moveq r0, #0

        @ output *= 10
        mov r1, #10
        mul r4, r4, r1

        @ output += digit
        add r4, r4, r0

        b dtmf_read_number_blocking_loop
    
    dtmf_read_number_blocking_confirm:

    @ return output
    mov r0, r4

    pop {r4-r5, pc}
