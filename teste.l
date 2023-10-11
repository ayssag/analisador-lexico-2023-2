%{

#include <stdio.h>

%}

id	[a-zA-Z][a-zA-Z0-9]*\n

numero	[0-9]*\n

constante [+\-]?[0-9][0-9]*[.]?[0-9]*\n

outro	.*\n

%%

{id}		{printf("Identificador\n");}

{constante}		{printf("Constante\n");}

{outro}		{printf(":-(\n");}

%%

/* recomendavel declarar sempre

   funcao yywrap() */

int yywrap ();


/* programa principal */

main() {

  yylex(); /* scanner gerado por Flex */

}


int yywrap() {

 return 1;

}
