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

        bl tg_led_set_num

        mov r0, r4
        bl tg_dial_set_num

        b main_loop

    pop {r4, pc}
