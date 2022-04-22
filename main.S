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
        bl tg_dtmf_read_blocking
        mov r4, r0

        @ level = 0x0800 * num / 15
        mov r0, #0x0800
        mul r0, r0, r4
        mov r1, #15
        udiv r0, r0, r1
        bl tg_led_set

        mov r0, r4
        bl tg_dial_set_num

        b main_loop

    pop {r4, pc}
