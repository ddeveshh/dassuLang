
%{
#include <stdio.h>
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <cstdlib>
#include <map>
#include <algorithm>
#include <fstream>
using namespace std;
int yylex(void);
void yyerror(char * s);

extern char* yytext;
extern int yyleng;
vector < map<string, pair<string,string> > > symbolTable(1, map<string,pair<string,string> >());

int scope  = 0;
bool semanticError = false;
bool syntacticError = false;
	
int findIdentifierScope(string id){
	for(int i=scope;i>=0;i--){
		if(symbolTable[i].find(id) != symbolTable[i].end())	return scope;
	}
	return -1;
}


typedef struct node node;
struct node {
	vector<node*> children;
	string token;
	vector<string> id;
	string type;
	string datatype = "";
};

#define YYSTYPE node*
node* mkleaf(string);
node* mknode(vector<node*> , string, string);


void printSymbolTable();
void printtree(node*);
extern int line_no;
node* root;
int number =0;
vector< vector<string> > A(vector<string>);
map<string, vector < pair<string, string>  > > funcTable;
vector<pair<string,string> > args;
vector<string> prms;
string ThreeAdressCode(node* n);
void pop();
void printFuncTable();
string identifier = "";
vector<string> loopStack;
vector<string> argStack;
pair <string,string> l;
string currFunc ="";
vector<string> iflabels;
string current_func="";
int returnflag = 0;

%}



%token ID CINT CFLOAT CCHAR CSTRING TRUE FALSE
%token PTR_OP INC DEC LEFT_OP RIGHT_OP CMP_LE CMP_GE CMP_EQ CMP_NEQ CMP_LESS CMP_MORE

%token AND OR NOT

%token EXTERNAL STATIC
%token CHAR INT FLOAT BOOL
%token STRUCT VOID

%token IF ELSE ELSEIF END LOOP BREAK CONTINUE RETURN
%token WRITE READ
%start START

%%

START
	: TRANSLATION							{$$=$1;root = $$;/*printSymbolTable();printFuncTable()*/;remove( "MIPS/TAC.txt" );
//cout << "\n\n\n+++++++++++++++++++++++++ 3 ADDRESS CODE ++++++++++++++++++++++++++++\n" << endl;
ThreeAdressCode(root);
}//{vector<node*> b;b.push_back($1);$$=mknode(b,"START", "??");}
	;

TRANSLATION
	: OUTER								{$$=$1;}
	| TRANSLATION OUTER						{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"TRANSLATION", "??");}
	;

OUTER
	: FUNC								{$$=$1;}
	| DECLARATION							{$$=$1;}
	;

/// VARIABLE DECLARATIONS

DECLARATION
	//: DEC_SPECIFIERS SEMICOLON					{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"DECLARATION", "??");}
	: DEC_SPECIFIERS INIT_DEC_LIST SEMICOLON			{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"DECLARATION", "??");	
									
									for(int q = 0;q<$2->id.size();q++){
										string s1="",s2="";
										string s = $2->id[q];
										for(int i=0;i<s.length();i++){
											if(s[i]=='*')
												s1 += s[i];
											else
												s2 += s[i];
											}
										//cout << "scope: "<< scope << endl;
										//cout << "table.size: "<< symbolTable.size() << endl;
						int temp = scope+1;int check =0;	
						while(temp--){
									if(symbolTable[temp].find(s2)==symbolTable[temp].end())
									;
									else
									{
									check= 1;
									}	
								}
						if(!check){
								symbolTable[scope][s2] = make_pair(($1)->token + s1, "NONFUNC");
											}
						else{
							semanticError = true;
							cout << "Multiple declaration of " << s2 << " at line no. " << line_no <<endl;
							}
							}
						}
	
	| error								{cout <<"Expected ';' or 'end' in line number -> "<< line_no <<endl;vector<node*> b;b.push_back(mkleaf("error"));$$=mknode(b,"DECLARATION", "??");}
	;

DEC_SPECIFIERS
	//: STCLASS							{$$=$1;}
	//| STCLASS DEC_SPECIFIERS					{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"DEC_SPECIFIERS", "??");}
	: TYPE_SPEC							{$$=$1;}
	//| TYPE_SPEC DEC_SPECIFIERS					{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"DEC_SPECIFIERS", "??");}
	;

INIT_DEC_LIST
	: INIT_DEC							{$$=$1; }
	| INIT_DEC COMMA INIT_DEC_LIST					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"INIT_DEC_LIST", "??");$$->id = $3->id; $$->id.push_back($1->id[0]);}
	;

INIT_DEC
	: DECLARATOR							{vector<node*> b;b.push_back($1);$$=mknode(b,"INIT_DEC", "??");/*prms.push_back($1->type);*/$$->id=$1->id;}
	| DECLARATOR OP_ASSIGN INIT					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"INIT_DEC", "??");$$->id.push_back($1->id[0]);}
	;

INIT
	: EXP_ASSIGN							{$$=$1;}
	| CBRAC INIT_LIST CBRAC_CLOSE					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"INIT", "??");}
	;

INIT_LIST
	: INIT								{$$=$1;}
	| INIT_LIST COMMA INIT						{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"INIT_LIST", "??");}
	;

DECLARATOR
	: POINTER DIRECT_DEC						{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"DECLARATOR", "??"); string s ="";for(int i=0;i<$1->id.size();i++){s+=$1->id[i];}s+=$2->id[0];$$->id.push_back(s);}
	| DIRECT_DEC							{$$=$1;}
	;

