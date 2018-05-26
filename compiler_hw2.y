/*	Definition section */
%{
#include <stdio.h>
extern int yylineno;
extern int yylex();

/* Symbol table function - you can add new function if need. */
int lookup_symbol();
void create_symbol();
void insert_symbol();
void dump_symbol();

%}

/* Using union to define nonterminal and token type */
%union {
    int i_val;
    double f_val;
    char* string;
}

/* Token without return */
%token PRINT PRINTLN 
%token IF ELSE FOR
%token VAR NEWLINE
%token INT VOID FLOAT 
%token ASSIGN
%token ADD SUB MUL DIV MOD INCRE DECRE
%token LARGER SMALLER EQ_LARGER EQ_SMALLER EQUAL NOT_EQUAL
%token LB RB LCB RCB

/* Token with return, which need to sepcify type */
%token <i_val> I_CONST INT
%token <f_val> F_CONST FLOAT
%token <string> ID STRING

/* Nonterminal with return, which need to sepcify type */
%type <f_val> stat declaration initializer
%type <f_val> type


/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : program stat
    |
;

stat
    : declaration
    | compound_stat
    | expression_stat
    | print_func
;

declaration
    : VAR ID type ASSIGN initializer NEWLINE {$$=$5;printf("VAR ID(%s) type '=' initializer(%f) NEWLINE\n",$2,$5);}
    | VAR ID type NEWLINE {printf("VAR ID type NEWLINE\n");}
;


initializer
    : I_CONST 
    | F_CONST {$$=$1;printf("%f\n",$1);}
    | STRING
;

print_func 
    : 
;

type
    : INT { $$ = $1;}
    | FLOAT { $$ = $1; }
;

%%

/* C code section */
int yyerror(char *s)
{
 fprintf(stderr, "%s\n", s);
 return 0;
}

int main(int argc, char** argv)
{
    yylineno = 0;

    yyparse();

    return 0;
}

void create_symbol() {}
void insert_symbol() {}
int lookup_symbol() {}
void dump_symbol() {}