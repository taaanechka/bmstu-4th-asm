#include <stdio.h>

float add_float(float a, float b)
{
    float c = 0;

    c = a + b;

    return c;
}

int main(void)
{
    float a = 23.654, b = 32848.2423;
    float c = add_float(a, b);

    return 0;
}