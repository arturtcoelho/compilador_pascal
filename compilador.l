
/* -------------------------------------------------------------------
 *            Arquivo: compilador.l
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

%{


#include<stdio.h>
#include<string.h>

#include "compilador.h"
#include "compilador.tab.h"

// #define IMPRIME(STR) {};
#define IMPRIME(STR) printf("%s    # %s \n", STR, token);

int nl = 1;

%}

pulo_linha [\n]

descarte [\t ]+

ident [a-zA-Z][a-zA-Z0-9]*

numero [0-9]+

comentario "(*".*"*)"

%%

{pulo_linha} {nl++;printf("%d ", nl);}

{descarte}

{comentario}

program { simbolo  = simb_program;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("program ");
          return PROGRAM;
 }

var      { simbolo = simb_var;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("var  ");
          return VAR;
 }

type      { simbolo = simb_type;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("type  ");
          return TYPE;
 }

begin { simbolo = simb_begin;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("begin ");
          return T_BEGIN;
 }

end { simbolo = simb_end;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("end  ");
          return T_END;
 }

procedure { simbolo = simb_procedure;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("procedure  ");
          return T_PROCEDURE;
 }

function { simbolo = simb_function;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("function  ");
          return T_FUNCTION;
 }

while { simbolo = simb_while;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("while  ");
          return T_WHILE;
 }

do { simbolo = simb_do;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME("do  ");
          return T_DO;
 }

if { simbolo = simb_if;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("if  ");
        return T_IF;
}

then { simbolo = simb_then;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("then  ");
        return T_THEN;
}

else { simbolo = simb_else;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("else  ");
        return T_ELSE;
}

\+ { simbolo = simb_mais;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("+  ");
        return T_MAIS;
}


\- { simbolo = simb_menos;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("-  ");
        return T_MENOS;
}


\* { simbolo = simb_asterisco;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("*  ");
        return T_ASTERISCO;
}


\< { simbolo = simb_menor;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("<  ");
        return T_MENOR;
}


\> { simbolo = simb_maior;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME(">  ");
        return T_MAIOR;
}


\<= { simbolo = simb_menorigual;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("<=  ");
        return T_MENORIGUAL;
}


\>= { simbolo = simb_maiorigual;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME(">=  ");
        return T_MAIORIGUAL;
}


\= { simbolo = simb_igual;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("=  ");
        return T_IGUAL;
}


\<> { simbolo = simb_desigual;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("<>  ");
        return T_DESIGUAL;
}


div { simbolo = simb_div;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("div  ");
        return T_DIV;
}


not { simbolo = simb_not;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("not  ");
        return T_NOT;
}


and { simbolo = simb_and;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("and  ");
        return T_AND;
}


or { simbolo = simb_or;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("or  ");
        return T_OR;
}


integer { simbolo = simb_integer;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("integer  ");
        return T_INTEGER;
}


boolean { simbolo = simb_bool;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("bool  ");
        return T_BOOL;
}


true { simbolo = simb_true;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("true  ");
        return T_TRUE;
}


false { simbolo = simb_false;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("false  ");
        return T_FALSE;
}

:= { simbolo = simb_atribuicao;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" atribuicao  ");
          return ATRIBUICAO;
 }

\; { simbolo = simb_ponto_e_virgula;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" pt_virgula  ");
          return PONTO_E_VIRGULA;
 }

\: { simbolo = simb_dois_pontos;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" dois pontos ");
          return DOIS_PONTOS;
 }

\, { simbolo = simb_virgula;
          strncpy (lastToken, token, TAM_TOKEN);
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" virgula  ");
          return VIRGULA;
 }


\. { simbolo = simb_ponto;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" ponto  ");
          return PONTO;
    }

\(  { simbolo = simb_abre_parenteses;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" abre_parenteses  ");
          return ABRE_PARENTESES;
    }

\)  { simbolo = simb_fecha_parenteses;
          strncpy (lastToken, token, TAM_TOKEN);
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" fecha_parenteses ");
          return FECHA_PARENTESES;
 }

read { simbolo = simb_read;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("read  ");
        return T_READ;
}

write { simbolo = simb_write;
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("write  ");
        return T_WRITE;
}

{ident} { simbolo = simb_identificador;
          strncpy (lastToken, token, TAM_TOKEN);
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" ident  ");
          return IDENT;
        }

{numero} { simbolo = simb_numero;
          strncpy (token, yytext, TAM_TOKEN);
          IMPRIME(" numero  ");
          return NUMERO;
        }


%%
