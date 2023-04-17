-- Active: 1681730644093@@localhost@3306@battleship

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
        IF filas <= 10 THEN
            INSERT INTO TABLERO (idPartida, jugador, fila) VALUES (idPartidaP, idJ1, filas);
        ELSE 
            INSERT INTO TABLERO (idPartida, jugador, fila) VALUES (idPartidaP, idJ2, filas-10);
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
    IF navio NOT LIKE '%portaaviones%' AND navio NOT LIKE '%acorazado%' AND navio NOT LIKE '%destructor%' AND navio NOT LIKE '%submarino%' THEN
        RETURN 'El nombre del navio no corresponde';
    END IF;

    -- Verificamos si el estado de la partida es el de colocar naves
    IF NOT EXISTS (SELECT 1 FROM PARTIDA WHERE estado = 0 AND idPartidaP = idPartida) THEN
        RETURN 'La partida no se encuentra en fase de colocar naves';
    END IF;

    IF navio LIKE '%portaaviones%' THEN
        IF portaavionesF < 1 THEN
            RETURN 'Ya hay un portaaviones desplegado';
        ELSEIF (fila > 6 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F')) THEN
            RETURN 'No se puede desplegar un portaaviones en esta posición';
        END IF;
        CALL llenado(idPartidaP, userId, fila, columna, 5, orientacion, 'P', @resultadoF);
        SET portaavionesF = portaavionesF - 1;
    ELSEIF navio LIKE '%acorazado%' THEN
        IF acorazadoF < 1 THEN
            RETURN 'Ya hay un acorazado desplegado';
        ELSEIF (fila > 7 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G')) THEN
            RETURN 'No se puede desplegar un acorazado en esta posición';
        END IF;
        CALL llenado(idPartidaP, userId, fila, columna, 4, orientacion, 'A', @resultadoF);
        SET acorazadoF = acorazadoF - 1;
    ELSEIF navio LIKE '%destructor%' THEN
        IF destructorF < 1 THEN
            RETURN 'Ya estan desplegados todos los destructores';
        ELSEIF (fila > 9 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H')) THEN
            RETURN 'No se puede desplegar un destructor en esta posición';
        END IF;
        CALL llenado(idPartidaP, userId, fila, columna, 3, orientacion, 'D', @resultadoF);
        SET destructorF = destructorF - 1;
    ELSEIF navio LIKE '%submarino%' THEN
        IF submarinoF < 1 THEN
            RETURN 'Ya hay un submarino desplegado';
        ELSEIF (fila > 8 OR columna NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I')) THEN
            RETURN 'No se puede desplegar un submarino en esta posición';
        END IF;
        CALL llenado(idPartidaP, userId, fila, columna, 2, orientacion, 'S', @resultadoF);
        SET submarinoF = submarinoF - 1;
    END IF;

    SET resultadoLL = @resultadoF;

    IF resultadoLL = 0 THEN
        UPDATE NAVIO SET portaaviones=portaavionesF, acorazado=acorazadoF, destructor=destructorF, submarino=submarinoF WHERE userId = jugador AND idPartidaP = idPartida;
        RETURN 'Navio colocado';
    END IF;
    RETURN 'El navio no se ha podido colocar';

END //
DELIMITER ;

DROP PROCEDURE IF EXISTS llenado;
DELIMITER //
CREATE PROCEDURE llenado(IN idPartidaAct INT, IN userIdAct INT, IN filaAct INT, IN col CHAR(1), IN ttl INT, IN orientacionAct INT, IN xim CHAR(1), OUT resultado INT)
`whole_procedure`:
BEGIN

    DECLARE ttlR INT;
    DECLARE filaR INT;
    DECLARE colR CHAR(1);
    DECLARE resultadoAct INT;

    SET max_sp_recursion_depth=255;
    SET ttlR = ttl - 1;
    SET filaR = filaAct;
    SET colR = col;

    IF ttl = 0 THEN
        SET resultado = 0;
        LEAVE `whole_procedure`;
    END IF;

    IF col = 'A' THEN
        IF (SELECT colA FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'B';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colA = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'B' THEN
        IF (SELECT colB FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'C';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colB = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'C' THEN
        IF (SELECT colC FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'D';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colC = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'D' THEN
        IF (SELECT colD FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'E';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colD = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'E' THEN
        IF (SELECT colE FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'F';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colE = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'F' THEN
        IF (SELECT colF FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'G';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colF = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'G' THEN
        IF (SELECT colG FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'H';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colG = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'H' THEN
        IF (SELECT colH FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'I';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colH = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'I' THEN
        IF (SELECT colI FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            IF orientacionAct = 0 THEN
                SET colR = 'J';
            ELSE
                SET filaR = filaR + 1;
            END IF;
            UPDATE TABLERO SET colI = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    ELSEIF col = 'J' THEN
        IF (SELECT colB FROM TABLERO WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila) <> ' ' THEN
            SET resultado = 1;
            LEAVE `whole_procedure`;
        ELSEIF ttl <> 0 THEN
            SET filaR = filaR + 1;
            UPDATE TABLERO SET colB = xim WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
            CALL llenado(idPartidaAct, userIdAct, filaR, colR, ttlR, orientacionAct, xim, @resultadoF2);
        END IF;
    END IF;

    IF @resultadoF2 = 0 THEN
        SET resultado = 0;
    ELSE
        SET resultado = 1;
        UPDATE TABLERO SET colB = ' ' WHERE userIdAct = jugador AND idPartida = idPartidaAct AND filaAct = fila;
    END IF;

END//
DELIMITER ;

DROP PROCEDURE IF EXISTS mostrarTablero;
DELIMITER //
CREATE PROCEDURE mostrarTablero(IN idPartidaP INT)
`whole_proc`:
BEGIN

    DECLARE usuario VARCHAR(255);
    DECLARE userId INT;

    SET usuario = USER();
    SELECT idJugador INTO userId FROM JUGADOR WHERE usuario = nombreJugador;

    SELECT fila AS 'X', colA AS 'A', colB AS 'B', colC AS 'C', colD AS 'D', colE AS 'E', colF AS 'F', colG AS 'G', colH AS 'H', colI AS 'I', colJ AS 'J' FROM TABLERO WHERE idPartidaP = idPartida AND userId = jugador;

END//
DELIMITER ;

DROP TRIGGER IF EXISTS actualizarEstado;
DELIMITER //
CREATE TRIGGER actualizarEstado AFTER UPDATE ON NAVIO FOR EACH ROW
`whole_trigger`:
BEGIN
    
    DECLARE idPartidaT, estadoAct, userId1, userId2, user1Des, user2Des, p1, a1, d1, s1, p2, a2, d2, s2, idJA, idJB INT;

    SET idPartidaT = OLD.idPartida;
    SELECT estado INTO estadoAct FROM PARTIDA WHERE idPartidaT = idPartida;
    SET userId1 = OLD.jugador;
    SELECT jugador INTO userId2 FROM NAVIO WHERE jugador <> userId1 AND idPartidaT = idPartida;
    SELECT portaaviones, acorazado, destructor, submarino INTO  p1, a1, d1, s1 FROM NAVIO WHERE idPartida = idPartidaT AND userId1 = jugador;
    SELECT portaaviones, acorazado, destructor, submarino INTO  p2, a2, d2, s2 FROM NAVIO WHERE idPartida = idPartidaT AND userId2 = jugador;
    SELECT destruidos INTO user1Des FROM NAVIO WHERE idPartidaT = idPartida AND userId1 = jugador;
    SELECT destruidos INTO user2Des FROM NAVIO WHERE idPartidaT = idPartida AND userId2 = jugador;
    SELECT jugadorA, jugadorB INTO idJA, idJB FROM PARTIDA WHERE idPartidaT = idPartida;

    -- Verificamos si se ha terminado la fase de colocar navios
    IF EXISTS (SELECT 1 FROM PARTIDA WHERE estado = 0 AND idPartidaT = idPartida) AND p1 = 0 AND a1 = 0 AND d1 = 0 AND s1 = 0 AND p2 = 0 AND a2 = 0 AND d2 = 0 AND s2 = 0 THEN
        UPDATE PARTIDA SET estado = 1 WHERE idPartida = idPartidaT;
        LEAVE `whole_trigger`;
    END IF;

    -- Verificamos si algun jugador ha destruido todos los navios
    IF user1Des = 4 OR user2Des = 4 THEN
        IF idJA = userId1 AND user1Des = 4 THEN
            UPDATE PARTIDA SET estado = 4 WHERE idPartida = idPartidaT;
            UPDATE JUGADOR SET partidasGanadas = partidasGanadas + 1 WHERE idJugador = idJB;
            UPDATE JUGADOR SET partidasPerdidas = partidasPerdidas + 1 WHERE idJugador = idJA;
        ELSE 
            UPDATE PARTIDA SET estado = 3 WHERE idPartida = idPartidaT;
            UPDATE JUGADOR SET partidasGanadas = partidasGanadas + 1 WHERE idJugador = idJA;
            UPDATE JUGADOR SET partidasPerdidas = partidasPerdidas + 1 WHERE idJugador = idJB;
        END IF;
    END IF;

    -- Verificamos si se tiene que iterar el turno del jugador
    IF OLD.tiros < NEW.tiros THEN
        IF estadoAct = 1 THEN
            UPDATE PARTIDA SET estado = 2 WHERE idPartida = idPartidaT;
        ELSE 
            UPDATE PARTIDA SET estado = 1 WHERE idPartida = idPartidaT;
        END IF;
    END IF;

END//
DELIMITER ;

DROP FUNCTION IF EXISTS disparar;
CREATE FUNCTION disparar(idPartidaF INT, coorX CHAR(1), coorY INT) RETURNS VARCHAR(160)
BEGIN

    DECLARE username VARCHAR(255);
    DECLARE userId, userIdE INT;
    DECLARE estadoAct INT;
    DECLARE tipoN CHAR(1);

    SET username = USER();
    SELECT idJugador INTO userId FROM JUGADOR WHERE nombreJugador = username;
    SELECT jugador INTO userIde FROM NAVIO WHERE idPartidaF = idPartida AND userId <> jugador;
    SELECT estado INTO estadoAct FROM PARTIDA WHERE idPartidaF = idPartida;

    -- Verificamos que el usuario existe en la partida
    IF NOT EXISTS (SELECT 1 FROM PARTIDA WHERE (userId = jugadorA OR userId = jugadorB) AND idPartida = idPartidaF) THEN
        RETURN 'El jugador no se encuentra en la partida, o la partida no existe';
    END IF;

    -- Verificamos que las coordenadas indicadas son correctas
    IF (coorY < 1 OR coorY > 10 OR coorX NOT IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J')) THEN
        RETURN 'Las coordenadas especificadas no son correctas.';
    END IF;

    -- Verificamos que la partida en fase de tiro
    IF estadoAct = 3 OR estadoAct = 4 THEN
        RETURN 'La partida ha finalizado. Has perdido.';
    END IF;

    -- Verificamos si es su turno
    IF estadoAct = 1 AND NOT EXISTS (SELECT 1 FROM PARTIDA WHERE idPartidaF = idPartida AND userId = jugadorA) THEN
        RETURN 'Es el turno del jugador 1';
    ELSEIF estadoAct = 2 AND NOT EXISTS (SELECT 1 FROM PARTIDA WHERE idPartidaF = idPartida AND userId = jugadorB) THEN
        RETURN 'Es el turno del jugador 2';
    END IF;

    UPDATE NAVIO SET tiros = tiros + 1 WHERE idPartidaF = idPartida AND jugador = userId;

    IF coorX = 'A' THEN
        SELECT colA INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colA = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'B' THEN
        SELECT colB INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colB = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'C' THEN
        SELECT colC INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colC = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'D' THEN
        SELECT colD INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colD = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'E' THEN
        SELECT colE INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colE = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'F' THEN
        SELECT colF INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colF = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'G' THEN
        SELECT colG INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colG = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'H' THEN
        SELECT colH INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colH = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'I' THEN
        SELECT colI INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colI = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    ELSEIF coorX = 'J' THEN
        SELECT colJ INTO tipoN FROM TABLERO WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
        UPDATE TABLERO SET colJ = 'X' WHERE idPartidaF = idPartida AND coorY = fila AND jugador = userIdE;
    END IF;

    IF tipoN = ' ' OR tipoN = 'X' THEN
        RETURN 'MISS: AGUA';
    ELSEIF tipoN = 'P' THEN
        CALL hundirNavio('P', idPartidaF, userIdE);
        UPDATE NAVIO SET destruidos = destruidos + 1 WHERE idPartidaF = idPartida AND jugador = userIdE;
        UPDATE JUGADOR SET naviosHundidos = naviosHundidos + 1 WHERE idJugador = userId;
        RETURN 'IMPACTO: portaaviones enemigo destruido';
    ELSEIF tipoN= 'A' THEN
        CALL hundirNavio('A', idPartidaF, userIdE);
        UPDATE NAVIO SET destruidos = destruidos + 1 WHERE idPartidaF = idPartida AND jugador = userIdE;
        UPDATE JUGADOR SET naviosHundidos = naviosHundidos + 1 WHERE idJugador = userId;
        RETURN 'IMPACTO: acorazado enemigo destruido';
    ELSEIF tipoN = 'D' THEN
        CALL hundirNavio('D', idPartidaF, userIdE);
        UPDATE NAVIO SET destruidos = destruidos + 1 WHERE idPartidaF = idPartida AND jugador = userIdE;
        UPDATE JUGADOR SET naviosHundidos = naviosHundidos + 1 WHERE idJugador = userId;
        RETURN 'IMPACTO: destructor enemigo destruido';
    ELSEIF tipoN = 'S' THEN
        CALL hundirNavio('S', idPartidaF, userIdE);
        UPDATE NAVIO SET destruidos = destruidos + 1 WHERE idPartidaF = idPartida AND jugador = userIdE;
        UPDATE JUGADOR SET naviosHundidos = naviosHundidos + 1 WHERE idJugador = userId;
        RETURN 'IMPACTO: submarino enemigo destruido';
    END IF;

END//
DELIMITER ;

DROP PROCEDURE IF EXISTS hundirNavio;
DELIMITER //
CREATE PROCEDURE hundirNavio(IN tipoNavio CHAR(1), IN idPartidaP INT, IN idJugadorP INT)
BEGIN

    DECLARE contador INT;

    SET contador = 1;
    WHILE contador <= 10 DO
        UPDATE TABLERO SET colA = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colA = tipoNavio;
        UPDATE TABLERO SET colB = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colB = tipoNavio;
        UPDATE TABLERO SET colC = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colC = tipoNavio;
        UPDATE TABLERO SET colD = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colD = tipoNavio;
        UPDATE TABLERO SET colE = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colE = tipoNavio;
        UPDATE TABLERO SET colF = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colF = tipoNavio;
        UPDATE TABLERO SET colG = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colG = tipoNavio;
        UPDATE TABLERO SET colH = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colH = tipoNavio;
        UPDATE TABLERO SET colI = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colI = tipoNavio;
        UPDATE TABLERO SET colJ = ' ' WHERE idPartidaP = idPartida AND contador = fila AND jugador = idJugadorP AND colJ = tipoNavio;
        SET contador = contador + 1;
    END WHILE;

END//
DELIMITER ;