%option noyywrap

%{
#include <string>
#include <iostream>
#include <stack>
using namespace std;

string link_text, link_href;
stack<string> list_stack; string list_cur, list_par;
%}

%s ALINK 
%%
\<(\!|HTML|HEAD|META|LINK|BODY|FONT)[^>]*\>
\<\/(HTML|HEAD|META|LINK|BODY|FONT)\>
\<STYLE[^>]*\>[^<]*\<\/STYLE\>
\<BR\>
\<(B|(STRONG))\>              
\<\/(B|(STRONG))\>            
\&nbsp;                       cout<<" ";
\&gt;                         cout<<">";
\&lt;                         cout<<"<";
\&amp;                        cout<<"&";
\<TITLE\>[^<]*\<\/TITLE\>     {
								string title=yytext; 
								int pos1 = title.find_first_of(">"); 
								int pos2 = title.find_first_of("<",pos1+1); 
								title=title.substr(pos1+1, pos2-pos1-1); 
								if(title!="") cout<<"%title "<<title<<endl;
							  }
\<H([0-9])[^>]*\>             cout<<string(atoi(yytext+2),'=');cout<<" ";
\<\/H([0-9])>                 cout<<" ";cout<<string(atoi(yytext+3),'=');
\<\/?CENTER\>                 cout<<" ";
\<\/?(U|(EM))\>               cout<<"_";
\<\/?DEL\>                    cout<<"~~";
\<\/?CODE\>                   cout<<"`";
\<\/?P\>                      cout<<endl;
\<SUP\>\<SMALL\>              cout<<"^";
\<\/SMALL\>\<\/SUP\>          cout<<"^";
\<SUB\>\<SMALL\>              cout<<",,";
\<\/SMALL\>\<\/SUB\>          cout<<",,";
\<BLOCKQUOTE\>                cout<<endl<<"    ";
\<\/BLOCKQUOTE\>              
\<PRE[^>]*\>                  cout<<"{{{";
\<\/PRE\>                     cout<<"}}}";
\<UL[^>]*\>                   list_par=list_cur; list_cur="UL"; list_stack.push(list_par);
\<OL[^>]*\>                   list_par=list_cur; list_cur="OL"; list_stack.push(list_par);
\<LI[^>]*\>                   {string out = (list_cur == "OL") ? "# " : (list_par == "UL" ? "* " : "  - "); cout<<"\r"<<out;}
\<\/LI\>
\<\/(U|O)L\>                  list_cur=list_par; list_par = list_stack.top(); list_stack.pop();
\<A\ href=[^"]*\"[^"]*\"\>    {
								  BEGIN(ALINK); link_href=yytext; 
								  int pos1 = link_href.find_first_of("\""); 
								  int pos2 = link_href.find_first_of("\"",pos1+1); 
								  link_href=link_href.substr(pos1+1, pos2-pos1-1);
							  }
\<IMG\ src=\"[^"]*\"\>        {
	                              string src=yytext; 
								  int pos1 = src.find_first_of("\""); 
								  int pos2 = src.find_first_of("\"", pos1+1); 
								  src=src.substr(pos1+1,pos2 - pos1 -1);
								  cout<<"\[\["<<src<<"\]\]";
							  }
<ALINK>\<IMG\ src=\"[^"]*\"\><\/A\> {
	                                    link_text=yytext; 
										int pos1 = link_text.find_first_of("\""); 
										int pos2 = link_text.find_first_of("\"", pos1+1); 
										link_text=link_text.substr(pos1+1,pos2 - pos1 -1);
										if(link_text == link_href) cout<<"\[\["<<link_href<<"\]\]"; 
										BEGIN(INITIAL);
									}
<ALINK>[^<]*\<\/A\>            	{
									link_text=yytext; link_text=link_text.substr(0,link_text.size()-4); 
									if(link_href.find("http")==string::npos) 
									{
										if(link_href.find(".html") != string::npos) 
										{
											link_href = link_href.substr(0,link_href.size()-5);
										}
										cout<<"\[\["<<link_href<<"\]\["<<link_text<<"\]\]";
									}
									else cout<<"\["<<link_href<<" "<<link_text<<"\]"; 
									BEGIN(INITIAL);
								}
<ALINK>(.|\n)         
\n\n(\n)*                       cout<<endl<<endl;
                            
.|\n                          ECHO;
%%
main()
{
 	FlexLexer* lexer = new yyFlexLexer();
 	while (lexer->yylex() != 0);
	return 0;
}
