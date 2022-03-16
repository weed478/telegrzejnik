#include "defs.h"
#include "gpio.h"
#include "system_timer.h"
#include "ws2812.h"

#define LED (2)
#define BTN (3)

void main()
{
    ws2812_setup();

    gpio_set_function(LED, GPIO_FUNCTION_OUT);
    gpio_set_function(BTN, GPIO_FUNCTION_IN);
    gpio_set_pull(BTN, GPIO_PULL_UP);
    
    u64 last_blink = 0;
    u64 last_led = 0;

    for (;;)
    {
        u64 now = micros();

        if (last_blink + (gpio_read(BTN) ? 500000 : 50000) < now)
        {
            gpio_write(LED, !gpio_read(LED));
            last_blink = now;
        }

        if (last_led + 1000 < now)
        {
            u8 data[] = {
                255, 0, 0,
                0, 255, 0,
                0, 0, 255,
            };
            ws2812_send(data, sizeof(data));
            last_led = now;
        }
    }
}
