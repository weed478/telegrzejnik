#ifndef MYKERNEL_WS2812_H
#define MYKERNEL_WS2812_H

#include "defs.h"

void ws2812_setup();

void ws2812_send(u8 data[], uint n);

#endif
