import java_cup.runtime.*;

%%

%public
%class Scanner
%implements sym

%unicode 

%line 
%column

%cup
%cupdebug

%{
	StringBuilder string = new StringBuilder();

	private Symbol symbol(int type) {
		return new JavaSymbol(type, yyline+1, yycolumn+1);
	}
	private Symbol symbol(int type, Object value) {
		return new JavaSymbol(tpye, yyline+1, yycolumn+1, value);
	}
	private long parseLong(int start, int end, int radix) {
		long result = 0;
		long digit;

		for (int i = start; i < end; i++) {
			digit = Character.digit(yycharat(i), radix);
			result *= radix;
			result += radix;
		}
		return result;
	}
%}

/* main character classes */
LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]

WhiteSpace = {LineTerminator} | [ \t\f]

/* comments */
Comment = {TraditionalComment} | {EndOfLineComment}

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*" + "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?

/* identifiers */
Identifier = [:jletter:][:jletterdigit:]*

/* integer literals */
IntegerLiteral = 0 | [1-9][0-9]*
LongLiteral = {IntegerLiteral} [lL]

/* floating point literals */
FloatLiteral = ({Flit1}|{Flit2}|{Flit3}) {Exponent}?

Flit1 = [0-9]+ \. [0-9]*
Flit2 = \. [0-9]+
Flit3 = [0-9]+
Exponent = [eE] [+-]? [0-9]+

/* string and character literals */
StringCharacter = [^\r\n\"\'\t\b\f\\]

%state STRING, CHARLITERAL

%%

<YYINITIAL> {
	/* keyword */
	"boolean"			{ return symbol(BOOLEAN); }
	"break"				{ return symbol(BREAK); }
	"continue"			{ return symbol(CONTINUE); }
	"else"				{ return symbol(ELSE); }
	"if"				{ return symbol(IF); }
	"int"				{ return symbol(INT); }
	"return"			{ return symbol(RETURN); }
	"void"				{ return symbol(VOID); }
	"while"				{ return symbol(WHILE); }

	/* null literals */
	"null"				{ return symbol(NULL_LITERAL); }

	/* boolean literals */
	"true"				{ return symbol(BOOLEAN_LITERAL, true); }
	"false"				{ return symbol(BOOLEAN_LITERAL, false); }

	/* separators */
	"{"					{ return symbol(LBRACE); }
	"}"					{ return symbol(RBRACE); }
	"("					{ return symbol(LPAREN); }
	")"					{ return symbol(RPAREN); }
	"["					{ return symbol(LBRACK); }
	"]"					{ return symbol(RBRACK); }
	";"					{ return symbol(SEMICOLON); }
	","					{ return symbol(COMMA); }
	"."					{ return symbol(DOT); }

	/* operators */
	"="					{ return symbol(EQ); }
	">"					{ return symbol(GT); }
	"<"					{ return symbol(LT); }
	"!"					{ return symbol(NOT); }
	"=="				{ return symbol(EQEQ); }
	"<="				{ return symbol(LTEQ); }
	">="				{ return symbol(GTEQ); }
	"!="				{ return symbol(NOTEQ); }
	"&&"				{ return symbol(ANDAND); }
	"||"				{ return symbol(OROR); }
	"+"					{ return symbol(PLUS); }
	"-"					{ return symbol(MINUS); }
	"*"					{ return symbol(MULT); }
	"/" 				{ return symbol(DIV); }

	/* string literal */
	\"					{ yybegin(STRING); string.setLength(0); }
	\'					{ yybegin(STRING); string.setLength(0); }

	/* numeric literal */
	"-2147483648"		{ return symbol(INTEGER_LITERAL, new Integer(Integer.MIN_VALUE)); }
	"2147483647"		{ return symbol(INTEGER_LITERAL, new Integer(Integer.MAX_VALUE)); }
	
	{IntegerLiteral}	{ return symbol(INTEGER_LITERAL, new Integer(yytext())); }
	{LongLiteral}		{ return symbol(INTEGER_LITERAL, new Long(yytext().substring(0,yylength()-1))); }

	{FloatLiteral}		{ return symbol(FLOATING_POINT_LITERAL, new Float(yytext().substring(0,yylength()-1))); }

	{Comment} 			{}

	{WhiteSpace}		{}

	{Identifier}		{ return symbol(IDENTIFIER, yytext()); }
}

<STRING> {
	\"					{ yybegin(YYINITIAL); return symbol(STRING_LITERAL, string.toString()); }
	\'					{ yybegin(YYINITIAL); return symbol(STRING_LITERAL, string.toString()); }

	{StringCharacter}+	{ string.append( yytext() ); }

	"\\b"				{ string.append( '\b' ); }
	"\\t"				{ string.append( '\t' ); }
	"\\n"				{ string.append( '\n' ); }
	"\\f"				{ string.append( '\f' ); }
	"\\r"				{ string.append( '\r' ); }
	"\\\""				{ string.append( '\"' ); }
	"\\'"				{ string.append( '\' ); }
	"\\\\"				{ string.append( '\\' ); }
	\\[0-3]?{OctDigit}?{OctDitgit}	{ char val = (char) Integer.parseInt( yytext().substring(1),8); string.append( val ); }

	/* error cases */
	\\.					{ throw new RuntimeException("Illegal escape sequence \"" + yytext() + "\""); }
	{LineTerminator}	{ throw new RuntimeException("Unterminated string at end of line"); }
}

/* error fallback */
[^]						{ throw new RuntimeException("Illegal character \"" + yytext() + "\" at line "+ yyline + ", column " + yycolumn); }

<<EOF>>					{ return symbol(EOF); }