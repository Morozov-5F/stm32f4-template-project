#include <CMSIS/stm32f4xx.h>

#define LED_PIN 5
#define LED_ON() GPIOD->BSRR |= GPIO_BSRR_BR13
#define LED_OFF() GPIOD->BSRR &= ~GPIO_BSRR_BR13

int main(int argc, const char * argv[])
{
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIODEN;
    GPIOD->MODER |= GPIO_MODER_MODER13_0;

    GPIOD->ODR = GPIO_ODR_OD13;

    for ( ; ; ) {}
}
