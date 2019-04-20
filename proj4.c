#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "proj3.h"
#include "proj4.h"

#define MAX_LABEL_SIZE 100

int class_id = 0;
int stack_size = 0;
bool method_invocation = false;

extern char string_table[4096];

// Function declarations
void process_node(tree root);
void get_address(tree root);
void generate_func_call(tree root);
void generate_expression(tree root);
void generate_global(tree root);

////////////////////////////////////////////////////////////
// The following section contains a series of utility 
// functions for retrieving information from the AST
////////////////////////////////////////////////////////////
int get_initial_value(tree initial_node) {
  int initial_value = 0;

  if (NUMNode == initial_node->NodeKind) {
    initial_value = initial_node->IntVal;
  } else if (UnaryNegOp == initial_node->NodeOpType) {
    initial_value = -1 * initial_node->LeftC->IntVal;
  }

  return initial_value;
}

extern int st_top;
char** labels = NULL;
void set_label(int id, char* label) {
  if (NULL == labels) {
    labels = malloc(sizeof(char*) * st_top);
  }

  labels[id] = label;
}

void get_address(tree root) {
  int id = root->LeftC->IntVal;
  if (0 == GetAttr(id, NEST_ATTR)) {
    printf("\tla $v1 %s\n", labels[id]);
  } else if (1 == GetAttr(id, NEST_ATTR)) {
    if (method_invocation) {
      printf("\tlw $v1 %d($fp)\n", GetAttr(id, 11));
    } else {
      printf("\tla $v1 %s\n", labels[class_id]);
    }
    printf("\taddi $v1 $v1 %d\n", GetAttr(id, OFFSET_ATTR));
  } else {
    int offset = GetAttr(id, OFFSET_ATTR);
    if (REF_ARG == GetAttr(id, KIND_ATTR)) {
      offset -= 4;
      printf("\tlw $v1 %d($fp)\n", offset);
    } else {
      if (VALUE_ARG == GetAttr(id, KIND_ATTR)) {
        offset -= 4;
      }

      printf("\taddi $v1 $fp %d\n", offset);
    }
  }

  tree select_node = root->RightC;
  while (SelectOp == select_node->NodeOpType) {
    if (FieldOp == select_node->LeftC->NodeOpType) {
      int field_id = select_node->LeftC->LeftC->IntVal;

      if (FUNC != GetAttr(field_id, KIND_ATTR) && PROCE != GetAttr(field_id, KIND_ATTR)) {
        printf("\taddi $v1 %d\n", GetAttr(field_id, OFFSET_ATTR));
      }
    } else {
      if (NUMNode == select_node->LeftC->LeftC->NodeKind) {
        int index = select_node->LeftC->LeftC->IntVal;
        printf("\taddi $v1 %d\n", 4 * index);
      } else {
        printf("\taddi $sp $sp -4\n");
        printf("\tsw $v1 ($sp)\n");
        generate_expression(select_node->LeftC->LeftC);
        printf("\tlw $t7 ($sp)\n");
        printf("\taddi $sp $sp 4\n");
        printf("\tmul $v0 $v0 4\n");
        printf("\tadd $v1 $v0 $t7\n");
      }
    }

    select_node = select_node->RightC;
  }
}

