%{
#include <stdio.h>
#include "sintaxe.tab.h"
%}


IDENTIFIER	[a-zA-Z][a-zA-Z0-9]*

NUMBER	[0-9]+

%%

"if"			{ return T_IF;      }
"then"			{ return T_THEN; 	}
"else"			{ return T_ELSE; 	}
"end"			{ return T_END; 	}
"repeat"		{ return T_REPEAT; 	}
"until"			{ return T_UNTIL; 	}
"read"			{ return T_READ; 	}
"write"			{ return T_WRITE; 	}

"+"				{ return T_PLUS;	}
"-"				{ return T_MINUS;	}
"*"				{ return T_MUL;		}
"/"				{ return T_DIV;		}
"<"				{ return T_LT;		}
"="				{ return T_EQ;		}
"("				{ return T_LPAR;	}
")"				{ return T_RPAR;	}
";"				{ return T_SEMICOL;	}
":=" 			{ return T_ASSIGN; 	}
[\n\t\r ]+		{;}	/* ignore whitespace */

{NUMBER}		{   
                    yylval.numero = atoi(yytext);
                    return NUMBER;	
                }
{IDENTIFIER}	{ 
                    yylval.cadeia= (char *) strdup(yytext);
                    return IDENTIFIER;
                }

.		        {return yytext[0];}

%%


int yywrap() {

 return 1;

}
