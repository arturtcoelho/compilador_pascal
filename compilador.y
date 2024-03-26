
%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "tabSimbolos.h"
#include "pilha.h"

int num_vars;
int deslocamento;
int nivel_lexico = 0;

t_pilha pilha_e;
t_pilha pilha_t;
t_pilha pilha_f;

t_simbolo *simb_esquerda;

char mepa_buffer[64];

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO NUMERO
%token T_PROCEDURE T_FUNCTION T_WHILE T_IF
%token T_MAIS T_MENOS T_BARRA T_ASTERISCO T_DIV
%token T_MENOR T_MAIOR T_MENORIGUAL T_MAIORIGUAL T_IGUAL T_DESIGUAL
%token T_NOT T_AND T_OR
%token T_INTEGER T_BOOL T_TRUE T_FALSE

%%

programa    :{
             geraCodigo (NULL, "INPP");
             }
             PROGRAM IDENT parte_opcional_program PONTO_E_VIRGULA
             bloco PONTO {
             geraCodigo (NULL, "PARA");
             }
;

parte_opcional_program
            :
               ABRE_PARENTESES lista_idents FECHA_PARENTESES 
               | %empty
;

bloco       :
              parte_declara_vars
              {
              }

              comando_composto
              { //printTabSimbolo();
              geraCodigoDmem(nivel_lexico);removeTabLex(nivel_lexico);}
              ;

parte_declara_vars  
            : {deslocamento = 0;} VAR declara_vars
            | %empty
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : {num_vars = 0;}
              lista_id_var DOIS_PONTOS tipo {updateTipoSimbolo(simbolo, num_vars);}
              {geraCodigoAmem(num_vars);}
              PONTO_E_VIRGULA
;

tipo        : T_INTEGER | T_BOOL
;

lista_id_var: lista_id_var VIRGULA IDENT
              {addSimbolo(token, simples, deslocamento, nivel_lexico);num_vars++; deslocamento++; }
            | IDENT {addSimbolo(token, simples, deslocamento, nivel_lexico);num_vars++; deslocamento++;}
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;

pv_opcional     : PONTO_E_VIRGULA | %empty
;

comando_composto: T_BEGIN varios_comandos pv_opcional T_END
;

varios_comandos : varios_comandos PONTO_E_VIRGULA comando |
                  comando
;

comando        : 
               comando_atribuicao
;

comando_atribuicao : IDENT {
      simb_esquerda = buscaSimbolo(token);
      if (!simb_esquerda) imprimeErro("Não existe o simbolo");
      if (simb_esquerda->cat != simples) imprimeErro("Impossivel atribuir");
   } 
   ATRIBUICAO expressao
   {
      int t = desempilha(&pilha_e);
      // printf("%d, %d\n", t, simb_esquerda->tipo);
      if (simb_esquerda->tipo != t) imprimeErro("Erro de tipo");
      sprintf(mepa_buffer, "ARMZ %d, %d", simb_esquerda->lex, simb_esquerda->desl);
      geraCodigo(NULL, mepa_buffer);
   }
;

expressao:
   expressao_aritmetica |
   expressao T_IGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMIG");
   } | 
   expressao T_DESIGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMDG");
   } | 
   expressao T_MAIOR expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMMA");
   } | 
   expressao T_MENOR expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMME");
   } | 
   expressao T_MAIORIGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMAG");
   } | 
   expressao T_MENORIGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMEG");
   } |
   expressao T_AND expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CONJ");
   } |
   expressao T_OR expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("DISJ");
   }| bool_val 
         {empilha(&pilha_e, simb_bool);
         geraCodigoBool(token);}
;

bool_val: T_TRUE | T_FALSE;

expressao_aritmetica : E
;

E:
   E T_MAIS T {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("SOMA");
               } 
   | E T_MENOS T 
               {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("SUBT");
               } 
   | T {
      int t = desempilha(&pilha_t);
      empilha(&pilha_e, t);
   }
;

T:
   T T_ASTERISCO F
               {comparaTipos(&pilha_t, &pilha_f);
               geraCodigoSimples("MULT");
               } 
   | T T_DIV F {comparaTipos(&pilha_t, &pilha_f);
               geraCodigoSimples("DIVI");
               } 
   | F {
      int t = desempilha(&pilha_f);
      empilha(&pilha_t, t);
   }
;

F:
   NUMERO {
         empilha(&pilha_f, simb_integer);
         geraCodigoCrct(token);
   }
   | IDENT {
      t_simbolo *id = buscaSimbolo(token);
      if (!id) imprimeErro("Não existe o simbolo");
      if (id->cat != simples) imprimeErro("Quero um val simples");
      empilha(&pilha_f, id->tipo);
      geraCodigoCrvl(id->lex, id->desl);
   }
   | ABRE_PARENTESES expressao_aritmetica FECHA_PARENTESES
    {
        int t = desempilha(&pilha_e);
        empilha(&pilha_f, t);
    }
;

%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }

   inicia_tab();
   inicia_pilha(&pilha_e);
   inicia_pilha(&pilha_t);
   inicia_pilha(&pilha_f);

   yyin=fp;
   yyparse();

   return 0;
}
