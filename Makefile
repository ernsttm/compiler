driver : lex
	gcc -o lexer lex.yy.c driver.c

lex :
	lex lexer.l

clean : 
	rm lex_driver lex.yy.c