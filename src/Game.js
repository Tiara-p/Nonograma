import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';

let pengine;

function Game() {

  // State
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [mode, setMode] = useState('paint');
  const [gameCompleted, setGameCompleted] = useState(false);
  const [rowsSatisfied, setRowsCluesSat] = useState([]);
  const [colsSatisfied, setColsCluesSat] = useState([]);
  const [initialCluesChecked, setInitialCluesChecked] = useState(false);

  useEffect(() => {
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
  }, []);

  
  useEffect(() => {
    // Comprobación de si todos los elementos en rowsSatisfied y colsSatisfied son true.
    const allRowsSatisfied = rowsSatisfied.every(satisfied => satisfied);
    const allColsSatisfied = colsSatisfied.every(satisfied => satisfied);

    if (allRowsSatisfied && allColsSatisfied) {
      setGameCompleted(true);
    }else{
      setGameCompleted(false);
    }

  }, [rowsSatisfied, colsSatisfied]);

  useEffect(() => {
    // Solo ejecuta checkInitialClues() la primera vez que se actualicen los estados relevantes
    if (
      grid &&
      rowsClues &&
      colsClues &&
      rowsSatisfied.length > 0 &&
      colsSatisfied.length > 0 &&
      !initialCluesChecked
    ) {
      checkInitialRows(grid, rowsClues);
      checkInitialCols(grid, colsClues);
      setInitialCluesChecked(true);
    }
  }, [grid, rowsClues, colsClues]);

  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid)';
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setRowsCluesSat(Array(response['RowClues'].length).fill(false));
        setColsCluesSat(Array(response['ColumClues'].length).fill(false));
      }
    });
  }

  function checkInitialRows(grid, rowsClues){
    if (!grid || !rowsClues || !rowsSatisfied ) {
      // Si alguna de las variables de estado es nula, no realices la comprobación
      return;
    }
    let newRowsSatisfied = [...rowsSatisfied];
    for (let i = 0; i < grid.length; i++) {
      const row = grid[i];
      const rowModified = row.map(elemento => {
        // Verificamos si el elemento es '#'
        if (elemento === '#') {
          // Si es '#', agregamos comillas dobles
          return '"#"';
        } else {
          // Si no es '#', dejamos el elemento sin modificar
          return elemento;
        }
      });
      const queryRowS = `getRowStateList(${row.length}, ${row.length}, [${rowModified}], Counter, List)`;
      let List;
      setWaiting(true);
      pengine.query(queryRowS, (success, response) => { 
        if(success){
          List = response['List'];
          if(List== null){
            List=0;
          }
          const queryRowC = `checkLists([${List}], [${rowsClues[i]}] , RowSat)`;
          pengine.query(queryRowC, (success, response) => {
            if(success){
              const RowSat = response['RowSat'];
              newRowsSatisfied[i] = RowSat;
              console.log(newRowsSatisfied);
            }
          });
        }
        setWaiting(false); 
      });
    }
    console.log("estado final : " + newRowsSatisfied)
    setRowsCluesSat(newRowsSatisfied);
  }

  function checkInitialCols(grid, colsClues){
    if (!grid || !colsClues) {
      // Si alguna de las variables de estado es nula, no realices la comprobación
      return;
    }
    const newColsSatisfied = [...colsSatisfied];
    for (let j = 0; j < grid[0].length; j++) {
      const column = grid.map(row => row[j]); // Obtener la columna j
      const columnModified = column.map(elemento => {
        // Verificamos si el elemento es '#'
        if (elemento === '#') {
          // Si es '#', agregamos comillas dobles
          return '"#"';
        } else {
          // Si no es '#', dejamos el elemento sin modificar
          return elemento;
        }
      });
      const queryColS = `getRowStateList(${column.length}, ${column.length}, [${columnModified}], Counter, List)`;
      let List;
      setWaiting(true);
      pengine.query(queryColS, (success, response) => { 
        if(success){
          List = response['List'];
          const queryColC = `checkLists([${List}], [${colsClues[j]}] , ColSat)`;
          pengine.query(queryColC, (success, response) => {
            if(success){
              const ColSat = response['ColSat'];
              newColsSatisfied[j] = ColSat;
            }
          });
        }
        setWaiting(false);
      });
    }
    setColsCluesSat(newColsSatisfied);
  }

  function handleClick(i, j) {
    if (waiting || gameCompleted){
      return;
    }
  
    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    let content;
    if (mode === 'paint') {
      content = '#';
    } else {
      content = 'X';
    }
     // Content to put in the clicked square.

    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    const queryS = `put("${content}", [${i},${j}], ${rowsCluesS}, ${colsCluesS}, ${squaresS}, ResGrid, RowSat, ColSat)`; // queryS = put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
    setWaiting(true);
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['ResGrid']);
         // Accede a RowSat y ColSat desde la respuesta de la consulta.
      const RowSat = response['RowSat'];
      const ColSat = response['ColSat'];

      const newrowsSatisfied = [...rowsSatisfied];
      newrowsSatisfied[i] = RowSat;
      setRowsCluesSat(newrowsSatisfied);

      const newcolsSatisfied = [...colsSatisfied];
      newcolsSatisfied[j] = ColSat;
      setColsCluesSat(newcolsSatisfied);
      }
      setWaiting(false);
    });
  }

  function handleModeChange() {
    // Cambiar entre los modos 'paint' y 'erase'
    setMode(mode === 'paint' ? 'erase' : 'paint');
  }

  if (!grid) {
    return null;
  }


  let statusText;
  if (rowsSatisfied.every(satisfied => satisfied) && colsSatisfied.every(satisfied => satisfied)) {
    statusText = "¡Level completed!";
  }else{
    statusText = "Keep playing";
  }

  return (
  <div className="game" style={{ display: 'flex', flexDirection:'column', justifyContent: 'center', alignItems: 'center', height: '100%', width: '100%' }}>
    <div className="league-spartan-text">
        Nonograma
    </div>
    <Board
      grid={grid}
      rowsClues={rowsClues}
      colsClues={colsClues}
      onClick={(i, j) => handleClick(i, j)}
      rowsSatisfied={rowsSatisfied}
      colsSatisfied={colsSatisfied}
      gameCompleted={gameCompleted}
    />
    <div className="game-info" style={{color:'#ece5f0'}}>
      {statusText}
      <div className="container">
        <input type="checkbox" id="check" className="switch-input" checked={mode === 'paint'} onChange={handleModeChange} />
        <label htmlFor="check" className="button switch-label"></label>
    </div>
    </div>
  </div>
  
    
  );
}

export default Game;
