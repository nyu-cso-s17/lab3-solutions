# Computer Systems Organization : Lab 3

In this project you will practice analyzing cache use and how to tweak C code to make it (more) cache friendly. The repository contains five files: part1.c, ..., part5.c with different C functions that perform operations that are fairly memory intensive.  Your task is to implement equivalent functions (i.e., your functions should perform exactly the same tasks) but in a cache-aware manner. Your functions will be called part1_opt, ...,  part5_opt.

## Obtaining the lab code  

Clone this repository. (Do not fork!)

## Installing Valgrind

Before starting your lab you must install [Valgrind](http://valgrind.org/). In a terminal on your VM run the following command.

```
sudo apt-get install valgrind

```

## Notes

* Do not modify the code where the comments state so.  
* You can add any variables or data structure you want, but you are not allowed to remove/modify available variables or data structures.
* You can create additional helper functions if you choose. If you do, name them starting with the name of the function in which they are used. For example, if you want a helper function for part1_opt function, it should be called part1_opt_<some-suffix>. The cache misses that occur within the helper function will count towards the function that calls it.  
* Do not use recursion.
* Your changes should not change the underlying algorithm. They should make the existing implementation more efficient. For example, if one of the functions implements a bubble sort, do not change it to quick sort.
*  Always remember that cache friendly means locality of data access, both temporal and spatial.
* You should first understand what the function does, then attempt to optimize it.

## Completing the lab


The repository contains all files you need to work on this project. There are the problem files part1.c ... part5.c. You need to develop implement your optimized functions within those files. There are function stubs there for you already.

## Testing the C functions

To compile and execute each function...

```
$ make
$ ./test-part 1
part1 [part1.c]: (0.2s)
  part1: FAIL
         part1: FAIL
    MISSING 'part1: OK'
    Program output saved to part1.out
```

From the above error messages, you can see that your optimized code did not pass correctness tests. Debug and try again. Complete and test each part individually. 

When the your attempt at an optimized algorithm is correctly (not necessarily performantly) implemented, the `./test-part` command will also display something that *starts* with this...

```
$ make
$ ./test-part 1
part1 [part1.c]: 
  part1: OK
==2360== Cachegrind, a cache and branch-prediction profiler
==2360== Copyright (C) 2002-2013, and GNU GPL'd, by Nicholas Nethercote et al.
==2360== Using Valgrind-3.10.1 and LibVEX; rerun with -h for copyright info
==2360== Command: ./build/part1
==2360== 
......lots more output
```

Once you've passed the tests for all 5 problems, you *must* double check your test-passing status by typing: 

```
$ ./test-lab 
Part 1 =========================================================================
part1 [part1.c]: 
  part1: OK
     D1mr D1mw  file:function
--------------------------------------------------------------------------------
1,048,577    2  /home/stud/Desktop/labs-master/lab3/lab3-sol/part1.c:part1
  131,073    1  /home/stud/Desktop/labs-master/lab3/lab3-sol/part1.c:part1_opt

.....
```

This will display whether or not your implementation is correct and then display abbreviated performance information.

# Testing Cache Performance

If your optimized version of the method passes correctness tests, the `./test-part` command will also run a cache simulator to see the code's cache performance using a tool called Cachegrind. 

Here is some sample output...

```
stud@lubuntu64:~/Desktop/labs-master/lab3/lab3-sol$ ./test-part 1
part1 [part1.c]: 
  part1: OK
==2204== Cachegrind, a cache and branch-prediction profiler
==2204== Copyright (C) 2002-2013, and GNU GPL'd, by Nicholas Nethercote et al.
==2204== Using Valgrind-3.10.1 and LibVEX; rerun with -h for copyright info
==2204== Command: ./build/part1
==2204== 
--2204-- Warning: Cannot auto-detect cache config, using defaults.
--2204--          Run with -v to see.
part1: OK
==2204== 
==2204== I   refs:      52,607,646
==2204== I1  misses:           865
==2204== LLi misses:           860
==2204== I1  miss rate:       0.00%
==2204== LLi miss rate:       0.00%
==2204== 
==2204== D   refs:      21,035,114  (18,921,974 rd   + 2,113,140 wr)
==2204== D1  misses:     1,192,023  ( 1,189,400 rd   +     2,623 wr)
==2204== LLd misses:     1,116,790  ( 1,116,260 rd   +       530 wr)
==2204== D1  miss rate:        5.6% (       6.2%     +       0.1%  )
==2204== LLd miss rate:        5.3% (       5.8%     +       0.0%  )
==2204== 
==2204== LL refs:        1,192,888  ( 1,190,265 rd   +     2,623 wr)
==2204== LL misses:      1,117,650  ( 1,117,120 rd   +       530 wr)
==2204== LL miss rate:         1.5% (       1.5%     +       0.0%  )
--------------------------------------------------------------------------------
I1 cache:         65536 B, 64 B, 2-way associative
D1 cache:         1024 B, 32 B, 16-way associative
LL cache:         262144 B, 64 B, 8-way associative
Command:          ./build/part1
Data file:        cache.trace
Events recorded:  Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Events shown:     D1mr D1mw
Event sort order: Ir I1mr ILmr Dr D1mr DLmr Dw D1mw DLmw
Thresholds:       0.05 100 100 100 100 100 100 100 100
Include dirs:     
User annotated:   
Auto-annotation:  off

--------------------------------------------------------------------------------
     D1mr  D1mw 
--------------------------------------------------------------------------------
1,189,400 2,623  PROGRAM TOTALS

--------------------------------------------------------------------------------
     D1mr D1mw  file:function
--------------------------------------------------------------------------------
1,048,577    2  /home/stud/Desktop/labs-master/lab3/lab3-sol/part1.c:part1
  131,073    1  /home/stud/Desktop/labs-master/lab3/lab3-sol/part1.c:part1_opt
    2,080    5  /build/buildd/eglibc-2.19/elf/dl-addr.c:_dl_addr
```

The above output contains numbers of cache read misses (D1mr) and cache write misses (D1mw). You should be looking at the lines that show the results of all of the partN and partN_opt functions. In the above example you can see that the part1 function had 1,048,577 cahe read misses and the part1_opt function had 131,073 cache read misses (this is almost the order of magnitude difference!). The reduction in the number of cache misses will not be always so large. Your objective is to both numbers (for cache read and write misses) to be as low as possible. (Note, that sometime reducing one of those implies the other one goes up. This is fine, as long as there is overall benefit.) 

## Evaluation
Your score will be computed out of a maximum of 100 points based on the following distribution:

* Correctness points (100 points total) The number of cache misses will be compared for each partN function and its corresponding partN_opt function. Your grade for each level will be determined based on the correctness of the code (i.e., does the optimized function perform the same operations as its unoptimized equivalent?) and based on the decrease in the number of cache read/write misses.

<i>Note while the testing script will give you a good idea of your final lab grade, its score does NOT constitute an assurance. In particular, just because they pass the tests does not necessarily mean that you have implemented everything perfectly. The test harness tests your functions on a limited set of inputs. The fact that your implementation passes the test does not guarantee that the code that you wrote is correct.</i>

## Turning in your work

```
git commit -am "Submitting lab 3"  
git push origin master
```  

