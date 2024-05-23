#ifndef PILHA_SIMB
#define PILHA_SIMB

#include "compilador.h"

#define MAX_PILHA 2048

typedef struct pilha_s {
    t_simbolo* vetor[MAX_PILHA];
    int tam;
} t_pilha_s;

void inicia_pilha_s(t_pilha_s*);
void empilha_s(t_pilha_s*, t_simbolo*);
t_simbolo* desempilha_s(t_pilha_s*);
void imprime_pilha_s(t_pilha_s*);

#endif