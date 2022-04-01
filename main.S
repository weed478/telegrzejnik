#include "pins.h"
#include "gpio_defs.h"



.lcomm tg_stepper_pos, 4
.lcomm tg_stepper_state, 4



.text

@ -------------------------

.global main
main:
    bl tg_init
    bl tg_stepper_home

    ldr r0, =1000
    bl delay_ms
    
    main_loop:
        ldr r0, =512
        bl tg_stepper_set
        ldr r0, =500
        bl delay_ms

        ldr r0, =-512
        bl tg_stepper_set
        ldr r0, =500
        bl delay_ms

        b main_loop



@ -------------------------

tg_init:
    push {lr}

    @ tg_stepper_state = stepper_init(STEPPER_PIN0)
    ldr r0, =STEPPER_PIN0
    bl stepper_init
    ldr r1, =tg_stepper_state
    str r0, [r1]

    @ gpio_set_function(STEPPER_HOME_PIN, GPIO_FUNCTION_IN)
    ldr r0, =STEPPER_HOME_PIN
    ldr r1, =GPIO_FUNCTION_IN
    bl gpio_set_function

    @ gpio_set_pull(STEPPER_HOME_PIN, GPIO_PULL_UP)
    ldr r0, =STEPPER_HOME_PIN
    ldr r1, =GPIO_PULL_UP
    pop {lr}
    b gpio_set_pull



@ -------------------------

tg_stepper_home:
    push {r4, lr}

    @ stage1 = leave home switch
    tg_stepper_home_stage1:
        @ r0 = read home switch
        bl tg_stepper_read_home_switch

        @ if home switch not pressed
        @   go to stage2
        cmp r0, #0
        bne tg_stepper_home_stage2

        @ tg_stepper_step(1)
        ldr r0, =1
        bl tg_stepper_step

        @ loop
        b tg_stepper_home_stage1

    @ stage2 = find home switch
    tg_stepper_home_stage2:
        @ r0 = read home switch
        bl tg_stepper_read_home_switch

        @ if home switch pressed
        @   go to stage3
        cmp r0, #0
        beq tg_stepper_home_stage3

        @ tg_stepper_step(-1)
        ldr r0, =-1
        bl tg_stepper_step

        @ loop
        b tg_stepper_home_stage2

    @ stage3 = measure home area
    @ r4 = home area width
    ldr r4, =0
    tg_stepper_home_stage3:
        @ r0 = read home switch
        bl tg_stepper_read_home_switch

        @ if home switch not pressed
        @   go to stage4
        cmp r0, #0
        bne tg_stepper_home_stage4

        @ tg_stepper_step(-1)
        ldr r0, =-1
        bl tg_stepper_step

        @ home area width ++
        add r4, r4, #1

        @ loop
        b tg_stepper_home_stage3

    @ stage4 = move to center of home area
    tg_stepper_home_stage4:
        @ tg_stepper_step(width / 2)
        lsr r0, r4, #1
        bl tg_stepper_step

    @ pos = 0
    ldr r0, =0
    ldr r1, =tg_stepper_pos
    str r0, [r1]

    pop {r4, pc}



@ -------------------------

tg_stepper_read_home_switch:
    @ return gpio_read(STEPPER_HOME_PIN)
    ldr r0, =STEPPER_HOME_PIN
    b gpio_read



@ -------------------------

@ in: r0 = steps
tg_stepper_step:
    push {lr}

    @ state = stepper_step(STEPPER_PIN0, state, steps)

    @ steps
    mov r2, r0

    @ pin
    ldr r0, =STEPPER_PIN0

    @ state
    ldr r3, =tg_stepper_state
    ldr r1, [r3]

    bl stepper_step

    @ state = new state
    ldr r1, =tg_stepper_state
    str r0, [r1]

    pop {pc}



@ -------------------------

@ in: r0 = pos
tg_stepper_set:
    push {r4-r6, lr}

    @ load variable addresses
    ldr r4, =tg_stepper_pos
    ldr r5, =tg_stepper_state

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
