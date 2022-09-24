#include <stdio.h>
#include <inttypes.h>
#include <sys/time.h>

#define N           4 
#define N_REPEAT    1000000

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

void asm_mul_vec(float *sum, float* x, float* y)
{
    __asm__ volatile
    (
        "movups     %[x], %%xmm0\n\t"
        "movups     %[y], %%xmm1\n\t"
        "mulps      %%xmm1, %%xmm0\n\t" // перемножить пакеты плавающих точек: xmm0 = xmm0 * xmm1
                    // xmm00 = xmm00 * xmm10
                    // xmm01 = xmm01 * xmm11
                    // xmm02 = xmm02 * xmm12
                    // xmm03 = xmm03 * xmm13
        "movups %%xmm0, %[sum]\n\t"	// выгрузить результаты из регистра xmm0 по адресам sum
        : [sum]"=m"(*sum)
        : [x]"m"(*x), [y]"m"(*y)
        : "%xmm0", "%xmm1");
}

float asm_svmul(float* x, float* y)
{
    float sum = 0;

    // SSE - 128 битов, т.е. в один xmmn регистр влезет не больше 4 значений типа float
    __asm__ volatile // приемник в такой ассемблерной вставке находится справа
    (
        "movups     %[x], %%xmm0\n\t"
        "movups     %[y], %%xmm1\n\t"
        "mulps      %%xmm1, %%xmm0\n\t" // перемножить пакеты плавающих точек: xmm0 = xmm0 * xmm1
                    // xmm00 = xmm00 * xmm10
                    // xmm01 = xmm01 * xmm11
                    // xmm02 = xmm02 * xmm12
                    // xmm03 = xmm03 * xmm13
        "movhlps    %%xmm0, %%xmm1\n\t" //
        "addps      %%xmm1, %%xmm0\n\t"
        "movaps     %%xmm0, %%xmm1\n\t" // movups
        "shufps     $1, %%xmm1, %%xmm1 \n\t"
        "addps      %%xmm1, %%xmm0\n\t"
        "movss      %%xmm0, %0\n\t"
        : "=m"(sum)
        : [x]"m"(*x), [y]"m"(*y)
        : "%xmm0", "%xmm1"
    );
        
   return sum;

}

uint64_t tick_asm_svmul_test(float *x, float *y)
{
    uint64_t t_start, t_stop;
    uint64_t  time, sum = 0;

    float c = 0;

    for (int k = 0; k < N_REPEAT; k++)
    {
        t_start = tick();
        c = asm_svmul(x, y);
        t_stop = tick();

        sum += t_stop - t_start;
    }

    time = sum / N_REPEAT;

    return time;
}

float c_svmul(float *x, float *y, int n)
{
    float sum = 0;

    for (int i = 0; i < n; i++)
    {
        sum += x[i]*y[i];
    }

    return sum;
}

uint64_t tick_c_svmul_test(float *x, float *y, int n)
{
    uint64_t t_start, t_stop;
    uint64_t  time, sum = 0;

    float c = 0;

    for (int k = 0; k < N_REPEAT; k++)
    {
        t_start = tick();
        c = c_svmul(x, y, n);
        t_stop = tick();

        sum += t_stop - t_start;
    }

    time = sum / N_REPEAT;

    return time;
}

void float_arr_print(float *arr, int n)
{
    for (int i = 0; i < n; i++)
    {
        printf("%f ", arr[i]);
    }
}

int main(void)
{
    float x[N] = {1, 2, 3, 4};
    float y[N] = {1, 1, 1, 1};

    uint64_t ta = 0, tc = 0;

    printf("< Dot product of vectors >\n");

    ta = tick_asm_svmul_test(x, y);
    printf("float asm time: %llu ticks\n", ta);

    tc = tick_c_svmul_test(x, y, N);
    printf("float c time:   %llu ticks\n", tc);

    return 0;
}
