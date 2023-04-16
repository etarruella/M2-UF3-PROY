-- Active: 1680536394058@@127.0.0.1@3306@battleship
/* Estructura de la BBDD */

DROP DATABASE IF EXISTS battleship;
CREATE DATABASE battleship;
USE battleship;

-- Creacuón de las tablas
CREATE TABLE TABLERO (
    idPartida INT,
    fila INT,
    jugador INT,
    colA CHAR(1) DEFAULT ' ',
    colB CHAR(1) DEFAULT ' ',
    colC CHAR(1) DEFAULT ' ',
    colD CHAR(1) DEFAULT ' ',
    colE CHAR(1) DEFAULT ' ',
    colF CHAR(1) DEFAULT ' ',
    colG CHAR(1) DEFAULT ' ',
    colH CHAR(1) DEFAULT ' ',
    colI CHAR(1) DEFAULT ' ',
    colJ CHAR(1) DEFAULT ' ',
    PRIMARY KEY (idPartida, fila, jugador)
);

CREATE TABLE PARTIDA (
    idPartida INT AUTO_INCREMENT,
    jugadorA INT,
    jugadorB INT,
    estado INT DEFAULT 0,
    PRIMARY KEY (idPartida)
);

CREATE TABLE JUGADOR (
    idJugador INT AUTO_INCREMENT,
    nombreJugador VARCHAR(50),
    partidasGanadas INT DEFAULT 0,
    partidasPerdidas INT DEFAULT 0,
    naviosHundidos INT DEFAULT 0,
    PRIMARY KEY (idJugador)
);

CREATE TABLE ESTADO (
    idEstado INT,
    nombreEstado VARCHAR(50),
    PRIMARY KEY (idEstado)
);

-- Relaciones de las tablas (FK)
ALTER TABLE PARTIDA ADD CONSTRAINT fkPartidaJ1 FOREIGN KEY (jugadorA) REFERENCES JUGADOR(idJugador) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE PARTIDA ADD CONSTRAINT fkPartidaJ2 FOREIGN KEY (jugadorB) REFERENCES JUGADOR(idJugador) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE PARTIDA ADD CONSTRAINT fkPartidaEstado FOREIGN KEY (estado) REFERENCES ESTADO(idEstado) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE TABLERO ADD CONSTRAINT fkTableroPartida FOREIGN KEY (idPartida) REFERENCES PARTIDA(idPartida) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE TABLERO ADD CONSTRAINT fkTableroJugador FOREIGN KEY (jugador) REFERENCES JUGADOR(idJugador) ON UPDATE CASCADE ON DELETE CASCADE;

-- Añadimos los estados posibles de una partida (unica tabla que no será modificada por rutinas)
INSERT INTO ESTADO VALUES (0, "Turno jugador 1");
INSERT INTO ESTADO VALUES (1, "Turno jugador 2");
INSERT INTO ESTADO VALUES (2, "Ganada por jugador 1");
INSERT INTO ESTADO VALUES (3, "Ganada por jugador 1");

-- No rellenamos las demás tablas, pues, estas serán gestionadas por las rutinas