#include "ws2812.h"

#include "gpio.h"
#include "system_timer.h"
#include "regs.h"

void ws2812_setup()
{
    // PWM0_0
    gpio_set_function(12, GPIO_FUNCTION_ALT0);

    // reset PWM
    REG(PWM0_CTL) = 0u;
    delay_us(10);

    // stop and set source
    //                                PLLD = 500 MHz
    REG(CM_PWMCTL) = (0x5au << 24) | (6u << 0);
    delay_us(10);

    // set divider
    //                                int            frac
    REG(CM_PWMDIV) = (0x5au << 24) | (200u << 12) | (0u << 0);
    delay_us(10);
    // f = 2.5 MHz
    
    // enable clock
    //                                PLLD        enable
    REG(CM_PWMCTL) = (0x5au << 24) | (6u << 0) | (1u << 4);
    delay_us(10);

    // last bit padded to 0
    REG(PWM0_RNG1) = 33u;
    delay_us(10);

    // flush fifo
    //               CLRF
    REG(PWM0_CTL) = (1u << 6);
    delay_us(10);

    // start PWM
    //               USEF1       MODE1
    REG(PWM0_CTL) = (1u << 5) | (1u << 1);
    delay_us(10);
}

void ws2812_send(u8 data[], uint n)
{
    if (n > 86) n = 86;

    u32 words[64];
    for (uint i = 0; i < sizeof(words) / sizeof(*words); ++i)
    {
        words[i] = 0;
    }

    uint nwords = 0;
    uint nbits = 0;

    // byte
    for (uint Bi = 0; Bi < n; ++Bi)
    {
        // bit
        for (uint bi = 0; bi < 8; ++bi)
        {
            // MSB first
            uint bit = (data[Bi] << bi) & (1 << 7);
            words[nwords] |= (bit ? (0b110u << 29) : (0b100u << 29)) >> nbits;
            nbits += 3;
            if (nbits >= 33)
            {
                nwords++;
                nbits = 0;
            }
        }
    }

    // wait for last transmission
    //                        EMPT1
    while (!(REG(PWM0_STA) & (1u << 1)));

    // disable
    REG(PWM0_CTL) &= ~1u;
    delay_us(10);

    // fill fifo
    for (uint i = 0; i < sizeof(words) / sizeof(*words); ++i)
    {
        REG(PWM0_FIF1) = words[i];
    }

    // start transmission
    REG(PWM0_CTL) |= 1u;
}
