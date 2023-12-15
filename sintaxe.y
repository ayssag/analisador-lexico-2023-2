/* Verificando a sintaxe de programas segundo nossa GLC-exemplo */
/* considerando notacao polonesa para expressoes */
%{
	#include <stdio.h> 
	#include <string>
	#include <cstring>
	#include "louden/code.h"
	
	#define YYDEBUG 1

	extern int yylex();
	extern int yydebug;
	extern FILE* yyin;
	extern FILE* yyout;

	int savedLoc1;
	int savedLoc2;
	int currentLoc;
	int tmp_offset = 0;

	//begin semantico
		struct regTabSimb {
			char *nome; /* nome do simbolo */
			char *tipo; /* tipo_int ou tipo_cad ou nsa */
			char *natureza; /* variavel ou procedimento */
			char *usado; /* sim ou nao */
			int locMem;
			struct regTabSimb *prox; /* ponteiro */
		};
		typedef struct regTabSimb regTabSimb;
		regTabSimb *tabSimb = (regTabSimb *)0;
		regTabSimb *colocaSimb();
		int erroSemantico;

		static int proxLocMemVar = 0;
	//end semantico


	//begin gerador de codigo	
		int locMemId = 0; /* para recuperacao na TS */

		/* TM location number for current instruction emission */
		static int emitLoc = 0 ;
		
		/* Highest TM location emitted so far
		For use in conjunction with emitSkip,
		emitBackup, and emitRestore */
		static int highEmitLoc = 0;

		std::string strinstr, strdesc;
		char strtypeint[] = "tipo_int", strvar[] = "variavel", strbool[] = "nao";
	//end gerador de codigo


	void yyerror(const char *str);
	int recuperaLocMemId(char *nomeSimb);
	int constaTabSimb(char *nomeSimb);
	regTabSimb *colocaSimb(char *nomeSimb, char *tipoSimb, char *naturezaSimb, char *usadoSimb,int loc);
%}
%union {
	int numero;
	char* cadeia; 
}
%token <numero> NUMBER
%token <cadeia> IDENTIFIER

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
program:			stmt_sequence	{
						printf("\nSintaxe ok.\n");
						if (erroSemantico) 
							printf("\nErro semantico: esqueceu de declarar alguma variavel que usou...\n");
						else 
							printf("\nSemantica ok: se variaveis usadas, elas foram declaradas ok.\n");
		
					}
					|/* empty */	{
						printf ("Sintaxe incorreta!\n");	
					}
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
if_stmt:			T_IF exp T_THEN {
						// savedLoc2 = emitSkip(1) ;
         				// currentLoc = emitSkip(0) ;
         				// emitBackup(savedLoc1) ;
         				// emitRM_Abs("JEQ",ac,currentLoc,"if: jmp to else");
         				// emitRestore() ;
					}
					stmt_sequence T_END {;}

					|T_IF exp T_THEN {

					} 
					stmt_sequence T_ELSE {

					}
					stmt_sequence T_END	{;}		
;
repeat_stmt: 		T_REPEAT {
						savedLoc1 = emitSkip(0);
					}
					stmt_sequence{;} 
					T_UNTIL exp {

						strinstr = "JEQ", strdesc = "repeat: retorna à origem";
						emitRM_Abs((char*) strinstr.c_str(),ac,savedLoc1,(char*) strdesc.c_str());
					}
; 
assign_stmt: 		IDENTIFIER T_ASSIGN exp 	 {
						if(!constaTabSimb($1)){
							colocaSimb($1,strtypeint,strvar,strbool,proxLocMemVar++);
						}
						locMemId = recuperaLocMemId($1);
						strinstr = "ST", strdesc = "atribuicao: armazena valor";
						emitRM((char*) strinstr.c_str(),ac,locMemId,gp,(char*) strdesc.c_str());
					}
;
read_stmt: 			T_READ IDENTIFIER 	{
						if(!constaTabSimb($2)){
							colocaSimb($2,strtypeint,strvar,strbool,proxLocMemVar++);
						}
						locMemId = recuperaLocMemId($2);
						strinstr = "ST", strdesc = "atribuicao: armazena valor";
						emitRM((char*) strinstr.c_str(),ac,locMemId,gp,(char*) strdesc.c_str());
					}
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
simple_exp:			simple_exp {
						strinstr = "ST", strdesc = "dando store da esquerda";
    					emitRM((char*) strinstr.c_str(), ac, tmp_offset--, mp, (char*) strdesc.c_str());
  					}
					addop term				{;}
					|term					{;}
;
addop:				T_PLUS{
						strinstr = "LD", strdesc = "dando load da esquerda";
						emitRM((char*) strinstr.c_str(), ac1, ++tmp_offset, mp, (char*) strdesc.c_str());
						strinstr = "ADD", strdesc = "operacao +";
						emitRO((char*) strinstr.c_str(), ac, ac1, ac, (char*) strdesc.c_str());
					}
					|T_MINUS{
						strinstr = "LD", strdesc = "dando load da esquerda";
						emitRM((char*) strinstr.c_str(), ac1, ++tmp_offset, mp, (char*) strdesc.c_str());
						strinstr = "SUB", strdesc = "operacao -";
						emitRO((char*) strinstr.c_str(), ac, ac1, ac, (char*) strdesc.c_str());
					}
