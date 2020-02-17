// Circuit.lex
//
// CS2A Language Processing 2001-2002
//
// Description of lexer for circuit description language.
// See Lecture Note 12 for further explanation.
//
// Ian Stark

package lexer;

import java_cup.runtime.Symbol; //This is how we pass tokens to the parser
import java.lang.Integer;
import parser.*;
import java.util.HashMap;
import java.io.*;
%%


// Declarations for JFlex
%unicode // We wish to read text files
%cupsym parser.SPECSSym
%cup // Declare that we expect to use Java CUP
%class Lexer
%public
%line
%column 



%{
/*
Scelgo di usare la symbol table solo per gli identificatori. 
Infatti le costanti non hanno scope (dunque non penso sia necessario metterle in tabella: n� in quella
scoped n� in quella non scoped)
 ed il loro tipo pu� essere riconosciuto dalla classe del lessema (es: <double_const, const_value>.
*/
private static HashMap<String, Symbol> symbolTable; 


	public Lexer initialize() throws IOException{
	
		symbolTable = new HashMap<String, Symbol> ();
		
		//Restituisco il lexer solo al termine dell'inizializzazione.
		return this;

	} 
	
	
	
	private Symbol installID(int line, int column, String lexeme){

		//utilizzo come chiave della hashmap il lessema
		if(symbolTable.containsKey(lexeme)){
			/*
			* Non posso semplicemente restituire il token gi� presente nella symbol table: viene
			* lanciato un Error: 
			* 		"Exception in thread "main" java.lang.Error: Symbol recycling detected (fix your scanner).".
			* Ne devo dunque restituire uno identico, senza inserirlo nella symbol table: in questo modo
			* punter� allo stesso elemento della tabella dei simboli dell'omonimo predecessore.
			* Non posso nemmeno usare il metodo clone(): non � visibile.
			*/
			return new Symbol (SPECSSym.ID, lexeme);
			
		}
		else{
			Symbol symbol =  new Symbol (SPECSSym.ID, lexeme);
			symbolTable.put(lexeme, symbol);
			return symbol;
		}
	}
	

	
	
	
	private HashMap<String, Symbol> getSymbolTable(){

		return symbolTable;
	}
	
	
	
%}




// Abbreviations for regular expressions


inline_comment = "//" [^\n]*
multi_line_comment = "/*" ~ "*/"

whitespace = [ \r\n\t\f] | "\r\n"
id = [:jletter:] ([:jletterdigit:])*

