#include "pins.h"



.global tg_dtmf_init
.global tg_dtmf_read_blocking



.text

@ -------------------------

tg_dtmf_init:
    ldr r0, =DTMF_PIN0
    b dtmf_init



@ -------------------------

tg_dtmf_read_blocking:
    ldr r0, =DTMF_PIN0
    b dtmf_read_blocking
