#ifndef PILHA
#define PILHA

#define MAX_PILHA 2048

typedef struct pilha {
    int vetor[MAX_PILHA];
    int tam;
} t_pilha;

void inicia_pilha(t_pilha*);
void empilha(t_pilha*, int);
int desempilha(t_pilha*);
void imprime_pilha(t_pilha*);

#endif