:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY is the result of replacing the occurrence of X in position XIndex of Xs by Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%

put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, RowSat, ColSat):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),
	investVertically(NewGrid,InvertedGrid),
	numberOfRows(NewGrid,ColLenght),
	getColStateList(ColLenght,ColLenght,InvertedGrid,ColN,Counter, List),
	nth0(ColN,ColsClues,ColNClues),
	checkLists(List,ColNClues,ColSat),
	numberOfCols(NewGrid,RowLenght),
	nth0(RowN,NewGrid,RowNList),
	getRowStateList(RowLenght,RowLenght,RowNList,CounterR,RList),
	investList(RList,RListInverted),
	nth0(RowN,RowsClues,RowNClues),
	checkLists(RListInverted,RowNClues,RowSat).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getRowStateList(_,1, [Body], Counter, List) :-
	(Body == "#" -> Counter = 1; Counter = 0),
	List = [].
	
getRowStateList(FinalRow,RowLength,[Head|Body],Counter,FinalList):-
	RowLength > 0,
	RowLengthAux is RowLength-1,
	getRowStateList(FinalRow, RowLengthAux,Body, FormerCounter,FormerList),
	(Head == "#" -> NewCc = Head ; NewCc = "0"),
	processCases(NewCc,FormerCounter,FormerList,Counter,List),
	processLastInstance(FinalRow, RowLength, List,Counter, FinalList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

getColStateList(_,1, [Body], ColN, Counter, List) :-
    nth0(ColN, Body, Cc),
    (Cc == "#" -> Counter = 1; Counter = 0),
    List = [].

getColStateList(FinalCol,ColLength,[Head|Body],ColN,Counter,FinalList):-
		ColLength > 0,
		ColLengthAux is ColLength-1,
		getColStateList(FinalCol, ColLengthAux,Body, ColN, FormerCounter,FormerList),
		nth0(ColN,Head,Cc),
		(Cc == "#" -> NewCc = Cc ; NewCc = "0"),
		processCases(NewCc,FormerCounter,FormerList,Counter,List),
		processLastInstance(FinalCol, ColLength, List,Counter, FinalList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
processCases("0", FormerCounter, FormerList, 0, List) :-
    FormerCounter > 0,
    append(FormerList, [FormerCounter], List).
% 
processCases("0", 0, FormerList, 0, FormerList).
% 
processCases("#",FormerCounter, FormerList, Counter, List) :-
    FormerCounter> 0,
    Counter is FormerCounter + 1,
    List = FormerList.
% 
processCases("#", 0, FormerList, Counter, List) :-
    Counter is 1,
    List = FormerList.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------
processLastInstance(FinalCol, ActualCol, List, Counter,FinalList):-
    FinalCol = ActualCol, Counter > 0, 
    append(List, [Counter], FinalList).
%-------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

processLastInstance(_, _, List,_, List). % Si no se cumple la condición, FinalList es igual a List

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Comprueba si dos Lists son iguales
checkLists([], [], true).
checkLists([X|Xs], [Y|Ys], Result) :-
    X = Y,
    checkLists(Xs, Ys, Result).
checkLists(_, _, false).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Predicate to obtain the number of columns of a grid
numberOfCols([Row|_], NumCols) :-
    length(Row, NumCols).
% Predicate to obtain the number of rows of a grid
numberOfRows(Grid, NumRows) :-
    length(Grid, NumRows).
%----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

investVertically([], []).
investVertically([Fila|Filas], MatrizInverted) :-
    investVertically(Filas, FilasInverteds),
    append(FilasInverteds, [Fila], MatrizInverted).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	investList([], []). % La List vacía se invierte en la List vacía
investList([X|Xs], Y) :- % La List Inverted de [X|Xs] es la concatenación de la List Inverted de Xs con [X]
    investList(Xs, InvertedXs),
    append(InvertedXs, [X], Y).