////////////////////////////////////////////////////////////
// The following section contains a series of utilit 
// functions to generate code from an AST node
////////////////////////////////////////////////////////////
void generate_expression(tree root) {
  // These two ifs constitute the base case for an expression, it can either
  // be an immediate or a variable.  Correctly set $v0 and return.
  if (NUMNode == root->NodeKind) {
    printf("\tli $v0 %d\n", root->IntVal);
    return;
  }
  if (VarOp == root->NodeOpType) {
    get_address(root);
    printf("\tlw $v0 ($v1)\n"); 
    return;
  }
  if (RoutineCallOp == root->NodeOpType) {
    generate_func_call(root);
    return;
  }

  if (UnaryNegOp == root->NodeOpType || NotOp == root->NodeOpType) {
    // Handle single operand operations.
    generate_expression(root->LeftC);
    switch (root->NodeOpType) {
      case UnaryNegOp:
        printf("\tneg $v0 $v0\n");
        break;
      case NotOp:
        printf("\tnot $v0 $v0\n");
        break;
    }
  } else {
    // Handle double operand operations.
    // Correctly generate and handle the left and right side of the
    // expressions
    generate_expression(root->RightC);
    printf("\taddi $sp $sp -4\n");
    printf("\tsw $v0 ($sp)\n");  // TODO : Increase efficiency using saved reg
    generate_expression(root->LeftC);
    printf("\tmove $t3 $v0\n");
    printf("\tlw $t4 ($sp)\n");
    printf("\taddi $sp $sp 4\n");

    // Generate the specific operation
    switch (root->NodeOpType)  {
      case EQOp:
        printf("\tseq $v0 $t3 $t4\n");
        break;
      case NEOp:
        printf("\tsne $v0 $t3 $t4\n");
        break;
      case GEOp:
        printf("\tsge $v0 $t3 $t4\n");
        break;
      case GTOp:
        printf("\tsgt $v0 $t3 $t4\n");
        break;
      case LEOp:
        printf("\tsle $v0 $t3 $t4\n");
        break;
      case LTOp:
        printf("\tslt $v0 $t3 $t4\n");
        break;
      case AddOp:
        printf("\tadd $v0 $t3 $t4\n");
        break;
      case SubOp:
        printf("\tsub $v0 $t3 $t4\n");
        break;
      case MultOp:
        printf("\tmul $v0 $t3 $t4\n");
        break;
      case DivOp:
        printf("\tdiv $v0 $t3 $t4\n");
        break;
      case AndOp:
        printf("\tand $v0 $t3 $t4\n");
        break;
      case OrOp:
        printf("\tor $v0 $t3 $t4\n");
        break;
    }
  }
}

/**
 * Generate the default header information required to create a
 * program. 
 */
void generate_header() {
  printf(".data\n");
  printf("Enter:\t.asciiz \"\n\"\n");
  printf("base:\n");
  printf(".text\n");
}

/**
 * Generate a unique data label to be used within the output code
 */
int label_counter = 0;
char* generate_data_label() {
  char* label = malloc(MAX_LABEL_SIZE);
  sprintf(label, "V%d", label_counter);
  label_counter++;

  return label;
}

void generate_global_str(tree root, char* label) {
  printf(".data\n");
  printf("%s: .asciiz \"%s\"\n", label, &string_table[root->IntVal]);
  printf(".text\n");
}

void initialize_array(tree root) {
  if (CommaOp == root->LeftC->NodeOpType) {
    initialize_array(root->LeftC);
  }

  int initial_value = get_initial_value(root->RightC);
  printf("\t.word %d\n", initial_value);
}

void generate_global_array(tree root) {
  // Initialize the array (if not explicit with default values)
  tree array_node = root->RightC->RightC->RightC;
  if (BoundOp == array_node->LeftC->NodeOpType) {
    for (int i = 0; i < array_node->LeftC->RightC->IntVal; i++) {
      printf("\t.word 0\n");
    }
  } else {
    initialize_array(array_node->LeftC);
  }
}

/**
 * A function to generate a global integer value specifically.
 */
void generate_global_int(tree root) {
  int initial_value = get_initial_value(root->RightC->RightC->RightC);

  printf("\t.word %d\n", initial_value);
}

void generate_global_class(tree root) {
  int class_id = root->RightC->RightC->LeftC->LeftC->IntVal;
  
  tree def_node = (tree)GetAttr(class_id, CLASS_DEF_ATTR);
  if (BodyOp == def_node->NodeOpType) {
    generate_global(def_node);
  }
}

/**
 * The root function for generating a global value in the program.
 */ 
