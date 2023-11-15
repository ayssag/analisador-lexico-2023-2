/* Verificando a sintaxe de programas segundo nossa GLC-exemplo */
/* considerando notacao polonesa para expressoes */
%{
	#include <stdio.h> 

	extern int yylex();
	extern FILE* yyin;
	//#define YYDEBUG 1
	
	void yyerror(const char *str);

%}
%token NUMBER
%token IDENTIFIER

%token T_IF 
%token T_THEN
%token T_ELSE
%token T_END
%token T_REPEAT
%token T_UNTIL
%token T_READ
%token T_WRITE
%token T_ASSIGN

%token T_SEMICOL
%token T_LT
%token T_EQ
%token T_PLUS
%token T_MINUS
%token T_MUL
%token T_DIV
%token T_LPAR
%token T_RPAR

%%
/* Regras definindo a GLC e acoes correspondentes */
/* neste nosso exemplo quase todas as acoes estao vazias */
program:			stmt_sequence	    		{printf ("Programa sintaticamente correto!\n");}
					|/* empty */				{printf ("sintaxe incorreta!\n");}
;
stmt_sequence:		stmt_sequence T_SEMICOL statement 	{;}
					|statement					{;}
;
statement:			if_stmt				{;}
					|repeat_stmt		{;}
					|assign_stmt		{;}
					|read_stmt			{;}
					|write_stmt			{;}
;
if_stmt:			T_IF exp T_THEN stmt_sequence T_END 						{;}
					|T_IF exp T_THEN stmt_sequence T_ELSE stmt_sequence T_END	{;}		
;
repeat_stmt: 		T_REPEAT stmt_sequence T_UNTIL exp {;}
; 
assign_stmt: 		IDENTIFIER T_ASSIGN exp 	{;}
;
read_stmt: 			T_READ IDENTIFIER 	{;}
;
write_stmt: 		T_WRITE exp 	{;}
;
exp: 				simple_exp comparison_op simple_exp 	{;}
					|simple_exp 							{;}
;
comparison_op: 		T_LT|T_EQ {;}
;
simple_exp:			simple_exp addop term 	{;}
					|term					{;}
;
addop:				T_PLUS|T_MINUS		{;}
;
term:				term mulop factor	{;} 
					|factor				{;}
;
mulop:				T_MUL|T_DIV				{;}
;
factor:				T_LPAR exp T_RPAR 		{;}
					| NUMBER  		{;}
					| IDENTIFIER	{;}
;
%%

void yyerror(const char *str) {
	printf("erro sintatico\n");
}

int main(){
	#if YYDEBUG
		yydebug = 1;
	#endif
	yyparse();
	return 0;
}




