  /**
   * Todd M. Ernst 2019
   */
  #include <stdbool.h>
  #include "Tokens.h"

  int handle_string();
  void increment_column();
  void process_comment();
  void ReportError(char* message);

  int yylval;
  int yyline = 1;
  int yycolumn = 1;

  int table_index = 0;
  char string_table[STRING_TABLE_SIZE];

DIGIT [0-9]

LETTER [a-zA-Z]

  // Consider a way to make this accept new lines as well
WS [ \t]

  // Think about a way to make a "delimiter" grouping

%%

"/*"([^*]|"*"[^"/"])*"*/" {
  process_comment();
}

"&&" {
  increment_column();
  return ANDnum;
}

":=" {
  increment_column();
  return ASSGNnum;
}

"declarations" {
  increment_column();
  return DECLARATIONSnum;
}

"." {
  increment_column();
  return DOTnum;
}

"enddeclarations" {
  increment_column();
  return ENDDECLARATIONSnum;
}

"=" {
  increment_column();
  return EQUALnum;
}

">" {
  increment_column();
  return GTnum;
}

"int" {
  increment_column();
  return INTnum;
}

"[" {
  increment_column();
  return LBRACnum;
}

"(" {
  increment_column();
  return LPARENnum;
}

"method" {
  increment_column();
  return METHODnum;
}

"!=" {
  increment_column();
  return NEnum;
}

"||" {
  increment_column();
  return ORnum;
}

"program" {
  increment_column();
  return PROGRAMnum;
}

"]" {
  increment_column();
  return RBRACnum;
}

")" {
  increment_column();
  return RPARENnum;
}

";" {
  increment_column();
  return SEMInum;
}

"val" {
  increment_column();
  return VALnum;
}

"while" {
  increment_column();
  return WHILEnum;
}

"class" {
  increment_column();
  return CLASSnum;
}

"," {
  increment_column();
  return COMMAnum;
}

"/" {
  increment_column();
  return DIVIDEnum;
}

"else" {
  increment_column();
  return ELSEnum;
}

"==" {
  increment_column();
  return EQnum;
}

">=" {
  increment_column();
  return GEnum;
}

"if" {
  increment_column();
  return IFnum;
}

"{" {
  increment_column();
  return LBRACEnum;
}

"<=" {
  increment_column();
  return LEnum;
}

"<" {
  increment_column();
  return LTnum;
}

"-" {
  increment_column();
  return MINUSnum;
}

"!" {
  increment_column();
  return NOTnum;
}

"+" {
  increment_column();
  return PLUSnum;
}

"}" {
  increment_column();
  return RBRACEnum;
}

"return" {
  increment_column();
  return RETURNnum;
}

"*" {
  increment_column();
  return TIMESnum;
}

"void" {
  increment_column();
  return VOIDnum;
}

{DIGIT}+ {
  increment_column();

  yylval = atoi(yytext);
  return ICONSTnum;
}

"'"([^"'"\n]|"\\\'")*"'" {
  increment_column();

  // Process the string constant.  Remove the "'" delimiters,
  // and replace any escape sequences.
  int prev_length = strlen(yytext);
  char* string_const = malloc(prev_length - 2);
  int new_string_index = 0;
  for (int i = 1; i < prev_length - 1; i++) {
    bool escape = ('\\' == yytext[i]);
    if (escape && '\'' == yytext[i + 1]) {
      i++;
      string_const[new_string_index] = '\'';
    } else if (escape && '\\' == yytext[i + 1]) {
      i++;
      string_const[new_string_index] = '\\';
    } else if (escape && 'n' == yytext[i + 1]) {
      i++;
      string_const[new_string_index] = '\n';
    } else if (escape && 't' == yytext[i + 1]) {
      i++;
      string_const[new_string_index] = '\t';
    } else {
      string_const[new_string_index] = yytext[i];
    }

    new_string_index++;
  }
  string_const[strlen(string_const)] = 0;

  yylval = handle_string(string_const);
  // free(string_const);
  return SCONSTnum;
}

{LETTER}({LETTER}|{DIGIT})* {
  increment_column();

  yylval = handle_string(yytext);
  return IDnum;
}

{WS} {
  yycolumn++;
}

\n {
  yycolumn = 1;
  yyline++;
}

{DIGIT}({LETTER}|{DIGIT})* {
  // Create and report the error
  char* id_error_format = "Malformed identifier '%s'";
  char* message = malloc(strlen(id_error_format) + strlen(yytext));
  sprintf(message, id_error_format, yytext);
  ReportError(message);
  free(message);

  increment_column();
  continue;
}

"'"([^"'"\n]|"\\\'")* {
  // Create and report the error
  char* message = "Unmatched string constant";
  ReportError(message);

  increment_column();
  continue;
}

"/*"([^*]|"*"[^"/"])* {
  process_comment();

  char* message = "EOF found in comment";
  ReportError(message);

  continue;
}

. {
  // This must be the final rule as it defines what 
  // happens if a a correct case isn't determined.
  char* symbol_format = "Undefined symbol \'%s\'";
  char* message = malloc(strlen(symbol_format) + strlen(yytext));
  sprintf(message, symbol_format, yytext);
  ReportError(message);
  free(message);

  increment_column();
  continue;
}

<<EOF>> {
  return EOFnum;
}

%%
int handle_string(char* string) {
  for (int i = 0; i < table_index; i++) {
    if (0 == strcmp(string, &(string_table[i]))) {
      return i;
    }

    i += strlen(&(string_table[i]));
  }

  int prev_index = table_index;
  int length = strlen(string);
  if (length + table_index < STRING_TABLE_SIZE) {
    strcpy(&(string_table[table_index]), string);
    table_index += length + 1;
  } else {
    ReportError("Value would exceed string table size.");
  }

  return prev_index;
}

void increment_column() {
  yycolumn += strlen(yytext);
}

void process_comment() {
  // A comment has been detected, begin to process it.  
  // Start from the rear to ease column/line manipulation
  bool first_new_line_found = false;
  for (int i = strlen(yytext); i != 0; i--) {
    if ('\n' == yytext[i]) {
      // If this is the first new line, then the column index
      // is equal to the number of characters processed.
      if (!first_new_line_found) {
        // Add a one to account for one-indexing 
        yycolumn = strlen(yytext) - i + 1;
      }

      yyline++;
      first_new_line_found = true;
    }
  }

  // If no new line is found, simple increment the column
  // by the size of the comment. 
  if (!first_new_line_found) {
    increment_column();
  }
}

void ReportError(char* message) {
  printf("Error: %s, at line %d column %d\n",message, yyline, yycolumn);
}
