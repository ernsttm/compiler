/**
 * Todd M. Ernst 2019
 */
%{
  #include <stdbool.h>
  #include <stdio.h>
  #include <string.h>
  #include "proj2.h"

  // Defined limits on the string table 
  #define DISTINCT_IDS 500
  #define STRING_TABLE_SIZE 4096

  // Declare later functions to avoid compiler warnings
  int yylex();
  int yywrap();
  void yyerror();
  int fileno(FILE* file);
  void printtree(tree file, int start);

  // Define yyline/yycolumn global to ease driver implementation
  extern int yyline;
  extern int yycolumn;
  extern int table_index;
  extern char string_table[STRING_TABLE_SIZE];

  int argType;
  tree typeTree;
%}

%token <intg> ANDnum ASSGNnum DECLARATIONSnum DOTnum ENDDECLARATIONSnum EQUALnum GTnum IDnum INTnum LBRACnum LPARENnum METHODnum NEnum ORnum PROGRAMnum RBRACnum RPARENnum SEMInum VALnum WHILEnum CLASSnum COMMAnum DIVIDEnum ELSEnum EQnum GEnum ICONSTnum IFnum LBRACEnum LEnum LTnum MINUSnum NOTnum PLUSnum RBRACEnum RETURNnum SCONSTnum TIMESnum VOIDnum EOFnum 0
%type <tptr> Program ClassDecl ClassBody Decl MethodDecl FieldDecl Type Index VariableDeclId VariableInitializer VariableDecl Expression SimpleExpression Term Factor UnsignedConstant MethodHead ParamList Void RefParam ValParam ParamType Block StatementList Statement AssignmentStatement MethodCallStatement ReturnStatement IfStatement WhileStatement Variable ArrayIndexer Argument IfBody ArrayInitializer ArrayVarInit ArrayCreationExpression

%%

Program : PROGRAMnum IDnum SEMInum ClassDecl EOFnum { 
  $$ = MakeTree(ProgramOp, $4, MakeLeaf(IDNode, $2));
  printtree($$, 0);
}

ClassDecl : ClassDecl CLASSnum IDnum ClassBody {};
          | { }

ClassBody : LBRACEnum MethodDecl RBRACEnum {} 
          | { }

Decl : DECLARATIONSnum ENDDECLARATIONSnum { }
     | DECLARATIONSnum Decl ENDDECLARATIONSnum { }
     | Decl FieldDecl { }
     | { }

MethodDecl : MethodDecl METHODnum MethodHead Block { }
           | Decl { }

MethodHead : Type IDnum LPARENnum ParamList RPARENnum { }
           | Void IDnum LPARENnum ParamList RPARENnum { }

ParamList : ParamType { }

ParamType : INTnum RefParam { }
          | VALnum INTnum ValParam { }
          | { }

RefParam : IDnum COMMAnum RefParam { }
         | IDnum SEMInum ParamType { }
         | IDnum { }
          
ValParam : IDnum COMMAnum ValParam { }
         | IDnum SEMInum ParamType { }
         | IDnum { }

Block : Decl StatementList { }

StatementList : LBRACEnum RBRACEnum { }
              | LBRACEnum StatementList RBRACEnum { }
              | StatementList Statement SEMInum { }
              | Statement SEMInum { }

Statement : AssignmentStatement { }
          | MethodCallStatement { }
          | ReturnStatement { }
          | IfStatement {} 
          | WhileStatement { }
          | { }

AssignmentStatement : Variable ASSGNnum Expression { }

MethodCallStatement : Variable LPARENnum Argument RPARENnum { }

Argument : Expression COMMAnum Argument { }
         | Expression { }
         | { }

ReturnStatement : RETURNnum Expression { }
                | RETURNnum { }

IfStatement : IFnum IfBody { }
            | IfStatement ELSEnum IFnum IfBody { }
            | IfStatement ELSEnum StatementList { }

IfBody : Expression StatementList { }

WhileStatement : WHILEnum Expression StatementList { }

FieldDecl : Type VariableDecl SEMInum { }

Type : IDnum Index { }
     | INTnum Index { }

Void : VOIDnum { }

Index : LBRACnum RBRACnum Index { }
      | LBRACnum RBRACnum { }

VariableDecl : VariableDecl COMMAnum VariableDeclId EQUALnum VariableInitializer { }
             | VariableDecl COMMAnum VariableDeclId { }
             | VariableDeclId EQUALnum VariableInitializer { }
             | VariableDeclId { }

VariableDeclId : VariableDeclId LBRACnum RBRACnum { }
               | IDnum { }

VariableInitializer : Expression { }
                    | ArrayInitializer { }
                    | INTnum ArrayCreationExpression { }

ArrayInitializer : LBRACEnum ArrayVarInit RBRACEnum { }

ArrayVarInit : ArrayVarInit COMMAnum VariableInitializer { }
             | VariableInitializer { }

ArrayCreationExpression : ArrayCreationExpression LBRACnum Expression RBRACnum { }
                        | LBRACnum Expression RBRACnum { }

Expression : SimpleExpression GTnum SimpleExpression { }
           | SimpleExpression GEnum SimpleExpression { }
           | SimpleExpression EQnum SimpleExpression { }
           | SimpleExpression LEnum SimpleExpression { }
           | SimpleExpression LTnum SimpleExpression { }
           | SimpleExpression { }

SimpleExpression : PLUSnum Term { }
                 | MINUSnum Term { }
                 | SimpleExpression PLUSnum Term { }
                 | SimpleExpression MINUSnum Term { }
                 | SimpleExpression EQUALnum Term { }
                 | Term { }

Term : Term DIVIDEnum Factor { }
     | Term TIMESnum Factor { }
     | Term ANDnum Factor { }
     | Factor { }

Factor : UnsignedConstant { }
       | Variable { }
       | MethodCallStatement { }
       | LPARENnum Expression RPARENnum { }
       | NOTnum Factor { }

UnsignedConstant : ICONSTnum { }
                 | SCONSTnum { }

Variable : IDnum {} 
         | IDnum Variable { }
         | LBRACnum ArrayIndexer RBRACnum { }
         | LBRACnum ArrayIndexer RBRACnum Variable { }
         | DOTnum IDnum Variable { }
         | DOTnum IDnum {;}


ArrayIndexer : Expression COMMAnum ArrayIndexer { }
             | Expression { }

%%
FILE* treelst;


char string_table[STRING_TABLE_SIZE];

void print_string_table() {
  for (int i = 0; i < table_index; i++) {
    printf("%s ", &(string_table[i]));
    i += strlen(&string_table[i]);
  }

  printf("\n");
}

int main() {
  treelst = stdout;
  yyparse();
  print_string_table();
}

void yyerror(char* str) {
  printf("%s at line %d, column %d\n", str, yyline, yycolumn);
}

int yywrap() {
  return 1;
}

#include "lex.yy.c"