unicode_char = "\\u" [0-9A-F]{4}
plain_char = [^']
char_or_unicode_char = {plain_char} | {unicode_char} | "\\n" | "\\r" |"\\t" | "\\f"
char_const = "'" {char_or_unicode_char} "'" 

// cosa significa che una stringa � finita? Devono esserci un numero pari di \. Ossia due \ ripetute (a coppie) e non precedute da \, oppure qualcosa diverso da \
end_of_string_const= "\\\\"*  "\""
string_const = "\"" ~{end_of_string_const}


non_zero_digit = [1-9]
digit = [0-9]
exponential_segment= ([Ee] (([+-]?{non_zero_digit}{digit}*)| "0"))?
int_const = ({non_zero_digit}{digit}*) | "0"
double_const =  {int_const} ("." (({digit}* {non_zero_digit}) | "0")) {exponential_segment}






%% 
// Now for the actual tokens and assocated actions

	{multi_line_comment} { }
	{inline_comment} {}

	{char_const} { 
		char c;
		switch (yytext().substring(1,3)){
		case "\\n": {c='\n'; break;}
		case "\\t": {c='\t'; break;}
		case "\\f": {c='\f'; break;}
		case "\\r": {c='\r'; break;}
		default: {c=yytext().charAt(1); break;}
		}
		return new Symbol  (SPECSSym.CHAR_CONST, yyline, yycolumn, c);
	}

 
	"=" { return new Symbol  (SPECSSym.ASSIGN, yyline, yycolumn );}
	"in" { return new Symbol  (SPECSSym.IN, yyline, yycolumn );}
	"out" {return new Symbol  (SPECSSym.OUT, yyline, yycolumn );}
	"inout" { return new Symbol  (SPECSSym.INOUT, yyline, yycolumn );}
	

	">" { return new Symbol  (SPECSSym.GT, yyline, yycolumn );}
	">=" { return new Symbol  (SPECSSym.GE, yyline, yycolumn );}
	"==" { return new Symbol  (SPECSSym.EQ, yyline, yycolumn );}
	"<" { return new Symbol (SPECSSym.LT, yyline, yycolumn );}
	"<=" {  return new Symbol (SPECSSym.LE, yyline, yycolumn );} 
	
	
	"head" {return new Symbol  (SPECSSym.HEAD, yyline, yycolumn );}
	"start" { return new Symbol  (SPECSSym.START, yyline, yycolumn );}
	
	";" {return new Symbol  (SPECSSym.SEMI, yyline, yycolumn );}
	"int" { return new Symbol (SPECSSym.INT, yyline, yycolumn );}
	"bool" {  return new Symbol (SPECSSym.BOOL, yyline, yycolumn );}
	"char" {  return new Symbol (SPECSSym.CHAR, yyline, yycolumn );}
	"double" {  return new Symbol (SPECSSym.DOUBLE, yyline, yycolumn );}
	"string" {  return new Symbol (SPECSSym.STRING, yyline, yycolumn );}
	"," { return new Symbol (SPECSSym.COMMA, yyline, yycolumn );}
	
	"if" { return new Symbol (SPECSSym.IF, yyline, yycolumn );}
	"then"  {  return new Symbol (SPECSSym.THEN, yyline, yycolumn );}
	"else" {  return new Symbol (SPECSSym.ELSE, yyline, yycolumn );}
	"do"  {  return new Symbol (SPECSSym.DO, yyline, yycolumn );}
	"while"  { return new Symbol (SPECSSym.WHILE, yyline, yycolumn );}
	"false" {  return new Symbol  (SPECSSym.FALSE, yyline, yycolumn );}
	"true" {  return new Symbol  (SPECSSym.TRUE, yyline, yycolumn );}
	
	"def" { return new Symbol  (SPECSSym.DEF, yyline, yycolumn );}
	"true" { return new Symbol  (SPECSSym.TRUE, yyline, yycolumn );}
	
	"not" { return new Symbol  (SPECSSym.NOT, yyline, yycolumn );}
	"and" { return new Symbol  (SPECSSym.AND, yyline, yycolumn );}
	"or" { return new Symbol  (SPECSSym.OR, yyline, yycolumn );}
	
	
	"(" { return new Symbol  (SPECSSym.LPAR, yyline, yycolumn );}
	")" { return new Symbol  (SPECSSym.RPAR, yyline, yycolumn );}
	"{" {  return new Symbol (SPECSSym.LGPAR, yyline, yycolumn );}
	"}" {  return new Symbol (SPECSSym.RGPAR, yyline, yycolumn );}
	"<-" {  return new Symbol (SPECSSym.READ, yyline, yycolumn );}
	"->" {  return new Symbol (SPECSSym.WRITE, yyline, yycolumn );}
	
	
	"+" { return new Symbol  (SPECSSym.PLUS, yyline, yycolumn );}
	"-" { return new Symbol (SPECSSym.MINUS, yyline, yycolumn );}
	"*" {  return new Symbol (SPECSSym.TIMES, yyline, yycolumn );}
	"/" {  return new Symbol (SPECSSym.DIV, yyline, yycolumn );}
	
	
	{int_const} { return new Symbol  (SPECSSym.INT_CONST, yyline, yycolumn, Integer.parseInt(yytext()) );}
	{double_const} {  return new Symbol (SPECSSym.DOUBLE_CONST, yyline, yycolumn, Double.parseDouble(yytext()) );}


	
	
	{whitespace} { /* ignore */ }
	{id} { return this.installID( yyline, yycolumn, yytext() );}

	{string_const} { return new Symbol (SPECSSym.STRING_CONST, yyline, yycolumn, yytext() );}

	
	
	
	
<<EOF>> {return new Symbol (SPECSSym.EOF, yyline, yycolumn );} 


