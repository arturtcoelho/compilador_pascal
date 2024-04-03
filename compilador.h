#ifndef COMPILADOR
#define COMPILADOR

#define TAM_TOKEN 16
#define MAX_ARGS 16

#include "pilha.h"

/* -------------------------------------------------------------------
 *            Arquivo: compilador.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [09/08/2020, 19h:01m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e variáveis globais do compilador (via extern)
 *
 * ------------------------------------------------------------------- */
typedef char bool;

typedef enum simbolos {
  simb_program, simb_var, simb_begin, simb_end,
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses,
  simb_procedure, simb_function,
  simb_while, simb_do, 
  simb_if, simb_else, simb_then,
  simb_mais, simb_menos, simb_barra, simb_asterisco, simb_div,
  simb_menor, simb_maior, simb_menorigual, simb_maiorigual, simb_igual, simb_desigual, 
  simb_not, simb_and, simb_or,
  simb_integer, simb_bool, simb_true, simb_false,
  simb_read, simb_write
} simbolos;

typedef enum tipo_simbolo {
  SIMPLES, PROCEDIMENTO
} t_categoria;

typedef struct args {
    char nome[TAM_TOKEN];
    int tipo;
    bool p_ref;
} t_arg;

typedef struct simbolo {
    char nome[TAM_TOKEN];
    int lex, desl;
    t_categoria cat;
    int tipo;
    int rotulo;
    int num_args;
    t_arg args_list[MAX_ARGS];
} t_simbolo;

/* -------------------------------------------------------------------
 * variáveis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int desloc;
extern int nl;


/* -------------------------------------------------------------------
 * prototipos globais
 * ------------------------------------------------------------------- */

void geraCodigo (char*, char*);
void geraCodigoAmem(int);
void geraCodigoDmem();
void geraCodigoCrct(char*);
void geraCodigoBool(char*);
void geraCodigoCrvl(int, int);
void geraCodigoArmz(int, int);
void geraCodigoSimples(char*);
void geraCodigoRotulo(int);
void geraCodigoDesvioF(int);
void geraCodigoDesvioS(int);
void geraCodigoEntraProc(int, int);
void geraCodigoRetProc(int, int);
void geraCodigoChamaProc(int, int);
void geraWrite();
void geraWriteConstante();

void comparaTipos(t_pilha*, t_pilha*);
void comparaTiposBool(t_pilha*, t_pilha*);

int imprimeErro ( char* erro );

int yylex();
void yyerror(const char *s);

#endif