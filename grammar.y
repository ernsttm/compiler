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

ClassDecl : ClassDecl CLASSnum IDnum ClassBody { $$ = MakeTree(ClassOp, $1, MakeTree(ClassDefOp, $4, MakeLeaf(IDNode, $3))); };
          | { $$ = MakeLeaf(DUMMYNode, 0); }

ClassBody : LBRACEnum MethodDecl RBRACEnum { $$ = $2; } 
          | { $$ = MakeLeaf(DUMMYNode, 0); }

Decl : DECLARATIONSnum ENDDECLARATIONSnum { $$ = MakeTree(BodyOp, MakeLeaf(DUMMYNode, 0), MakeLeaf(DUMMYNode, 0)); }
     | DECLARATIONSnum Decl ENDDECLARATIONSnum { $$ = $2; }
     | Decl FieldDecl { $$ = MakeTree(BodyOp, $1, $2); }
     | { $$ = MakeLeaf(DUMMYNode, 0); }

MethodDecl : MethodDecl METHODnum MethodHead Block { $$ = MakeTree(BodyOp, $1, MakeTree(MethodOp, $3, $4)); }
           | Decl { $$ = $1; }

MethodHead : Type IDnum LPARENnum ParamList RPARENnum { $$ = MakeTree(HeadOp, MakeLeaf(IDNode, $2), $4); }
           | Void IDnum LPARENnum ParamList RPARENnum { $$ = MakeTree(HeadOp, MakeLeaf(IDNode, $2), $4); }

ParamList : ParamType { $$ = MakeTree(SpecOp, $1, typeTree); }

ParamType : INTnum RefParam { $$ = $2; }
          | VALnum INTnum ValParam { $$ = $3; }
          | { $$ = MakeLeaf(DUMMYNode, 0); }

RefParam : IDnum COMMAnum RefParam { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), $3); }
         | IDnum SEMInum ParamType { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), $3); }
         | IDnum { $$ = MakeTree(RArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), MakeLeaf(DUMMYNode, 0)); }
          
ValParam : IDnum COMMAnum ValParam { $$ = MakeTree(VArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), $3); }
         | IDnum SEMInum ParamType { $$ = MakeTree(VArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), $3); }
         | IDnum { $$ = MakeTree(VArgTypeOp, MakeTree(CommaOp, MakeLeaf(IDNode, $1), MakeLeaf(INTEGERTNode, 0)), MakeLeaf(DUMMYNode, 0)); }

Block : Decl StatementList { $$ = MakeTree(BodyOp, $1, $2); }

StatementList : LBRACEnum RBRACEnum { $$ = MakeTree(StmtOp, MakeLeaf(DUMMYNode, 0), MakeLeaf(DUMMYNode, 0)); }
              | LBRACEnum StatementList RBRACEnum { $$ = $2; }
              | StatementList Statement SEMInum { $$ = MakeTree(StmtOp, $1, $2); }
              | { $$ = MakeLeaf(DUMMYNode, 0); }

Statement : AssignmentStatement { $$ = $1; }
          | MethodCallStatement { $$ = $1; }
          | ReturnStatement { $$ = $1; }
          | IfStatement { $$ = $1; } 
          | WhileStatement { $$ = $1; }

AssignmentStatement : Variable ASSGNnum Expression { $$ = MakeTree(AssignOp, MakeTree(AssignOp, MakeLeaf(DUMMYNode, 0), $1), $3); }

MethodCallStatement : Variable LPARENnum Argument RPARENnum { $$ = MakeTree(RoutineCallOp, $1, $3); }

Argument : Expression COMMAnum Argument { $$ = MakeTree(CommaOp, $1, $3); }
         | Expression { $$ = MakeTree(CommaOp, $1, MakeLeaf(DUMMYNode, 0)); }
         | { $$ = MakeLeaf(DUMMYNode, 0); }

ReturnStatement : RETURNnum Expression { $$ = MakeTree(ReturnOp, $2, MakeLeaf(DUMMYNode, 0)); }
                | RETURNnum { $$ = MakeTree(ReturnOp, MakeLeaf(DUMMYNode, 0), MakeLeaf(DUMMYNode, 0)); }

IfStatement : IFnum IfBody { $$ = MakeTree(IfElseOp, MakeLeaf(DUMMYNode, 0), $2); }
            | IfStatement ELSEnum IFnum IfBody { $$ = MakeTree(IfElseOp, $1, $4); }
            | IfStatement ELSEnum StatementList { $$ = MakeTree(IfElseOp, $1, $3); }

IfBody : Expression StatementList { $$ = MakeTree(CommaOp, $1, $2); }

WhileStatement : WHILEnum Expression StatementList { $$ = MakeTree(LoopOp, $2, $3); }

FieldDecl : Type VariableDecl SEMInum {  $$ = $2; }

Type : IDnum Index { typeTree = MakeTree(TypeIdOp, MakeLeaf(IDNode, $1), $2); }
     | INTnum Index {  typeTree = MakeTree(TypeIdOp, MakeLeaf(INTEGERTNode, 0), $2); }

Void : VOIDnum { typeTree = MakeLeaf(DUMMYNode, 0); }

Index : LBRACnum RBRACnum Index { $$ = MakeTree(IndexOp, MakeLeaf(DUMMYNode, 0), $3); }
      | { $$ = MakeLeaf(DUMMYNode, 0); }

