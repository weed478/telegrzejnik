#include "system_timer.h"

#include "regs.h"

u64 millis()
{
    u32 lo = REG(SYSTEM_TIMER_CLO);
    u32 hi = REG(SYSTEM_TIMER_CHI);
    return (((u64) (hi / 1000)) << 32) | ((u64) (lo / 1000));
}

u64 micros()
{
    u64 lo = REG(SYSTEM_TIMER_CLO);
    u64 hi = REG(SYSTEM_TIMER_CHI);
    return (hi << 32) | lo;
}

void delay_ms(u64 ms)
{
    u64 stop = micros() + ms * 1000;
    while (micros() < stop);
}

void delay_us(u64 us)
{
    u64 stop = micros() + us;
    while (micros() < stop);
}
