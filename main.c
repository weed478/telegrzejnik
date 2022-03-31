#include "defs.h"
#include "system_timer.h"
#include "stepper.h"
#include "pins.h"

void stepper_set_pos(int pos);

void main()
{
    stepper_init(STEPPER_PIN0);

    for (;;)
    {
        stepper_set_pos(512);
        stepper_set_pos(-512);
    }
}
