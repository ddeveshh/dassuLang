Digit			[0-9]
Letter			[a-zA-Z]
LetterU			[a-zA-Z_]
Exp			[Ee][+-]?{D}+


%{
#include<iostream>
#include<vector>
#include<stdio.h>
#include<algorithm>
enum{
	IDENTIFIER=	1,
	EndOFile =	2,
	LABEL	=	3,
	FUNCTION=	4,
	OTH=		5,
	OT=		6
};
using namespace std;
vector<string> var;
%}
%%
[l][a][b][e][l][0-9]*[:] 		{return(LABEL);}
[l][a][b][e][l][0-9]	 		{return(OTH);}
"FuncStart" 		 		{return(OTH);}
"FuncEnd" 		 		{return(OTH);}
"return" 		 		{return(OTH);}
"L_Call" 			 	{return(OT);}
"push_params" 		 		{return(OT);}
"Pop_Params" 		 		{return(OTH);}
"echo" 		 			{return(OTH);}
"read"	 		 		{return(OTH);}
[i][f] 			 		{return(OT);}
[i][f][Z] 			 	{return(OT);}
[g][o][t][o] 		 		{return(OT);}

{LetterU}({LetterU}|{Digit})*[:] 	{return(FUNCTION);}
{LetterU}({LetterU}|{Digit})* 		{return(IDENTIFIER);}
<<EOF>> 				{return(EndOFile);}
(.|\n) 					{return(OTH);}
%%
int yywrap()
{
	return 1;
}
int main()
{
	int flg,n=1,flag =0;
	//freopen("mid.txt","w",stdout);
	//
	while(1)
	{
		
		flg=yylex();
		
		 if(flg==IDENTIFIER)
		{	
			if(yytext[0] == 'l'){
		;
			}
			//else if(flag != 1){
				if(find(var.begin(),var.end(),yytext) == var.end()){
					//printf("%0.*s\n",yyleng,yytext);
					var.push_back(yytext);
					cout<<yytext<<endl;
				}	n++;		
			//}else{
			//	flag = 0;n++;
			//}
			
		}
		else if(flg==EndOFile)
		{
			break;
		}
		else if(flg==FUNCTION)
		{
			//printf("@%s\n",yytext);
			cout<<"@"<<yytext<<endl;
			var.clear();
		}
		else if(flg == OT){
			flag = 1;
		}
	}
	return 0;
}
