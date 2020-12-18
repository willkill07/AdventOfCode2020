%{

#include <stdio.h>
#include <stdlib.h>

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(long long*, const char* s);
%}

%parse-param { long long * result }

%union {
	long long val;
}

%token<val> T_NUM
%token T_PLUS T_MULTIPLY T_LEFT T_RIGHT T_NEWLINE

// part 1
// %left T_MULTIPLY T_PLUS

// part 2
// %left T_MULTIPLY
// %left T_PLUS

%type<val> expression

%start calculation

%%

calculation: 
    | calculation line
;

line: T_NEWLINE
    | expression T_NEWLINE { *result += $1; }
;

expression: T_LEFT expression T_RIGHT       { $$ = $2; }
    | expression T_PLUS expression        { $$ = $1 + $3; }
    | expression T_MULTIPLY expression    { $$ = $1 * $3; }
    | T_NUM                               { $$ = $1; }
;

%%

int main() {
	yyin = stdin;

	do {
        long long result = 0;
		yyparse(&result);
        printf("%lld\n", result);
	} while(!feof(yyin));

	return 0;
}

void yyerror(long long* answer, const char* s) {
	fprintf(stderr, "Parse error: %s\n", s);
	exit(1);
}