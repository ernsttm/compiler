build : lex grammar
	gcc -std=c99 -gdwarf-5 -g -o parser y.tab.c proj2.c

proj1_build : lex
	gcc -std=c99 -o lexer lex.yy.c driver.c

lex :
	lex lexer.l

grammar : 
	yacc grammar.y

clean : 
	-rm lexer lex.yy.c y.tab.c
	-rm -r test_cases

test_phase_one : clean proj1_build
	./test_phase_one.sh

test : clean build
	./test_phase_two.sh