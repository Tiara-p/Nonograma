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
  const [rowSatisfied, setRowsCluesSat] = useState([]);
  const [colSatisfied, setColsCluesSat] = useState([]);

  useEffect(() => {
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
  }, []);

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

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting) {
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

      const newRowSatisfied = [...rowSatisfied];
      newRowSatisfied[i] = RowSat;
      setRowsCluesSat(newRowSatisfied);

      const newColSatisfied = [...colSatisfied];
      newColSatisfied[j] = ColSat;
      setColsCluesSat(newColSatisfied);
      //alert("New Col Satisfied: " + JSON.stringify(newColSatisfied));

      // Muestra los valores en una alerta.
      //alert("RowSat: " + RowSat + ", ColSat: " + ColSat);
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

  const statusText = 'Keep playing!';
  return (
    <div className="game">
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        rowSatisfied={rowSatisfied}
        colSatisfied={colSatisfied}
        onClick={(i, j) => handleClick(i, j)}
      />
      <div className="game-info">
        {statusText}
      </div>
      <div class="container">
        <input type="checkbox" id="check" class="switch-input" checked={mode === 'paint'} onChange={handleModeChange} />
        <label for="check" class="button switch-label">
        </label>
      </div>

    </div>
    
  );
}

export default Game;