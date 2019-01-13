#include <stdbool.h>
#include <stdio.h>

#include "Tokens.h"

char* get_token(int token) {
  switch (token) {
    case ANDnum:
      return "ANDnum";
    case ASSGNnum:
      return "ASSGNnum";
    case DECLARATIONnum:
      return "DECLARATIONnum";
    case DOTnum:
      return "DOTnum";
    case ENDDECLARATIONSnum:
      return "ENDDECLARATIONSnum";
    case EQUALnum:
      return "EQUALnum";
    case GTnum:
      return "GTnum";
    case IDnum:
      return "IDnum";
    case INTnum:
      return "INTnum";
    case LBRACnum:
      return "LBRACnum";
    case LPARENnum:
      return "LPARENnum";
    case METHODnum:
      return "METHODnum";
    case NEnum:
      return "NEnum";
    case ORnum:
      return "ORnum";
    case PROGRAMnum:
      return "PROGRAMnum";
    case RBRACnum:
      return "RBRACnum";
    case RPARENnum:
      return "RPARENnum";
    case SEMInum:
      return "SEMInum";
    case VALnum:
      return "VALnum";
    case WHILEnum:
      return "WHILEnum";
    case CLASSnum:
      return "CLASSnum";
    case COMMAnum:
      return "COMMAnum";
    case DIVIDEnum:
      return "DIVIDEnum";
    case ELSEnum:
      return "ELSEnum";
    case EQnum:
      return "EQnum";
    case GEnum:
      return "GEnum";
    case ICONSTnum:
      return "ICONSTnum";
    case IFnum:
      return "IFnum";
    case LBRACEnum:
      return "LBRACEnum";
    case LEnum:
      return "LEnum";
    case LTnum:
      return "LTnum";
    case MINUSnum:
      return "MINUSnum";
    case NOTnum:
      return "NOTnum";
    case PLUSnum:
      return "PLUSnum";
    case RBRACEnum:
      return "RBRACEnum";
    case RETURNnum:
      return "RETURNnum";
    case SCONSTnum:
      return "SCONSTnum";
    case TIMESnum:
      return "TIMESnum";
    case VOIDnum:
      return "VOIDnum";
  }
}

void report_token(int token, int table_in_index) {
  if (table_in_index >= 0) {
    printf("%d\t%d\t%s\t\t%d\n", yyline, yycolumn, get_token(token), table_in_index);
  } else {
    printf("%d\t%d\t%s\n", yyline, yycolumn, get_token(token));
  }
}

int main() {
  printf("Line\tColumn\tToken\t\tIndex_in_String_table\n");

  bool eof = false;
  while (!eof) {
    int token = yylex();

    if (EOFnum == token) {
      printf("File fully processed.\n");
      eof = true;
    } else {
      report_token(token, -1);
    }
  }
}

int yywrap() {
  return 1;
}