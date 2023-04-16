/* Gestión de usuarios (creación y administración de permisos) */
/* ejecutar cómo root */

USE battleship;

-- Creación de usuarios
DROP USER IF EXISTS 'jose'@'localhost';
DROP USER IF EXISTS 'dolores'@'localhost';
DROP USER IF EXISTS 'alan'@'localhost';
DROP USER IF EXISTS 'gonzalo'@'localhost';

CREATE USER 'jose'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'dolores'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'alan'@'localhost' IDENTIFIED BY 'root';
CREATE USER 'gonzalo'@'localhost' IDENTIFIED BY 'root';

-- Administración de los permisos (principalmente execute) únicamente podrán trabajar con rutinas
GRANT EXECUTE ON FUNCTION logUsuario TO 'jose'@'localhost', 'dolores'@'localhost', 'alan'@'localhost', 'gonzalo'@'localhost';