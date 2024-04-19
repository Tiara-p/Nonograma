import React, { useState } from 'react';

function ToggleButton() {
    // Estado para almacenar el modo actual (inicialmente "pintar")
    const [mode, setMode] = useState('strike');

    // Función para cambiar entre los modos
    const toggleMode = () => {
        if (mode === 'paint') {
            // Cambiar a modo "tachar"
            setMode('strike');
        } else {
            // Cambiar a modo "pintar"
            setMode('paint');
        }
    };

    return (
        <button className="toggle-button" onClick={toggleMode}>
            {mode === 'paint' ? 'Pintar' : 'Tachar'}
        </button>
    );
}

export default ToggleButton;
