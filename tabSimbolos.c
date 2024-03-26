#include <string.h>
#include <stdio.h>
#include "tabSimbolos.h"

t_tab_simbolo tabSim;

void inicia_tab()
{
    tabSim.tam = -1;
}

void addSimbolo(char* token, t_categoria ts, int desloc, int lex)
{
    tabSim.tam++;
    strncpy(tabSim.tokens[tabSim.tam].nome, token, TAM_TOKEN);
    tabSim.tokens[tabSim.tam].cat = ts;
    tabSim.tokens[tabSim.tam].desl = desloc;
    tabSim.tokens[tabSim.tam].lex = lex;
}

t_simbolo* buscaSimbolo(char* token)
{
    for (int i = tabSim.tam; i >= 0; i--) {
        if (!strcmp(tabSim.tokens[i].nome, token))
            return &tabSim.tokens[i];
    }
    return NULL;    
}

void removeTabLex(int lex)
{
    int i = tabSim.tam;
    int count = 0;
    while (i >= 0 && tabSim.tokens[i].lex == lex) {
        i--;
        count++;
    }
    tabSim.tam -= count;
    printf("%d\n", tabSim.tam);
}

void updateTipoSimbolo(int simbolo, int n)
{
    for (int i = tabSim.tam; i > tabSim.tam-n; i--){
        tabSim.tokens[i].tipo = simbolo;
    }
}

int contaTabSimb(int lex) 
{
    int i = tabSim.tam;
    while (i >= 0 && tabSim.tokens[i].lex == lex) {
        i--;
    }
    return tabSim.tam - i;
}

void printTabSimbolo()
{
    printf("TabSimbolos: %d\n", tabSim.tam+1);
    for (int i = 0; i < tabSim.tam+1; i++) {
        printf("%d: %s | %d, %d | cat: %d | type: %d\n", i, tabSim.tokens[i].nome, tabSim.tokens[i].lex, tabSim.tokens[i].desl, tabSim.tokens[i].cat, tabSim.tokens[i].tipo);
    }
    
}