POINTER
	: '*'								{$$=mkleaf("*");$$->id.push_back("*");}
	| '*' POINTER							{vector<node*> b;b.push_back(mkleaf("*"));b.push_back($2);$$=mknode(b,"POINTER", "??");$$->id = $2->id; $$->id.push_back("*");}
	;

DIRECT_DEC
	: id								{$$=$1;}
	| DIRECT_DEC '[' EXP_OR ']'					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("["));b.push_back($3);b.push_back(mkleaf("]"));$$=mknode(b,"DIRECT_DEC", "??");$$->id.push_back("*"+$1->id[0]);}
	| DIRECT_DEC '[' ']'						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("["));b.push_back(mkleaf("]"));$$=mknode(b,"DIRECT_DEC", "??");$$->id.push_back("*"+$1->id[0]);}
	;




/// FUNCTION DECLARATIONS
FUNC
	: DEC_SPECIFIERS FUNC_DECLARATOR INNER				{prms.clear();vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"FUNC", "??");
									string s1="",s2="";
										string s = $2->id[0];
										for(int i=0;i<s.length();i++){
											if(s[i]=='*')
												s1 += s[i];
											else
												s2 += s[i];							
										}
									if(symbolTable[scope].find(s2)==symbolTable[scope].end())
																{	
																	symbolTable[scope][s2] = make_pair(($1)->token + s1, "FUNC");
																	funcTable[s2] = args;
																	args.clear();
																}
																else
																{

																	semanticError = true;
																	cout << "Multiple declaration of " << s2 << " at line no. " << line_no << 																		endl;
																}
									
									}
	;

FUNC_DECLARATOR
	: POINTER FUNC_DIRECT_DECLARATOR				{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"FUNC_DECLARATOR", "??");string s;for(int i=0;i<$1->id.size();i++){s+=$1->id[i];}s+=$2->id[0];$$->id.push_back(s);}
	| FUNC_DIRECT_DECLARATOR					{$$=$1;}
	;

FUNC_DIRECT_DECLARATOR
	: id '(' PARAM_LIST ')'						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("("));b.push_back($3);b.push_back(mkleaf(")"));$$=mknode(b,"FUNC_DIRECT_DEC", "??");$$->id.push_back($1->id[0]);}
	| id '(' ')'							{vector<node*> b;b.push_back($1);b.push_back(mkleaf("("));b.push_back(mkleaf(")"));$$=mknode(b,"FUNC_DIRECT_DEC", "??");$$->id.push_back($1->id[0]);}
	;

PARAM_LIST
	: PARAM_DEC							{$$=$1;}
	| PARAM_LIST COMMA PARAM_DEC						{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"PARAM_LIST", "??");}
	;

PARAM_DEC
	: DEC_SPECIFIERS DECLARATOR					{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"PARAM_DEC", "??");
										string s1="",s2="";
										string s = $2->id[0];
										for(int i=0;i<s.length();i++){
											if(s[i]=='*')
												s1 += s[i];
											else
												s2 += s[i];							
										}
									if(symbolTable.size()<scope+2){
										map<string,pair<string, string> > temp;
										symbolTable.push_back(temp);
									}
									if(symbolTable[scope+1].find(s2)==symbolTable[scope+1].end())
																{	
																	symbolTable[scope+1][s2] = make_pair(($1)->token + s1, "PARAM");
l = make_pair(($1)->token + s1,s2);
args.push_back(l);																	//prms.push_back(($1)->token + s1);
																}
																else
																{

																	semanticError = true;
																	cout <<"Line No.:"<<line_no <<":::Multiple declaration of " << s2 << endl;
																}
												
									}
	;

INNER
	: COLON STATEMENT_LIST THE_END					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"INNER", "??");}
	| COLON THE_END							{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"INNER", "??");}
	//| error								{cout << "Expected ':' in line number -> " << line_no << endl;vector<node*> b;b.push_back(mkleaf("error"));$$=mknode(b,"FUNC_DECLARATOR", "??");}
	;





/// STATEMENTS
STATEMENT_LIST
	: STATEMENT							{$$=$1;}
	| STATEMENT_LIST STATEMENT					{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"STATEMENT_LIST", "??");}
	;

STATEMENT
	: DECLARATION							{$$=$1;}
	| EXP_STATEMENT							{$$=$1;}
	| LOOP_STATEMENT						{$$=$1;}
	| SELECT_STATEMENT						{$$=$1;}
	| JUMP_STATEMENT						{$$=$1;}
	| WRITE_STATEMENT						{$$=$1;}
	| READ_STATEMENT SEMICOLON					{$$=$1;}
	;

LOOP_STATEMENT
	: LOOP EXPRESSION COLON STATEMENT_LIST THE_END			{vector<node*> b;b.push_back(mkleaf("LOOP"));b.push_back($2);b.push_back($3);b.push_back($4);b.push_back($5);$$=mknode(b,"LOOP_STATEMENT", "??");}
	| LOOP EXPRESSION COLON THE_END					{vector<node*> b;b.push_back(mkleaf("LOOP"));b.push_back($2);b.push_back($3);b.push_back($4);$$=mknode(b,"LOOP_STATEMENT", "??");}
	//| error								{cout << "Expected ':' in line number -> " << line_no << endl;vector<node*> b;b.push_back(mkleaf("error"));$$=mknode(b,"LOOP_STATEMENT", "??");}
	;

