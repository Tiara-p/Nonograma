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
	invertir_verticalmente(NewGrid,InvertedGrid),
	numberOfRows(NewGrid,ColLenght),
	getColCluesList(ColLenght,ColLenght,InvertedGrid,ColN,Counter, Lista),
	nth0(ColN,ColsClues,ColNClues),
	checkLists(Lista,ColNClues,ColSat),
	numberOfCols(NewGrid,RowLenght),
	nth0(RowN,NewGrid,RowNList),
	getRowCluesList(RowLenght,RowLenght,RowNList,CounterR,ListaR),
	invertir_lista(ListaR,ListaRInvertida),
	nth0(RowN,RowsClues,RowNClues),
	checkLists(ListaRInvertida,RowNClues,RowSat).

getRowCluesList(_,1, [Body], Counter, Lista) :-
	(Body == "#" -> Counter = 1; Counter = 0),
	Lista = [].
	
getRowCluesList(FinalRow,RowLength,[Head|Body],Counter,ListaFinal):-
	RowLength > 0,
	RowLengthAux is RowLength-1,
	getRowCluesList(FinalRow, RowLengthAux,Body, CounterAnterior,ListaAnterior),
	(Head == "#" -> NewCc = Head ; NewCc = "0"),
	procesar_casos(NewCc,CounterAnterior,ListaAnterior,Counter,Lista),
	procesar_instancia_final(FinalRow, RowLength, Lista,Counter, ListaFinal).

getColCluesList(_,1, [Body], ColN, Counter, Lista) :-
    nth0(ColN, Body, Cc),
    (Cc == "#" -> Counter = 1; Counter = 0),
    Lista = [].

getColCluesList(FinalCol,ColLength,[Head|Body],ColN,Counter,ListaFinal):-
		ColLength > 0,
		ColLengthAux is ColLength-1,
		getColCluesList(FinalCol, ColLengthAux,Body, ColN, CounterAnterior,ListaAnterior),
		nth0(ColN,Head,Cc),
		(Cc == "#" -> NewCc = Cc ; NewCc = "0"),
		procesar_casos(NewCc,CounterAnterior,ListaAnterior,Counter,Lista),
		procesar_instancia_final(FinalCol, ColLength, Lista,Counter, ListaFinal).

% 
procesar_casos("0", CounterAnterior, ListaAnterior, 0, Lista) :-
    CounterAnterior > 0,
    append(ListaAnterior, [CounterAnterior], Lista).
% 
procesar_casos("0", 0, ListaAnterior, 0, ListaAnterior).
% 
procesar_casos("#",CounterAnterior, ListaAnterior, Counter, Lista) :-
    CounterAnterior> 0,
    Counter is CounterAnterior + 1,
    Lista = ListaAnterior.
% 
procesar_casos("#", 0, ListaAnterior, Counter, Lista) :-
    Counter is 1,
    Lista = ListaAnterior.
%------
procesar_instancia_final(FinalCol, ActualCol, Lista, Counter,ListaFinal):-
    FinalCol = ActualCol, Counter > 0, 
    append(Lista, [Counter], ListaFinal).
%-------
procesar_instancia_final(_, _, Lista,_, Lista). % Si no se cumple la condición, ListaFinal es igual a Lista

% Comprueba si dos listas son iguales
checkLists([], [], true).
checkLists([X|Xs], [Y|Ys], Result) :-
    X = Y,
    checkLists(Xs, Ys, Result).
checkLists(_, _, false).
% Predicate to obtain the number of columns of a grid
numberOfCols([Row|_], NumCols) :-
    length(Row, NumCols).
% Predicate to obtain the number of rows of a grid
numberOfRows(Grid, NumRows) :-
    length(Grid, NumRows).
%----------------
invertir_verticalmente([], []).
invertir_verticalmente([Fila|Filas], MatrizInvertida) :-
    invertir_verticalmente(Filas, FilasInvertidas),
    append(FilasInvertidas, [Fila], MatrizInvertida).

	invertir_lista([], []). % La lista vacía se invierte en la lista vacía
invertir_lista([X|Xs], Y) :- % La lista invertida de [X|Xs] es la concatenación de la lista invertida de Xs con [X]
    invertir_lista(Xs, InvertidaXs),
    append(InvertidaXs, [X], Y).