VariableDecl : VariableDecl COMMAnum VariableDeclId EQUALnum VariableInitializer { $$ = MakeTree(DeclOp, $1, MakeTree(CommaOp, $3, MakeTree(CommaOp, typeTree, $5))); }
             | VariableDecl COMMAnum VariableDeclId { $$ = MakeTree(DeclOp, $1, MakeTree(CommaOp, $3, MakeTree(CommaOp, typeTree, MakeLeaf(DUMMYNode, 0)))); }
             | VariableDeclId EQUALnum VariableInitializer { $$ = MakeTree(DeclOp, MakeLeaf(DUMMYNode, 0), MakeTree(CommaOp, $1, MakeTree(CommaOp, typeTree, $3))); }
             | VariableDeclId { $$ = MakeTree(DeclOp, MakeLeaf(DUMMYNode, 0), MakeTree(CommaOp, $1, MakeTree(CommaOp, typeTree, MakeLeaf(DUMMYNode, 0)))); }

VariableDeclId : VariableDeclId LBRACnum RBRACnum { $$ = $1; }
               | IDnum { $$ = MakeLeaf(IDNode, $1); }

VariableInitializer : Expression { $$ = $1; }
                    | ArrayInitializer { $$ = $1; }
                    | ArrayCreationExpression { $$ = $1; }

ArrayInitializer : LBRACEnum ArrayVarInit RBRACEnum { $$ = MakeTree(ArrayTypeOp, $2, typeTree); }

ArrayVarInit : ArrayVarInit COMMAnum VariableInitializer { $$ = MakeTree(CommaOp, $1, $3); }
             | VariableInitializer { $$ = MakeTree(CommaOp, MakeLeaf(DUMMYNode, 0), $1); }

ArrayCreationExpression : INTnum ArrayCreationExpression { $$ = MakeTree(ArrayTypeOp, $2, MakeLeaf(INTEGERTNode, 0)); }
                        | ArrayCreationExpression LBRACnum Expression RBRACnum { $$ = MakeTree(BoundOp, $1, $3); }
                        | { $$ = MakeLeaf(DUMMYNode, 0); }

Expression : SimpleExpression GTnum SimpleExpression { $$ = MakeTree(GTOp, $1, $3); }
           | SimpleExpression GEnum SimpleExpression { $$ = MakeTree(GEOp, $1, $3); }
           | SimpleExpression EQnum SimpleExpression { $$ = MakeTree(EQOp, $1, $3); }
           | SimpleExpression LEnum SimpleExpression { $$ = MakeTree(LEOp, $1, $3); }
           | SimpleExpression LTnum SimpleExpression { $$ = MakeTree(LTOp, $1, $3); }
           | SimpleExpression { $$ = $1; }

SimpleExpression : PLUSnum Term { $$ = MakeTree(AddOp, $2, MakeLeaf(DUMMYNode, 0)); }
                 | MINUSnum Term { $$ = MakeTree(UnaryNegOp, $2, MakeLeaf(DUMMYNode, 0)); }
                 | SimpleExpression PLUSnum Term { $$ = MakeTree(AddOp, $1, $3); }
                 | SimpleExpression MINUSnum Term { $$ = MakeTree(SubOp, $1, $3); }
                 | SimpleExpression EQUALnum Term { $$ = MakeTree(EQOp, $1, $3); }
                 | Term { $$ = $1; }

Term : Term DIVIDEnum Factor { $$ = MakeTree(DivOp, $1, $3); }
     | Term TIMESnum Factor { $$ = MakeTree(MultOp, $1, $3); }
     | Term ANDnum Factor { $$ = MakeTree(AndOp, $1, $3); }
     | Factor { $$ = $1; }

Factor : UnsignedConstant { $$ = $1; }
       | Variable { $$ = $1; }
       | MethodCallStatement { $$ = $1; }
       | LPARENnum Expression RPARENnum { $$ = $2; }
       | NOTnum Factor { $$ = $2; }

UnsignedConstant : ICONSTnum { $$ = MakeLeaf(NUMNode, $1); }
                 | SCONSTnum { $$ = MakeLeaf(STRINGNode, $1); }

Variable : IDnum { $$ = MakeTree(VarOp, MakeLeaf(IDNode, $1), MakeLeaf(DUMMYNode, 0)); } 
         | IDnum Variable { $$ = MakeTree(VarOp, MakeLeaf(IDNode, $1), $2); }
         | LBRACnum ArrayIndexer RBRACnum { $$ = MakeTree(SelectOp, $2, MakeLeaf(DUMMYNode, 0)); }
         | LBRACnum ArrayIndexer RBRACnum Variable { $$ = MakeTree(SelectOp, $2, $4); }
         | DOTnum IDnum Variable { $$ = MakeTree(SelectOp, MakeTree(FieldOp, MakeLeaf(IDNode, $2), MakeLeaf(DUMMYNode, 0)), $3); }
         | DOTnum IDnum { $$ = MakeTree(SelectOp, MakeTree(FieldOp, MakeLeaf(IDNode, $2), MakeLeaf(DUMMYNode, 0)), MakeLeaf(DUMMYNode, 0));}


ArrayIndexer : Expression COMMAnum ArrayIndexer { $$ = MakeTree(IndexOp, $1, $3); }
             | Expression { $$ = MakeTree(IndexOp, $1, MakeLeaf(DUMMYNode, 0)); }

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