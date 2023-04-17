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
    CALL llenarNavio(idPartidaAct, idA, idB);

    RETURN CONCAT('Partida creada correctamente id: ', idPartidaAct);

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS llenarNavio;
DELIMITER //
CREATE PROCEDURE llenarNavio(IN idPartidaP INT, IN idJ1 INT, IN idJ2 INT)
BEGIN

    INSERT INTO NAVIO (idPartida, jugador) VALUES (idPartidaP, idJ1);
    INSERT INTO NAVIO (idPartida, jugador) VALUES (idPartidaP, idJ2);

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS crearTablero;
DELIMITER //
CREATE PROCEDURE crearTablero(IN idPartidaP INT, IN idJ1 INT, IN idJ2 INT)
BEGIN

    DECLARE filas INT;
    SET filas = 1;

    WHILE filas <= 20 DO
        IF filas < 10 THEN
            INSERT INTO TABLERO (idPartida, jugador, fila) VALUES (idPartidaP, idJ1, filas);
        ELSE 
            INSERT INTO TABLERO (idPartida, jugador, fila) VALUES (idPartidaP, idJ2, filas);
        END IF;
        SET filas = filas + 1;
    END WHILE;

END //
DELIMITER ;

DROP FUNCTION IF EXISTS colocarNavio;
DELIMITER //
CREATE FUNCTION colocarNavio(idPartidaP INT, navio VARCHAR(30), columna CHAR(1), fila INT, orientacion INT) RETURNS VARCHAR(150)
BEGIN

    DECLARE username VARCHAR(255);
    DECLARE userId INT;
    DECLARE portaavionesF, acorazadoF, destructorF, submarinoF INT;
    DECLARE posiciones INT;
    DECLARE resultadoLL INT;

    SET username = USER();
    SELECT idJugador INTO userId FROM JUGADOR WHERE nombreJugador = username;
    SELECT portaaviones, acorazado, destructor, submarino INTO portaavionesF, acorazadoF, destructorF, submarinoF FROM NAVIO WHERE userId = jugador AND idPartidaP = idPartida;
    
    -- Verificamos que el usuario existe en la partida
    IF NOT EXISTS (SELECT 1 FROM PARTIDA WHERE (userId = jugadorA OR userId = jugadorB) AND idPartida = idPartidaP) THEN
        RETURN 'El jugador no se encuentra en la partida, o la partida no existe';
    END IF;

    -- Verificamos que las coordenadas indicadas son correctas
    IF (fila < 1 OR fila > 10 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J')) THEN
        RETURN 'Las coordenadas especificadas no son correctas.';
    END IF;

    -- Verificamos que tipo de navio se ha introducido
    IF navio NOT LIKE '%portaaviones%' OR navio NOT LIKE '%acorazado%' OR navio NOT LIKE '%destructor%' OR navio NOT LIKE '%submarino%' THEN
        RETURN 'El nombre del navio no corresponde';
    END IF;

    -- Verificamos si el estado de la partida es el de colocar naves
    IF NOT EXISTS (SELECT 1 FROM PARTIDA WHERE estado <> 0 AND idPartidaP = idPartida) THEN
        RETURN 'La partida no se encuentra en fase de colocar naves';
    END IF;

    IF navio LIKE '%portaaviones%' THEN
        IF portaavionesF < 1 THEN
            RETURN 'Ya hay un portaaviones desplegado';
        ELSEIF (fila > 5 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F')) THEN
            RETURN 'No se puede desplegar un portaaviones en esta posición';
        END IF;
        SET resultadoLL = llenado(idPartidaP, userId, fila, columna, 5, orientacion, 'P');
    ELSEIF navio LIKE '%acorazado%' THEN
        IF acorazadoF < 1 THEN
            RETURN 'Ya hay un acorazado desplegado';
        ELSEIF (fila > 6 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G')) THEN
            RETURN 'No se puede desplegar un acorazado en esta posición';
        END IF;
        SET resultadoLL = llenado(idPartidaP, userId, fila, columna, 4, orientacion, 'A');
    ELSEIF navio LIKE '%destructor%' THEN
        IF destructorF < 1 THEN
            RETURN 'Ya estan desplegados todos los destructores';
        ELSEIF (fila > 7 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H')) THEN
            RETURN 'No se puede desplegar un destructor en esta posición';
        END IF;
        SET resultadoLL = llenado(idPartidaP, userId, fila, columna, 3, orientacion, 'D');
    ELSEIF navio LIKE '%submarino%' THEN
        IF submarinoF < 1 THEN
            RETURN 'Ya hay un submarino desplegado';
        ELSEIF (fila > 8 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I')) THEN
            RETURN 'No se puede desplegar un submarino en esta posición';
        END IF;
        SET resultadoLL = llenado(idPartidaP, userId, fila, columna, 2, orientacion, 'S');
    END IF;

    IF resultadoLL = 0 THEN
        RETURN 'Navio colocado';
    END IF;
    RETURN 'El navio no se ha podido colocar';

END //
DELIMITER ;

DROP FUNCTION IF EXISTS llenado;
DELIMITER //
CREATE FUNCTION llenado(idPartidaAct INT, userIdAct INT, filaAct INT, col CHAR(1), ttl INT, orientacionAct INT, xim CHAR(1)) RETURNS INT
BEGIN

    DECLARE ttlR INT;
    DECLARE filaR INT;
    DECLARE colR CHAR(1);
    DECLARE resultado INT;

    SET ttlR = ttl - 1;
    SET filaR = filaAct;
    SET colR = col;

    IF ttl = 0 THEN
        RETURN 0;
    END IF;

    IF col = 'A' THEN
        IF (SELECT colA FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'B';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colB = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'B' THEN
        IF (SELECT colB FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'C';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colB = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'C' THEN
        IF (SELECT colC FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'D';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colC = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'D' THEN
        IF (SELECT colD FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'E';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colD = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'E' THEN
        IF (SELECT colE FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'F';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colE = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'F' THEN
        IF (SELECT colF FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'G';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colF = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'G' THEN
        IF (SELECT colG FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'H';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colG = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'H' THEN
        IF (SELECT colH FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'I';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colH = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'I' THEN
        IF (SELECT colI FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'J';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colI = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    ELSEIF col = 'J' THEN
        IF (SELECT colB FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            RETURN 1;
        ELSEIF ttl <> 0 THEN
            SET filaR = filaR + 1;
            UPDATE TABLERO SET colB = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            SET resultado = llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim);
        END IF;
    END IF;

    IF resultado = 0 THEN
        RETURN 0;
    ELSE
        RETURN 1;
    END IF;

END//
DELIMITER ;

SELECT logUsuario();

SELECT crearPartida('jose@localhost', 'erik@localhost');