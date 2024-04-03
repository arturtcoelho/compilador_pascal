
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

int pilha_rotulos = -1;

char ident_save[64];
int num_param = 0;
t_simbolo* guarda_simbolo;
t_arg* arg;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO NUMERO
%token T_PROCEDURE T_FUNCTION 
%token T_WHILE T_DO 
%token T_IF T_THEN T_ELSE
%token T_MAIS T_MENOS T_BARRA T_ASTERISCO T_DIV
%token T_MENOR T_MAIOR T_MENORIGUAL T_MAIORIGUAL T_IGUAL T_DESIGUAL
%token T_NOT T_AND T_OR
%token T_INTEGER T_BOOL T_TRUE T_FALSE
%token T_READ T_WRITE

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
              parte_declara_procedimetos
              comando_composto
              { printTabSimbolo();
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
              {addSimboloSimples(token, deslocamento, nivel_lexico);num_vars++; deslocamento++; }
            | IDENT {addSimboloSimples(token, deslocamento, nivel_lexico);num_vars++; deslocamento++;}
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
               IDENT {strcpy(ident_save, token);} ident_solto
               | comando_while
               | comando_if
               | leitura | escrita
               | comando_composto
;

comando_if: T_IF expressao {
   pilha_rotulos+=2;
   geraCodigoDesvioF(pilha_rotulos-1);
} T_THEN comando {geraCodigoDesvioS(pilha_rotulos);geraCodigoRotulo(pilha_rotulos-1);} parte_else {geraCodigoRotulo(pilha_rotulos);pilha_rotulos-=2;}
;

parte_else : T_ELSE comando | %empty;

comando_while : T_WHILE {pilha_rotulos+=2;geraCodigoRotulo(pilha_rotulos-1);} 
               expressao T_DO 
               {geraCodigoDesvioF(pilha_rotulos);}
               comando
               {geraCodigoDesvioS(pilha_rotulos-1);
               geraCodigoRotulo(pilha_rotulos);
               pilha_rotulos-=2;}
;

ident_solto: chamada_procedimento | 
         comando_atribuicao 
;

comando_atribuicao: {
      strcpy(token, ident_save);
      simb_esquerda = buscaSimbolo(token);
      if (!simb_esquerda) imprimeErro("Não existe o simbolo");
      if (simb_esquerda->cat != SIMPLES) imprimeErro("Impossivel atribuir");
   } 
   ATRIBUICAO expressao
   {
      int t = desempilha(&pilha_e);
      if (simb_esquerda->tipo != t) imprimeErro("Erro de tipo");
      geraCodigoArmz(simb_esquerda->lex, simb_esquerda->desl);
   }
;

chamada_procedimento: {
   strcpy(token, ident_save);
   t_simbolo *id = buscaSimbolo(token);
   if (!id) imprimeErro("Não existe o simbolo");
   if (id->cat != PROCEDIMENTO) imprimeErro("Quero um procedimento");
   geraCodigoChamaProc(id->rotulo, nivel_lexico);
} parte_chamada_parametros
;

parte_chamada_parametros: ABRE_PARENTESES argumentos FECHA_PARENTESES 
                              | %empty
;

argumentos: argumentos VIRGULA argumento | argumento
;

argumento: IDENT | expressao
;

expressao : expressao_aritmetica expressao_booleana | expressao_aritmetica;

expressao_booleana:
      T_IGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMIG");
   } | 
      T_DESIGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMDG");
   } | 
      T_MAIOR expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMMA");
   } | 
      T_MENOR expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMME");
   } | 
      T_MAIORIGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMAG");
   } | 
      T_MENORIGUAL expressao_aritmetica {
      comparaTiposBool(&pilha_e, &pilha_e);
      geraCodigoSimples("CMEG");
   }
;


expressao_aritmetica : E
;

E:
   E T_MAIS T {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("SOMA");} 
   | E T_MENOS T {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("SUBT");} 
   | E T_OR T {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("DISJ");
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
   | T T_AND F {
               comparaTipos(&pilha_t, &pilha_f);
               geraCodigoSimples("CONJ");
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
   | bool_val 
          {empilha(&pilha_f, simb_bool);
          geraCodigoBool(token);
   }
   | IDENT {
      t_simbolo *id = buscaSimbolo(token);
      if (!id) imprimeErro("Não existe o simbolo");
      if (id->cat != SIMPLES) imprimeErro("Quero um val simples");
      empilha(&pilha_f, id->tipo);
      geraCodigoCrvl(id->lex, id->desl);
   }
   | ABRE_PARENTESES expressao FECHA_PARENTESES
    {
        int t = desempilha(&pilha_e);
        empilha(&pilha_f, t);
    }
;

bool_val: T_TRUE | T_FALSE;

parte_declara_procedimetos: declaracao_procedimeto 
                              | parte_declara_procedimetos declaracao_procedimeto 
                              | %empty
;

declaracao_procedimeto: T_PROCEDURE IDENT 
                        {
                           nivel_lexico++;
                           pilha_rotulos+=2;
                           geraCodigoDesvioS(pilha_rotulos-1);
                           geraCodigoEntraProc(pilha_rotulos, nivel_lexico);
                           guarda_simbolo = addSimboloProcedimento(token, nivel_lexico, pilha_rotulos);
                           guarda_simbolo->num_args = 0;
                           num_param = 0;
                        }
                        opt_param_formal PONTO_E_VIRGULA 
                        bloco
                        {
                           geraCodigoRetProc(nivel_lexico, num_param);
                           geraCodigoRotulo(pilha_rotulos-1);
                           
                           nivel_lexico--;
                        } 
                        PONTO_E_VIRGULA
;

opt_param_formal: ABRE_PARENTESES lista_param_formal FECHA_PARENTESES 
                     | %empty
;

lista_param_formal: lista_param_formal VIRGULA parte_param_formal
                     | parte_param_formal
                     | %empty
;

parte_param_formal:  {
   arg = &guarda_simbolo->args_list[guarda_simbolo->num_args++];
}
param_formal DOIS_PONTOS tipo
{
   arg->tipo = simbolo;
}
;

param_formal: VAR IDENT {arg->p_ref = 1;strcpy(arg->nome, token);}
               | IDENT {arg->p_ref = 0;strcpy(arg->nome, token);}
;

leitura: T_READ ABRE_PARENTESES IDENT {
   t_simbolo * s = buscaSimbolo(token);
   if (s->cat != SIMPLES) imprimeErro("Tentando ler valor em simbolo nao simples");
   geraCodigoSimples("LEIT");
   geraCodigoArmz(s->lex, s->desl);} 
   FECHA_PARENTESES
;

escrita: T_WRITE ABRE_PARENTESES lista_write FECHA_PARENTESES
;

lista_write: lista_write VIRGULA parte_imprimivel 
   | parte_imprimivel
;

parte_imprimivel: IDENT {geraWrite();} | NUMERO {geraWriteConstante();};

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
