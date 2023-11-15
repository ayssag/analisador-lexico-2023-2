all:
	bison -d sintaxe.y
	flex lexico.l
	g++ lex.yy.c sintaxe.tab.c
