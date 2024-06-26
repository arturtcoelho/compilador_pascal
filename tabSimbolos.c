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

t_simbolo* addSimboloProcedimento(char* token, int lex, int rot, int cat)
{
    tabSim.tam++;
    strncpy(tabSim.tokens[tabSim.tam].nome, token, TAM_TOKEN);
    tabSim.tokens[tabSim.tam].cat = cat;
    tabSim.tokens[tabSim.tam].lex = lex;
    tabSim.tokens[tabSim.tam].rotulo = rot;
    return &tabSim.tokens[tabSim.tam];
}

void adicionaSimboloFormal(char* token, int lex, int tipo, int ref)
{
    tabSim.tam++;
    strncpy(tabSim.tokens[tabSim.tam].nome, token, TAM_TOKEN);
    tabSim.tokens[tabSim.tam].cat = PARAMETRO_FORMAL;
    tabSim.tokens[tabSim.tam].lex = lex;
    tabSim.tokens[tabSim.tam].tipo = tipo;
    tabSim.tokens[tabSim.tam].p_ref = ref;
}

void adicionaSimboloRetFunc(char* token, int lex, int desl, int tipo)
{
    tabSim.tam++;
    strncpy(tabSim.tokens[tabSim.tam].nome, token, TAM_TOKEN);
    tabSim.tokens[tabSim.tam].cat = RET_FUNCAO;
    tabSim.tokens[tabSim.tam].lex = lex;
    tabSim.tokens[tabSim.tam].desl = desl;
    tabSim.tokens[tabSim.tam].tipo = tipo;
    tabSim.tokens[tabSim.tam].p_ref = 0;
}

void corrigeDeslocFormal(int n)
{
    int count = -4;
    for (int i = tabSim.tam; i > tabSim.tam-n; i--){
        if (tabSim.tokens[i].cat == PARAMETRO_FORMAL) {
            tabSim.tokens[i].desl = count--;
        } 
    }
}


t_simbolo* buscaSimbolo(char* token, int lex)
{
    // printf("My lex: %d\n", lex);
    // printf("My tok: %s\n", token);
    for (int i = tabSim.tam; i >= 0; i--) {
        // printSimbolo(&(tabSim.tokens[i]));
        // printf("lex %d >= %d \n", lex + ((tabSim.tokens[i].cat == PROCEDIMENTO) ? 1 : 0), tabSim.tokens[i].lex);
        if ((lex + ((tabSim.tokens[i].cat == PROCEDIMENTO) ? 1 : 0)) >= tabSim.tokens[i].lex 
            && !strcmp(tabSim.tokens[i].nome, token))
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
    // printf("TAM: %d\n", tabSim.tam);
    int count = 0;
    for (int i = 0; i < tabSim.tam; i++) {
        if (tabSim.tokens[i].lex == lex && tabSim.tokens[i].cat == SIMPLES)
            count++;
    // for (int i = 0; i < tabSim.tam+1; i++) {
    //     // printSimbolo(&(tabSim.tokens[i]));
    //     if (tabSim.tokens[i].lex == lex 
    //         && tabSim.tokens[i].cat != PROCEDIMENTO 
    //         && tabSim.tokens[i].cat != PARAMETRO_FORMAL)
    //         count++;        
    // }
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
        case RET_FUNCAO:
            printf("RFUN | %d: %s | %d, %d | type: %d\n", i, 
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
            break;
        case FUNCAO:  
            printf("FUNC | %d: %s | %d | R%02d | args: %d | ty: %d\n", i, 
                                                    tabSim.tokens[i].nome, 
                                                    tabSim.tokens[i].lex, 
                                                    tabSim.tokens[i].rotulo,
                                                    tabSim.tokens[i].num_args,
                                                    tabSim.tokens[i].tipo);
            for (int j = 0; j < tabSim.tokens[i].num_args; j++) {
                printf("     ARGS | %s | t: %d | ref: %d\n", tabSim.tokens[i].args_list[j].nome, 
                                                            tabSim.tokens[i].args_list[j].tipo,
                                                            tabSim.tokens[i].args_list[j].p_ref);
            }
            break;
        case PARAMETRO_FORMAL:
            printf("FORM | %d: %s | %d, %d | type: %d | ref: %d\n", i,
                                                tabSim.tokens[i].nome, 
                                                tabSim.tokens[i].lex, 
                                                tabSim.tokens[i].desl, 
                                                tabSim.tokens[i].tipo,
                                                tabSim.tokens[i].p_ref);
            break;
        default:
            break;
        }
    }
}

void printSimbolo(t_simbolo* sim)
{
    printf("Simbolo: "); 
    if (!sim) {
        printf("Simbolo Nulo\n"); 
        return;
    } 
    switch (sim->cat)
        {
        case SIMPLES:
            printf("SIMP | %s | %d, %d | type: %d\n", sim->nome, sim->lex, sim->desl, sim->tipo);
            break;
        case RET_FUNCAO:
            printf("RFUN | %s | %d, %d | type: %d\n", sim->nome, sim->lex, sim->desl, sim->tipo);
            break;
        case PROCEDIMENTO:  
            printf("PROC | %s | %d | R%02d | args: %d\n",
                                                    sim->nome, 
                                                    sim->lex, 
                                                    sim->rotulo,
                                                    sim->num_args);
            for (int j = 0; j < sim->num_args; j++) {
                printf("     ARGS | %s | t: %d | ref: %d\n", 
                                                            sim->args_list[j].nome, 
                                                            sim->args_list[j].tipo,
                                                            sim->args_list[j].p_ref);
            }
            break;
        case FUNCAO:  
            printf("PROC | %s | %d | R%02d | args: %d | ty: %d\n",
                                                    sim->nome, 
                                                    sim->lex, 
                                                    sim->rotulo,
                                                    sim->num_args,
                                                    sim->tipo);
            for (int j = 0; j < sim->num_args; j++) {
                printf("     ARGS | %s | t: %d | ref: %d\n", 
                                                            sim->args_list[j].nome, 
                                                            sim->args_list[j].tipo,
                                                            sim->args_list[j].p_ref);
            }
            break;
        case PARAMETRO_FORMAL:
            printf("FORM | %s | %d, %d | type: %d | ref: %d\n",
                                                sim->nome, 
                                                sim->lex, 
                                                sim->desl, 
                                                sim->tipo,
                                                sim->p_ref);
            break;
        default:
            break;
        }
}