#if SOL >= 999
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "panic_cond.h"
#include "part4.h"

extern long part4(long* B, long* A, int x); 
extern long part4_opt(long* B, long* A, int x);

int list[LARGER];
void flood_cache();

int main(int argc, char **argv)
{
    long* F1 = (long*) malloc(N * N * sizeof(long));
    if (!F1) return 0; 
    long* F2 = (long*) malloc(N * N * sizeof(long));
    if (!F2) return 0; 

    int i;
    for (i = 0; i < N * N; i++) {
        F1[i] = rand();
        F2[i] = rand();
    }
    
    int x = rand() % N; 
    
    flood_cache(); 
    long l1 = part4(F1, F2, x);
    printf("part4 executed\n" ) ; 
    
    flood_cache(); 
    long l2 = part4_opt(F1, F2, x);
    printf("part4_opt executed\n") ; 

    if (l1 == l2)
        printf("part4: OK\n");
    else
        panic_cond(0, "part4: FAIL");

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
