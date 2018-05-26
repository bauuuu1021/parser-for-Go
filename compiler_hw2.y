/*	Definition section */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
	extern int yylineno;
	extern int yylex();

	/* Symbol table function - you can add new function if need. */
	int lookup_symbol();
	void create_symbol();
	void insert_symbol();
	void insert_value();
	void dump_symbol();

	typedef union {
		int intData;
		float floatData;
		char *stringData;
	} value;

	struct dataBlock *head, *current, *tail;
	value temp; /* union contain value to insert into symbol table */
	int numIndex = 1; /* aka current index number */
	int countLine = 0;
	
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
%token VAR NL
%token INT VOID FLOAT
%token ASSIGN
%token ADD SUB MUL DIV MOD INCRE DECRE
%token LARGER SMALLER EQ_LARGER EQ_SMALLER EQUAL NOT_EQUAL
%token LB RB LCB RCB

/* Token with return, which need to sepcify type */
%token <i_val> I_CONST INT FLOAT
%token <f_val> F_CONST
%token <string> ID STRING

/* Nonterminal with return, which need to sepcify type */
%type <f_val> stat declaration exp_stat initializer
%type <i_val> type decl_check


/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
:
program stat
|
;

stat
:
declaration
| compound_stat /* { } */
| assign_stat
| print_func
| newline
;

declaration
:
VAR ID type ASSIGN initializer newline {
	if (lookup_symbol($2))      /* redeclare */
	{
		printf("[ERROR]redeclare variable at line %d\n", countLine);
	} else { /* doesn't redeclare */
		printf("insert symbol %s\n", $2);
		insert_symbol($2,$3);
		lookup_symbol($2);
		switch ($3)
		{
		case 0: /* int */
			temp.intData = $5;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData = $5;
			insert_value(temp);
			break;
			/* todo string
			case 2: /* string *\/
			    temp.stringData = $5;
			    insert_value(temp);
			    break;
			*** todo string ***/
		}
		tail->noValue = 0;	/* contain value flag */
		numIndex++;
	}
}
| VAR ID type newline {
	if (lookup_symbol($2))      /* redeclare */
	{
		printf("[ERROR]redeclare variable at line %d\n", countLine);
	} else { /* doesn't redeclare */
		printf("insert symbol %s\n", $2);
		insert_symbol($2,$3);
		tail->noValue = 1;	/* without value flag */
		numIndex++;
	}
}
;


initializer
:
I_CONST   {$$=$1;}
| F_CONST   {$$=$1;}
| STRING    /* {$$=$1;} */
;

exp_stat
:
LB exp_stat RB    {$$=$2;}
| exp_stat MUL exp_stat {$$=$1*$3;}
| exp_stat DIV exp_stat {
	if (!$3)
		printf("[ERROR]the divisor is 0 at line %d\n", countLine+1); /* hasn't matched newline yet */
	else
		$$=$1/$3;
}
//| exp_stat MOD exp_stat { $$=$1%$3;}
| exp_stat ADD exp_stat {$$=$1+$3;}
| exp_stat SUB exp_stat {$$=$1-$3;}
| ID { if (!lookup_symbol($1))
		printf("[ERROR]undeclare variable at line %d\n", countLine+1); /* hasn't matched newline yet */
	else $$=current->data.intData;
}
| initializer

assign_stat
:
ID ASSIGN exp_stat newline { 
	if (lookup_symbol($1)) { 
		current->noValue=0;	/* contain value flag */
		switch (current->type)	{
		case 0: /* int */
			temp.intData = $3;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData = $3;
			insert_value(temp);
			break;
			/* todo string
			case 2: /* string *\/
			    temp.stringData = $3;
			    insert_value(temp);
			    break;
			*** todo string ***/
		}
	}
}
;

print_func
:
;

type
:
INT { $$ = $1;}
| FLOAT { $$ = $1; }
;

newline
:
NL { countLine++; }
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

/* Implete symbol table */
enum dataType { numInt, numFloat32, numString };

/**** comment out to avoid conflict ****
typedef union {
        int intData;
        float floatData;
        char *stringData;
} value;
**** comment out to avoid conflict ****/

struct dataBlock {
	int index;
	char id[16];
	int type;
	value data;
	int noValue;    /* 1 = doesn't assign value */
	struct dataBlock *next;
};


void create_symbol()
{
	head = NULL;
	tail = head;
}
void insert_symbol(char *id, int type)
{
	current = (struct dataBlock*)malloc(sizeof(struct dataBlock));
	if (!current)
		perror("[insert_symbol]malloc failed\n");

	if (tail)
		tail->next = current;
	else
		head = current;
	tail = current;
	current->index = numIndex;
	strcpy(current->id,id);
	current->type = type;
}

void insert_value(value dataUnion)
{
	if (!current)
		return;

	current->data = dataUnion;
	dump_symbol();
}

int lookup_symbol(char *id)
{
	for (current=head; current; current=current->next)
		if (!strcmp(current->id,id))
			return 1;   /* id is found */
	return 0;   /* id not found */
}

void dump_symbol()
{
	printf("index\tID\ttype\tdata\n");

	for (current=head; current; current=current->next) {
		printf("%d\t%s\t",current->index, current->id);
		switch (current->type) {
		case numInt:
			if (!current->noValue) printf("int\t%d\n", current->data.intData);
			else printf("int\t\t\n");
			break;
		case numFloat32:
			if (!current->noValue) printf("float32\t%f\n",current->data.floatData);
			else printf("float32\t\t\n");
			break;
		case numString:
			printf("string\t%s\n",current->data.stringData);
			break;
		}
	}
}