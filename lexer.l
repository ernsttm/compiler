  #include "Tokens.h"

  int yyline = 1;
  int yycolumn = 0;
%%
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
  return DECLARATIONnum;
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

\n {
  yycolumn = 0;
  yyline++;
}

%%
void increment_column() {
  yycolumn += strlen(yytext);
}

void ReportError(char* message) {
  printf("Error detected at line: %d, column: %d.\n", yyline, yycolumn);
  printf("%s\n", message);
}