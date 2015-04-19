#include <bits/stdc++.h>
#include <string>
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <map>
#include <sstream>

using namespace std;


stack <string> presentFuncStack;
int arg_count = 0; int count_label=0; string finalCode= ""; string presentFunc= "";
string get_label()
{
	static int label=0;
	std::stringstream ss;
	ss<<++label;
	string s1="_lb"+ss.str();
	return s1;
}

stack <int> nparamstack;
map<string,map<string,int> > functionVariables;
map<string,int> totalvariables;
map<string,int> values;
vector<string> globals;

string get_register()
{
	static int r=0;
	std::stringstream ss;
	ss<<++r;
	string s1="r"+ss.str();
	return s1;
}

int find_variable(string variable)
{
	//cout<<"hello "<<presentFunc<<endl;
	if(find(globals.begin(),globals.end(), variable) != globals.end()){
		return -1001;
	}
	else if(functionVariables[presentFunc].find(variable)!=functionVariables[presentFunc].end())
	{
		
		return functionVariables[presentFunc][variable];
	}
	
	else
	{
		return -1000;
	}
}

int get_integer(string s2)
{
	stringstream ss(s2);
    int x;
    ss >> x;
    return x;
}

string modify(string s)
{
	if(s.find("main")!=std::string::npos)
		return "main:";
	else
		return s;
}

string get_string(int a1)
{
	stringstream ss;
	ss<<a1;
	return ss.str();
}

string findType(string s)
{
	if(s.find("FuncStart")!=std::string::npos)
		return "BEGINFUNC";
	else if(s.find("FuncEnd")!=std::string::npos)
		return "ENDFUNC";
	else if(s.find("echo")!=std::string::npos)
		return "ECHO";
	else if(s.find("read")!=std::string::npos)
		return "READ";
	else if(s.find("return")!=std::string::npos)
		return "RETURN";
	else if(s.find("push_params")!=std::string::npos)
		return "PUSHPARAMS";
	else if(s.find("Pop_Params")!=std::string::npos)
		return "POPPARAMS";
	else if(s.find("L_Call ")!=std::string::npos)
		return "CALL";
	else if(s[0]=='g'||s[1]=='o'||s[2]=='t'||s[3]=='o')
		return "GOTOLABEL";
	else if(s.find("label")==0)
		return "LABEL";
	else if(s.find("ifZ ")!=std::string::npos)
		return "IFZ";
	else if(s.find("if ")!=std::string::npos)
		return "IF";
	else if(s.find(":")!=std::string::npos)
		return "FUNC";
	else if(s.find("+")!=std::string::npos)
		return "ADD";
	else if(s.find("-")!=std::string::npos)
		return "SUB";
	else if(s.find("*")!=std::string::npos)
		return "MULT";
	else if(s.find("/")!=std::string::npos)
		return "DIV";
	else if(s.find("&")!=std::string::npos || s.find("&&")!=std::string::npos)
		return "AND";
	else if(s.find("|")!=std::string::npos || s.find("||")!=std::string::npos)
		return "OR";
	else if(s.find("^")!=std::string::npos)
		return "XOR";
	else if(s.find("%%")!=std::string::npos)//check
		return "MOD";
	else if(s.find("<=")!=std::string::npos)
		return "LEQ";
	else if(s.find(">=")!=std::string::npos)
		return "GEQ";
	else if(s.find("==")!=std::string::npos)
		return "EQEQ";
	else if(s.find("!=")!=std::string::npos)
		return "NEQ";
	else if(s.find(">>")!=std::string::npos)
		return "RSH";
	else if(s.find("<<")!=std::string::npos)
		return "LSH";
	else if(s.find("<")!=std::string::npos)
		return "LESSTHAN";
	else if(s.find(">")!=std::string::npos)
		return "GREATERTHAN";
	else if(s.find("write")!=std::string::npos)
		return "WRITE";
	else if(s.find("=")!=std::string::npos)
		return "ASSGN";
	return "GADBAD";
}


