#ifndef MYKERNEL_GPIO_H
#define MYKERNEL_GPIO_H

#include "defs.h"

typedef uint gpio_num_t;

typedef enum gpio_function_t
{
    GPIO_FUNCTION_IN   = 0b000,
    GPIO_FUNCTION_OUT  = 0b001,
    GPIO_FUNCTION_ALT0 = 0b100,
    GPIO_FUNCTION_ALT1 = 0b101,
    GPIO_FUNCTION_ALT2 = 0b110,
    GPIO_FUNCTION_ALT3 = 0b111,
    GPIO_FUNCTION_ALT4 = 0b011,
    GPIO_FUNCTION_ALT5 = 0b010,
} gpio_function_t;

typedef enum gpio_pull_t
{
    GPIO_PULL_NONE = 0,
    GPIO_PULL_DOWN = 2,
    GPIO_PULL_UP   = 1,
} gpio_pull_t;

void gpio_set_function(gpio_num_t pin, gpio_function_t function);

void gpio_set_pull(gpio_num_t pin, gpio_pull_t pull);

uint gpio_read(gpio_num_t pin);

void gpio_write(gpio_num_t pin, uint val);

#endif
