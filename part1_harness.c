#if SOL >= 999
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#include "panic_cond.h"
#include "part1.h"

extern int part1(int* B, int x, int y);
extern int part1_opt(int* B, int x, int y);

int list[LARGER];
void flood_cache();

int main(int argc, char **argv)
{
    srand(time(0));
    
    int* B1 = (int*) malloc(N * N * sizeof(int));
    if (!B1) return -1;

    int* B2 = (int*) malloc(N * N * sizeof(int));
    if (!B2) return -1;

    int i;
    for (i = 0; i < N*N; i++)
    {
        int b = rand();
        B1[i] = b;
        B2[i] = b;
    }

    flood_cache();
    int x = rand()%N;
    int y = rand()%N;

    int n1 = part1(B1, x, y);
    printf("part1 executed\n" ) ;

    int n2 = part1_opt(B2, x, y);
    printf("part1_opt executed \n" ) ;

    if (n1 == n2)
        printf("part1: OK\n");
    else
        panic_cond(0, "part1: FAIL");

    free(B1);
    free(B2);

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
