.section ".text.boot"

.global _start

_start:
    @ setup stack before code
    ldr     sp, =_start

    @ zero bss
    ldr     r1, =__bss_start
    ldr     r2, =__bss_end
    mov     r0, #0
    b       loop_cond
loop:
    @ write 0 to mem,
    @ move r1 by one word
    str     r0, [r1], #4
loop_cond:
    @ loop while r1 < r2
    cmp     r1, r2
    blt     loop

    @ call C entrypoint
    bl      main

    @ halt if main returns
halt:
    wfe
    b       halt
