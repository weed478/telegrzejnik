#include "system_timer.h"

#include "regs.h"

static u64 system_timer_get_64()
{
    u64 lo = REG(SYSTEM_TIMER_CLO);
    u64 hi = REG(SYSTEM_TIMER_CHI);
    return (hi << 32) | lo;
}

u64 millis()
{
    return system_timer_get_64() / 1000;
}

u64 micros()
{
    return system_timer_get_64();
}
