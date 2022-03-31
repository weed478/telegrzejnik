#include "regs.h"



.section ".text.system_timer"



@ ---------------------

.global delay_ms
@ in: r0 = ms
delay_ms:
    mov r1, #1000
    mul r0, r0, r1
    b delay_us



@ ---------------------

.global delay_us
@ in: r0 = us
delay_us:
    push {r4-r5, lr}

    @ r4 = delay
    mov r4, r0

    @ r5 = start
    bl micros
    mov r5, r0

    delay_us_loop:
        @ r0 = now
        bl micros
        
        @ r0 = elapsed = now - start
        sub r0, r0, r5

        @ elapsed cmp delay
        cmp r0, r4

        @ if elapsed < delay
        @   loop
        blo delay_us_loop

    pop {r4-r5, pc}



@ ---------------------

.global micros
@ out: r0 = micros
micros:
    ldr r1, =SYSTEM_TIMER_CLO
    ldr r0, [r1]
    bx lr



@ ---------------------

.global millis
@ out: r0 = millis
millis:
    push {lr}

    @ r0 = micros
    bl micros

    @ micros /= 1000
    mov r1, #1000
    udiv r0, r0, r1

    pop {pc}
