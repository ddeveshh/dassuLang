# dassuLang

## Group Members:
	1. Devesh
	2. Sachin Mittal
	3. Animesh Karmakar

## Description
	This is language is made as a Compilers Lab Project at Indian Institute of Technology Guwahati by the team members mentioned above. This language is a Subset of C. Syntax somewhat resembles Python. The supported are "integer" and "bool". It supports global declarations, recursive function calls, unary operators like negation, logical NOT, logical OR, logical AND, bitwise NOT ("~") and binary operators like addition, subtaction, division, multiplication, modulus, biwise and("&"), bitwise or("|"), bitwise xor("^") and various comparators like greaterthan equal to (">="), less than equal to ("<="), equal to ("==") and not equal to ("!="). There is only one kind of loop that is similar to "while" loop in C, if else statement is also similar to C. All the global variables are initialized to 0.

### Syntax
	Syntax of the language is quite similar to python and C. Every statement ends with a semicolon (";") as in C.

#### Functions
	1. Every function start with a type specifier("int" or "bool") just like C.
	2. Then argument list is provided in brackets just like C.
	3. A colon ":" indicates the start of a function and at the end of a function "end" is written.
	4. Every function must have a return statement.

#### if-else statements
	1. Starts with an "if" and then a condition separated by a space.
	2. After the condition there is a colon ":".
	3. There can be many elseif statements with an if statement. Syntax is similar to if statement.
	4. At the end there is an optional else statement.
	5. after the if else statement is finished there is an "end" to signify its end.

#### loop 
	1. This language supports only one loop statement that is called "loop".
	2. Starts with "loop" and then space separated condition followed by a colon ":".
	3. end of the loop is signified by "end".
	4. Behaviour is similar to while loop in C.

#### jump statements
	jump statements are similar to C. It supports "break" and "return" statements only.

#### read and print statements
	1. "read <identifier>;" read the input (only integer data type is supported).
	2. "echo <expression>;" prints the value of expression to console (0 or 1 for boolean data type).

## Sample Code
	```
	int increment(int a):
		return a++;
	end

	int main():
		bool c;
		int a = 0;
		c = true;
		loop c == true:
			if a<10:
				echo a;
				a = increment(a);
			elseif a==10:
				echo a*2;
				a = a*2;
			else:
				a = increment(a);
				echo a;
				c = NOT c;	
			end 
		end 
		return 0;
	end
	```


## How to run the Code.
	1. Go to the Directory with all the files and run "make" command. This will generate a few files.
	2. Now write your code in a file. File named "input" is taken as example here.
	3. Now run "./lang <input" in the terminal. This will generate a TAC.txt file in the "MIPS" directory. This file contains three address code for the your code.
	4. Now go to the "MIPS" directory and run "./make.sh" command. This will generate mips.s file that can be run on a mips simulator. We used "spim" to run the file.
