USE battleship;

DROP FUNCTION IF EXISTS logUsuario;
DELIMITER //
CREATE FUNCTION logUsuario() RETURNS VARCHAR(255)
BEGIN

    DECLARE username VARCHAR(255);
    SET username = USER();

    IF NOT EXISTS (SELECT 1 FROM JUGADOR WHERE nombreJugador = username) THEN
        INSERT INTO JUGADOR (nombreJugador) VALUES (username);
        RETURN CONCAT('Usuario: ', username, ' registrado correctamente.');
    END IF;

    RETURN CONCAT('Usuario: ', username, ' ya esta registrado');

END //
DELIMITER ;

DROP FUNCTION IF EXISTS crearPartida;
DELIMITER //
CREATE FUNCTION crearPartida(nombreJugador1 VARCHAR(50), nombreJugador2 VARCHAR(50)) RETURNS VARCHAR(50)
BEGIN

    DECLARE idA, idB INT;
    DECLARE idPartidaAct INT;

    IF (NOT EXISTS (SELECT 1 FROM JUGADOR WHERE nombreJugador = nombreJugador1)) OR (NOT EXISTS (SELECT 1 FROM JUGADOR WHERE nombreJugador = nombreJugador2)) THEN
        RETURN 'Uno de los jugadores no existe';
    END IF;

    SELECT idJugador INTO idA FROM JUGADOR WHERE nombreJugador1 = nombreJugador;
    SELECT idJugador INTO idB FROM JUGADOR WHERE nombreJugador2 = nombreJugador;

    INSERT INTO PARTIDA (jugadorA, jugadorB) VALUES (idA, idB);

    SELECT idPartida INTO idPartidaAct FROM PARTIDA ORDER BY idPartida DESC LIMIT 1;

    CALL crearTablero(idPartidaAct, idA, idB);

    RETURN 'Partida creada correctamente';

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS crearTablero;
DELIMITER //
CREATE PROCEDURE crearTablero(IN idPartidaP INT, IN idJ1 INT, IN idJ2 INT)
BEGIN

    DECLARE filas INT;
    SET filas = 1;

    WHILE filas < 20 DO
        IF filas < 10 THEN
            INSERT INTO TABLERO (idPartida, jugador, fila) VALUES (idPartidaP, idJ1, filas);
        ELSE 
            INSERT INTO TABLERO (idPartida, jugador, fila) VALUES (idPartidaP, idJ2, filas);
        END IF;
        SET filas = filas + 1;
    END WHILE;

END //
DELIMITER ;

SELECT logUsuario();

SELECT crearPartida('jose@localhost', 'erik@localhost');