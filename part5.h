/***********************************************/
/* Do not change anything below this line      */
/***********************************************/

#define SMALL   64
#define N       1024
#define DIM     512
#define DIM2    1024
#define LARGE   10000
#define LARGER  50000

typedef struct d { 
    double d;
    int n1; 
    int n2;
} data; 

typedef struct n { 
    data value;
    struct n * next; 
} node; 

void part5(node** head, int length);

void part5_opt(node** head, int length);

/***********************************************/
/* Do not change anything above this line      */
/***********************************************/