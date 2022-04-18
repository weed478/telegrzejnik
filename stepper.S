#include "regs.h"
#include "gpio_defs.h"

#define STEP_DELAY_US (5000)



.section ".text.stepper"



@ -------------------

.global stepper_init
@ in: r0 = pin0
@ out: state
stepper_init:
    push {r4-r5, lr}

    @ r4 = pin0
    mov r4, r0
    @ r5 = pin offset
    mov r5, #0

    stepper_init_loop:
        @ gpio_set_function(pin0 + offset, GPIO_FUNCTION_OUT)
        add r0, r4, r5
        mov r1, #GPIO_FUNCTION_OUT
        bl gpio_set_function

        @ offset++
        add r5, r5, #1

        @ if offset < 4
        @   again
        cmp r5, #4
        blo stepper_init_loop

    @ stepper_set(pin0, 0)
    mov r0, r4
    mov r1, #0
    bl stepper_set

    @ return initial state
    mov r0, #0

    pop {r4-r5, pc}



@ -------------------

.global stepper_step
@ in: r0 = pin0
@     r1 = state
@     r2 = steps
@ out: new state
stepper_step:
    push {r4-r6, lr}

    @ r4 = pin0
    mov r4, r0
    @ r5 = state
    mov r5, r1
    @ r6 = steps
    mov r6, r2

    stepper_step_loop:
        @ steps cmp 0
        cmp r6, #0

        @ if steps == 0
        @   return
        beq stepper_step_end

        @ if steps > 0
        @   state++
        @   steps--
        addgt r5, r5, #1
        subgt r6, r6, #1

        @ if steps < 0
        @   state--
        @   steps++
        sublt r5, r5, #1
        addlt r6, r6, #1

        @ state %= 4
        and r5, r5, #0b11

        @ r0 = pin0
        mov r0, r4
        @ r1 = state
        mov r1, r5
        bl stepper_set

        @ step delay
        mov r0, #STEP_DELAY_US
        bl delay_us

        b stepper_step_loop

    stepper_step_end:
    @ return new state
    mov r0, r5

    pop {r4-r6, pc}



@ -------------------

@ in: r0 = pin0
@     r1 = state [0-3]
stepper_set:
    mov r2, #0b00110011
    lsl r1, r2, r1
    lsr r1, r1, #4
    b stepper_set_bits



@ -------------------

@ in: r0 = pin0
@     r1 = bit mask
stepper_set_bits:
    push {r4-r5, lr}

    @ r4 = pin0
    mov r4, r0
    @ r5 = mask
    mov r5, r1

    @ r0 = pin0
    add r0, r4, #0
    @ r1 = bit 3 of mask
    and r1, r5, #8
    bl gpio_write

    @ r0 = pin1
    add r0, r4, #1
    @ r1 = bit 2 of mask
    and r1, r5, #4
    bl gpio_write

    @ r0 = pin2
    add r0, r4, #2
    @ r1 = bit 1 of mask
    and r1, r5, #2
    bl gpio_write

    @ r0 = pin3
    add r0, r4, #3
    @ r1 = bit 0 of mask
    and r1, r5, #1
    bl gpio_write

    pop {r4-r5, pc}
