#if SOL >= 999
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <assert.h>

#include "panic_cond.h"
#include "part3.h"

extern char* part3();
extern char* part3_opt();

int list[LARGER];
void flood_cache();

int main(int argc, char **argv)
{
    flood_cache();
    char* c1 = part3();
    printf("part3 completed \n" ) ;

    flood_cache();
    char* c2 = part3_opt();
    printf("part3_opt completed \n" ) ;

    if (strcmp(c1, c2) == 0)
        printf("part3: OK\n");
    else
        panic_cond(0, "part3: FAIL");

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
