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


	struct dataBlock {
		int index;
		char id[16];
		int type;
		value data;
		int noValue;    /* 1 = doesn't assign value */
		struct dataBlock *next;
	};

	struct dataBlock *head, *current, *tail;
	value temp; 		/* union contain value to insert into symbol table */
	int numIndex = 1; 	/* aka current index number */
	int countLine = 1;	/* input file should not be empty */
	
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
%token ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token ADD SUB MUL DIV MOD INCRE DECRE
%token LARGER SMALLER EQ_LARGER EQ_SMALLER EQUAL NOT_EQUAL
%token AND OR NOT
%token LB RB LCB RCB
%token C_PLUS COMMENT_START 
%token PRINT PRINTLN QUOTE
%token IF_START IF ELSEIF ELSE 
%token SEMICOLON

/* Token with return, which need to sepcify type */
%token <i_val> I_CONST INT FLOAT COMMENT_END IF_END
%token <f_val> F_CONST
%token <string> ID STRING C_PLUS C_COMMENT

/* Nonterminal with return, which need to sepcify type */
%type <f_val> stat declaration exp_stat initializer
%type <i_val> type 


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
| assign_stat
| relation_stat	
| print_func
| newline
| comment
| if_stat
| incre_decre
| for_stat
| logical_stat
;

