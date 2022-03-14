#include "gpio.h"

#include "regs.h"

void gpio_set_function(gpio_num_t pin, gpio_function_t function)
{
    reg_addr_t gpfsel;
    if (pin < 10)
        gpfsel = GPIO_GPFSEL0;
    else if (pin < 20)
        gpfsel = GPIO_GPFSEL1;
    else if (pin < 30)
        gpfsel = GPIO_GPFSEL2;
    else if (pin < 40)
        gpfsel = GPIO_GPFSEL3;
    else if (pin < 50)
        gpfsel = GPIO_GPFSEL4;
    else
        gpfsel = GPIO_GPFSEL5;

    uint val = REG(gpfsel);
    val &= ~(0b111 << ((pin % 10) * 3));
    val |= function << ((pin % 10) * 3);
    REG(gpfsel) = val;
}

void gpio_set_pull(gpio_num_t pin, gpio_pull_t pull)
{
    reg_addr_t reg;
    if (pin < 16)
        reg = GPIO_PUP_PDN_CNTRL_REG0;
    else if (pin < 32)
        reg = GPIO_PUP_PDN_CNTRL_REG1;
    else if (pin < 48)
        reg = GPIO_PUP_PDN_CNTRL_REG2;
    else
        reg = GPIO_PUP_PDN_CNTRL_REG3;

    uint val = REG(reg);
    val &= ~(0b11 << ((pin % 16) * 2));
    val |= pull << ((pin % 16) * 2);
    REG(reg) = val;
}

uint gpio_read(gpio_num_t pin)
{
    reg_addr_t gplev;
    if (pin < 32)
        gplev = GPIO_GPLEV0;
    else
        gplev = GPIO_GPLEV1;

    return REG(gplev) & (1 << (pin % 32));
}

static void gpio_set(gpio_num_t pin)
{
    reg_addr_t gpset;
    if (pin < 32)
        gpset = GPIO_GPSET0;
    else
        gpset = GPIO_GPSET1;

    REG(gpset) = 1 << (pin % 32);
}

static void gpio_clear(gpio_num_t pin)
{
    reg_addr_t gpclr;
    if (pin < 32)
        gpclr = GPIO_GPCLR0;
    else
        gpclr = GPIO_GPCLR1;

    REG(gpclr) = 1 << (pin % 32);
}

void gpio_write(gpio_num_t pin, uint val)
{
    if (val) gpio_set(pin);
    else     gpio_clear(pin);
}
