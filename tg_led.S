#define LEDS_COUNT (8)



.global tg_led_init
.global tg_led_set_num



@ GRB buffer
.lcomm buf, (LEDS_COUNT * 3)



.text

@ -------------------------

tg_led_init:
    push {lr}
    bl ws2812_setup
    pop {lr}

    @ disable LEDs
    mov r0, #0
    b tg_led_set_num



@ -------------------------

@ in: r0 = num
tg_led_set_num:
    @ r2 = buf base
    ldr r2, =buf

    @ r3 = counter
    ldr r3, =LEDS_COUNT

    @ for counter <- [LEDS_COUNT..1]
    tg_led_set_num_loop:
        @ store GRB, increment buf base       
        
        @ G
        cmp r3, r0
        @ if counter <= num; green = 100
        movle r1, #50
        @ else; green = 0
        movgt r1, #0
        strb r1, [r2], #1

        @ R
        mov r1, #0
        strb r1, [r2], #1

        @ B
        mov r1, #0
        strb r1, [r2], #1
        
        @ counter--
        subs r3, r3, #1
        @ if counter != 0; loop
        bne tg_led_set_num_loop

    @ ws2812_send(buf, LEDS_COUNT * 3)
    ldr r0, =buf
    ldr r1, =(LEDS_COUNT * 3)
    b ws2812_send
