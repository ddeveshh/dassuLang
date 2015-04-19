# Makefile

OBJS	= bison.o lex.o main.o

CC	= g++
CFLAGS	= -g -w -fmax-errors=10 -Wall -ansi -pedantic

lang:		$(OBJS)
		$(CC) $(CFLAGS) $(OBJS) -o lang -lfl

lex.o:		lex.c
		$(CC) $(CFLAGS) -c lex.c -o lex.o

lex.c:		lang.lex 
		flex lang.lex
		cp lex.yy.c lex.c

bison.o:	bison.c
		$(CC) $(CFLAGS) -c bison.c -o bison.o

bison.c:	lang.y
		bison -d -v lang.y
		cp lang.tab.c bison.c
		cmp -s lang.tab.h tok.h || cp lang.tab.h tok.h

main.o:		main.cc
		$(CC) $(CFLAGS) -c main.cc -o main.o > output

lex.o main.o		: tok.h

clean:
	rm -f *.o *~ lex.c lex.yy.c bison.c tok.h lang.tab.c lang.tab.h lang.output lang

