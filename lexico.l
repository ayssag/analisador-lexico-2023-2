%{
#include <stdio.h>
#include "sintaxe.tab.h"
%}
%x SC_COMMENT

IDENTIFIER	[a-zA-Z]+

NUMBER	[0-9]+

%%

"if"			{return T_IF;}
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
\n				{;}
[\t\r ]+		{;}	/* ignore whitespace */
{NUMBER}		{ return NUMBER;	}
{IDENTIFIER}	{ return IDENTIFIER;}

%%


int yywrap() {

 return 1;

}
