#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "part2.h"

/*
 * Implement the C function called part2_opt. It should perform
 * the same task as the implemented part2 function. In the
 * comments for the function describe why your changes make the
 * function more cache friendly.
 *
 * Note: Your function needs to compute the entire matrix A, not only A[x+y]
 */

double part2(double* B, double* A, int x, int y)
{
    int i, j;
    for(i = 0; i < LARGE; i++)
        for(j = 0; j < SMALL; j++)
            A[i] = A[i] + B[ j * LARGE + i];

    return A[x+y];
}

double part2_opt(double * B, double * A, int x, int y )
{
#if SOL >= 999
    int i, j; 
    for(j = 0; j < SMALL; j++) 
        for(i = 0; i < LARGE; i++)
            A[i]  = A[i] + B[j * LARGE + i] ;

    return A[x+y];
#else
    // TODO: Your code here.
    assert(0);

    // Do not modify the rest of this function
    return A[x+y];
#endif
}