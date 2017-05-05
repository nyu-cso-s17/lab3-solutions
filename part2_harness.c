#if SOL >= 999
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#include "panic_cond.h"
#include "part2.h"

extern double part2(double* B, double* A, int x, int y);
extern double part2_opt(double* B, double* A, int x, int y);

int list[LARGER];
void flood_cache();

int main(int argc, char **argv)
{
    srand(time(0));
    srand48(time(0));

    double* D1 = (double*) malloc(SMALL * LARGE * sizeof(double));
    if (!D1) return 0;

    double* D2 = (double*) calloc(LARGE, sizeof(double));
    if (!D2) return 0;

    double* D3 = (double*) calloc(LARGE, sizeof(double));
    if (!D3) return 0;

    int i;
    for (i = 0; i < SMALL * LARGE; i++)
    {
        D1[i] = drand48();
    }

    int x = rand() % LARGE / 2;
    int y = rand() % LARGE / 2;

    flood_cache();
    double d1 = part2(D1, D2, x, y);

    printf("part2 executed\n") ;

    flood_cache();
    double d2 = part2_opt(D1, D3, x, y);

    printf("part2_opt executed\n") ;

    if (d1 == d2)
        printf("part2: OK\n");
    else
        panic_cond(0, "part2: FAIL");

    free(D1);
    free(D2);
    free(D3);

    return 0;
}

void flood_cache()
{
    int i;
    for (i = 0; i < LARGER; i++)
    {
        list[i] = rand();
    }
}
#endif
