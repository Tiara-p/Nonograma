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

put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 0, 0):-
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
	invertir_verticalmente(Grid,InvertedGrid),
	%getRowCluesList()%
	numberOfRows(Grid,ColLenght),
	getColCluesList(ColLenght,ColLenght,InvertedGrid,ColN,0, []).

	
%getRowCluesList()%

getColCluesList(_,1, [Body], ColN, Counter, Lista) :-
    nth0(ColN, Body, Cc),
    (Cc == '#' -> Counter = 1; Counter = 0),
    Lista = [].

getColCluesList(FinalCol,ColLength,[Head|Body],ColN,Counter,ListaFinal):-
		ColLength > 0,
		ColLengthAux is ColLength-1,
		getColCluesList(FinalCol, ColLengthAux,Body, ColN, CounterAnterior,ListaAnterior),
		nth0(ColN,Head,Cc), procesar_casos(Cc,CounterAnterior,ListaAnterior,Counter,Lista),
		procesar_instancia_final(FinalCol, ColLength, Lista,Counter, ListaFinal).

% Caso 1: Cc es igual a # y Counter es mayor a 0
procesar_casos('#',CounterAnterior, ListaAnterior, Counter, Lista) :-
    CounterAnterior> 0,
    Counter is CounterAnterior + 1,
    Lista = ListaAnterior.

% Caso 2: Cc es igual a # y Counter es 0
procesar_casos('#', 0, ListaAnterior, Counter, Lista) :-
    Counter is 1,
    Lista = ListaAnterior.

% Caso 3: Cc es distinto a # y Counter es mayor a 0
procesar_casos(_, CounterAnterior, ListaAnterior, 0, Lista) :-
    CounterAnterior > 0,
    append(ListaAnterior, [CounterAnterior], Lista).

% Caso 4: Cc es distinto a # y Counter es 0
procesar_casos(_, 0, _ListaAnterior, 0, _Lista).


%------
procesar_instancia_final(FinalCol, ActualCol, Lista, Counter,ListaFinal):-
    FinalCol = ActualCol, Counter > 0, !,
    append(Lista, [Counter], ListaFinal).

procesar_instancia_final(_, _, Lista,_, Lista). % Si no se cumple la condición, ListaFinal es igual a Lista

% Comprueba si dos listas son iguales
checkLists([], []).
checkLists([_|Xs], [_|Ys]):-checkLists(Xs,Ys).

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

