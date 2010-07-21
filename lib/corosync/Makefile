all: clean
	pyrexc libcpg.pyx
	gcc -g  -pthread -fno-strict-aliasing -DNDEBUG -fmessage-length=0  -Wall -D_FORTIFY_SOURCE=2 -fstack-protector -funwind-tables -fasynchronous-unwind-tables -g -fwrapv -fPIC -I/usr/include/python2.6 -c libcpg.c -o libcpg.o
	gcc -g -pthread -shared libcpg.o -L/usr/lib64 -lcpg -lpython2.6 -o libcpg.so
clean:
	rm -f libcpg.c libcpg.so libcpg.o *.pyc *~
