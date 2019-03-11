/**
 * Todd M. Ernst 2019
 */
%{
  #include <stdbool.h>
  #include <stdio.h>
  #include <string.h>
  #include "proj2.h"
  #include "proj3.h"

  // Defined limits on the string table 
  #define DISTINCT_IDS 500
  #define STRING_TABLE_SIZE 4096

  // Declare later functions to avoid compiler warnings
  int yylex();
  int yywrap();
  int loc_str(char* str);
  void yyerror();
  int fileno(FILE* file);
  void printtree(tree file, int start);
  void process_tree(tree root);

  // Define yyline/yycolumn global to ease driver implementation
  extern int yyline;
  extern int yycolumn;
  extern int table_index;
  extern char string_table[STRING_TABLE_SIZE];

  int main_count;
  int argType;
  tree root;
  tree typeTree;
%}

%token <intg> ANDnum ASSGNnum DECLARATIONSnum DOTnum ENDDECLARATIONSnum EQUALnum GTnum IDnum INTnum LBRACnum LPARENnum METHODnum NEnum ORnum PROGRAMnum RBRACnum RPARENnum SEMInum VALnum WHILEnum CLASSnum COMMAnum DIVIDEnum ELSEnum EQnum GEnum ICONSTnum IFnum LBRACEnum LEnum LTnum MINUSnum NOTnum PLUSnum RBRACEnum RETURNnum SCONSTnum TIMESnum VOIDnum EOFnum 0
%type <tptr> Program ClassDecl ClassBody Decl MethodDecl FieldDecl Type Index VariableDeclId VariableInitializer VariableDecl Expression SimpleExpression Term Factor UnsignedConstant MethodHead ParamList Void RefParam ValParam ParamType Block StatementList Statement AssignmentStatement MethodCallStatement ReturnStatement IfStatement WhileStatement Variable ArrayIndexer Argument IfBody ArrayInitializer ArrayVarInit ArrayCreationExpression

%%