;
term:				term{
						strinstr = "ST", strdesc = "dando store da esquerda";
    					emitRM((char*) strinstr.c_str(), ac, tmp_offset--, mp, (char*) strdesc.c_str());
					}
					mulop factor	{;} 
					|factor				{;}
;
mulop:				T_MUL{
						strinstr = "LD", strdesc = "dando load da esquerda";
						emitRM((char*) strinstr.c_str(), ac1, ++tmp_offset, mp, (char*) strdesc.c_str());
						strinstr = "MUL", strdesc = "operacao *";
						emitRO((char*) strinstr.c_str(), ac, ac1, ac, (char*) strdesc.c_str());
					}
  					|T_DIV{
						strinstr = "LD", strdesc = "dando load da esquerda";
						emitRM((char*) strinstr.c_str(), ac1, ++tmp_offset, mp, (char*) strdesc.c_str());
						strinstr = "DIV", strdesc = "operacao +";
						emitRO((char*) strinstr.c_str(), ac, ac1, ac, (char*) strdesc.c_str());
					}
;
factor:				T_LPAR exp T_RPAR 		{;}
					| NUMBER  		{ 
						strinstr = "LDC", strdesc = "load const";
						emitRM( (char*) strinstr.c_str(),ac,$1,0, (char*) strdesc.c_str() );
					}
					| IDENTIFIER	{
						printf("banana");
						if(!constaTabSimb($1)){
							erroSemantico = 1 ;		
						}
						else{
							locMemId = recuperaLocMemId($1);
							strinstr = "LD", strdesc = "carrega valor de id em ac";
							emitRM((char*) strinstr.c_str(), ac, locMemId, gp, (char*) strdesc.c_str());
						}
					}
;
%%

// begin semantico
	regTabSimb *colocaSimb(char *nomeSimb, char *tipoSimb, char *naturezaSimb, char *usadoSimb,int loc){
		regTabSimb *ptr;
		ptr = (regTabSimb *) malloc (sizeof(regTabSimb));

		ptr->nome= (char *) malloc(strlen(nomeSimb)+1);
		ptr->tipo= (char *) malloc(strlen(tipoSimb)+1);
		ptr->natureza= (char *) malloc(strlen(naturezaSimb)+1);
		ptr->usado= (char *) malloc(strlen(usadoSimb)+1);

		std::strcpy (ptr->nome,nomeSimb);
		std::strcpy (ptr->tipo,tipoSimb);
		std::strcpy (ptr->natureza,naturezaSimb);
		std::strcpy (ptr->usado,usadoSimb);
		ptr->locMem= loc;

		ptr->prox= (struct regTabSimb *)tabSimb;
		tabSimb= ptr;
		return ptr;
	}

	int constaTabSimb(char *nomeSimb) {
		regTabSimb *ptr;
		for (ptr=tabSimb; ptr!=(regTabSimb *)0; ptr=(regTabSimb *)ptr->prox)
		if (strcmp(ptr->nome,nomeSimb)==0) return 1;
		return 0;
	}
// end semantico 

//begin gerador de codigo
	void emitRO(char* op, int r, int s, int t, char *c){
		/* Procedure emitRO emits a register-only
		* TM instruction
		* op = the opcode
		* r = target register
		* s = 1st source register
		* t = 2nd source register
		* c = a comment to be printed if TraceCode is TRUE
		*/
		fprintf(yyout,"%3d:  %5s  %d,%d,%d ",emitLoc++,op,r,s,t);
		//if (TraceCode) fprintf(code,"\t%s",c) ;
		fprintf(yyout,"\n") ;
		//if (highEmitLoc < emitLoc) highEmitLoc = emitLoc ;
	} /* emitRO */

	void emitRM(char* op, int r, int d, int s, char *c){ 
		/* Procedure emitRM emits a register-to-memory
		* TM instruction
		* op = the opcode
		* r = target register
		* d = the offset
		* s = the base register
		* c = a comment to be printed if TraceCode is TRUE
		*/
		fprintf(yyout,"%3d:  %5s  %d,%d(%d) ",emitLoc++,op,r,d,s);
		//if (TraceCode) fprintf(code,"\t%s",c) ;
		fprintf(yyout,"\n") ;
		//if (highEmitLoc < emitLoc)  highEmitLoc = emitLoc ;
	}

	int emitSkip(int howMany){
		int i = emitLoc;
		emitLoc += howMany ;
		//if (highEmitLoc < emitLoc)  highEmitLoc = emitLoc ;
		return i;
	}

	void emitRM_Abs( char *op, int r, int a, char * c){ 
		fprintf(yyout,"%3d:  %5s  %d,%d(%d) ", emitLoc,op,r,a-(emitLoc+1),pc);
		++emitLoc ;
		fprintf(yyout,"\n") ;
		//if (highEmitLoc < emitLoc) highEmitLoc = emitLoc ;
	}

	int recuperaLocMemId(char *nomeSimb) {
		// recupera locacao de memoria de um id cujo nome eh passado em parametro
		regTabSimb *ptr;
		for (ptr=tabSimb; ptr!=(regTabSimb *)0; ptr=(regTabSimb *)ptr->prox)
		if (strcmp(ptr->nome,nomeSimb)==0) return ptr->locMem;
		return -1;
	}
//end gerador de codigo



void yyerror(const char *str) {
	printf("erro sintatico\n");
}

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




