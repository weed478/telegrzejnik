#ifndef MYKERNEL_GPIO_H
#define MYKERNEL_GPIO_H

#include "defs.h"
#include "gpio_defs.h"

typedef uint gpio_num_t;
typedef uint gpio_function_t;
typedef uint gpio_pull_t;

void gpio_set_function(gpio_num_t pin, gpio_function_t function);

void gpio_set_pull(gpio_num_t pin, gpio_pull_t pull);

uint gpio_read(gpio_num_t pin);

void gpio_write(gpio_num_t pin, uint val);

#endif
