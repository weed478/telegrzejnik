.text

@ -------------------------

.global main
main:
    bl tg_dtmf_init
    bl tg_dial_init
    bl tg_dial_home
    
    main_loop:
        bl tg_dtmf_read_blocking
        bl tg_dial_set_num

        b main_loop