SELECT_STATEMENT
	: IF EXPRESSION COLON STATEMENT_LIST THE_END			{vector<node*> b;b.push_back(mkleaf("IF"));b.push_back($2);b.push_back($3);b.push_back($4);b.push_back($5);$$=mknode(b,"SELECT_STATEMENT", "??");}
	| IF EXPRESSION COLON STATEMENT_LIST ELSE_STATEMENT THE_END	{vector<node*> b;b.push_back(mkleaf("IF"));b.push_back($2);b.push_back($3);b.push_back($4);b.push_back($5);b.push_back($6);$$=mknode(b,"SELECT_STATEMENT", "??");}
	| IF EXPRESSION COLON THE_END					{vector<node*> b;b.push_back(mkleaf("IF"));b.push_back($2);b.push_back($3);b.push_back($4);$$=mknode(b,"SELECT_STATEMENT", "??");}
	| IF EXPRESSION COLON ELSE_STATEMENT THE_END	{vector<node*> b;b.push_back(mkleaf("IF"));b.push_back($2);b.push_back($3);b.push_back($4);b.push_back($5);$$=mknode(b,"SELECT_STATEMENT", "??");}
	;

ELSE_STATEMENT
	: else COLON STATEMENT_LIST					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"ELSE_STATEMENT", "??");}
	| elseif EXPRESSION COLON STATEMENT_LIST			{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);b.push_back($4);$$=mknode(b,"ELSE_STATEMENT", "??");}
	| elseif EXPRESSION COLON STATEMENT_LIST ELSE_STATEMENT		{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);b.push_back($4);b.push_back($5);$$=mknode(b,"ELSE_STATEMENT", "??");}
	| else COLON							{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"ELSE_STATEMENT", "??");}
	| elseif EXPRESSION COLON					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"ELSE_STATEMENT", "??");}
	| elseif EXPRESSION COLON ELSE_STATEMENT			{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);b.push_back($4);$$=mknode(b,"ELSE_STATEMENT", "??");}
	;

EXP_STATEMENT
	: SEMICOLON							{$$=$1;}
	| EXPRESSION SEMICOLON						{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"EXP_STATEMENT", "??");}
	;

JUMP_STATEMENT
	: RETURN SEMICOLON						{vector<node*> b;b.push_back(mkleaf("RETURN"));b.push_back($2);$$=mknode(b,"JUMP_STATEMENT", "??");}
	| BREAK SEMICOLON						{vector<node*> b;b.push_back(mkleaf("BREAK"));b.push_back($2);$$=mknode(b,"JUMP_STATEMENT", "??");}
	| RETURN EXP_LOGICAL_OR SEMICOLON					{vector<node*> b;b.push_back(mkleaf("RETURN"));b.push_back($2);b.push_back($3);$$=mknode(b,"JUMP_STATEMENT", "??");}
	;

WRITE_STATEMENT
	: WRITE EXP_LOGICAL_OR SEMICOLON						{vector<node*> b;b.push_back(mkleaf("WRITE"));b.push_back($2);b.push_back($3);$$=mknode(b,"WRITE_STATEMENT", "??");}
	;

READ_STATEMENT
	: READ ID 						{vector<node*> b;b.push_back(mkleaf("READ"));b.push_back(mkleaf("READ"));$$=mknode(b,"READ_STATEMENT", "??");  $$->id.push_back(yytext);int temp = scope+1;int check =0;	string x="";							//printSymbolTable();
//cout<<"current scope is "<<scope<<endl;
									while(temp--){
									if(symbolTable[temp].find(yytext)!=symbolTable[temp].end())
										{	
										$$->type = symbolTable[temp][yytext].first;
										x = symbolTable[temp][yytext].first;
										check =1; 	
break;
								}
						}	if(!check){
											cout << "Line No.: " << line_no << ":::Identifier '" << yytext << "' is undeclared in this scope." << endl;
										}
	else{
		if(x!="INT"){
			cout << "Line No.: " << line_no << ":::Identifier '" << yytext << "' should be INTEGER to READ." << endl;
}
}}
	;





/// EXPRESSIONS
ARG_EXP_LIST
	: EXP_ASSIGN							{vector<node*> b;b.push_back($1);$$=mknode(b,"ARG_EXP_LIST", "??");prms.push_back($1->type);}
	| ARG_EXP_LIST COMMA EXP_ASSIGN					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"ARG_EXP_LIST", "??");prms.push_back($3->type);}
	;

EXPRESSION 
	: EXP_ASSIGN							{$$=$1;}
	| EXPRESSION COMMA EXP_ASSIGN					{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"EXPRESSION", "??");}
	;

