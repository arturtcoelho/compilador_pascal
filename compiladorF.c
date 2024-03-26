
/* -------------------------------------------------------------------
 *            Aquivo: compilador.c
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [09/08/2020, 19h:01m]
 *
 * -------------------------------------------------------------------
 *
 * Funções auxiliares ao compilador
 *
 * ------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "tabSimbolos.h"

/* -------------------------------------------------------------------
 *  variáveis globais
 * ------------------------------------------------------------------- */

simbolos simbolo, relacao;
char token[TAM_TOKEN];

FILE* fp=NULL;
void geraCodigo (char* rot, char* comando) 
{

  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }

  if ( rot == NULL ) {
    fprintf(fp, "     %s\n", comando); fflush(fp);
  } else {
    fprintf(fp, "%s: %s \n", rot, comando); fflush(fp);
  }
}

int imprimeErro ( char* erro ) {
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}

void geraCodigoAmem(int n) 
{
  if (n <= 0) return;
  fprintf(fp, "     AMEM %d\n", n); fflush(fp);
}

void geraCodigoDmem(int lex) {
  int n = contaTabSimb(lex);
  if (n <=0) return;
  fprintf(fp, "     DMEM %d\n", n); fflush(fp);
}

void geraCodigoCrct(char* n)
{
  fprintf(fp, "     CRCT %s\n", n); fflush(fp);
}

void geraCodigoBool(char* cod)
{
  if (!strcmp(cod, "true")) {
    fprintf(fp, "     CRCT 1\n"); fflush(fp);
  } else {
    fprintf(fp, "     CRCT 0\n"); fflush(fp);
  }
}


void geraCodigoCrvl(int lex, int desl)
{
  fprintf(fp, "     CRVL %d, %d\n", lex, desl); fflush(fp);
}

void geraCodigoArmz(int lex, int desl)
{
  fprintf(fp, "     ARMZ %d, %d\n", lex, desl); fflush(fp);
}

void geraCodigoSimples(char* m)
{
  fprintf(fp, "     %s\n", m); fflush(fp);
}

void geraCodigoRotulo(int n)
{
  fprintf(fp, "R%02d: NADA\n", n); fflush(fp);
}

void geraCodigoDesvioF(int n)
{
  fprintf(fp, "     DSVF R%02d\n", n); fflush(fp);
}

void geraCodigoDesvioS(int n)
{
  fprintf(fp, "     DSVS R%02d\n", n); fflush(fp);
}

void geraWrite()
{
  t_simbolo * s = buscaSimbolo(token);
  if (s->cat != simples) imprimeErro("Tentando ler valor em simbolo nao simples");
  geraCodigoCrvl(s->lex, s->desl);
  geraCodigoSimples("IMPR");
}

void geraWriteConstante()
{
  geraCodigoCrct(token);
  geraCodigoSimples("IMPR");
}

void comparaTipos(t_pilha* a, t_pilha* b)
{
  int t1 = desempilha(a);
  int t2 = desempilha(b);
  // printf("%d, %d\n", t1, t2);
  // printf("%s\n", token);
  if (t1 == t2)
    empilha(a, t1);
  else
    imprimeErro("Erro tipos");
}

void comparaTiposBool(t_pilha* a, t_pilha* b)
{
  int t1 = desempilha(a);
  int t2 = desempilha(b);
  // printf("%d, %d\n", t1, t2);
  if (t1 == t2)
    empilha(a, simb_bool);
  else
    imprimeErro("Erro tipos bool");
}