int main()
{
	ifstream file("vars.txt",ios::in);
	int k=1,m=0;
	string func;
	int flag = 0;
	string s1;
	while(file>>s1)
	{	
         if(s1[0]=='@')
         {
         	k = 1;
		m = -2;
         	string s2(s1);
		func= s2.substr(1);
		map <string,int> varAdd;
         	functionVariables.insert(make_pair(func,varAdd));
		values[func] = 0;

         }
         else if ( s1.find("_a_")!=string::npos)
		 {
			values[func]++;
			//cout<<func<<endl;
			functionVariables[func].insert(make_pair(s1.substr(3), m--));
		 }
         else
		 {
			
			if(functionVariables[func].find(s1)==functionVariables[func].end())
			{
				
				functionVariables[func].insert(make_pair(s1, k++));
				//cout<<"yosxkank "<<s1<<endl;
			}
			
		 }

	}
    file.close();
    string line = "";
	ifstream file1("TAC.txt", ios::in);
	//finalCode+= ".text\n" ;
	finalCode+= ".data\n" ;
	finalCode+= "space: .asciiz \"\\n\"";
	finalCode+= "\n";
  	while(getline(file1,line))
  	{
  		string l1,l2;
  		string temporary1="";
		string splitstring[10];
		char* p;int i=0,k=0;
		if(findType(line)!="LABEL" && findType(line)!="FUNC" && flag==0){
			p = strtok((char*)(line.c_str())," ,\n"); i=0;
        		while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			if(splitstring[2] == "")
				splitstring[2] = "0";
			finalCode += splitstring[0] + ": .word " + splitstring[2] + "\n";
			globals.push_back(splitstring[0]);
		}else if(flag == 0){
			finalCode+= ".text\n" ;
			flag = 1;
		}
	if(flag == 1){
        if(findType(line)=="ADD")
        {
        	p = strtok((char*)(line.c_str())," ,\n"); i=0;
        	while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0 ,"+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1 ,"+get_string(-4*k+4)+"($fp) \n";
			}
			
			finalCode+= "add $t2, $t0, $t1 \n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{	finalCode += "sw $t2, "+splitstring[0]+" \n";
			}
			else{
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest}

        }
}

       else if(findType(line)=="SUB")
        {
        	p = strtok((char*)(line.c_str())," ,\n"); i=0;
        	while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0 ,"+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1 ,"+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "sub $t2, $t0, $t1 \n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
			finalCode += "sw $t2, "+splitstring[0]+"\n"; //reg source RAM dest	
			}
			else{
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest}

        }
	}
        else if(findType(line)=="MULT")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "mult $t0, $t1 \n";
			finalCode+= "mflo $t2 \n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
				finalCode += "sw $t2, "+splitstring[0]+" \n"; //reg source RAM dest
			else
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			
        }

        else if(findType(line)=="DIV")
        {
        	i=0;
				p = strtok((char*)(line.c_str())," ,\n");
				while(p!=NULL)
				{
					splitstring[i++] = p;
					p = strtok(NULL," ,\n");
				}
				k = find_variable(splitstring[2]);
				if(k==-1000)
				{
					finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
				}
				else if(k==-1001)
				{
					finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
				}
					else
				{
					finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
				}
				k = find_variable(splitstring[4]);
				if(k==-1000)
				{
					finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
				}
				else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
				else
				{
					finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
				}
				finalCode+= "div $t0, $t1 \n";
				finalCode+= "mflo $t2 \n";
				k = find_variable(splitstring[0]);
				if(k==-1001)
				finalCode += "sw $t2, "+ splitstring[0]+ "\n";
				else
				finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
				break;
        }


        else if(findType(line)=="MOD")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "div $t0, $t1 \n";
			finalCode+= "mfhi $t2";
			k = find_variable(splitstring[0]);
			 if(k==-1001)
			{
				finalCode+= "sw $t2 ,"+splitstring[0] + "\n";
			}
			else
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
        }

        else if(findType(line)=="LESSTHAN")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[2] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t2, "+splitstring[4] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t2 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t2, "+get_string(-4*k+4)+"($fp) \n";
			}
			
			l1 = get_label();
			l2 = get_label();
			finalCode+= "blt $t1,$t2,"+l1+" \n";
			finalCode+="li $t7, 0\n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode+="b "+l2+" \n";
			finalCode += l1+":\n";
			finalCode+="li $t7, 1\n";
			k = find_variable(splitstring[0]);
			 if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}
