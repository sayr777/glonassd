PROJECT = glonassd

CC = gcc
LIBS = -lpq -lpthread -L/usr/lib/nptl -rdynamic -ldl -lrt -lm
INCLUDE = -I/usr/include/nptl -I/usr/include/postgresql
# https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html#Option-Summary
CFLAGS = -std=gnu99 -D_REENTERANT -m64
SOCFLAGS = -std=gnu99 -D_REENTERANT -m64 -fpic -Wall -Werror
# https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
OPTIMIZE = -O2 -flto -g0
# https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html#Debugging-Options
DEBUG = -g

SOURCE = glonassd.c loadconfig.c todaemon.c logger.c worker.c lib.c forwarder.c

HEADERS = $(wildcard *.h)

$(PROJECT): $(SOURCE) $(HEADERS)
	$(CC) $(CFLAGS) $(OPTIMIZE) $(INCLUDE) $(LIBS) $(SOURCE) -o $(PROJECT)

run: $(PROJECT)
	./$(PROJECT) start

# shared library for database PostgreSQL
pg: pg.c glonassd.h de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) $(INCLUDE) $(LIBS) pg.c -o pg.o
	$(CC) -shared -o pg.so pg.o
	rm pg.o

# shared library for decode/encode GALILEO
galileo: galileo.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) galileo.c -o galileo.o
	$(CC) -shared -o galileo.so galileo.o
	rm galileo.o

# shared library for decode/encode NTS
# -lm : link libm for "fmod" and other mathematic functions
nts: nts.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) nts.c -o nts.o
	$(CC) -lm -shared -o nts.so nts.o
	rm nts.o

# shared library for decode/encode SAT-LITE/SAT-LITE2
satlite: satlite.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) satlite.c -o satlite.o
	$(CC) -shared -o satlite.so satlite.o
	rm satlite.o

# shared library for decode/encode ARNAVI 4
arnavi: arnavi.c arnavi.h de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) arnavi.c -o arnavi.o
	$(CC) -shared -o arnavi.so arnavi.o
	rm arnavi.o

# shared library for decode/encode FAVW
favw: favw.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) favw.c -o favw.o
	$(CC) -shared -o favw.so favw.o
	rm favw.o

# shared library for decode/encode FAVA
fava: fava.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) fava.c -o fava.o
	$(CC) -shared -o fava.so fava.o
	rm fava.o

# shared library for decode/encode Wialon IPS
wialonips: wialonips.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) wialonips.c -o wialonips.o
	$(CC) -shared -o wialonips.so wialonips.o
	rm wialonips.o

# shared library for decode/encode GPS-101 - GPS-103
gps103: gps103.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) gps103.c -o gps103.o
	$(CC) -shared -o gps103.so gps103.o
	rm gps103.o

# shared library for decode/encode SOAP
soap: soap.c de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) soap.c -o soap.o
	$(CC) -shared -o soap.so soap.o
	rm soap.o

# shared library for decode/encode EGTS
egts: egts.c egts.h de.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) egts.c -o egts.o
	$(CC) -shared -o egts.so egts.o
	rm egts.o

# shared library for test/log protocol
prototest: prototest.c de.h glonassd.h logger.h
	$(CC) -c $(SOCFLAGS) $(OPTIMIZE) prototest.c -o prototest.o
	$(CC) -shared -o prototest.so prototest.o
	rm prototest.o

# all
all: $(PROJECT) pg galileo nts satlite favw fava wialonips gps103 soap egts arnavi prototest

clean:
	rm -f *.o
