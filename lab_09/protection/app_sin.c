#include <stdio.h>
#include <math.h>

int main(void)
{
    double pi1 = 3.14;
    double pi2 = 3.141596;
    float pi_asm;

    asm(
        "finit  \n\t"
        "fldpi  \n\t"
        "fstp   %0\n\t"
        : "=m" (pi_asm)
    );

    printf("-----------sin(pi)----------\n");
    printf("sin(3.14)      : %9lf\n", sin(pi1));
    printf("sin(3.141596)  : %9lf\n", sin(pi2));
    printf("sin(pi_asm)    : %9lf\n", sin(pi_asm));

    printf("----------sin(pi/2)---------\n");
    printf("sin(3.14/2)    : %9lf\n", sin(pi1 / 2));
    printf("sin(3.141596/2): %9lf\n", sin(pi2 / 2));
    printf("sin(pi_asm/2)  : %9lf\n", sin(pi_asm / 2));

    return 0;
}