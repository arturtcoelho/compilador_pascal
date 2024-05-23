
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

t_pilha pilha_args;

t_simbolo *simb_esquerda_atribuicao;
t_simbolo *simb_esquerda_procedimento;
t_simbolo *simb_esquerda;

int pilha_rotulos = -1;
int rotulo_main = 0;

char ident_save[64];
int num_param = 0;
t_simbolo* guarda_simbolo;
t_arg* arg;

int guarda_tipo;
bool eh_vs = 0;
bool eh_param = 0;
bool carregou = 0;

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

programa:
{
   geraCodigo (NULL, " INPP");
}
   PROGRAM IDENT parte_opcional_program PONTO_E_VIRGULA
   bloco 
   {
      geraCodigo (NULL, " PARA");
   }
   PONTO 
;

parte_opcional_program: ABRE_PARENTESES lista_idents FECHA_PARENTESES 
   | %empty
;

bloco:
   parte_declara_vars
   parte_declara_procedimetos
   comando_composto
{ 
   printTabSimbolo();
   geraCodigoDmem(nivel_lexico);
   removeTabLex(nivel_lexico);
}
;

// DECLARA VARS

parte_declara_vars: 
{deslocamento = 0;} 
   VAR declara_vars
   | %empty
;

declara_vars: declara_vars declara_var
   | declara_var
;

declara_var : 
{num_vars = 0;}
   lista_id_var DOIS_PONTOS tipo {updateTipoSimbolo(simbolo, num_vars);}
{geraCodigoAmem(num_vars);}
   PONTO_E_VIRGULA
;

tipo: T_INTEGER 
   | T_BOOL
;

lista_id_var: 
   lista_id_var VIRGULA IDENT
{addSimboloSimples(token, deslocamento, nivel_lexico);num_vars++; deslocamento++; }
   | IDENT {addSimboloSimples(token, deslocamento, nivel_lexico);num_vars++; deslocamento++;}
;

lista_idents: lista_idents VIRGULA IDENT
   | IDENT
;

// COMANDOS

comando_composto: T_BEGIN varios_comandos pv_opcional T_END
;

pv_opcional: PONTO_E_VIRGULA 
   | %empty
;

varios_comandos: 
   varios_comandos PONTO_E_VIRGULA comando |
   comando
;

comando: 
   IDENT {strcpy(ident_save, token);} ident_solto
   | comando_while
   | comando_if
   | leitura | escrita
   | comando_composto
;

// IF

comando_if: T_IF expressao 
{
   pilha_rotulos+=2;
   geraCodigoDesvioF(pilha_rotulos-1);
} 
T_THEN comando
{
   geraCodigoDesvioS(pilha_rotulos);
   geraCodigoRotulo(pilha_rotulos-1);
} 
parte_else 
{
   geraCodigoRotulo(pilha_rotulos);
   pilha_rotulos-=2;
}
;

parte_else: T_ELSE comando 
   | %empty
;

// WHILE

comando_while: 
   T_WHILE 
{
   pilha_rotulos+=2;
   geraCodigoRotulo(pilha_rotulos-1);
} 
   expressao T_DO 
{geraCodigoDesvioF(pilha_rotulos);}
   comando
{
   geraCodigoDesvioS(pilha_rotulos-1);
   geraCodigoRotulo(pilha_rotulos);
   pilha_rotulos-=2;
}
;

// ATRIBUICAO

ident_solto: parte_chamada_argumentos 
   | comando_atribuicao
   | %empty {
   strcpy(token, ident_save);
   t_simbolo *id = buscaSimbolo(token, nivel_lexico);
   if (!id) imprimeErro("Não existe o simbolo");
   if (id->cat != PROCEDIMENTO) imprimeErro("Quero um procedimento");
   geraCodigoChamaProc(id->rotulo, nivel_lexico);
   simb_esquerda = id;
} 
;

comando_atribuicao: 
{
   strcpy(token, ident_save);
   simb_esquerda_atribuicao = buscaSimbolo(token, nivel_lexico);
   if (!simb_esquerda_atribuicao) imprimeErro("Não existe o simbolo");
   if (simb_esquerda_atribuicao->cat != SIMPLES && simb_esquerda_atribuicao->cat != PARAMETRO_FORMAL) imprimeErro("Impossivel atribuir");
} 
   ATRIBUICAO expressao
{
   int t = desempilha(&pilha_e);
   if (simb_esquerda_atribuicao->tipo != t) imprimeErro("Erro de tipo");
   // printSimbolo(simb_esquerda_atribuicao);
   if (simb_esquerda_atribuicao->p_ref) {
      geraCodigoArmi(simb_esquerda_atribuicao->lex, simb_esquerda_atribuicao->desl);
   } else {
      geraCodigoArmz(simb_esquerda_atribuicao->lex, simb_esquerda_atribuicao->desl);
   }
}
;

// DECLARA PROD

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
   simb_esquerda = addSimboloProcedimento(token, nivel_lexico, pilha_rotulos);
   simb_esquerda->num_args = 0;
   empilha(&pilha_args, 0);
}
   opt_param_formal PONTO_E_VIRGULA 
   bloco
{
   int n = desempilha(&pilha_args);
   geraCodigoRetProc(nivel_lexico, n);
   geraCodigoRotulo(pilha_rotulos-1);
   
   nivel_lexico--;

   if (nivel_lexico == 1){
      pilha_rotulos -= 2;
   }
} 
   PONTO_E_VIRGULA
;