void generate_global(tree root) {
  if (BodyOp == root->LeftC->NodeOpType) {
    generate_global(root->LeftC);
  }

  tree decl_node = root->RightC;
  while (DeclOp == decl_node->NodeOpType) {
    if (ArrayTypeOp == decl_node->RightC->RightC->RightC->NodeOpType) {
      generate_global_array(decl_node);
    } else {
      int var_id = decl_node->RightC->LeftC->IntVal;
      tree type_tree = (tree)GetAttr(var_id, TYPE_ATTR);
      if (INTEGERTNode == type_tree->LeftC->NodeKind) {
        generate_global_int(decl_node);
      } else {
        generate_global_class(decl_node);
      }
    }
    decl_node = decl_node->LeftC;
  }
}

void generate_class_variables(tree root) {
  // Skip generating class variables for classes which don't have them.
  int id = root->RightC->IntVal;
  if ((DUMMYNode == root->LeftC->NodeKind) || 
      (DUMMYNode == root->LeftC->LeftC->NodeKind && 
       DeclOp != root->LeftC->RightC->NodeOpType)) {
    return;
  }

  class_id = id;

  char* label = generate_data_label();
  set_label(id, label);
  printf(".data\n");
  printf("%s:\n", label);

  tree body_node = root->LeftC->LeftC;
  if (DeclOp == root->LeftC->RightC->NodeOpType) {
    body_node = root->LeftC;
  }
  if (BodyOp == body_node->NodeOpType) {
    generate_global(body_node);
  }

  SetAttr(id, CLASS_DEF_ATTR, body_node);

  printf(".text\n");
}

void generate_method_variables(tree root) {
  if (DUMMYNode == root->RightC->NodeKind ||
      DUMMYNode == root->RightC->LeftC->NodeKind) {
    return;
  }

  tree body_node = root->RightC->LeftC;
  while (BodyOp == body_node->NodeOpType) {
    int initial_value = get_initial_value(body_node->RightC->RightC->RightC->RightC);
    int offset = GetAttr(body_node->RightC->RightC->LeftC->IntVal, OFFSET_ATTR);
    printf("\tli $t0 %d\n", initial_value);
    printf("\tsw $t0 %d($fp)\n", offset);
    body_node = body_node->LeftC;
  }
}

/*
 * Generate the output for a system.println call
 */
void generate_println_call(tree root) {
  // Determine the context of the output and inoke the 
  // correct syscall based on it. 
  if (STRINGNode == root->RightC->LeftC->NodeKind) {
    char* label = generate_data_label();
    generate_global_str(root->RightC->LeftC, label);

    // Generate the code to execute the syscall
    printf("\tli $v0 4\n");
    printf("\tla $a0 %s\n", label);
    printf("\tsyscall\n");
  } else if (VarOp == root->RightC->LeftC->NodeOpType) {
    tree var_node = root->RightC->LeftC;
    get_address(var_node);

    // Generate the code to execute the 
    printf("\tli $v0 1\n");
    printf("\tlw $a0 ($v1)\n");
    printf("\tsyscall\n");
  } else if (RoutineCallOp == root->RightC->LeftC->NodeOpType) {
    generate_func_call(root->RightC->LeftC);
    printf("\tmove $a0 $v0\n");
    printf("\tli $v0 1\n");
    printf("\tsyscall\n");
  } else {
    generate_expression(root->RightC->LeftC);
    printf("\tmove $a0 $v0\n");
    printf("\tli $v0 1\n");
    printf("\tsyscall\n");
  }

  // Finally output the required newlines.
  printf("\tli $v0 4\n");
  printf("\tla $a0 Enter\n");
  printf("\tsyscall\n");
}

void generate_readln_call(tree root) {
  tree var_node = root->RightC->LeftC;
  get_address(var_node);

  printf("\tli $v0 5\n");
  printf("\tsyscall\n");
  printf("\tsw $v0 ($v1)\n");
}

void generate_assign(tree root) {
  get_address(root->LeftC->RightC);
  printf("\taddi $sp $sp -4\n");
  printf("\tsw $v1 ($sp)\n");

  if (RoutineCallOp == root->RightC->NodeOpType) {
    generate_func_call(root->RightC);
    printf("\tmove $t5 $v0\n");
  } else {
    generate_expression(root->RightC);
    printf("\tmove $t5 $v0\n");
  }

  printf("\tlw $v1 ($sp)\n");
  printf("\taddi $sp $sp 4\n"); 
  printf("\tsw $t5 ($v1)\n");
}

