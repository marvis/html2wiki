all:
	flex++ html2wiki.flex
	g++ lex.yy.cc -o _html2wiki
