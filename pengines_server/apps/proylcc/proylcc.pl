

:- module(proylcc,
	[  
		put/8, solveNonogram/4,check_initial_clues/5
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
	getColStateList(ColLenght,ColLenght,InvertedGrid,ColN,_Counter, List), 
	nth0(ColN,ColsClues,ColNClues),
	checkLists(List,ColNClues,ColSat),
	numberOfCols(NewGrid,RowLenght),
	nth0(RowN,NewGrid,RowNList),
	getRowStateList(RowLenght,RowLenght,RowNList,_CounterR,RList),
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



% Asegúrate de definir `reverse/2` si no está disponible.
%reverse([], []).
%reverse([H|T], R) :-
    %reverse(T, RevT),
    %append(RevT, [H], R).

check_initial_clues(RowsClues, ColClues, InitialGrid, StateR, StateC):-
    numberOfRows(InitialGrid, NRows),
    numberOfCols(InitialGrid, NCols),
    getInitialRowsClues(NRows, NRows, InitialGrid, InitialRCluesList),
    investList(InitialGrid,InitialInvertedGrid),
    getInitialColsClues(NCols, NCols, InitialInvertedGrid, InitialCCluesList),
    checkCluesList(NRows, RowsClues, InitialRCluesList, StateR),
    checkCluesList(NCols, ColClues, InitialCCluesList, StateC).

getInitialRowsClues(Length, 1, InitialGrid, ResultR):-
    nth0(0,InitialGrid,Fila),
    getRowStateList(Length, Length, Fila, _Counter, Result),
    reverse(Result, InvertedResult),
    append([InvertedResult],[],ResultR).

getInitialRowsClues(Length, NRows, InitialGrid, InitialRCluesList):-
    NRowsAux is NRows-1,
    getInitialRowsClues(Length, NRowsAux, InitialGrid, FormerList),
    nth0(NRowsAux,InitialGrid,RowN),
    getRowStateList(Length, Length, RowN, _Counter, List),
     reverse(List, InvertedList),
    append(FormerList, [InvertedList], InitialRCluesList).

getInitialColsClues(Length, 1, InitialInvertedGrid, ResultC):-
    getColStateList(Length,Length, InitialInvertedGrid, 0, _Counter, List),
    append([List], [], ResultC).

getInitialColsClues(Length, NCols, InitialInvertedGrid, InitialCCluesList):-
    NColsAux is NCols-1,
    getInitialColsClues(Length, NColsAux, InitialInvertedGrid, FormerList),
    getColStateList(Length, Length, InitialInvertedGrid, NColsAux, _Counter, List),
    append(FormerList, [List], InitialCCluesList).

checkCluesList(1, RowsClues, InitialGrid, [Result]):-
    nth0(0, RowsClues, RE),
    nth0(0, InitialGrid, IRE),
    checkLists(RE, IRE, Result).

checkCluesList(NRows, RowsClues, InitialRCluesList, State):-
    NRows > 0,
    NRowsAux is NRows - 1,
    checkCluesList(NRowsAux, RowsClues, InitialRCluesList, PreviousState),
    nth0(NRowsAux, RowsClues, RE),
    nth0(NRowsAux, InitialRCluesList, IRE),
    checkLists(RE, IRE, Result),    
    append(PreviousState, [Result], State).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  Etapa 2                                      %

generate_grid([],_Length,[]).
generate_grid([X|Xs],Length,[Y|Ys]):-
    generate_list(X,Length,Y),
    generate_grid(Xs,Length,Ys).
% Predicado para generar una lista de longitud Length con "#" en las posiciones indicadas por la lista de números Numbers y "_" en las demás posiciones
generate_list(Numbers, Length, Result) :-
    generate_list(Numbers, Length, 1, Result).

% Caso base: cuando la lista de números está vacía, llena el resto de la lista con "_"
generate_list([], Length, Index, Result) :-
    fill_with_underscore(Index, Length, Result).

% Caso recursivo: cuando hay números en la lista, generamos la lista de acuerdo a esos números
generate_list([Number|Numbers], Length, Index, [Element|Result]) :-
    Index =:= Number, % Si el índice actual coincide con el número, colocamos "#" en esa posición
    Element = '#',
    NextIndex is Index + 1,
    generate_list(Numbers, Length, NextIndex, Result).

generate_list([Number|Numbers], Length, Index, [Element|Result]) :-
    Index =\= Number, % Si el índice actual no coincide con el número, colocamos "_" en esa posición
    Element = 'X',
    NextIndex is Index + 1,
    generate_list([Number|Numbers], Length, NextIndex, Result).

% Predicado auxiliar para llenar el resto de la lista con "_"
fill_with_underscore(Index, Length, Result) :-
    Index =< Length,
    append(['X'], Rest, Result),
    NextIndex is Index + 1,
    fill_with_underscore(NextIndex, Length, Rest).

fill_with_underscore(Index, Length, []) :-
    Index > Length.

% sum(Summ, List) - Summ of elements of List
sum(0, []).
sum(Sum, [Head|Tail]) :- sum(K, Tail), Sum is K + Head.

% inRange(I, Low, Hi) I is between Low and Hi
inRange(Low, Low, High) :- Low =< High.
inRange(I, Low, High) :- Low < High, LessLow is Low + 1, inRange(I, LessLow, High).

range([N], N, N).
range([Low|Tail], Low, High) :- Low < High, LesLow is Low + 1, range(Tail, LesLow, High).


%%      
%   Generates all possible combos for passed lines conditions, and length
%%
generate(LineCombos, Lines, Size, InitialGrid) :- generate_supp(1, LineCombos, Lines, Size, InitialGrid).

%%
%   Supportive predicate for generate/4 to include line number
%%
generate_supp(_, [], [], _, _).
generate_supp(LineNumber, [FinalCombos|LineCombosTail], [Line|LinesTail], Size, InitialGrid) :- 
    findall(Combo, combinate(Line, Size, Combo), Combos),
    NextLineNumber is LineNumber + 1,
    ActualIndex is LineNumber - 1,
    nth0(ActualIndex, InitialGrid, RowGrid),
    discardCombos(Combos,RowGrid,FinalCombos),
    generate_supp(NextLineNumber, LineCombosTail, LinesTail, Size, InitialGrid).

%%
%   Returns possible line for passed conditions and size
%%
combinate(Line, Size, Combo) :- 
    sum(Sum, Line),
    length(Line, Length),
    CortegeLength is Sum + Length - 1,
    combinate_supp(Line, 1, CortegeLength, Size, [], Combo).

%%
%   Supportive predicate for combinate/3
%%
combinate_supp([0], _, _, _, _, []).
combinate_supp([Number], Start, _, Size, PreCombo, Combo) :- 
    End is Size - Number + 1,
    inRange(First, Start, End),
    Last is First + Number - 1,
    range(EndCombo, First, Last),
    append(PreCombo, EndCombo, Combo).
combinate_supp([Number|Tail], Start, CortegeLength, Size, PreCombo, Combo) :-
    End is Size - CortegeLength + 1,
    inRange(First, Start, End),
    Last is First + Number - 1,
    range(EndCombo, First, Last),
    NewCortegeLength is CortegeLength - Number - 1,
    NewStart is Last + 2,
    append(PreCombo, EndCombo, LowCombo),
    combinate_supp(Tail, NewStart, NewCortegeLength, Size, LowCombo, Combo).

%%
%   Check if a combination is compatible with the initial grid
%%
discardCombos(Combos,RowGrid,FinalCombos):-
    	posiciones_elemento('X',RowGrid,Posiciones),
    	filtrar_listas(Posiciones,Combos,CombosNoCoincidentes),
		FinalCombos=CombosNoCoincidentes.

% Predicado para comparar y filtrar listas
filtrar_listas([], Combos, Combos).
filtrar_listas([X|Xs], Combos, Resultado) :-
    eliminar_coincidentes(X, Combos, CombosFiltrados),
    filtrar_listas(Xs, CombosFiltrados, Resultado).

% Predicado auxiliar para eliminar listas que contienen el elemento X
eliminar_coincidentes(_, [], []).
eliminar_coincidentes(X, [Lista|Listas], Resultado) :-
    (   member(X, Lista)
    ->  eliminar_coincidentes(X, Listas, Resultado)
    ;   eliminar_coincidentes(X, Listas, Resto),
        Resultado = [Lista|Resto]).

% Predicado para encontrar la posición de un elemento en una lista.
encontrar_posiciones(_, [], [], _).
encontrar_posiciones(Elemento, [Elemento|Resto], [Posicion|RestoPosiciones], Posicion) :-
    PosicionActual is Posicion + 1,
    encontrar_posiciones(Elemento, Resto, RestoPosiciones, PosicionActual).
encontrar_posiciones(Elemento, [Distinto|Resto], Posiciones, Posicion) :-
    Distinto \= Elemento,
    PosicionActual is Posicion + 1,
    encontrar_posiciones(Elemento, Resto, Posiciones, PosicionActual).

% Predicado principal para encontrar posiciones de un elemento en una lista
posiciones_elemento(Elemento, Lista, Posiciones) :-
    encontrar_posiciones(Elemento, Lista, Posiciones, 1).

% Combina listas seleccionando un elemento de cada sublista
combine([], []).
combine([Sublist|Rest], [Element|Combination]) :-
    member(Element, Sublist),
    combine(Rest, Combination).

% Genera todas las combinaciones posibles
generate_combinations(List, Combinations) :-
    findall(Combination, combine(List, Combination), Combinations).



%   Solving nonograms.
%%
solveNonogram(Rows,Cols,InitialGrid,Solution):-
    length(Rows, VSize),
    length(Cols, HSize),
    generate(RowCombos, Rows, HSize, InitialGrid),
	transpose(InitialGrid, TInitialGrid),
    generate(ColsCombos, Cols, VSize,TInitialGrid),
    generate_combinations(RowCombos,RCombosCombinationsList),
	generate_combinations(ColsCombos,CCombosCombinationsList),
	find_matching_list(RCombosCombinationsList,CCombosCombinationsList,FinalGrid),
	generate_grid(FinalGrid,HSize,Solution).

% Check if an element exists at specific positions in sublists of a list of lists
check_positions(_, [], _).
check_positions(Element, [PositionA|PositionsA], Positions, ListOfLists) :-
    nth1(PositionA, ListOfLists, SubList),
    member(Element, SubList),
    check_positions(Element, PositionsA,Positions, ListOfLists),!.
check_positions(Element,[PositionA],_,ListOfLists):-
    nth1(PositionA, ListOfLists, SubList),
    member(Element, SubList).

% Main predicate to check if a sublist from A matches any sublist from B
match_lists([], _, _).
match_lists([SublistA|RestA], ListB, Index) :-
    Index1 is Index + 1,
    findall(Index1, between(1, Index1, Index1), Positions),
    check_positions(Index1, SublistA ,Positions, ListB),
    match_lists(RestA, ListB, Index1).

% Predicate to check if a single list from A matches any list from B
match_single_list_with_any([], _, false).
match_single_list_with_any([ListB|RestB], ListA, Result) :-
    (   match_lists(ListA, ListB, 0)
    ->  Result = true
    ;   match_single_list_with_any(RestB, ListA, Result)
    ).

% Predicate to find the first matching list from A with any list from B
find_first_matching_list([], _, []).
find_first_matching_list([ListA|RestA], ListB, Result) :-
    (   match_single_list_with_any(ListB, ListA, true)
    ->  Result = ListA
    ;   find_first_matching_list(RestA, ListB, Result)
    ).

% Helper predicate to start with the right initial index
find_matching_list(A, B, Matched) :-
    find_first_matching_list(A, B, Matched).


transpose([], []).
transpose([[]|_], []).
transpose(Matrix, [FirstCol|Transposed]) :-
    transpose_1st_col(Matrix, FirstCol, RestMatrix),
    transpose(RestMatrix, Transposed).

transpose_1st_col([], [], []).
transpose_1st_col([[X|Xs]|RestMatrix], [X|Col], [Xs|RestMatrix1]) :-
    transpose_1st_col(RestMatrix, Col, RestMatrix1).
