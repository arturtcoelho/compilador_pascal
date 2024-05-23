 # -------------------------------------------------------------------
 #            Arquivo: Makefile
 # -------------------------------------------------------------------
 #              Autor: Bruno Müller Junior
 #               Data: 08/2007
 #      Atualizado em: [09/08/2020, 19h:01m]
 #
 # -------------------------------------------------------------------

$DEPURA=1

compilador: lex.yy.c compilador.tab.c compilador.o compilador.h tabSimbolos.o pilha.o pilha_s.o
	gcc lex.yy.c compilador.tab.c compilador.o tabSimbolos.o pilha.o pilha_s.o -o compilador -ll -ly -lc

lex.yy.c: compilador.l compilador.h
	flex compilador.l

compilador.tab.c: compilador.y compilador.h
	bison compilador.y -d -v

compilador.o : compilador.h compiladorF.c
	gcc -c compiladorF.c -o compilador.o

tabSimbolos.o: tabSimbolos.h tabSimbolos.c
	gcc -c tabSimbolos.c -o tabSimbolos.o

pilha.o: pilha.h pilha.c
	gcc -c pilha.c -o pilha.o

pilha_s.o: pilha_s.h pilha_s.c
	gcc -c pilha_s.c -o pilha_s.o

clean :
	rm -f compilador.tab.* lex.yy.c *.o compilador
