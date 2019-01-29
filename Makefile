build : lex
	gcc -std=c99 -o lexer lex.yy.c driver.c

lex :
	lex lexer.l

clean : 
	-rm lexer lex.yy.c
	-rm -r test_cases

test : clean build
	./test_phase_one.sh
