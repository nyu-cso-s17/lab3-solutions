#if SOL >= 999
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "panic_cond.h"
#include "part5.h"

extern void part5(node** head, int length);
extern void part5_opt(node** head, int length);

int list[LARGER];
void flood_cache();
void prepend(data* s, node ** head);

int main(int argc, char **argv)
{
    node* head1 = 0;
    node* head2 = 0; 
    
    int i;
    for (i = 0; i < LARGER; i++)  {
        data s = { rand() * 2.0, rand(), rand() } ; 
        prepend(&s, &head1);
        prepend(&s, &head2); 
    }
    
    node* head1_org = head1;
    node* head2_org = head2;
    
    flood_cache();
    part5(&head1, LARGER); 
    printf("part5 executed \n" ) ; 
        
    flood_cache();
    part5_opt( &head2, LARGER ); 
    printf("part5_opt executed \n" ) ; 
    
    int passed = 1;
    if (head2_org == head2) 
        passed = 0;

    node* h1 = head1;
    node* h2 = head2; 
    for (i = 0; i < LARGER && passed; i++)  {
        if ((h1->value).n1 != (h2->value).n1) {
            passed = 0;
            break;
        }
    }

    if (passed)
        printf("part5: OK\n");
    else
        panic_cond(0, "part5: FAIL");

    return 0;
}

void prepend(data* s, node ** head) {
    if (head == 0) return;
    if (s == 0) return; 
    
    // Allocate memory for storing the node 
    node *n = ( node *)malloc(sizeof( node));
    if (n == NULL) return;
    
    n->value = *s;
    n->next = (*head);
    (*head) = n;
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