void generate_arguments(tree root, tree arg_node) {
  if (DUMMYNode != root->RightC->NodeKind) {
    generate_arguments(root->RightC, arg_node->RightC);
  }
  
  if (NUMNode == root->LeftC->NodeKind) {
    printf("\taddi $sp $sp -4\n");
    printf("\tli $t6 %d\n", root->LeftC->IntVal);
    printf("\tsw $t6 ($sp)\n");
  } else {
    if (RArgTypeOp == arg_node->NodeOpType) {
      get_address(root->LeftC);
      printf("\taddi $sp $sp -4\n");
      printf("\tsw $v1 ($sp)\n");
    } else {
      generate_expression(root->LeftC);
      printf("\taddi $sp $sp -4\n");
      printf("\tsw $v0 ($sp)\n"); 
    }
  }
}



/**
 * Generate a function call.
 */
void generate_func_call(tree root) {
  int firstId = root->LeftC->LeftC->IntVal;
  // Since the system/println are always injected, 
  // we can rely on the values to be as expected.
  if (0 == strcmp("system", &string_table[GetAttr(firstId, NAME_ATTR)])) {
    tree func = root->LeftC->RightC->LeftC->LeftC;
    if (0 == strcmp("println", &string_table[GetAttr(func->IntVal, NAME_ATTR)])) {
      generate_println_call(root);
    } else if (0 == strcmp("readln", &string_table[GetAttr(func->IntVal, NAME_ATTR)])) {
      generate_readln_call(root);
    }
  } else {
    int method_id = root->LeftC->LeftC->IntVal;
    if (DUMMYNode != root->LeftC->RightC->NodeKind) { 
      get_address(root->LeftC);
      method_invocation = true;
      printf("\taddi $sp $sp -4\n");
      printf("\tsw $v1 ($sp)\n");
      method_id = root->LeftC->RightC->LeftC->LeftC->IntVal;
    } 

    // Push any arguments unto the stack
    if (DUMMYNode != root->RightC->NodeKind) {
      // Retrieve the argument list
      tree arg_node = ((tree)GetAttr(method_id, TREE_ATTR))->LeftC->RightC->LeftC;

      generate_arguments(root->RightC, arg_node);
    } 

    // TODO: Store temporary registers here, actually this is a maybe
    printf("\tjal %s\n", &string_table[GetAttr(method_id, NAME_ATTR)]);
    // TODO: Reload temporary registers here, actually this is a maybe
    
    // Pop the stack where the arguments were added.
    tree param_node = root->RightC;
    while (DUMMYNode != param_node->NodeKind) {
      printf("\taddi $sp $sp 4\n");  

      param_node = param_node->RightC;
    }

    if (method_invocation) {
      method_invocation = false;
      printf("\taddi $sp $sp 4\n");
    }
  }
}

void generate_if_else_block(tree root, char* if_label, int depth) {
  if (IfElseOp == root->LeftC->NodeOpType) {
    generate_if_else_block(root->LeftC, if_label, depth + 1);
  }
  // Generate compairsion expression and jump
  if (CommaOp == root->RightC->NodeOpType) {
    // If the comparison operation fails, jump to the end of if's statements
    generate_expression(root->RightC->LeftC);
    printf("\tbeqz $v0 %s_%d_end\n", if_label, depth);  
  }

  // Generate code
  if (CommaOp == root->RightC->NodeOpType) {
    process_node(root->RightC->RightC);
  } else {
    process_node(root->RightC);
  }

  // Generate jump to end
  printf("\tb %s_end\n", if_label);
  printf("%s_%d_end:\n", if_label, depth);

  if (0 == depth) {
    printf("%s_end:\n", if_label);
  }
}

