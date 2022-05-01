.lcomm current_deg, 4



.text

@ -------------------------

.global main
main:
    push {r4-r5, lr}

    bl tg_dtmf_init
    bl tg_dial_init
    bl tg_led_init
    
    bl tg_dial_home

    @ current_deg = 0
    mov r0, #0
    ldr r1, =current_deg
    str r0, [r1]
    
    main_loop:
        @ r4 = target_deg
        bl tg_dtmf_read_number_blocking
        mov r4, r0

        @ r5 = current_deg
        ldr r0, =current_deg
        ldr r5, [r0]

        set_deg_loop:
            cmp r5, r4
            @ current == target: done
            beq main_loop
            @ current < target: current++
            addlt r5, #1
            @ current > target: current--
            subgt r5, #1

            @ tg_led_set(level)
            @ level = 0x0800 * current_deg / 360
            mov r0, #0x0800
            mul r0, r0, r5
            mov r1, #360
            udiv r0, r0, r1
            bl tg_led_set

            @ tg_dial_set_deg(current_deg)
            mov r0, r5
            bl tg_dial_set_deg

            b set_deg_loop

    pop {r4-r5, pc}
