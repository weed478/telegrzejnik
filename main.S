#include "pins.h"



.lcomm last_pos, 4
.lcomm last_state, 4



.text

@ -------------------------

.global stepper_set_pos
@ in: r0 = pos
stepper_set_pos:
    push {r4-r6, lr}

    @ load variable addresses
    ldr r4, =last_pos
    ldr r5, =last_state

    @ r6 = new_pos
    mov r6, r0

    @ r1 = last_pos
    ldr r1, [r4]

    @ r2 = new_pos - last_pos
    @ if new_pos == last_pos
    @   return
    subs r2, r6, r1
    popeq {r4-r6, pc}

    @ stepper_set(STEPPER_PIN0, last_state, new_pos - last_pos)
    mov r0, #STEPPER_PIN0
    ldr r1, [r5]
    bl stepper_step
    @ r0 = new_state

    @ last_state = new_state
    str r0, [r5]

    @ last_pos = new_pos
    str r6, [r4]

    pop {r4-r6, pc}