void generate_loop(tree root, char* loop_label) {
  // Output a label indicating the beginning of the loop
  printf("%s_begin:\n", loop_label);

  // Generate the while loops comparison expression
  generate_expression(root->LeftC);

  // If the comparison operation fails, jump to the end of the while loop
  printf("\tbeqz $v0, %s_end\n", loop_label);

  // Generate code inside loop and jump to top
  process_node(root->RightC);
  printf("\tb %s_begin\n", loop_label);

  // Generate the label at the end of the loop
  printf("%s_end:\n", loop_label);
}

void generate_return(tree root) {
  // Since all expression output is located in $v0, the expression
  // can be simply be evaluated and the output will be located in the 
  // correct register.
  generate_expression(root->LeftC);
}

/**
 * Generate a label for a method call
 */
void generate_method_header(tree root) {
  int id = root->LeftC->LeftC->IntVal;

  // Generate the appropriate label for the function
  int loc = GetAttr(id, NAME_ATTR);
  printf("%s:\n", &string_table[loc]);

  // Correctly handle the stack pointer offset
  int offset = 0;
  int varId = id + 1;
  int nest_level = GetAttr(id, NEST_ATTR) + 1;
  while (varId <= st_top && nest_level == GetAttr(varId, NEST_ATTR)) {
    if (REF_ARG != GetAttr(varId, KIND_ATTR) && 
        VALUE_ARG != GetAttr(varId, KIND_ATTR)) {
      offset = GetAttr(varId, OFFSET_ATTR);
    } 

    varId++;  
  }
  SetAttr(id, SIZE_ATTR, offset);
  printf("\taddi $sp $sp -4\n");
  printf("\tsw $fp ($sp)\n");
  printf("\taddi $sp $sp -4\n");
  printf("\tsw $ra ($sp)\n");
  printf("\tmove $fp $sp\n");
  printf("\taddi $sp $sp %d\n", offset);
}

/*
 * Generate the footer at the end of the method.
 */
void generate_method_footer(tree root) {
  int id = root->LeftC->LeftC->IntVal;

  // Correctly reset the stack pointer offset
  int offset = 0;
  int varId = id + 1;
  int nest_level = GetAttr(id, NEST_ATTR) + 1;
  while (varId <= st_top && nest_level == GetAttr(varId, NEST_ATTR)) {
    if (REF_ARG != GetAttr(varId, KIND_ATTR) && 
        VALUE_ARG != GetAttr(varId, KIND_ATTR)) {
      offset = GetAttr(varId, OFFSET_ATTR);
    }
    varId++;
  }

  printf("\taddi $sp $sp %d\n", -1 * offset);
  printf("\tlw $ra ($sp)\n");
  printf("\taddi $sp $sp 4\n");
  printf("\tlw $fp ($sp)\n");
  printf("\taddi $sp $sp 4\n");

  printf("\tjr $ra\n");
}

int if_count = 0;
int loop_count = 0;

void process_node(tree root) {
  // Here will be a switch statement processing the AST.
  switch (root->NodeOpType) {
    case ClassDefOp:
      generate_class_variables(root);
      break;
    case AssignOp:
      generate_assign(root);
      return;
    case RoutineCallOp:
      generate_func_call(root);
      return;
    case IfElseOp: {
      char if_label[MAX_LABEL_SIZE];
      snprintf(if_label, MAX_LABEL_SIZE, "if_block_%d", if_count++);
      generate_if_else_block(root, if_label, 0);
      return;
    }
    case LoopOp: {
      char loop_label[MAX_LABEL_SIZE];
      snprintf(loop_label, MAX_LABEL_SIZE, "loop_block_%d", loop_count++);
      generate_loop(root, loop_label);
      return;
    }
    case ReturnOp:
      generate_return(root);
      return;
    case MethodOp:
      generate_method_header(root);
      generate_method_variables(root);
      break;
  }

  if (NULL != root->LeftC) {
    process_node(root->LeftC);
  }

  if (NULL != root->RightC) {
    process_node(root->RightC);
  }

  if (MethodOp == root->NodeOpType) {
    generate_method_footer(root);
  }
}

void generate_code(tree root) {
  generate_header();
  process_node(root);
}