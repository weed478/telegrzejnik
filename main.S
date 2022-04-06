.text

@ -------------------------

.global main
main:
    bl tg_dial_init
    bl tg_dial_home

    ldr r0, =1000
    bl delay_ms
    
    main_loop:
        ldr r0, =3
        bl tg_dial_set_num
        ldr r0, =500
        bl delay_ms

        ldr r0, =180
        bl tg_dial_set_deg
        ldr r0, =500
        bl delay_ms

        ldr r0, =0
        bl tg_dial_set_num
        ldr r0, =500
        bl delay_ms

        b main_loop
