#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

#include "part3.h"

/*
 * Implement the C function called part3_opt. It should perform
 * the same task as the implemented part3 function. In the
 * comments for the function describe why your changes make the
 * function more cache friendly.
 *
 * You may observe that this function performs "useless" looping
 * over an array of structures that are all filled with zero bits.
 * Your task is not to remove that "useless" code, but modify it
 * so that it is more cache friendly. You also should not be removing
 * any parts of the structures.
 */

char* part3()
{
    // Note: struct 'data' is defined in part3.h, take a look
    data* B = (data*) calloc(LARGER, sizeof(data));
    if (!B) return 0;

    double sum_f = 0.0;
    double sum_n = 0;
    char* sum_c = (char*) malloc(( 2 * LARGER + 1) * sizeof(char));

    sum_c[2 * LARGER] = '\0';

    int i;
    for(i = 0; i < LARGER; i++)
    {
        sum_f += B[i].f1 + B[i].f2;
        sum_n += B[i].n1 + B[i].n2;
        sum_c[2 * i] = B[i].c1;
        sum_c[2 * i + 1] = B[i].c2;
    }

    free(B);
    return sum_c;
}

typedef struct { 
    double f1;
    double f2;
    int n1; 
    int n2;
    char c1; 
    char c2;
} data_opt; 

char* part3_opt()
{
#if SOL >= 999
    data_opt * B = (data_opt*) calloc(LARGER, sizeof(data_opt));
    if (!B) return 0; 
    double sum_f = 0.0;
    double sum_n = 0; 
    char* sum_c = (char*) calloc(2 * LARGER + 1, sizeof(char));    
    
    int i; 
    for(i = 0; i < LARGER; i++){
        sum_f += B[i].f1 + B[i].f2; 
        sum_n += B[i].n1 + B[i].n2; 
        sum_c[2*i] = B[i].c1;
        sum_c[2*i+1] = B[i].c2;
    }

    free(B); 
    return sum_c;
#else
    // TODO: Create the array of structures same or equivalent
    // to the one in the function above
    assert(0);

    // DO NOT modify the following 4 lines
    double sum_f = 0.0;
    double sum_n = 0;
    char* sum_c = (char*) malloc((2 * LARGER + 1) * sizeof(char));
    sum_c[2 * LARGER] = '\0';
    // DO NOT modify the preceeding 4 lines

    // TODO: Enter your code here (make sure to free
    // the array B once before returning)
    assert(0);

    //DO NOT modify the rest of this function
    return sum_c;
#endif
}
