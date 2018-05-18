# You need CUP v0.10j (or newer) for this makefile to work (for java12.cup)
#
# CUP classes should be included in CLASSPATH 

CUP        = java java_cup.Main -interface <
JFLEX      = ../../bin/jflex
CUPJAR     = ../../lib/java-cup-11a.jar
CP         = .:$(CUPJAR)
JAVA       = java
JAVAC      = javac
JAVACFLAGS = -cp $(CP)
CUP        = $(JAVA) -jar $(CUPJAR)



# --------------------------------------------------

all: lexer-output.txt

test: lexer-output.txt
	@(diff lexer-output.txt lexer-output.good && echo "Test OK!") || echo "Test failed!"

lexer-output.txt: compile
	$(JAVA) -cp $(CP) TestLexer TestLexer.vc > lexer-output.txt


compile: scanner parser unicode
	$(JAVAC) $(JAVACFLAGS) VCParser.java TestLexer.java

parser: parser.java 

parser.java: VCparser.cup
	$(CUP) -interface java12.cup

scanner: Scanner.java

Scanner.java: java.flex
	$(JFLEX) VC.flex

unicode: UnicodeEscapes.java

UnicodeEscapes.java: unicode.flex
	$(JFLEX) unicode.flex

clean:
	rm -f *.class
	rm -f *~
	rm -f Scanner.java
	rm -f parser.java
	rm -f sym.java
	rm -f UnicodeEscapes.java
	rm -f lexer-output.txt
