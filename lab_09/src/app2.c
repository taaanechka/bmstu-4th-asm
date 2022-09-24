#include <stdio.h>
#include <inttypes.h>
#include <sys/time.h>

#define N_REPEAT 1000000
//#define __addxf3

uint64_t tick(void)
{
    uint32_t high, low;
    __asm__ __volatile__ (
        "rdtsc\n"
        "movl %%edx, %0\n"
        "movl %%eax, %1\n"
        : "=r" (high), "=r" (low)
        :: "%rax", "%rbx", "%rcx", "%rdx"
        );

    uint64_t ticks = ((uint64_t)high << 32) | low;

    return ticks;
}

uint64_t tick_add_test1(float a, float b)
{
    uint64_t t_start, t_stop;
    uint64_t  time, sum = 0;

    float c = 0;

    for (int k = 0; k < N_REPEAT; k++)
    {
        t_start = tick();
        c = a + b;
        t_stop = tick();

        sum += t_stop - t_start;
    }

    time = sum / N_REPEAT;

    return time;
}

uint64_t tick_mull_test1(float a, float b)
{
    uint64_t t_start, t_stop;
    uint64_t  time, sum = 0;

    float c = 0;

    for (int k = 0; k < N_REPEAT; k++)
    {
        t_start = tick();
        c = a * b;
        t_stop = tick();

        sum += t_stop - t_start;
    }

    time = sum / N_REPEAT;

    return time;
}

uint64_t tick_add_test2(double a, double b)
{
    uint64_t t_start, t_stop;
    uint64_t  time, sum = 0;

    double c = 0;

    for (int k = 0; k < N_REPEAT; k++)
    {
        t_start = tick();
        c = a + b;
        t_stop = tick();

        sum += t_stop - t_start;
    }

    time = sum / N_REPEAT;

    return time;
}

uint64_t tick_mull_test2(double a, double b)
{
    uint64_t t_start, t_stop;
    uint64_t  time, sum = 0;

    double c = 0;

    for (int k = 0; k < N_REPEAT; k++)
    {
        t_start = tick();
        c = a * b;
        t_stop = tick();

        sum += t_stop - t_start;
    }

    time = sum / N_REPEAT;

    return time;
}


int main(void)
{
    uint64_t ta1 = 0, tm1 = 0, ta2 = 0, tm2 = 0;

    float a1 = 15747.1345;
    float b1 = 4252.8655;

    double a2 = 15747.1345676;
    double b2 = 4252.86559867;

    ta1 = tick_add_test1(a1, b1);
    printf("float add time:       %llu\n", ta1);
    tm1 = tick_mull_test1(a1, b1);
    printf("float mul time:       %llu\n", tm1);

    printf("---------------------------\n");

    ta2 = tick_add_test2(a2, b2);
    printf("float add time:       %llu\n", ta2);
    tm2 = tick_mull_test2(a2, b2);
    printf("double mul time:      %llu\n", tm2);

    return 0;
}