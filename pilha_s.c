#include <stdio.h>
#include "pilha_s.h"

#include "tabSimbolos.h"

void inicia_pilha_s(t_pilha_s *pilha)
{
    pilha->tam = -1;
}

void empilha_s(t_pilha_s *pilha, t_simbolo *n)
{
    // printf("%d\n", n);
    pilha->tam++;
    pilha->vetor[pilha->tam] = n;
}

t_simbolo* desempilha_s(t_pilha_s *pilha)
{
    // printf("Desempilha: %d\n", pilha->vetor[pilha->tam]);
    if (pilha->tam == -1 ) return NULL;
    return pilha->vetor[pilha->tam--];
}

void imprime_pilha_s(t_pilha_s *pilha)
{
    printf("STACK: %d ", pilha->tam);
    for (int i = -1; i < pilha->tam; i++) 
        printSimbolo(pilha->vetor[i]);
    printf("\n");
}