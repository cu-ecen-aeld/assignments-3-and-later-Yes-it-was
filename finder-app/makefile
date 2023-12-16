ifeq ($(CROSS_COMPILE),aarch64-none-linux-gnu-)  
	CC=aarch64-none-linux-gnu-gcc
else 
	CC=gcc
endif

CFLAGS = -O2 -Wall


all: writer


build_dir: 
	mkdir -p build

clean: 
	rm -r -f build

writer: writer.c | build_dir 
	$(CC) writer.c $(CFLAGS) -o build/writer
