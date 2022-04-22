#define LEDS_COUNT (8)



.global tg_led_init
.global tg_led_set



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
    b tg_led_set



@ -------------------------

@ in: r0 = q8.8 level
tg_led_set:
    push {r4-r6, lr}

    # r4 = q8.8 level
    mov r4, r0

    @ r5 = buf base
    ldr r5, =buf

    @ r6 = counter
    ldr r6, =LEDS_COUNT

    @ for counter <- [LEDS_COUNT..1]
    loop:
        @ if (counter << 8) < level
        @   led = 100%
        mov r0, r6, lsl #8
        cmp r0, r4
        blt led_100

        @ else if counter - 1 == (level >> 8)
        @   led = (level - (counter << 8))% ???
        mov r0, r4, lsr #8
        sub r1, r6, #1
        cmp r1, r0
        beq led_dyn

        @ else
        @   led = 0%
        b led_0


        led_0:
            @ GRB = 0:0:0
            mov r3, #0
            b set_led


        led_100:
            @ r0 = colors_get(counter * 400 / LEDS_COUNTS)
            mov r1, #400
            mul r0, r6, r1
            ldr r1, =LEDS_COUNT
            udiv r0, r0, r1
            bl colors_get
            mov r3, r0
            b set_led

        led_dyn:
            @ r0 = colors_get(level * 400 / NUM_LEDS / 0x100)
            mov r1, #400
            mul r0, r4, r1
            ldr r1, =(LEDS_COUNT * 0x100)
            udiv r0, r0, r1
            bl colors_get


            @ r2: q8 = frac(level)
            and r2, r4, #0xff
            

            @ r1: q8 = extract chan 1
            and r1, r0, #0xff
            @ conv to q8
            mov r1, r1, lsl #8
            @ r1: q16 = chan * frac(level)
            mul r1, r1, r2
            @ r3[7:0] = int(new_chan)
            mov r3, r1, lsr #16


            @ r1: q8 = extract chan 2
            and r1, r0, #0xff00
            @ r1: q16 = chan * frac(level)
            mul r1, r1, r2
            @ conv to int
            mov r1, r1, lsr #16
            @ r3[15:8] = int(new_chan)
            orr r3, r1, lsl #8


            @ r1: q8 = extract chan 3
            and r1, r0, #0xff0000
            @ conv to q8
            mov r1, r1, lsr #8
            @ r1: q16 = chan * frac(level)
            mul r1, r1, r2
            @ cont to int
            mov r1, r1, lsr #16
            @ r3[23:16] = int(new_chan)
            orr r3, r1, lsl #16
            

            b set_led


        @ in: r3 = color
        set_led:

        @ G
        strb r3, [r5], #1

        @ R
        mov r1, r3, lsr #8
        strb r1, [r5], #1

        @ B
        mov r1, r3, lsr #16
        strb r1, [r5], #1

        @ counter--
        subs r6, r6, #1

        @ if counter != 0; loop
        bne loop

    pop {r4-r6, lr}

    @ ws2812_send(buf, LEDS_COUNT * 3)
    ldr r0, =buf
    ldr r1, =(LEDS_COUNT * 3)
    b ws2812_send
