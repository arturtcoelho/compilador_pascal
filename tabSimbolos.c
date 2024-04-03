#include <string.h>
#include <stdio.h>
#include "tabSimbolos.h"

t_tab_simbolo tabSim;

void inicia_tab()
{
    tabSim.tam = -1;
}

void addSimboloSimples(char* token, int desloc, int lex)
{
    tabSim.tam++;
    strncpy(tabSim.tokens[tabSim.tam].nome, token, TAM_TOKEN);
    tabSim.tokens[tabSim.tam].cat = SIMPLES;
    tabSim.tokens[tabSim.tam].desl = desloc;
    tabSim.tokens[tabSim.tam].lex = lex;
}

t_simbolo* addSimboloProcedimento(char* token, int lex, int rot)
{
    tabSim.tam++;
    strncpy(tabSim.tokens[tabSim.tam].nome, token, TAM_TOKEN);
    tabSim.tokens[tabSim.tam].cat = PROCEDIMENTO;
    tabSim.tokens[tabSim.tam].lex = lex;
    tabSim.tokens[tabSim.tam].rotulo = rot;
    return &tabSim.tokens[tabSim.tam];
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
    while (i >= 0 && tabSim.tokens[i].lex == lex && tabSim.tokens[i].cat != PROCEDIMENTO) {
        i--;
        count++;
    }
    tabSim.tam -= count;
}

void updateTipoSimbolo(int simbolo, int n)
{
    for (int i = tabSim.tam; i > tabSim.tam-n; i--){
        tabSim.tokens[i].tipo = simbolo;
    }
}

int contaTabSimb(int lex) 
{
    int count = 0;
    for (int i = 0; i < tabSim.tam; i++) {
        if (tabSim.tokens[i].lex == lex)
            count++;        
    }
    return count;
}

void printTabSimbolo()
{
    printf("TabSimbolos: %d\n", tabSim.tam+1);
    for (int i = 0; i < tabSim.tam+1; i++) {
        switch (tabSim.tokens[i].cat)
        {
        case SIMPLES:
            printf("SIMP | %d: %s | %d, %d | type: %d\n", i, 
                                                            tabSim.tokens[i].nome, 
                                                            tabSim.tokens[i].lex, 
                                                            tabSim.tokens[i].desl, 
                                                            tabSim.tokens[i].tipo);
            break;
        case PROCEDIMENTO:  
            printf("PROC | %d: %s | %d | R%02d | args: %d\n", i, 
                                                    tabSim.tokens[i].nome, 
                                                    tabSim.tokens[i].lex, 
                                                    tabSim.tokens[i].rotulo,
                                                    tabSim.tokens[i].num_args);
            for (int j = 0; j < tabSim.tokens[i].num_args; j++) {
                printf("     ARGS | %s | t: %d | ref: %d\n", tabSim.tokens[i].args_list[j].nome, 
                                                            tabSim.tokens[i].args_list[j].tipo,
                                                            tabSim.tokens[i].args_list[j].p_ref);
            }
            
        default:
            break;
        }
    }
