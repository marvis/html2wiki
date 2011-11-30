all:
	flex++ html2wiki.flex
	g++ lex.yy.cc -o _html2wiki
	cp _html2wiki ~/Local/bin
	cp html2wiki ~/Local/bin