EXP_ASSIGN
	: EXP_LOGICAL_OR						{$$=$1;}
	| EXP_UNARY OP_ASSIGN EXP_ASSIGN				{vector<node*> b;b.push_back($1);b.push_back($2);b.push_back($3);$$=mknode(b,"EXP_ASSIGN", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '=' ." <<endl;}}
	;

EXP_LOGICAL_OR
	: EXP_LOGICAL_AND						{$$=$1;}
	| EXP_LOGICAL_OR OR EXP_LOGICAL_AND				{vector<node*> b;b.push_back($1);b.push_back(mkleaf("OR"));b.push_back($3);$$=mknode(b,"EXP_LOGICAL_OR", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator 'OR' ."<<endl; }}
	;

EXP_LOGICAL_AND
	: EXP_OR							{$$=$1;}
	| EXP_LOGICAL_AND AND EXP_OR					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("AND"));b.push_back($3);$$=mknode(b,"EXP_LOGICAL_AND", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator 'AND' ."<<endl; }}
	;

EXP_OR
	: EXP_XOR							{$$=$1;}
	| EXP_OR '|' EXP_XOR						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("|"));b.push_back($3);$$=mknode(b,"EXP_OR", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '|' ."<<endl; }}
	;

EXP_XOR
	: EXP_AND							{$$=$1;}
	| EXP_XOR '^' EXP_AND						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("^"));b.push_back($3);$$=mknode(b,"EXP_XOR", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '^' ."<<endl; }}
	;

EXP_AND
	: EXP_CMP_EQ							{$$=$1;}
	| EXP_AND '&' EXP_CMP_EQ					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("&"));b.push_back($3);$$=mknode(b,"EXP_AND", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '&' ."<<endl; }}
	;

EXP_CMP_EQ
	: EXP_CMP							{$$=$1;}
	| EXP_CMP_EQ CMP_EQ EXP_CMP					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("=="));b.push_back($3);$$=mknode(b,"EXP_CMP_EQ", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '==' ."<<endl; }}
	| EXP_CMP_EQ CMP_NEQ EXP_CMP					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("!="));b.push_back($3);$$=mknode(b,"EXP_CMP_EQ", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '!=' ."<<endl; }}
	;

EXP_CMP
	: EXP_SHIFT							{$$=$1;}
	| EXP_CMP CMP_LESS EXP_SHIFT					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("<"));b.push_back($3);$$=mknode(b,"EXP_CMP", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '<' ."<<endl; }}
	| EXP_CMP CMP_MORE EXP_SHIFT					{vector<node*> b;b.push_back($1);b.push_back(mkleaf(">"));b.push_back($3);$$=mknode(b,"EXP_CMP", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '>' ."<<endl; }}
	| EXP_CMP CMP_LE EXP_SHIFT					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("<="));b.push_back($3);$$=mknode(b,"EXP_CMP", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '<=' ."<<endl; }}
	| EXP_CMP CMP_GE EXP_SHIFT					{vector<node*> b;b.push_back($1);b.push_back(mkleaf(">="));b.push_back($3);$$=mknode(b,"EXP_CMP", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '>=' ."<<endl; }}
	;

EXP_SHIFT
	: EXP_ADD							{$$=$1;}
	| EXP_SHIFT LEFT_OP EXP_ADD					{vector<node*> b;b.push_back($1);b.push_back(mkleaf("<<"));b.push_back($3);$$=mknode(b,"EXP_SHIFT", "??");
										if($1->type == $3->type && $1->type == "INT"){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '<<' ."<<endl; }}
	| EXP_SHIFT RIGHT_OP EXP_ADD					{vector<node*> b;b.push_back($1);b.push_back(mkleaf(">>"));b.push_back($3);$$=mknode(b,"EXP_SHIFT", "??");
										if($1->type == $3->type && $1->type == "INT"){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '>>' ." <<endl;}}
	;

EXP_ADD
	: EXP_MULT							{$$=$1;}
	| EXP_ADD '+' EXP_MULT						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("+"));b.push_back($3);$$=mknode(b,"EXP_ADD", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '+' ."<<endl; }}
	| EXP_ADD '-' EXP_MULT						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("-"));b.push_back($3);$$=mknode(b,"EXP_ADD", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '-'." <<endl;}}
	;

EXP_MULT
	: EXP_CAST							{$$=$1;}
	| EXP_MULT '*' EXP_CAST						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("*"));b.push_back($3);$$=mknode(b,"EXP_MULT", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '*' ."<<endl; }}
	| EXP_MULT '/' EXP_CAST						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("/"));b.push_back($3);$$=mknode(b,"EXP_MULT", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '/' ."<<endl; }}
	| EXP_MULT '%' EXP_CAST						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("%"));b.push_back($3);$$=mknode(b,"EXP_MULT", "??");
										if($1->type == $3->type){$$->type = $1->type;}else{cout << "Line No.:" << line_no << ":::Mismatching operand types for operator '%' ."<<endl; }}
	;

EXP_CAST
	: EXP_UNARY							{$$=$1;}
	| '(' TYPE_SPEC ')' EXP_CAST					{vector<node*> b;b.push_back(mkleaf("("));b.push_back($2);b.push_back(mkleaf(")"));b.push_back($4);$$=mknode(b,"EXP_CAST", "??");$$->type=$2->token;}
	;

EXP_UNARY
	: EXP_POSTFIX							{$$=$1;}
	| INC EXP_UNARY							{vector<node*> b;b.push_back(mkleaf("INC"));b.push_back($2);$$=mknode(b,"EXP_UNARY", "??");
										if($1->type == "INT"){$$->type="INT";}else{cout << "Line No.: " << line_no << ":::Decrement operator('++') can't be used on a non-INT type." << endl;}}
	| DEC EXP_UNARY							{vector<node*> b;b.push_back(mkleaf("DEC"));b.push_back($2);$$=mknode(b,"EXP_UNARY", "??");
										if($1->type == "INT"){$$->type="INT";}else{cout << "Line No.: " << line_no << ":::Decrement operator('++') can't be used on a non-INT type." << endl;}}
	| UNARY_OP EXP_CAST						{vector<node*> b;b.push_back($1);b.push_back($2);$$=mknode(b,"EXP_UNARY", "??");
									if($2->type != "INT" && ($1->token == "+" | $1->token == "-" | $1->token == "~")){cout << "Line No.: " << line_no << ":::Unary operators('+')('-') and ('~') can't be used on a non-INT type." << endl;}else if($1->token == "*" && $2->type[$2->type.length()-1] == '*'){$$->type = $2->type.substr(0,$2->type.length()-1);}else if($1->token == "*" && $2->type[$2->type.length()-1] != '*'){cout << "Line No.: " << line_no << ":::Invalid type '" << $2->type <<"' for unary operator '*'" << endl;}else if($1->token == "&"){$$->type = $2->type+"*";}if($2->type != "BOOL" && $1->token == "NOT"){cout << "Line No.: " << line_no << ":::Invalid type '" << $2->type <<"' for unary operator 'NOT'" << endl;}else if($2->type == "BOOL" && $1->token == "NOT"){$$->type = $2->type;} }
	;
	
UNARY_OP
	: '&'								{$$=mkleaf("&");}
	| '*'								{$$=mkleaf("*");}
	| '+'								{$$=mkleaf("+");}
	| '-'								{$$=mkleaf("-");}
	| '~'								{$$=mkleaf("~");}
	| NOT								{$$=mkleaf("NOT");}
	;

EXP_POSTFIX
	: EXP_PRIMARY							{$$=$1;}						
	| EXP_POSTFIX '[' EXPRESSION ']'				{cout<<"I am here "<<endl;vector<node*> b;b.push_back($1);b.push_back(mkleaf("["));b.push_back($3);b.push_back(mkleaf("]"));$$=mknode(b,"EXP_POSTFIX","??");$$->type=$1->type;}
	| EXP_POSTFIX '(' ')'						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("("));b.push_back(mkleaf(")"));$$=mknode(b,"EXP_POSTFIX", "??");$$->type=$1->type;cout<<$1->token<<endl; current_func = $1->id[0];}
	| EXP_POSTFIX '(' ARG_EXP_LIST ')'				{vector<node*> b;b.push_back($1);b.push_back(mkleaf("("));b.push_back($3);b.push_back(mkleaf(")"));$$=mknode(b,"EXP_POSTFIX", "??");$$->type=$1->type;current_func = $1->id[0];
										if(funcTable[$1->id[0]].size() == prms.size()){
											for(int i=0;i<funcTable[$1->id[0]].size();i++){
												if(funcTable[$1->id[0]][i].first != prms[i]){
													cout << "Line No.:" << line_no << ":::Expected type '" <<funcTable[$1->id[0]][i].first << "' for argument "<< i+1 << " in function '" << $1->id[0] << "' but provided '" << prms[i] << "'." << endl; 
												}
											}
										}else{
											cout << "Line No.:" << line_no<<":::Incorrect number of arguments for " << $1->id[0] << endl;
										}prms.clear();
									}
	| EXP_POSTFIX '.' ID						{cout << yytext << " " << line_no << endl;vector<node*> b;b.push_back($1);b.push_back(mkleaf("."));b.push_back(mkleaf("ID"));$$=mknode(b,"EXP_POSTFIX", "??");
									if(symbolTable[scope].find(yytext)==symbolTable[scope].end())
																{	
																	cout << "Line No.: " << line_no << ":::Identifier " << yytext << " is undeclared in this scope." << endl;
																}
}
	| EXP_POSTFIX PTR_OP ID						{cout << yytext << " " << line_no << endl;vector<node*> b;b.push_back($1);b.push_back(mkleaf("PTR_OP"));b.push_back(mkleaf("ID"));$$=mknode(b,"EXP_POSTFIX", "??");
									if(symbolTable[scope].find(yytext)==symbolTable[scope].end())
																{	
																	cout << "Line No.: " << line_no << ":::Identifier " << yytext << " is undeclared in this scope." << endl;
																}
}
	| EXP_POSTFIX INC						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("INC"));$$=mknode(b,"EXP_POSTFIX", "??");
										if($1->type == "INT"){$$->type="INT";}else{cout << "Line No.: " << line_no << ":::Increment operator('++') can't be used on a non-INT type." << endl;}
									}
	| EXP_POSTFIX DEC						{vector<node*> b;b.push_back($1);b.push_back(mkleaf("DEC"));$$=mknode(b,"EXP_POSTFIX", "??");
										if($1->type == "INT"){$$->type="INT";}else{cout << "Line No.: " << line_no << ":::Decrement operator('--') can't be used on a non-INT type." << endl;}
									}
	;

EXP_PRIMARY
	: ID								{vector<node*> b;b.push_back(mkleaf("ID"));b[0]->id.push_back(yytext);$$=mknode(b,"EXP_PRIMARY", "??"); $$->id.push_back(yytext);int temp = scope+1;int check =0;								//printSymbolTable();
//cout<<"current scope is "<<scope<<endl;
									while(temp--){
								
										if(symbolTable[temp].find(yytext)!=symbolTable[temp].end())
											{
												
											$$->type = symbolTable[temp][yytext].first;
											check =1;
											 break;
											}
										    }	
										if(!check){
	
											cout << "Line No.: " << line_no << ":::Identifier '" << yytext << "' is undeclared in this scope." << endl;
											}
											}
	| CINT								{vector<node*> b;b.push_back(mkleaf("CINT"));$$=mknode(b, "EXP_PRIMARY", "??");$$->type = "INT";$$->id.push_back(yytext);}
	| CCHAR								{vector<node*> b;b.push_back(mkleaf("CCHAR"));$$=mknode(b, "EXP_PRIMARY", "??");$$->type = "CHAR";$$->id.push_back(yytext);}
	| CSTRING							{vector<node*> b;b.push_back(mkleaf("CSTRING"));$$=mknode(b, "EXP_PRIMARY", "??");$$->type = "STRING";$$->id.push_back(yytext);}
	| CFLOAT							{vector<node*> b;b.push_back(mkleaf("CFLOAT"));$$=mknode(b, "EXP_PRIMARY", "??");$$->type = "FLOAT";$$->id.push_back(yytext);}
	| TRUE								{vector<node*> b;b.push_back(mkleaf("TRUE"));$$=mknode(b, "EXP_PRIMARY", "??");$$->type = "BOOL";$$->id.push_back(yytext);}
	| FALSE								{vector<node*> b;b.push_back(mkleaf("FALSE"));$$=mknode(b, "EXP_PRIMARY", "??");$$->type = "BOOL";$$->id.push_back(yytext);}
	| '(' EXPRESSION ')'						{vector<node*> b;b.push_back(mkleaf("("));b.push_back($2);b.push_back(mkleaf(")"));$$=mknode(b,"EXP_PRIMARY", "??");}
	;





/// OTHER NON-TERMINALS
//STCLASS
//	: EXTERNAL							{vector<node*> b;b.push_back(mkleaf("EXTERNAL"));$$=mknode(b,"STCLASS", "??");}
//	| STATIC							{vector<node*> b;b.push_back(mkleaf("STATIC"));$$=mknode(b,"STCLASS", "??");}
//	;


TYPE_SPEC
	: VOID								{$$=mkleaf("VOID");}
	| INT								{$$=mkleaf("INT");}
	| FLOAT								{$$=mkleaf("FLOAT");}
	| CHAR								{$$=mkleaf("CHAR");}
	| BOOL								{$$=mkleaf("BOOL");}
	//| STRUCT_DEC							{vector<node*> b;b.push_back($1);$$=mknode(b,"TYPE_SPEC", "??");}
	;

else	: ELSE								{vector<node*> b;b.push_back(mkleaf("ELSE"));$$=mknode(b,"else", "??");pop();}
	;
elseif	: ELSEIF							{vector<node*> b;b.push_back(mkleaf("ELSEIF"));$$=mknode(b,"elseif", "??");pop();}
	;
id 
	: ID  								{vector<node*> b;b.push_back(mkleaf("ID"));b[0]->id.push_back(yytext);$$=mknode(b,"id", "??");$$->id.push_back(yytext);}
	;

SEMICOLON
	: ';'								{vector<node*> b;b.push_back(mkleaf(";"));$$=mknode(b,"SEMICOLON", "??");}
	//| error								{cout << "gotcha" << endl;vector<node*> b;b.push_back(mkleaf("error"));$$=mknode(b,"SEMICOLON", "??");}
	;

COMMA
	: ','								{vector<node*> b;b.push_back(mkleaf(","));$$=mknode(b,"COMMA", "??");}
	//| error ';'
	;

OP_ASSIGN
	: '='								{vector<node*> b;b.push_back(mkleaf("="));$$=mknode(b,"OP_ASSIGN", "??");}
	//| error
	;

CBRAC
	: '{'								{vector<node*> b;b.push_back(mkleaf("{"));$$=mknode(b,"CBRAC", "??");}
	//| error '}'
	;

CBRAC_CLOSE
	: '}'								{vector<node*> b;b.push_back(mkleaf("}"));$$=mknode(b,"CBRAC_CLOSE", "??");}
	//| error ';'
	;

COLON
	: ':'								{vector<node*> b;b.push_back(mkleaf(":"));$$=mknode(b,"COLON", "??");
									scope++;
									if(symbolTable.size()<scope+1){
										map<string,pair<string,string> > temp;
										symbolTable.push_back(temp);
									}
									}
	| error								{cout << "Expected ':' in line number -> " << line_no << endl;vector<node*> b;b.push_back(mkleaf("error"));$$=mknode(b,"COLON", "??");}
	;
THE_END
	: END								{vector<node*> b;b.push_back(mkleaf("END"));$$=mknode(b,"THE_END", "??");
									symbolTable.pop_back();
									scope--;
									
									}
	//| error '\n'
	;

%%

//extern char yytext[];
void printSymbolTable(){
	//cout << "\n\n\n+++++++++++++++++++++++++ SYMBOL TABLE ++++++++++++++++++++++++++++" << endl;
	for(int i = 0 ; i< symbolTable.size(); i++ ){
		cout<<"Scope "<<i<<endl;
		for ( map<string,pair<string,string> >::iterator it = symbolTable[i].begin() ; it!= symbolTable[i].end() ; it++){
			cout<<it->first<<" "<<it->second.first << " " << it->second.second <<endl;
		}
	}
}

void printFuncTable(){
	//cout << "\n\n\n++++++++++++++++++++++++++ FUNC TABLE +++++++++++++++++++++++++++++" << endl;
	for ( map<string,vector<pair<string,string> > >::iterator it = funcTable.begin() ; it!= funcTable.end() ; it++){
		cout<< "func Name: " << it->first << endl;
		for(int i=0;i<it->second.size();i++){
			cout << "	" << it->second[i].first ;
			cout<< " " <<it->second[i].second;			
		}
		cout << endl;
	}
}

node *mknode(vector<node*> v, string token, string lol){
	
	node *newnode = new node;
	string newstr = token;
	
	newnode->token = newstr;
	//some error found here
	newnode->children=v;
	return(newnode);
}

node *mkleaf(string token)
{
	node *newnode= new struct node;
	string newstr = token;
	newnode->token = newstr;
	vector<node*> v1;
	newnode->children= v1;
    	return(newnode);
}


void printtree(node *tree)
{
	if(tree!=NULL){
	     cout << tree->token << endl;
    	unsigned int j;
	  for(j=0;j<tree->children.size();j++)
	  {
	       printtree(tree->children[j]);
	  }
	}
}


void pop()
{
//cout<<"popping up at line : "<<line_no<<endl;
symbolTable.pop_back();
									scope--;

}


string get_label()
{
	static int label=0;
	std::stringstream ss;
	ss<<++label;
	string s1="label"+ss.str();
	return s1;
}

string get_register()
{
	static int r=0;
	std::stringstream ss;
	ss<<++r;
	string s1="r"+ss.str();
	return s1;
}

string ThreeAdressCode(node* n)
{	
	fstream out;
	out.open("MIPS/TAC.txt",fstream::in | fstream::out |fstream::app);
	
	if(n==NULL)
	{
	out.close();
		return "";
	}
	else if(n->token=="SELECT_STATEMENT")
	{
		
		string r1=ThreeAdressCode((n->children)[1]);
		string label1= get_label();
		//string label2= get_label();
		out<<"ifZ "<<r1<<" goto "<<label1<<endl;
		string z = get_label();
		iflabels.push_back(z);
		int i=3;
		int flag = 0;
		while(1){
			//cout << "hi" << endl;
			if(((n->children)[i])->token != "THE_END"){
				if(((n->children)[i])->token == "ELSE_STATEMENT"){
					
					out<<"goto "<<z<<endl;
					out<<label1 << ":" <<endl;
					flag = 1;
				}	
				ThreeAdressCode((n->children)[i]);
			}else{
				if(flag == 0)
					out<<label1 << ":" <<endl;
				iflabels.pop_back();				
				break;
			}
			i++;
		}
		out<<z<<":"<<endl;
		out.close();
		return "";
	}
	else if(n->token == "ELSE_STATEMENT")
	{

		string label1= get_label();
		
		if(((n->children)[0])->token=="elseif"){
			string r1="";
			//if((n->children).size()==3)
				r1=ThreeAdressCode(((n->children)[1]));
			out<<"ifZ "<<r1<<" goto "<<label1<<endl;
			//cout<<label1<<endl;
            		if((n->children).size()==4){
				out<<"goto "<<*(iflabels.end()-1)<<endl;
				out<<label1 << ":" <<endl;
			    	ThreeAdressCode((n->children)[3]);
				
			}
			if((n->children).size()==5){
				
			    	ThreeAdressCode((n->children)[3]);
				//out<<"goto "<<label1<<endl;
				out<<"goto "<<*(iflabels.end()-1)<<endl;
				out<<label1 << ":" <<endl;
			    	ThreeAdressCode((n->children)[4]);
			}

		}
		if(((n->children)[0])->token=="else"){
			string r1="";
			
			if((n->children).size()==3){
			    	ThreeAdressCode((n->children)[2]);
			
			}
		//out<<"goto "<<*(iflabels.end()-1)<<endl;

		}
	
	//out<<"label2:"<<endl;
		out.close();
		return "";	
	}

	else if(n->token=="LOOP_STATEMENT")
	{
		//cout<<"yo animesh2"<<endl;
		string label1= get_label();
		out<<label1<<":"<<endl;
		string label2= get_label();
		string label3= get_label();
		loopStack.push_back(label3);
        string r1=ThreeAdressCode((n->children)[1]);
        out<<"if "<<r1<<" goto "<<label2<<endl;
        out<<"goto "<<label3<<endl;
        out<<label2<<":"<<endl;
        if((n->children).size()==5)
        	ThreeAdressCode((n->children)[3]);
        out<< "goto "<<label1<<endl;
        out<<label3<<":"<<endl;
	if(find(loopStack.begin(),loopStack.end(),label3) != loopStack.end())
		loopStack.pop_back();
	out.close();
        return "";
	}

	else if(n->token=="JUMP_STATEMENT")
	{
		if((n->children[0])->token == "BREAK"){
			if(!loopStack.empty()){
				out << "goto " << *(loopStack.end()-1) << endl;
				loopStack.pop_back();			
			}else{
				out << "Can't use 'break' outside a Loop" << endl;
			}
		}
		if((n->children[0])->token == "RETURN" && n->children.size()==3){
			if(symbolTable[0][currFunc].first != n->children[1]->type){
				cout << "Return type of function "<<currFunc<<" does not match"<< endl;		
			}
			else{
				//out << "Can't use 'break' outside a Loop" << endl;
				string a = get_register();
				a = ThreeAdressCode(n->children[1]);
				out<<"return "<<a<<endl;
				returnflag = 1;
			}
		}
		else if((n->children[0])->token == "RETURN" && n->children.size()==2)
		{
			out<<"return"<<endl;returnflag = 1;
		}
	}

	else if(n->token=="EXP_ASSIGN" && (n->children).size()==3)
	{
	
		out<<ThreeAdressCode((n->children)[0])<<" = "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();
		return "";
	}

	else if(n->token=="INIT_DEC" )
	{
		if(n->children.size()==3)
		{
		out<<ThreeAdressCode((n->children)[0])<<" = ";
		out<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();
		return "";
		}
		else{
		out<<ThreeAdressCode((n->children)[0])<<" = 0"<<endl;
		out.close();
		return "";
		}
	}
	
	else if(n->token=="id")
	{

		out.close();return n->id[0];
	}	

   else  if(n->token=="EXP_OR" && (n->children).size()==3)
	{
	
		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" | "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_ADD" && (n->children).size()==3)
	{
	
		string r1 = get_register();
		out<<r1 << " = " <<ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_MULT" && (n->children).size()==3)
	{

		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_LOGICAL_OR" && (n->children).size()==3)
	{

		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_LOGICAL_AND" && (n->children).size()==3)
	{

		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_XOR" && (n->children).size()==3)
	{

		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_CMP_EQ" && (n->children).size()==3)
	{

		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_CMP" && (n->children).size()==3)
	{

		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_SHIFT" && (n->children).size()==3)
	{

		string r1 = get_register();
		out<< r1 << " = " << ThreeAdressCode((n->children)[0])<<" "<<((n->children)[1])->token<<" "<<ThreeAdressCode((n->children)[2])<<endl;
		out.close();return r1;
	}
	else if(n->token=="EXP_PRIMARY")
	{

		//cout<<(n->children)[0]->id.size()<<endl;
		//cout << "id[0] = " << n->id[0] << " id.size = " << n->children.size() << endl;
		
		if(n->id[0]=="true"){
			out.close();return "1";}
		else if	(n->id[0]=="false"){
			out.close();return "0";}	
		out.close();return n->id[0];
	}
	else if(n->token=="DIRECT_DEC" && (n->children).size()==1)
	{

		out.close();return ((n->children)[0])->id[0];
	}
	else if(n->token=="EXP_POSTFIX" && ((n->children)[1])->token=="[")
	{
		string r3= get_register();
        string r4= get_register();
        string r1 = get_register();
        string r6= get_register();
        string t1 = ThreeAdressCode((n->children)[2]);
        out<<r3<<" = "<<t1<<endl;
        out<<r4<<" = 4" <<endl; 
        out<<r1<<"= "<< r4<<" * " <<r3<<endl;
        out<<r6<<" = "<<ThreeAdressCode((n->children)[0])<<" + "<<r1<<endl;
		out.close();return "*("+r6+")";
	}
	else if(n->token=="FUNC_DIRECT_DEC")
	{
		
		
		out<<ThreeAdressCode((n->children)[0])<<":"<<endl;
		out<<"FuncStart"<<endl;
		returnflag = 0;
		currFunc = ThreeAdressCode((n->children)[0]);
		string q = n->children[0]->id[0];
		for(int i =0;i<funcTable[q].size();i++){
			out<<"_a_"<<funcTable[q][i].second<<endl;
		}
		
	}

	else if(n->token == "EXP_POSTFIX" && (n->children)[1]->token=="(")
	{
		ThreeAdressCode((n->children)[2]);			
		int s = argStack.size();
		//cout<<s<<endl;
			s = (s+1)/2;
		while(!argStack.empty())
		{
			out<<"push_params "<< *(argStack.end()-1) <<endl;
			argStack.pop_back();if(!argStack.empty())argStack.pop_back();
		}
		string abcd = "",r1="";
		
			 r1 = get_register();
			abcd = "L_Call "+n->children[0]->id[0];
			out<< r1 <<" = L_Call "<<n->children[0]->id[0]<<endl;
			
		
		if(s>0)
		out<<"Pop_Params "<<s<<endl;
		out.close();return r1;
	}
	else if(n->token == "EXP_POSTFIX" && (n->children)[1]->token=="INC")
	{
		
		string l = ThreeAdressCode((n->children)[0]);
		out<<l<<" = "<<l<<" + 1"<<endl;			
		
		out.close();
		return l;
	}
	else if(n->token == "EXP_POSTFIX" && (n->children)[1]->token=="DEC")
	{
		//string w = get_label();
		string l = ThreeAdressCode((n->children)[0]);
		out<<l<<" = "<<l<<" - 1"<<endl;			
		out.close();
		return l;
	}
	else if(n->token == "EXP_UNARY" )
	{
		//string w = get_label();
	string r1 = get_register();
		if(n->children[0]->token == "+")
		{
			out<<r1<<" = "<<ThreeAdressCode((n->children)[1])<<endl;
			
		}
		else if(n->children[0]->token == "-")
		{
			out<<r1<<" = 0 - "<<ThreeAdressCode((n->children)[1])<<endl;
		}
		else if(n->children[0]->token == "NOT")
		{
			out<<r1<<" = 1 - "<<ThreeAdressCode((n->children)[1])<<endl;
		}
		return r1;
		
	}
	else if(n->token == "ARG_EXP_LIST")
	{
		if(n->children.size()==1)
		{
			argStack.push_back(ThreeAdressCode(n->children[0]));
			
		}
		else
		{
			argStack.push_back(ThreeAdressCode(n->children[0]));
			argStack.push_back(ThreeAdressCode(n->children[2]));
		}
	}
	else if(n->token == "INNER")
	{
		if(n->children.size()==3)
		{
		ThreeAdressCode(n->children[1]);
		}
	//out<<"return 0"<<endl;
		if(returnflag==0)
		{cout<<"No Return Statement found for "<<currFunc<<endl;}
		out<<"FuncEnd"<<endl;
	}
	else if(n->token == "WRITE_STATEMENT")
	{	
		out<<"echo ";
		string s1 = ThreeAdressCode(n->children[1]);
		out<<s1<<endl;
	}
	else if(n->token == "READ_STATEMENT")
	{	
		out<<"read "<<n->id[0]<<endl;

	}	
	else
        {
		

            for(int i=0;i<(n->children).size();i++){
			ThreeAdressCode((n->children)[i]);
		}
	out.close();return "";
        }

	out.close();return "";
    
}





void yyerror(char *s)
{
}


