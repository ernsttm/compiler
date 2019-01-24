build : lex
	gcc -std=c99 -o lexer lex.yy.c driver.c

lex :
	lex lexer.l

clean : 
	rm lexer lex.yy.c

test : clean build
	./test_phase_one.sh
