.global colors_get



.text

@ -------------------------

@ in: r0 = x in [0..400]
@ out: r0[7:0] = G
@      r0[15:8] = R
@      r0[23:16] = B
colors_get:
    @ r1 = x / 4
    mov r1, r0, lsr #2

    @ if x < 200
    @   process low
    @ else
    @   process high
    cmp r0, #200
    blt colors_get_low

    
    colors_get_high:
        @ out = G = 100 - x/4
        mov r3, #100
        sub r0, r3, r1

        @ out[15:8] = R = x/4 - 50
        sub r2, r1, #50
        orr r0, r0, r2, lsl #8

        @ B = 0

        bx lr


    colors_get_low:
        @ out = G = x/4
        mov r0, r1

        @ R = 0

        @ out[23:16] = B = 50 - x/4
        mov r3, #50
        sub r2, r3, r1
        orr r0, r0, r2, lsl #16

        bx lr
