/* Verificando a sintaxe de programas segundo nossa GLC-exemplo */
/* considerando notacao polonesa para expressoes */
%{
	#include <stdio.h> 
	#include <string>
	#include "louden/code.h"
	
	extern int yylex();
	extern int yydebug;
	extern FILE* yyin;
	extern FILE* yyout;

	/* TM location number for current instruction emission */
	static int emitLoc = 0 ;
	
	/* Highest TM location emitted so far
   	For use in conjunction with emitSkip,
   	emitBackup, and emitRestore */
	static int highEmitLoc = 0;

	std::string strinstr, strdesc;
	
	void yyerror(const char *str);

%}
%union {
	int numero;
}
%token <numero> NUMBER
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
write_stmt: 		T_WRITE exp 	{
						strinstr = "OUT", strdesc = "write ac";
						emitRO( (char*) strinstr.c_str() ,ac,0,0, (char*) strdesc.c_str() );
					}
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
					| NUMBER  		{ 
						strinstr = "LDC", strdesc = "load const";
						emitRM( (char*) strinstr.c_str(),ac,$1,0, (char*) strdesc.c_str() );
					}
					| IDENTIFIER	{;}
;
%%

void yyerror(const char *str) {
	printf("erro sintatico\n");
}

/* Procedure emitRO emits a register-only
 * TM instruction
 * op = the opcode
 * r = target register
 * s = 1st source register
 * t = 2nd source register
 * c = a comment to be printed if TraceCode is TRUE
 */
void emitRO(char* op, int r, int s, int t, char *c){
	fprintf(yyout,"%3d:  %5s  %d,%d,%d ",emitLoc++,op,r,s,t);
	//if (TraceCode) fprintf(code,"\t%s",c) ;
	fprintf(yyout,"\n") ;
	//if (highEmitLoc < emitLoc) highEmitLoc = emitLoc ;
} /* emitRO */

/* Procedure emitRM emits a register-to-memory
 * TM instruction
 * op = the opcode
 * r = target register
 * d = the offset
 * s = the base register
 * c = a comment to be printed if TraceCode is TRUE
 */
void emitRM(char* op, int r, int d, int s, char *c){ 
	fprintf(yyout,"%3d:  %5s  %d,%d(%d) ",emitLoc++,op,r,d,s);
	//if (TraceCode) fprintf(code,"\t%s",c) ;
	fprintf(yyout,"\n") ;
	//if (highEmitLoc < emitLoc)  highEmitLoc = emitLoc ;
} /* emitRM */

int main(int argc, char **argv){
	#if YYDEBUG
		yydebug = 1;
	#endif
	//	extern int yydebug;
	//	yydebug=1;

	++argv; --argc; 	    /* abre arquivo de entrada se houver */
	if(argc > 0)
		yyin = fopen(argv[0],"rt");
	else
		yyin = stdin;    /* cria arquivo de saida se especificado */
	if(argc > 1)
		yyout = fopen(argv[1],"wt");
	else
		yyout = stdout;

	//emitComment("Standard prelude:");
	strinstr = "LD", strdesc = "load maxaddress from location 0";
	emitRM((char*)strinstr.c_str(),mp,0,ac,(char*)strdesc.c_str());
	strinstr = "ST", strdesc = "clear location 0";
	emitRM((char*)strinstr.c_str(),ac,0,ac,(char*)strdesc.c_str());
	//emitComment("End of standard prelude.");

	yyparse ();

	//emitComment("End of execution.");
	strinstr = "HALT", strdesc = "";
	emitRO((char*)strinstr.c_str(),0,0,0,(char*)strdesc.c_str());

	fclose(yyin);
	fclose(yyout);
	return 0;
}




