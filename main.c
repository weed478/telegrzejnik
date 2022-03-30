#include "defs.h"
#include "system_timer.h"
#include "stepper.h"
#include "gpio.h"

#define STEPPER_PIN0 (14)
#define LED_PIN (18)

void main()
{
    uint state = stepper_init(STEPPER_PIN0);
    gpio_set_function(LED_PIN, GPIO_FUNCTION_OUT);

    for (;;)
    {
        state = stepper_step(STEPPER_PIN0, state, 100);   
        gpio_write(LED_PIN, 0);

        state = stepper_step(STEPPER_PIN0, state, -100);
        gpio_write(LED_PIN, 1);
    }
}
