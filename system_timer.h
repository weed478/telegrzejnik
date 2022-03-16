#ifndef MYKERNEL_SYSTEM_TIMER_H
#define MYKERNEL_SYSTEM_TIMER_H

#include "defs.h"

u64 millis();

u64 micros();

void delay_ms(u64 ms);

void delay_us(u64 us);

#endif