else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode += l2+":\n";
        }

        else if(findType(line)=="GREATERTHAN")
        {
        	i=0;
				p = strtok((char*)(line.c_str())," ,\n");
				while(p!=NULL)
				{
					splitstring[i++] = p;
					p = strtok(NULL," ,\n");
				}
				k = find_variable(splitstring[2]);
				if(k==-1000)
				{
					finalCode+= "li $t1, "+splitstring[2] + "\n"; //load immediate
				}
				else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[2] + "\n"; //load immediate
			}
				else
				{
					finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
				}
				k = find_variable(splitstring[4]);
				if(k==-1000)
				{
					finalCode+= "li $t2, "+splitstring[4] + "\n"; //load immediate
				}
			else if(k==-1001)
			{
				finalCode+= "lw $t2 ,"+splitstring[4] + "\n"; //load immediate
			}
				else
				{
					finalCode+= "lw $t2, "+get_string(-4*k+4)+"($fp) \n";
				}
				
				l1 = get_label();
				l2 = get_label();
				finalCode+= "bgt $t1,$t2,"+l1+" \n";
				finalCode+="li $t7, 0\n";
				k = find_variable(splitstring[0]);
				 if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}
			else
				finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
				finalCode+="b "+l2+" \n";
				finalCode += l1+":\n";
				finalCode+="li $t7, 1\n";
				k = find_variable(splitstring[0]);
		 if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}
			else
				finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
				finalCode += l2+":\n";
        }
        else if(findType(line)=="LEQ")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t2, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t2 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t2, "+get_string(-4*k+4)+"($fp) \n";
			}
			
			l1 = get_label();
			l2 = get_label();
			finalCode+= "ble $t1,$t2,"+l1+" \n";
			finalCode+="li $t7, 0\n";
			k = find_variable(splitstring[0]);
			 if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}
			else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode+="b "+l2+" \n";
			finalCode += l1+":\n";
			finalCode+="li $t7, 1\n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode += l2+":\n";
        }

        else if(findType(line)=="GEQ")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t2, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t2 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t2, "+get_string(-4*k+4)+"($fp) \n";
			}
			
			l1 = get_label();
			l2 = get_label();
			finalCode+= "bge $t1,$t2,"+l1+" \n";
			finalCode+="li $t7, 0\n";
			k = find_variable(splitstring[0]);
			 if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}
			else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode+="b "+l2+" \n";
			finalCode += l1+":\n";
			finalCode+="li $t7, 1\n";
			k = find_variable(splitstring[0]);
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode += l2+":\n";
        }
        else if(findType(line)=="EQEQ")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t2, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t2 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t2, "+get_string(-4*k+4)+"($fp) \n";
			}
			
			l1 = get_label();
			l2 = get_label();
			finalCode+= "beq $t1,$t2,"+l1+" \n";
			finalCode+="li $t7, 0\n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode+="b "+l2+" \n";
			finalCode += l1+":\n";
			finalCode+="li $t7, 1\n";
			k = find_variable(splitstring[0]);
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode += l2+":\n";
        }
        else if(findType(line)=="NEQ")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[2] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t2, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t2 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t2, "+get_string(-4*k+4)+"($fp) \n";
			}
			
			l1 = get_label();
			l2 = get_label();
			finalCode+= "bne $t1,$t2,"+l1+" \n";
			finalCode+="li $t7, 0\n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode+="b "+l2+" \n";
			finalCode += l1+":\n";
			finalCode+="li $t7, 1\n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t7 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t7, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
			finalCode += l2+":\n";
        }
        else if(findType(line)=="AND")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "and $t2, $t0, $t1 \n";
			k = find_variable(splitstring[0]);
		 if(k==-1001)
			{
				finalCode+= "sw $t2 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
        }

        else if(findType(line)=="OR")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "or $t2, $t0, $t1 \n";
			k = find_variable(splitstring[0]);
			 if(k==-1001)
			{
				finalCode+= "sw $t2 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n"; //reg source RAM dest
        }

        else if(findType(line)=="XOR")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "xor $t2, $t0, $t1 \n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t2 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n";
        }

        else if(findType(line)=="LSH")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "sll $t2, $t0, $t1 \n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t1 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t2 ,"+get_string(-4*k+4)+"($fp) \n"; 
        }
        else if(findType(line)=="RSH")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[4]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[4] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[4] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "srl $t2, $t0, $t1 \n";
			k = find_variable(splitstring[0]);
			if(k==-1001)
			{
				finalCode+= "sw $t2 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t2, "+get_string(-4*k+4)+"($fp) \n";
        }
 else if(findType(line)=="IF")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			finalCode+="li $t0, 1 \n";
			k = find_variable(splitstring[1]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[1] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[1] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+="beq $t1,$t0,"+splitstring[3].substr(0,splitstring[3].length())+"\n";
        }
	else if(findType(line)=="IFZ")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			finalCode+="li $t0, 0 \n";
			k = find_variable(splitstring[1]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[1] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[1] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+="beq $t1,$t0,"+splitstring[3].substr(0,splitstring[3].length())+"\n";
        }
        else if(findType(line)=="GOTOLABEL")
        {
    		i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			finalCode+= "b "+splitstring[1].substr(0,splitstring[1].length())+"\n";
        }
        else if(findType(line)=="ASSGN")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[2]);
			if(k==-1000)
			{
				finalCode+= "li $t0, "+splitstring[2] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t0 ,"+splitstring[2] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t0, "+get_string(-4*k+4)+"($fp) \n";
			}
			k = find_variable(splitstring[0]);
			 if(k==-1001)
			{
				finalCode+= "sw $t0 ,"+splitstring[0] + "\n"; //load immediate
			}else
			finalCode += "sw $t0 ,"+get_string(-4*k+4)+"($fp) \n";
        }
        else if(findType(line)=="LABEL")
        {
        	finalCode+= line +"\n";
        }
       

	else if(findType(line)=="PUSHPARAMS")
	{	
		i=0;
		p = strtok((char*)(line.c_str())," ,\n");
		p = strtok(NULL," ,\n");
		string arg="";
		while(p!=NULL)
			{
				splitstring[i++] = p;
				arg = p;
				p = strtok(NULL," ,\n");
			}
		k = find_variable(splitstring[0]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[0] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[0] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "sw $t1,0($sp) \n";
			finalCode+= "li $t7,4\n";
			finalCode+= "sub $sp,$sp,$t7 \n";
		arg_count++;
	
	}
	else if(findType(line)=="POPPARAMS")
	{
		i=0;
		p = strtok((char*)(line.c_str())," ,\n");
		p = strtok(NULL," ,\n");
		string arg="";
		while(p!=NULL)
			{
				splitstring[i++] = p;
				arg = p;
				p = strtok(NULL," ,\n");
			}
		nparamstack.pop();
		arg_count = 0;
	
	}
	else if(findType(line)=="ECHO")
	{
		i=0;
		p = strtok((char*)(line.c_str())," ,\n");
		p = strtok(NULL," ,\n");
		string arg="";
		while(p!=NULL)
			{
				splitstring[i++] = p;
				arg = p;
				p = strtok(NULL," ,\n");
			}
		k = find_variable(splitstring[0]);
			if(k==-1000)
			{
				finalCode+= "li $a0, "+splitstring[0] + "\n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+= "lw $a0 ,"+splitstring[0] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $a0, "+get_string(-4*k+4)+"($fp) \n";
			}
		finalCode+="li $v0,1\n";
  		finalCode+="syscall\n";
		finalCode+="addi $v0, $zero, 4\n";
		finalCode+="la $a0, space\n";
		finalCode+="syscall\n";
	
	}
	else if(findType(line)=="READ")
	{
		i=0;
		p = strtok((char*)(line.c_str())," ,\n");
		p = strtok(NULL," ,\n");
		string arg="";
		while(p!=NULL)
			{
				splitstring[i++] = p;
				arg = p;
				p = strtok(NULL," ,\n");
			}
		k = find_variable(splitstring[0]);
			if(k==-1000)
			{
				finalCode+= "ERROR \n"; //load immediate
			}
			else if(k==-1001)
			{
				finalCode+="li $v0,5\n";
  				finalCode+="syscall\n";
				finalCode+= "sw $v0 ,"+splitstring[0] + "\n"; //load immediate
			}
			else
			{
				finalCode+="li $v0,5\n";
  				finalCode+="syscall\n";
				finalCode+="sw $v0, "+get_string(-4*k+4)+"($fp) \n";
			}
		
	
	}


        else if(findType(line)=="CALL")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			nparamstack.push(arg_count);
			finalCode+= "sw $ra,0($sp) \n";
			finalCode+= "li $t7,4\n";
			finalCode+= "sub $sp,$sp,$t7 \n"; //push $ra to stack
			finalCode+= "jal "+splitstring[3]+"\n";
			k = find_variable(splitstring[0]);
			finalCode+= "sw $v0, "+get_string(-4*k+4)+"($fp) \n";
			finalCode += "lw $ra 4($sp)\n"; // pop $ra
			finalCode+= "li $t7,4\n";
			finalCode+= "add $sp,$sp,$t7 \n";
			finalCode+= "addi $sp $sp "+get_string(4*nparamstack.top())+"\n";	
        }

        else if(findType(line)=="FUNC")
        {
        	finalCode +=modify(line)+"\n";
		 	finalCode+= "sw $fp,0($sp) \n"; //push frame pointer to stack
			finalCode+= "li $t7,4\n";
			finalCode+= "sub $sp,$sp,$t7 \n"; 
			finalCode+= "move $fp, $sp \n"; //make frame pointer = stack pointer
			presentFunc = line;
			presentFuncStack.push(presentFunc);
        }

        else if(findType(line)=="BEGINFUNC")
        {
        	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			//cout<<presentFunc<<"  "<<functionVariables[presentFunc].size()<<endl;

			finalCode += "addi $sp, $sp, -"+get_string((functionVariables[presentFunc].size()-values[presentFunc])*4)+"\n";
			totalvariables.insert(make_pair(presentFunc,((functionVariables[presentFunc].size()-values[presentFunc])*4)));
        }
        else if(findType(line)=="RETURN")
        {
        	presentFuncStack.pop(); 	//pop the function
		 	if(!presentFuncStack.empty())
		 		presentFunc = presentFuncStack.top();
		 	i=0;
			p = strtok((char*)(line.c_str())," ,\n");
			while(p!=NULL)
			{
				splitstring[i++] = p;
				p = strtok(NULL," ,\n");
			}
			k = find_variable(splitstring[1]);
			if(k==-1000)
			{
				finalCode+= "li $t1, "+splitstring[1] + "\n"; //load immediate
			}else if(k==-1001)
			{
				finalCode+= "lw $t1 ,"+splitstring[1] + "\n"; //load immediate
			}
			else
			{
				finalCode+= "lw $t1, "+get_string(-4*k+4)+"($fp) \n";
			}
			finalCode+= "move $v0,$t1 \n";
		 	finalCode += "addi $sp, $sp, "+get_string(totalvariables[presentFunc])+"\n"; 	//main may cause problem
		 	finalCode += "lw $fp 4($sp)\n"; // pop $ra
			finalCode+= "li $t7,4\n";
			finalCode+= "add $sp,$sp,$t7 \n";
			finalCode += "jr $ra\n";
        }
        else
        {
        	;
        }

	}
  	}
  	finalCode+="li $v0,10\n";
  	finalCode+="syscall\n";
  	file1.close();
  	cout<<finalCode;
	return 0;

	
}