opt_param_formal: ABRE_PARENTESES lista_param_formal FECHA_PARENTESES 
{
   corrigeDeslocFormal(simb_esquerda->num_args);
}
   | %empty
;

lista_param_formal: lista_param_formal PONTO_E_VIRGULA parte_param_formal
   | parte_param_formal
   | %empty
;

parte_param_formal:  
{
   arg = &simb_esquerda->args_list[simb_esquerda->num_args++];
   int n = desempilha(&pilha_args);
   empilha(&pilha_args, n+1);
}
   param_formal DOIS_PONTOS tipo
{
   arg->tipo = simbolo;
   adicionaSimboloFormal(arg->nome, nivel_lexico, simbolo, arg->p_ref);
}
;

param_formal: VAR IDENT {arg->p_ref = 1;strcpy(arg->nome, token);}
   | IDENT {arg->p_ref = 0;strcpy(arg->nome, token);}
;

// CHAMADA PROD

parte_chamada_argumentos: ABRE_PARENTESES
{
   simb_esquerda = buscaSimbolo(ident_save, nivel_lexico);
   num_param = -1;
}
   argumentos FECHA_PARENTESES 
{
   if (num_param+1 != simb_esquerda->num_args) imprimeErro("Numero errado de argumentos");
   if (!simb_esquerda) imprimeErro("Não existe o simbolo");
   if (simb_esquerda->cat != PROCEDIMENTO) imprimeErro("Quero um procedimento");
   geraCodigoChamaProc(simb_esquerda->rotulo, nivel_lexico);
}
;

argumentos: argumentos VIRGULA argumento
   | argumento
;

argumento: 
{
   carregou = 0;
   num_param++;
   if (simb_esquerda->args_list[num_param].p_ref)
      eh_param = 1;
   else
      eh_param = 0;
}
   expressao
{
   eh_param = 0;
   if (guarda_tipo != simb_esquerda->args_list[num_param].tipo) imprimeErro("Tipo errado do argumento");
   if (simb_esquerda->args_list[num_param].p_ref) {
      if (!eh_vs) imprimeErro("Argumento por ref deve ser uma variavel");
      if (!carregou) {
         if (guarda_simbolo->p_ref) {
            geraCodigoCrvl(guarda_simbolo->lex, guarda_simbolo->desl);
         } else {
            geraCodigoCren(guarda_simbolo->lex, guarda_simbolo->desl);
         }
      }
   }
}
;

// EXPRESSOES

expressao: expressao_aritmetica expressao_booleana | expressao_aritmetica
;

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


expressao_aritmetica: E
;

E:
   E T_MAIS T {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("SOMA");} 
   | E T_MENOS T {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("SUBT");} 
   | E T_OR T {comparaTipos(&pilha_e, &pilha_t);
               geraCodigoSimples("DISJ");} 
   | T {int t = desempilha(&pilha_t);
      empilha(&pilha_e, t);}
;

T:
   T T_ASTERISCO F
{comparaTipos(&pilha_t, &pilha_f);
geraCodigoSimples("MULT");
} 
   | T T_DIV F 
{comparaTipos(&pilha_t, &pilha_f);
geraCodigoSimples("DIVI");} 
   | T T_AND F 
{comparaTipos(&pilha_t, &pilha_f);
geraCodigoSimples("CONJ");}
   | F 
{int t = desempilha(&pilha_f);
empilha(&pilha_t, t);}
;

F:
   NUMERO 
{
   empilha(&pilha_f, simb_integer);
   geraCodigoCrct(token);
   guarda_tipo = simb_integer;
   eh_vs = 0;
}
   | bool_val
{
   empilha(&pilha_f, simb_bool);
   geraCodigoBool(token);
   guarda_tipo = simb_bool;
   eh_vs = 0;
}
   | IDENT 
{
   t_simbolo *id = buscaSimbolo(token, nivel_lexico);
   if (!id) imprimeErro("Não existe o simbolo");
   if (id->cat != SIMPLES && id->cat != PARAMETRO_FORMAL) imprimeErro("Quero um val simples");
   empilha(&pilha_f, id->tipo);
   if (!eh_param && id->p_ref) {
      geraCodigoCrvi(id->lex, id->desl);
   } else if (!eh_param) {
      geraCodigoCrvl(id->lex, id->desl);
      carregou = 1;
   }
   guarda_tipo = id->tipo;
   guarda_simbolo = id;
   eh_vs = 1;
}
   | ABRE_PARENTESES expressao FECHA_PARENTESES
{
   int t = desempilha(&pilha_e);
   empilha(&pilha_f, t);
   guarda_tipo = t;
   eh_vs = 0;
}
;

bool_val: T_TRUE | T_FALSE;

// IO

leitura: 
   T_READ ABRE_PARENTESES lista_idents_leitura FECHA_PARENTESES
;

lista_idents_leitura: lista_idents_leitura VIRGULA parte_leitura 
   | parte_leitura 
;

parte_leitura: IDENT
{
   t_simbolo * s = buscaSimbolo(token, nivel_lexico);
   if (s->cat != SIMPLES) imprimeErro("Tentando ler valor em simbolo nao simples");
   geraCodigoSimples("LEIT");
   geraCodigoArmz(s->lex, s->desl);
} 
;


escrita: T_WRITE ABRE_PARENTESES lista_write FECHA_PARENTESES
;

lista_write: lista_write VIRGULA parte_imprimivel 
   | parte_imprimivel
;

parte_imprimivel: 
   expressao 
{geraWrite();} 
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
   inicia_pilha(&pilha_args);

   yyin=fp;
   yyparse();

   return 0;
}
