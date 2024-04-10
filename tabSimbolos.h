#ifndef TAB_SIMBOLOS
#define TAB_SIMBOLOS

#include "compilador.h"

#define MAX_NUM_SIMBOLOS 1024

typedef struct tab_simbolo {
    t_simbolo tokens[MAX_NUM_SIMBOLOS];
    int tam;
} t_tab_simbolo;

void inicia_tab();
void addSimboloSimples(char*, int, int);
t_simbolo* addSimboloProcedimento(char*, int, int, int);
void adicionaSimboloFormal(char*, int, int, int);
void adicionaSimboloRetFunc(char*, int, int, int);
void corrigeDeslocFormal(int);
t_simbolo* buscaSimbolo(char*);
void removeTabLex(int);
void updateTipoSimbolo(int, int);
void printTabSimbolo();
void printSimbolo(t_simbolo*);
int contaTabSimb(int);

#endif