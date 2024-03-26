c1 = '{'
c2 = '}'
while s := input():
    print(f'''
{s} {c1} simbolo = simb_{s};
        strncpy (token, yytext, TAM_TOKEN);
        IMPRIME("{s}  ");
        return T_{s.upper()};
{c2}
''')