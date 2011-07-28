#include <string.h>
#include <stdlib.h>

#include "lexer.h"
#include "parser.h"
#include "parser.c"

#define INTEGER() { \
  tk = new Token(TK_INTEGER, ts, te); \
  tk->value = atoi(tk->str); \
  Parse(parser, TK_INTEGER, tk, &context); \
  printf("int: %d\n", tk->value); \
}

#define KEYWORD(ID) { \
  tk = new Token(ID, ts, te); \
  Parse(parser, ID, tk, &context); \
  printf("keyword: %s\n", tk->str);\
}

#define SYMBOL(ID) { \
  tk = new Token(ID, ts, te); \
  Parse(parser, ID, tk, &context); \
  printf("symbol: %s\n", tk->str);\
}

#define STRING() { \
  tk = new Token(TK_STRING, ts + 1, te - 1); \
  Parse(parser, TK_STRING, tk, &context); \
  printf("string: %s\n", tk->str);\
}

#define ID() { \
  tk = new Token(TK_ID, ts, te); \
  Parse(parser, TK_ID, tk, &context); \
  printf("id: %s\n", tk->str);\
}

%%{
  machine lexer;

  main := |*
    [1-9][0-9]* { INTEGER() };

    /select/i { KEYWORD(TK_SELECT) };
    /where/i { KEYWORD(TK_WHERE) };
    /or/i { KEYWORD(TK_OR) };
    /and/i { KEYWORD(TK_AND) };
    /not/i { KEYWORD(TK_NOT) };
    /from/i { KEYWORD(TK_FROM) };
    /order/i { KEYWORD(TK_ORDER) };
    /by/i { KEYWORD(TK_BY) };
    /asc/i { KEYWORD(TK_ASC) };
    /desc/i { KEYWORD(TK_DESC) };
    /limit/i { KEYWORD(TK_LIMIT) };

    ',' { SYMBOL(TK_COMMA) };
    '>' { SYMBOL(TK_GT); };
    '=' { SYMBOL(TK_EQ); };
    '*' { SYMBOL(TK_STAR) };

    dliteralChar = [^`"\\] | ( '\\' any );
    '"' (dliteralChar | '`')* '"' { STRING() };
    '`' (dliteralChar | '"')* '`' { STRING() };

    (print - space - [,>=*])+ { ID() };

    ' ';
  *|;
}%%

%% write data;

Statement *Parse(char *str) {
  int cs, act;
  char *ts, *te;
  char *p = str;
  char *pe = p + strlen(p);
  char *eof = pe;

  Token *tk = NULL;

  ParserContext context;

  void *parser = ParseAlloc(malloc);

  %% write init;
  %% write exec;

  if (cs < %%{ write first_final; }%%) {
    printf("error: %s\n", p);
  }

  Parse(parser, 0, 0, &context);

  ParseFree(parser, free);

  return context.stmt;
}

