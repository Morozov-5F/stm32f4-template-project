#include <CMSIS/stm32f407xx.h>

#define LED_PIN 5
#define LED_ON() GPIOA->BSRR |= GPIO_BSRR_BR13
#define LED_OFF() GPIOA->BSRR &= ~GPIO_BSRR_BR13

int main(int argc, const char * argv[])
{
	/* Enbale GPIOA clock */
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    /* Configure GPIOA pin 5 as output */
    GPIOD->MODER |= GPIO_MODER_MODER13;
    /* Configure GPIOA pin 5 in max speed */
    GPIOA->OSPEEDR |= GPIO_OSPEEDR_OSPEED13;
    /* Turn on the LED */
    LED_ON();

    for ( ; ; ) {}
}
