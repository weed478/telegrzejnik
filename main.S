.text

@ -------------------------

.global main
main:
    push {r4, lr}

    bl tg_dtmf_init
    bl tg_dial_init
    bl tg_led_init
    
    bl tg_dial_home
    
    main_loop:
        @ r4 = deg
        bl tg_dtmf_read_number_blocking
        mov r4, r0

        @ level = 0x0800 * deg / 360
        mov r0, #0x0800
        mul r0, r0, r4
        mov r1, #360
        udiv r0, r0, r1
        bl tg_led_set

        mov r0, r4
        bl tg_dial_set_deg

        b main_loop

    pop {r4, pc}