Program : PROGRAMnum IDnum SEMInum ClassDecl EOFnum { 
  root = MakeTree(ProgramOp, $4, MakeLeaf(DUMMYNode, 0));
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
                    | INTnum ArrayCreationExpression { $$ = MakeTree(ArrayTypeOp, $2, MakeLeaf(INTEGERTNode, 0)); }

ArrayInitializer : LBRACEnum ArrayVarInit RBRACEnum { $$ = MakeTree(ArrayTypeOp, $2, typeTree); }

ArrayVarInit : ArrayVarInit COMMAnum VariableInitializer { $$ = MakeTree(CommaOp, $1, $3); }
             | VariableInitializer { $$ = MakeTree(CommaOp, MakeLeaf(DUMMYNode, 0), $1); }

ArrayCreationExpression : ArrayCreationExpression LBRACnum Expression RBRACnum { $$ = MakeTree(BoundOp, $1, $3); }
                        | LBRACnum Expression RBRACnum { $$ = MakeTree(BoundOp, MakeLeaf(DUMMYNode, 0), $2); }

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

int get_arg_count(tree node) {
  int count = 0;
  if (RArgTypeOp == node->NodeOpType || VArgTypeOp == node->NodeOpType) {
    count++;
  }

  if (NULL != node->LeftC) {
    count += get_arg_count(node->LeftC);
  }
  if (NULL != node->RightC) {
    count += get_arg_count(node->RightC);
  }

  return count;
}

int get_index_count(tree node) {
  int count = 0;

  tree index_node = node;
  while (IndexOp == index_node->NodeOpType) {
    count++;
    index_node = index_node->RightC;
  }

  return count;
}

int get_var_index_count(tree node) {
  int count = 0;

  tree select_node = node;
  while (SelectOp == select_node->NodeOpType) {
    if (IndexOp == select_node->LeftC->NodeOpType) {
      count++;
    }

    select_node = select_node->RightC;
  }

  return count;
}

int get_call_arg_count(tree node) {
  int count = 0;

  tree arg_node = node;
  while (CommaOp == arg_node->NodeOpType) {
    count++;
    arg_node = arg_node->RightC;
  }

  return count;
}

void handle_select(int id, tree node) {
  if (SelectOp == node->NodeOpType) {
    int field_id = 0;
    if (FieldOp == node->LeftC->NodeOpType) {
      tree field_id_node = node->LeftC->LeftC;

      if (CLASS == GetAttr(id, KIND_ATTR)) {
        field_id = LookUpField(id, field_id_node->IntVal);

        if (0 != field_id) {
          field_id_node->NodeKind = STNode;
          field_id_node->IntVal = field_id;
        }
      } else if (VAR == GetAttr(id, KIND_ATTR)) {
        tree type = GetAttr(id, TYPE_ATTR);
        int type_id = type->LeftC->IntVal;
        field_id = LookUpField(type_id, field_id_node->IntVal);

        if (0 != field_id) {
          field_id_node->NodeKind = STNode;
          field_id_node->IntVal = field_id;
        }
      }
    }

    handle_select(field_id, node->RightC);
  }
}

int find_arg_count(tree node) {
  int kind = GetAttr(node->LeftC->IntVal, KIND_ATTR);
  if (FUNC == kind || PROCE == kind) {
    return GetAttr(node->LeftC->IntVal, ARGNUM_ATTR);
  }

  tree select_node = node->RightC;
  while (SelectOp == select_node->NodeOpType) {
    if (FieldOp == select_node->LeftC->NodeOpType) {
      kind = GetAttr(select_node->LeftC->LeftC->IntVal, KIND_ATTR);

      if (FUNC == kind || PROCE == kind) {
        return GetAttr(select_node->LeftC->LeftC->IntVal, ARGNUM_ATTR);
      }
    }

    select_node = select_node->RightC;
  }

  return -1;
}

int insert_table_entry(tree node) {
  int id = InsertEntry(node->IntVal);

  // The entry insert failed (indicating two names in scope)
  if (0 != id) {
    node->NodeKind = STNode;
    node->IntVal = id;
  }

  return id;
}

void process_class_def(tree node) {
  int id = insert_table_entry(node->RightC);

  if (0 != id) {
    SetAttr(id, KIND_ATTR, CLASS);
  }

  OpenBlock();
  if (NULL != node->LeftC) {
    process_tree(node->LeftC);
  }
  CloseBlock();
}

void process_decl_op(tree node) {
  int id = insert_table_entry(node->RightC->LeftC);
  tree type = node->RightC->RightC->LeftC;

  if (0 != id) {
    SetAttr(id, TYPE_ATTR, (uintptr_t)type);

    if (IndexOp == type->RightC->NodeOpType) {
      int count = get_index_count(type->RightC);
      SetAttr(id, KIND_ATTR, ARR);
      SetAttr(id, DIMEN_ATTR, count);
    } else if (IDNode == type->LeftC->NodeKind) {
      SetAttr(id, KIND_ATTR, VAR);
      tree class = type->LeftC;
      int id = LookUp(class->IntVal);

      if (0 != id) {
        class->NodeKind = STNode;
        class->IntVal = id;
      }
    } else {
      SetAttr(id, KIND_ATTR, VAR);
    }
  }

  if (NULL != node->LeftC) {
    process_tree(node->LeftC);
  }
  if (NULL != node->RightC) {
    process_tree(node->RightC);
  }
}

void process_method_op(tree node) {
  int id = 0;
  if (0 == strcmp("main", &(string_table[node->LeftC->LeftC->IntVal]))) {
    main_count++;
    if (1 == main_count) {
      id = insert_table_entry(node->LeftC->LeftC);
    } else {
      int old_val = node->LeftC->LeftC->IntVal;
      error_msg(REDECLARATION, old_val, old_val, old_val);
      id = 0;
    }
  } else {
    id = insert_table_entry(node->LeftC->LeftC); 
  }

  if (0 != id) {
    tree type = node->LeftC->RightC->RightC;
    if (DUMMYNode == type->NodeKind) {
      SetAttr(id, KIND_ATTR, PROCE);
    } else {
      SetAttr(id, KIND_ATTR, FUNC);
      SetAttr(id, TYPE_ATTR, (uintptr_t)type);
    }

    int count = get_arg_count(node->LeftC);
    SetAttr(id, ARGNUM_ATTR, count);
    SetAttr(id, TREE_ATTR, (uintptr_t)node);
  }

  OpenBlock();
  if (NULL != node->LeftC) {
    process_tree(node->LeftC);
  }
  if (NULL != node->RightC) {
    process_tree(node->RightC);
  }
  CloseBlock();
}

void process_rarg_op(tree node) {
  int id = insert_table_entry(node->LeftC->LeftC);

  if (0 != id) {
    SetAttr(id, KIND_ATTR, REF_ARG);
    SetAttr(id, TYPE_ATTR, (uintptr_t)node->LeftC->RightC);
  }

  if (NULL != node->RightC) {
    process_tree(node->RightC);
  }
}

void process_varg_op(tree node) {
  int id = insert_table_entry(node->LeftC->LeftC);

  if (0 != id) {
    SetAttr(id, KIND_ATTR, VALUE_ARG);
    SetAttr(id, TYPE_ATTR, (uintptr_t)node->LeftC->RightC);
  }

  if (NULL != node->RightC) {
    process_tree(node->RightC);
  }
}

void process_var_op(tree node) {
  tree id_node = node->LeftC;
  int old_val = id_node->IntVal;
  int id = LookUp(id_node->IntVal);

  if (0 != id) {
    id_node->NodeKind = STNode;
    id_node->IntVal = id;

    handle_select(id, node->RightC);

    // Verify the number of indices matches the expected.
    if (ARR == GetAttr(id, KIND_ATTR)) {
      int indices = get_var_index_count(node->RightC);

      if (indices != GetAttr(id, DIMEN_ATTR)) {
        error_msg(INDX_MIS, old_val, old_val, old_val);
      }
    }
  }

  if (NULL != node->LeftC) {
    process_tree(node->LeftC);
  }
  if (NULL != node->RightC) {
    process_tree(node->RightC);
  }
}

void process_call_op(tree node) {
  int old_val = node->LeftC->LeftC->IntVal;

  // First process the var op for the function called.
  process_var_op(node->LeftC);

  // Then retrieve the desired argument count.
  int desired_args = find_arg_count(node->LeftC);

  // Finally count the passed arguments, and see if they are different. 
  int found_args = get_call_arg_count(node->RightC);
  if (desired_args != found_args) {
    error_msg(ARGUMENTS_NUM2, old_val, old_val, old_val);
  }

  process_tree(node->RightC);
}

void process_tree(tree node) {
  if (ClassDefOp == node->NodeOpType) {
    process_class_def(node);
  } else if (DeclOp == node->NodeOpType) {
    process_decl_op(node);
  } else if (MethodOp == node->NodeOpType) {
    process_method_op(node);
  } else if (RArgTypeOp == node->NodeOpType) { 
    process_rarg_op(node);
  } else if (VArgTypeOp == node->NodeOpType) {
    process_varg_op(node);
  } else if (VarOp == node->NodeOpType) {
    process_var_op(node);
  } else if (RoutineCallOp == node->NodeOpType) { 
    process_call_op(node);
  } else {
    // Recurse through the other nodes in the tree. 
    if (NULL != node->LeftC) {
      process_tree(node->LeftC);
    }
    if (NULL != node->RightC) {
      process_tree(node->RightC);
    }
  }
}

int loc_str(char* str) {
  for (int i = 0; i < table_index; i++) {
    if (0 == strcmp(&(string_table[i]), str)) {
      return i;
    }
    i += strlen(&string_table[i]);
  }

  return -1;
}

int main() {
  main_count = 0;
  treelst = stdout;
  yyparse();

  // Initialize the symbol table.
  STInit();
  process_tree(root);
  
  // Print the symbol table 
  STPrint();

  // Print the tree
  printtree(root, 0);
}

void yyerror(char* str) {
  printf("%s at line %d, column %d\n", str, yyline, yycolumn);
}

int yywrap() {
  return 1;
}

#include "lex.yy.c"