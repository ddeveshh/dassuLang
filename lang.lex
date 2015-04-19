Digit			[0-9]
Letter			[a-zA-Z]
LetterU			[a-zA-Z_]
Exp				[Ee][+-]?{D}+

%{
#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include "lang.tab.h"
using namespace std;
int line_no = 1;
void inc_line();
%}

%%
"echo"									{ /*cout << yytext << endl;*/ return(WRITE);}
"read"									{ /*cout << yytext << endl;*/ return(READ);}
"char"									{ /*cout << yytext << endl;*/ return(CHAR);}
"bool"									{ /*cout << yytext << endl;*/ return(BOOL);}
"else"									{ /*cout << yytext << endl;*/ return(ELSE);}
"if"									{ /*cout << yytext << endl;*/ return(IF);}
"end"									{ /*cout << yytext << endl;*/ return(END);}
"elseif"								{ /*cout << yytext << endl;*/ return(ELSEIF);}
"external"								{ /*cout << yytext << endl;*/ return(EXTERNAL);}
"int"								{ /*cout << yytext << endl;*/ return(INT);}
"float"								{ /*cout << yytext << endl;*/ return(FLOAT);}
"loop"									{ /*cout << yytext << endl;*/ return(LOOP);}
"break"									{ /*cout << yytext << endl;*/ return(BREAK);}
"continue"								{ /*cout << yytext << endl;*/ return(CONTINUE);}
"static"								{ /*cout << yytext << endl;*/ return(STATIC);}
"void"									{ /*cout << yytext << endl;*/ return(VOID);}
"true"									{ /*cout << yytext << endl;*/ return(TRUE);}
"false"									{ /*cout << yytext << endl;*/ return(FALSE);}
"return"								{ /*cout << yytext << endl;*/ return(RETURN);}

"AND"									{ /*cout << yytext << endl;*/ return(AND);} 
"OR"									{ /*cout << yytext << endl;*/ return(OR);}
"NOT"									{ /*cout << yytext << endl;*/ return(NOT);}

{Letter}({LetterU}|{Digit})*						{ /*cout << yytext << endl;*/ return(ID);}
{Digit}+   								{ /*cout << yytext << endl;*/ return(CINT);}
\"(\\.|[^\\"])*\"							{ /*cout << yytext << endl;*/ return(CSTRING);}
'(\\.|[^\\'])'								{ /*cout << yytext << endl;*/ return(CCHAR);}
{Digit}*[.]{Digit}+							{ /*cout << yytext << endl;*/ return(CFLOAT);}
{Digit}+[.]{Digit}*							{ /*cout << yytext << endl;*/ return(CFLOAT);}
">>"									{ /*cout << yytext << endl;*/ return(RIGHT_OP);}
"<<"									{ /*cout << yytext << endl;*/ return(LEFT_OP);}
"++"									{ /*cout << yytext << endl;*/ return(INC);}
"--" 									{ /*cout << yytext << endl;*/ return(DEC);}
"->"									{ /*cout << yytext << endl;*/ return(PTR_OP);}
"<="									{ /*cout << yytext << endl;*/ return(CMP_LE);}
">="									{ /*cout << yytext << endl;*/ return(CMP_GE);}
"=="									{ /*cout << yytext << endl;*/ return(CMP_EQ);}
"!="									{ /*cout << yytext << endl;*/ return(CMP_NEQ);}
";"									{ /*cout << yytext << endl;*/ return(';');} 
","									{ /*cout << yytext << endl;*/ return(',');}
":"									{ /*cout << yytext << endl;*/ return(':');}
"="									{ /*cout << yytext << endl;*/ return('=');}
"("									{ /*cout << yytext << endl;*/ return('(');}
")"									{ /*cout << yytext << endl;*/ return(')');}
"\["									{ /*cout << yytext << endl;*/ return('[');}
"\]"									{ /*cout << yytext << endl;*/ return(']');}
"."									{ /*cout << yytext << endl;*/ return('.');}
"&"									{ /*cout << yytext << endl;*/ return('&');}
"~"									{ /*cout << yytext << endl;*/ return('~');}
"-"									{ /*cout << yytext << endl;*/ return('-');}
"+"									{ /*cout << yytext << endl;*/ return('+');}
"*"									{ /*cout << yytext << endl;*/ return('*');}
"/"									{ /*cout << yytext << endl;*/ return('/');}
"%"									{ /*cout << yytext << endl;*/ return('%');}
"<"									{ /*cout << yytext << endl;*/ return(CMP_LESS);}
">"									{ /*cout << yytext << endl;*/ return(CMP_MORE);}
"\^"									{ /*cout << yytext << endl;*/ return('|');}
"|"									{ /*cout << yytext << endl;*/ return('|');}
[\a\b\r\t\v\f\0?]*							;
" "									;
[\n]									{ inc_line();}
.									{ /*count(); return("<invalid token, \"%s\">\n", yytext);*/}

%%

void inc_line(){
	line_no++;
}
