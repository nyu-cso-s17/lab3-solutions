BUILD  := build
STATIC := static

SOURCES := part1.c part2.c part3.c part4.c part5.c

SOBJS := $(STATIC)/part1_harness.o \
		 $(STATIC)/part2_harness.o \
		 $(STATIC)/part3_harness.o \
		 $(STATIC)/part4_harness.o \
		 $(STATIC)/part5_harness.o 

CC     := gcc
CFLAGS := -std=c99

OBJS :=	$(BUILD)/part1 \
	    $(BUILD)/part2 \
	    $(BUILD)/part3 \
	    $(BUILD)/part4 \
	    $(BUILD)/part5

#if SOL >= 999
CFLAGS += -DSOL=999
#endif

all: $(OBJS)
	@:

real_all: $(OBJS)

$(BUILD)/part%: part%.c $(SOBJS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -g -c part$*.c -o $(BUILD)/part$*.o
	$(CC) $(CFLAGS) $(STATIC)/part$*_harness.o $(BUILD)/part$*.o -lm -o $(BUILD)/part$*

clean-logs: always
	rm -f *.out

clean: always clean-logs
	rm -rf $(BUILD)

test:
	@echo $(MAKE) clean
	@$(MAKE) -s --no-print-directory clean
	@./test-lab

.PHONY: all always

#if SOL >= 999
$(STATIC)/part%_harness.o: part%_harness.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c part$*_harness.c -o $(STATIC)/part$*_harness.o

static: $(SOBJS)

clean-static: always
	rm -rf $(STATIC)

export-lab: always $(SOBJS)
	./mklab.pl 1 0 lab3 *.c *.h testlib.py test-lab Makefile
	cp README.md lab3/
	cp test-part lab3/
	mkdir -p lab3/tests
	cp -r ./tests/* lab3/tests/
	mkdir -p lab3/static
	cp $(STATIC)/*.o lab3/static/
	echo 'build' > lab3/.gitignore
	echo '*.out' >> lab3/.gitignore
	echo '*.pyc' >> lab3/.gitignore

export-sol: always $(SOBJS)
	./mklab.pl 1 999 lab3-sol *.c *.h testlib.py test-lab Makefile
	cp README.md lab3-sol/
	cp test-part lab3-sol/
	mkdir -p lab3-sol/tests
	cp -r ./tests/* lab3-sol/tests/
	mkdir -p lab3-sol/static
	cp $(STATIC)/*.o lab3-sol/static/
	echo 'build' > lab3-sol/.gitignore
	echo '*.out' >> lab3-sol/.gitignore
	echo '*.pyc' >> lab3-sol/.gitignore

clean-export: always
	rm -rf $(EXPORT)

clean-all: always 
	rm -f *.out
	rm -f *.pyc
	rm -rf ./lab3
	rm -rf ./lab3-sol
	rm -rf $(BUILD)

#endif
