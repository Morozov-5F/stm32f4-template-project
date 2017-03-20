#include <CMSIS/stm32f4xx.h>

int main(int argc, const char * argv[])
{
    /* Enable Orange LED on STM32f4DISCOVERY */
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIODEN;
    GPIOD->MODER |= GPIO_MODER_MODER13_0;

    GPIOD->ODR = GPIO_ODR_OD13;

    for ( ; ; ) {}
}
