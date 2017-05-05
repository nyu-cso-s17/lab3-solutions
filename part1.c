#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "part1.h"

/*
 * Implement the C function called part1_opt. It should perform
 * the same task as the implemented part1 function. In the
 * comments for the function describe why your changes make the
 * function more cache friendly.
*/

int part1(int* B, int x, int y)
{
    if (!B) return -1;

    int c, r;
    for(c = 0; c < N; c++)
        for(r = 0; r < N; r++)
            B[r * N + c] = 2 * (B[r * N + c] + 2);

    return B[x * N + y];
}

int part1_opt(int* B, int x, int y)
{
#if SOL >= 999
    if (!B) return -1; 
    
    int c, r; 
    for(r = 0; r < N; r++)
        for(c = 0; c < N; c++)
            B[r * N + c] = 2 * (B[r * N + c] + 2);

    return  B[x * N + y];
#else
    if (!B) return -1;

    // TODO - your code here.
    assert(0);

    return B[x * N + y];
#endif
}