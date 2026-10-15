# Nonograma con React y Prolog

Aplicación web interactiva para jugar un **nonograma** (también conocido como picross). La interfaz está desarrollada con React y la lógica del tablero —validación de pistas y búsqueda de la solución— está implementada en Prolog, expuesta a la aplicación mediante Pengines.

## Funcionalidades

- Tablero interactivo con pistas para filas y columnas.
- Marcar y desmarcar celdas mientras se resuelve el puzzle.
- Indicador de las pistas que ya se satisfacen.
- Opción para mostrar la solución y modo de autocompletado.
- Validación y resolución del nonograma en Prolog.

## Tecnologías

- React 18 y Create React App.
- SWI-Prolog y la biblioteca Pengines.
- JavaScript, CSS y Prolog.

## Requisitos

- [Node.js](https://nodejs.org/) y npm.
- [SWI-Prolog](https://www.swi-prolog.org/Download.html).

## Cómo ejecutar el proyecto

Se necesitan **dos terminales**, una para el servidor Prolog y otra para React. Ejecutá ambos comandos desde la carpeta raíz del repositorio.

### 1. Iniciar el servidor Pengines

En la primera terminal:

```powershell
cd pengines_server
swipl run.pl
```

Dejá esta terminal abierta mientras usás la aplicación. El servidor queda disponible en [http://localhost:3030](http://localhost:3030). La consola de administración está en [http://localhost:3030/admin/server.html](http://localhost:3030/admin/server.html).

> Ejecutá `swipl run.pl` **desde `pengines_server`**; no ejecutes `swipl pengines_server/run.pl` desde la raíz, porque el servidor espera rutas relativas a su directorio.

### 2. Iniciar la aplicación React

En una segunda terminal, volvé a la raíz del repositorio si fuera necesario y ejecutá:

```powershell
npm install
npm start
```

La aplicación se abrirá en [http://localhost:3000](http://localhost:3000). Mantené las dos terminales abiertas: React necesita comunicarse con el servidor Prolog.

## Estructura principal

```text
src/                           Interfaz React y cliente Pengines
pengines_server/apps/proylcc/  Predicados Prolog y puzzle inicial
public/                        HTML y recursos públicos
```

El puzzle inicial está definido en `pengines_server/apps/proylcc/init.pl`. Si modificás el código Prolog, reiniciá el servidor Pengines para cargar los cambios.