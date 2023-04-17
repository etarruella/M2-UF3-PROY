-- Active: 1681730644093@@localhost@3306@battleship

/* Gestión de usuarios (creación y administración de permisos) */
/* ejecutar cómo root */

USE battleship;

-- Creación de usuarios
DROP USER IF EXISTS 'jose'@'localhost';
DROP USER IF EXISTS 'erik'@'localhost';
DROP USER IF EXISTS 'dolores'@'localhost';
DROP USER IF EXISTS 'alan'@'localhost';
DROP USER IF EXISTS 'gonzalo'@'localhost';

CREATE USER 'jose'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'erik'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'dolores'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'alan'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'gonzalo'@'localhost' IDENTIFIED BY 'root';

-- Administración de los permisos (principalmente execute) únicamente podrán trabajar con rutinas
GRANT EXECUTE ON FUNCTION logUsuario TO 'jose'@'localhost', 'dolores'@'localhost', 'alan'@'localhost', 'gonzalo'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'erik'@'localhost' WITH GRANT OPTION;
GRANT EXECUTE ON FUNCTION crearPartida TO 'jose'@'localhost', 'dolores'@'localhost', 'alan'@'localhost', 'gonzalo'@'localhost';
GRANT EXECUTE ON FUNCTION colocarNavio TO 'jose'@'localhost', 'dolores'@'localhost', 'alan'@'localhost', 'gonzalo'@'localhost';
GRANT EXECUTE ON FUNCTION disparar TO 'jose'@'localhost', 'dolores'@'localhost', 'alan'@'localhost', 'gonzalo'@'localhost';
GRANT EXECUTE ON PROCEDURE mostrarTablero TO 'jose'@'localhost', 'dolores'@'localhost', 'alan'@'localhost', 'gonzalo'@'localhost';