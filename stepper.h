#ifndef MYKERNEL_STEPPER_H
#define MYKERNEL_STEPPER_H

#include "defs.h"

uint stepper_init(uint pin0);

uint stepper_step(uint pin0, uint state, int steps);

#endif
