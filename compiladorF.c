
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
char lastToken[TAM_TOKEN];

FILE* fp=NULL;
void geraCodigo (char* rot, char* comando) 
{

  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }

  if ( rot == NULL ) {
    fprintf(fp, "    %s\n", comando); fflush(fp);
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
  printf("AMEM\n");
}

void geraCodigoDmem(int lex, int offset) {
  int n = contaTabSimb(lex);
  if (n-offset <=0) return;
  fprintf(fp, "     DMEM %d\n", n-offset); fflush(fp);
  printf("DMEM\n");
}

void geraCodigoCrct(char* n)
{
  fprintf(fp, "     CRCT %s\n", n); fflush(fp);
  printf("CRCT\n");
}

void geraCodigoBool(char* cod)
{
  if (!strcmp(cod, "true")) {
    fprintf(fp, "     CRCT 1\n"); fflush(fp);
  } else {
    fprintf(fp, "     CRCT 0\n"); fflush(fp);
  }
  printf("CRCT\n");
}

void geraCodigoCrvl(int lex, int desl)
{
  fprintf(fp, "     CRVL %d, %d\n", lex, desl); fflush(fp);
  printf("CRVL\n");
}

void geraCodigoCrvi(int lex, int desl)
{
  fprintf(fp, "     CRVI %d, %d\n", lex, desl); fflush(fp);
  printf("CRVI\n");
}

void geraCodigoArmz(int lex, int desl)
{
  fprintf(fp, "     ARMZ %d, %d\n", lex, desl); fflush(fp);
  printf("ARMZ\n");
}

void geraCodigoArmi(int lex, int desl)
{
  fprintf(fp, "     ARMI %d, %d\n", lex, desl); fflush(fp);
  printf("ARMI\n");
}

void geraCodigoSimples(char* m)
{
  fprintf(fp, "     %s\n", m); fflush(fp);
  printf("%s\n", m);
}

void geraCodigoRotulo(int n)
{
  fprintf(fp, "R%02d: NADA\n", n); fflush(fp);
  printf("NADA %d\n", n);
}

void geraCodigoDesvioF(int n)
{
  fprintf(fp, "     DSVF R%02d\n", n); fflush(fp);
  printf("DSVF\n");
}

void geraCodigoDesvioS(int n)
{
  fprintf(fp, "     DSVS R%02d\n", n); fflush(fp);
  printf("DSVS\n");
}

void geraCodigoEntraProc(int rot,int lex)
{
  fprintf(fp, "R%02d: ENPR %d\n", rot, lex); fflush(fp);
  printf("ENPR\n");
}

void geraCodigoRetProc(int lex,int num_param)
{
  fprintf(fp, "     RTPR %d, %d\n", lex, num_param); fflush(fp);
  printf("RTPR\n");
}

void geraCodigoChamaProc(int rot, int lex)
{
  fprintf(fp, "     CHPR R%02d, %d\n", rot, lex); fflush(fp);
  printf("CHPR\n");
}

void geraCodigoParam()
{
  
}

void geraCodigoCren(int lex, int desl)
{
  fprintf(fp, "     CREN %d, %d\n", lex, desl); fflush(fp);
  printf("CREN\n");
}

void geraWrite()
{
  // t_simbolo * s = buscaSimbolo(token);
  // if (s->cat != SIMPLES) imprimeErro("Tentando ler valor em simbolo nao simples");
  // geraCodigoCrvl(s->lex, s->desl);
  geraCodigoSimples("IMPR");
  printf("IMPR\n");
}

void geraWriteConstante()
{
  geraCodigoCrct(token);
  geraCodigoSimples("IMPR");
  printf("IMPR\n");
}

void comparaTipos(t_pilha* a, t_pilha* b)
{
  // printf("conparatipos\n");
  int t1 = desempilha(a);
  int t2 = desempilha(b);
  // printf("%d, %d\n", t1, t2);
  // printf("%s\n", token);
  checkErroTipo(t1, t2);
  empilha(a, t1);
}

void comparaTiposBool(t_pilha* a, t_pilha* b)
{
  // printf("Comparabool\n");
  int t1 = desempilha(a);
  int t2 = desempilha(b);
  // printf("%d, %d\n", t1, t2);
  checkErroTipo(t1, t2);
  empilha(a, simb_bool);
}

int geraTipoCustom(int n, int base)
{
    return (n+1)*base*13;
}

void checkErroTipo(int t1, int t2)
{
  printf("===COMPARA TIPOS===: %d / %d\n", t1, t2);
  if (t1 == t2)
    return;

  double d = (double) t1/t2;
  int i = t1/t2;
  if (d == i) return;

  d = (double) t2/t1;
  i = t2/t1;
  if (d == i) return;
  
  imprimeErro("Erro de tipo na avaliação ESPECIAL");
}