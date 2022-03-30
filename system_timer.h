#ifndef MYKERNEL_SYSTEM_TIMER_H
#define MYKERNEL_SYSTEM_TIMER_H

#include "defs.h"

u32 millis();

u32 micros();

void delay_ms(u32 ms);

void delay_us(u32 us);

#endif
