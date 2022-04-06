#include "pins.h"
#include "gpio_defs.h"



.global tg_dial_init
.global tg_dial_home
.global tg_dial_set_deg
.global tg_dial_set_num



.lcomm pos, 4
.lcomm state, 4



.text

@ -------------------------

tg_dial_init:
    push {lr}

    @ state = stepper_init(STEPPER_PIN0)
    ldr r0, =STEPPER_PIN0
    bl stepper_init
    ldr r1, =state
    str r0, [r1]

    @ gpio_set_function(STEPPER_HOME_PIN, GPIO_FUNCTION_IN)
    ldr r0, =STEPPER_HOME_PIN
    ldr r1, =GPIO_FUNCTION_IN
    pop {lr}
    b gpio_set_function



@ -------------------------

tg_dial_home:
    push {r4, lr}

    @ stage1 = leave home switch
    home_stage1:
        @ r0 = read home switch
        bl read_home_switch

        @ if home switch not pressed
        @   go to stage2
        cmp r0, #0
        bne home_stage2

        @ step(1)
        ldr r0, =1
        bl step

        @ loop
        b home_stage1

    @ stage2 = find home switch
    home_stage2:
        @ r0 = read home switch
        bl read_home_switch

        @ if home switch pressed
        @   go to stage3
        cmp r0, #0
        beq home_stage3

        @ step(-1)
        ldr r0, =-1
        bl step

        @ loop
        b home_stage2

    @ stage3 = measure home area
    @ r4 = home area width
    ldr r4, =0
    home_stage3:
        @ r0 = read home switch
        bl read_home_switch

        @ if home switch not pressed
        @   go to stage4
        cmp r0, #0
        bne home_stage4

        @ step(-1)
        ldr r0, =-1
        bl step

        @ home area width ++
        add r4, r4, #1

        @ loop
        b home_stage3

    @ stage4 = move to center of home area
    home_stage4:
        @ step(width / 2)
        lsr r0, r4, #1
        bl step

    @ pos = 0
    ldr r0, =0
    ldr r1, =pos
    str r0, [r1]

    pop {r4, pc}



@ -------------------------

@ in: r0 = num
tg_dial_set_num:
    ldr r1, =-2048
    mul r0, r0, r1
    ldr r1, =10
    sdiv r0, r0, r1 
    b set_steps



@ -------------------------

@ in: r0 = deg
tg_dial_set_deg:
    ldr r1, =-2048
    mul r0, r0, r1
    ldr r1, =360
    sdiv r0, r0, r1
    b set_steps



@ -------------------------

read_home_switch:
    @ return gpio_read(STEPPER_HOME_PIN)
    ldr r0, =STEPPER_HOME_PIN
    b gpio_read



@ -------------------------

@ in: r0 = steps
step:
    push {lr}

    @ state = stepper_step(STEPPER_PIN0, state, steps)

    @ steps
    mov r2, r0

    @ pin
    ldr r0, =STEPPER_PIN0

    @ state
    ldr r3, =state
    ldr r1, [r3]

    bl stepper_step

    @ state = new state
    ldr r1, =state
    str r0, [r1]

    pop {pc}



@ -------------------------

@ in: r0 = pos
set_steps:
    push {r4-r6, lr}

    @ load variable addresses
    ldr r4, =pos
    ldr r5, =state

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
    ldr r0, =STEPPER_PIN0
    ldr r1, [r5]
    bl stepper_step
    @ r0 = new_state

    @ last_state = new_state
    str r0, [r5]

    @ last_pos = new_pos
    str r6, [r4]

    pop {r4-r6, pc}
