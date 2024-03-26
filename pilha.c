#include <stdio.h>
#include "pilha.h"

void inicia_pilha(t_pilha *pilha)
{
    pilha->tam = -1;
}

void empilha(t_pilha *pilha, int n)
{
    pilha->tam++;
    pilha->vetor[pilha->tam] = n;
}

int desempilha(t_pilha *pilha)
{
    return pilha->vetor[pilha->tam--];
}

void imprime_pilha(t_pilha *pilha)
{
    printf("Stack: - ");    
    for (int i = 0; i < pilha->tam; i++) 
        printf("%d - ", pilha->vetor[i]);
    printf("\n");
}