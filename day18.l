%option noyywrap

%{
#include <stdio.h>

#define YY_DECL int yylex()

#include "day18.tab.h"

%}

%%

[ \t]	; // ignore all whitespace
[0-9]+	{yylval.val = atoi(yytext); return T_NUM;}
\n		{return T_NEWLINE;}
"+"		{return T_PLUS;}
"*"		{return T_MULTIPLY;}
"("		{return T_LEFT;}
")"		{return T_RIGHT;}

%%
