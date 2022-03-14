#include "defs.h"
#include "gpio.h"
#include "system_timer.h"

#define LED (2)
#define BTN (3)

void main()
{
    gpio_set_function(LED, GPIO_FUNCTION_OUT);
    gpio_set_function(BTN, GPIO_FUNCTION_IN);
    gpio_set_pull(BTN, GPIO_PULL_UP);
    
    u64 last_blink = millis();

    for (;;)
    {
        u64 now = millis();

        if (last_blink + (gpio_read(BTN) ? 500 : 50) < now)
        {
            gpio_write(LED, !gpio_read(LED));
            last_blink = now;
        }
    }
}