declaration
:
VAR ID type ASSIGN exp_stat newline {
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

exp_stat
:
LB exp_stat RB    {printf("BRACKET\n");$$=$2;}
| exp_stat MUL exp_stat {printf("MUL\n");$$=$1*$3;}
| exp_stat DIV exp_stat {
	printf("DIV\n");
	if (!$3)
		printf("[ERROR]the divisor is 0 at line %d\n", countLine+1); /* hasn't matched newline yet */
	else
		$$=$1/$3;
}
| exp_stat MOD exp_stat { 
	printf("MOD\n");
	if (($1==(int)$1) && ($3==(int)$3))		$$=(int)$1%(int)$3;
	else 	printf("[ERROR] invalid operands (double) in MOD at Line %d\n", countLine+1); }
| exp_stat ADD exp_stat {printf("ADD\n");$$=$1+$3;}
| exp_stat SUB exp_stat {printf("SUB\n");$$=$1-$3;}
| ID { 
	if (!lookup_symbol($1))
		printf("[ERROR]undeclare variable at line %d\n", countLine+1); /* hasn't matched 'newline' yet */
	else 
		$$=(!current->type)? current->data.intData : current->data.floatData;
}
| initializer
|
;

relation_stat
: exp_stat LARGER exp_stat		{ printf("%s\n",($1>$3)?"true":"false"); }
| exp_stat SMALLER exp_stat		{ printf("%s\n",($1<$3)?"true":"false"); }
| exp_stat EQ_LARGER exp_stat	{ printf("%s\n",($1>=$3)?"true":"false"); }
| exp_stat EQ_SMALLER exp_stat	{ printf("%s\n",($1<=$3)?"true":"false"); }
| exp_stat EQUAL exp_stat		{ printf("%s\n",($1==$3)?"true":"false"); }
| exp_stat NOT_EQUAL exp_stat	{ printf("%s\n",($1!=$3)?"true":"false"); }
|
;

initializer
:
I_CONST   {$$=$1;}
| F_CONST   {$$=$1;}
| STRING    /* {$$=$1;} */
;

assign_stat
:
ID ASSIGN exp_stat newline { 
	printf("ASSIGN\n");
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
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);
}
| ID ADD_ASSIGN exp_stat newline { 
	printf("ADD_ASSIGN\n");
	if (lookup_symbol($1)) { 
		current->noValue=0;	/* contain value flag */
		switch (current->type)	{
		case 0: /* int */
			temp.intData += $3;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData += $3;
			insert_value(temp);
			break;
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);
}
| ID SUB_ASSIGN exp_stat newline { 
	printf("SUB_ASSIGN\n");
	if (lookup_symbol($1)) { 
		current->noValue=0;	/* contain value flag */
		switch (current->type)	{
		case 0: /* int */
			temp.intData -= $3;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData -= $3;
			insert_value(temp);
			break;
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);
}
| ID MUL_ASSIGN exp_stat newline { 
	printf("MUL_ASSIGN\n");
	if (lookup_symbol($1)) { 
		current->noValue=0;	/* contain value flag */
		switch (current->type)	{
		case 0: /* int */
			temp.intData *= $3;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData *= $3;
			insert_value(temp);
			break;
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);
}
| ID DIV_ASSIGN exp_stat newline { 
	printf("DIV_ASSIGN\n");
	if (lookup_symbol($1)) { 
		current->noValue=0;	/* contain value flag */
		switch (current->type)	{
		case 0: /* int */
			temp.intData /= $3;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData /= $3;
			insert_value(temp);
			break;
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);
}
| ID MOD_ASSIGN exp_stat newline { 
	printf("MOD_ASSIGN\n");
	if (lookup_symbol($1)) { 
		current->noValue=0;	/* contain value flag */
		switch (current->type)	{
		case 0: /* int */
			if ($3==(int)$3) {	/* $3 is int */
				temp.intData %= (int)$3;
				insert_value(temp);
			}
			else
				printf("[ERROR] invalid operands (double) in MOD at Line %d\n", countLine+1);
			break;
		case 1: /* float */
			printf("[ERROR] invalid operands (double) in MOD at Line %d\n", countLine+1);
			break;
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);
}
;

print_func
: PRINT LB exp_stat RB newline					{if ($3==(int)$3) printf("print : %d\t",(int)$3); 
												 else	printf("print : %f\t",$3);}
| PRINT LB QUOTE STRING QUOTE RB newline		{printf("print : %s\t",$4);}
| PRINTLN LB exp_stat RB newline				{if ($3==(int)$3) printf("println : %d\n",(int)$3); 
												 else	printf("println : %f\n",$3);}
| PRINTLN LB QUOTE STRING QUOTE RB newline		{printf("println : %s\n",$4);}
;

type
:
INT { $$ = $1;}
| FLOAT { $$ = $1; }
;

newline
:
NL { countLine++; }
|
;

comment
:
C_PLUS newline { printf("C++ comment : \t%s\n",$1);}
|COMMENT_START  { printf("C type comment : \n/*");}
|comment C_COMMENT { printf("%s",$2);}													
|COMMENT_END newline { printf("*/\n"); countLine+=$1-1; }
|
;

if_stat		/* RE : IF (elseif)* [else] */
:
IF_START 	{printf("if\n");}
| IF		{printf("if\n");}
| ELSEIF	{printf("else if\n");}
| ELSE 		{printf("else\n");}
| IF_END	{ countLine+=$1;}
;

incre_decre
:
ID INCRE		{
	printf("INCRE\n");
	if (lookup_symbol($1)) { 
		switch (current->type)	{
		case 0: /* int */
			temp.intData++;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData++;
			insert_value(temp);
			break;
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);}
| ID DECRE		{
	printf("DECRE\n");
	if (lookup_symbol($1)) { 
		switch (current->type)	{
		case 0: /* int */
			temp.intData--;
			insert_value(temp);
			break;
		case 1: /* float */
			temp.floatData--;
			insert_value(temp);
			break;
		}
	}
	else	
		printf("[ERROR]undeclare variable at line %d\n", countLine);}
;

for_stat
: FOR LB stat SEMICOLON relation_stat SEMICOLON stat RB LCB program RCB	{ printf("for\n"); }
;

logical_stat
: 
relation_stat AND relation_stat 	{ printf("logical and\n"); }
| relation_stat OR relation_stat	{ printf("logical or\n"); }
| NOT relation_stat					{ printf("logical not\n"); }
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
	create_symbol();
	yyparse();
	printf("\ntotal line : %d\n", countLine);
	dump_symbol();

	return 0;
}

/* Implete symbol table */
enum dataType { numInt, numFloat32, numString };

void create_symbol()
{
	printf("Create symbol table\n");
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