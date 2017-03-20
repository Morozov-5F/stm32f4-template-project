#include <CMSIS/stm32f4xx.h>

void TIM2_IRQHandler(void)
{
    if (TIM2->SR & TIM_SR_UIF)
    {
        GPIOD->ODR ^= (GPIO_ODR_OD12 | GPIO_ODR_OD14);
    }

    TIM2->SR = 0x0;
}

int main(int argc, const char * argv[])
{
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIODEN;
    RCC->APB1ENR |= RCC_APB1ENR_TIM2EN;

    /* Enable green and red LEDs */
    GPIOD->MODER |= GPIO_MODER_MODER12_0 | GPIO_MODER_MODER14_0;

    /* Timer configuration (one second blink) */
    NVIC->ISER[0] |= 1 << (TIM2_IRQn);

    TIM2->PSC = 1680;
    TIM2->DIER = TIM_DIER_UIE;
    TIM2->ARR = 10000;
    TIM2->CR1 |= TIM_CR1_ARPE | TIM_CR1_CEN;
    TIM2->EGR = 0x01;

    for ( ; ; ) {}
}
