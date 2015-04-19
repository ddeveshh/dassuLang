flex countVar.l
g++ lex.yy.c
./a.out < TAC.txt > vars.txt
g++ mips.cpp
./a.out > mips.s
