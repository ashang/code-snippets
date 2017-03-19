/* wc.l, equal to wc in Unix */
/* To run it, use `lex wc.l`, then `gcc -o wc-lex lex.yy.c -lfl` */
/* Try `dmesg|./wc-lex` */
%{
int chars = 0;
int words = 0;
int lines = 0;
%}

%%

[a-zA-Z]+   { words++; chars += strlen(yytext); }
\n          { chars++; lines++; }
.           { chars++; }

%%

int main(int argc, char **argv)
{
  yylex();
  printf("%8d %8d %8d\n", lines, words, chars);
  return 0;
}
