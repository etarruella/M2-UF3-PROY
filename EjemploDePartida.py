import mariadb
import sys

ADMIN_USER = "erik"
ADMIN_HOST = "localhost"
ADMIN_PASSWD = "root"
WORKSPACE = "/home/erik/workspace/M2-UF3-PROY/"

def ejecutar_consulta(usuario, contraseña, consulta):
	mydb = mariadb.connect(
		host="localhost",
		user=usuario,
		password=contraseña,
		database="battleship"
	)
	
	mycursor = mydb.cursor()

	mycursor.execute(consulta)

	mydb.commit()

	resultados = mycursor.fetchall()

	mydb.close()
    
	return resultados

def ejecutar_vista(usuario, contraseña, consulta):
	mydb = mariadb.connect(
		host="localhost",
		user=usuario,
		password=contraseña,
		database="battleship"
	)
	
	mycursor = mydb.cursor()

	mycursor.execute(consulta)

	resultados = mycursor.fetchall()

	mydb.close()
    
	return resultados

# Creamos la partida con uno de los usuarios
print(ejecutar_consulta("jose", "root", "SELECT logUsuario();"))
print(ejecutar_consulta("gonzalo", "root", "SELECT logUsuario();"))


# Creamos la partida con uno de los usuarios
print(ejecutar_consulta("jose", "root", "SELECT crearPartida('jose@localhost', 'gonzalo@localhost');"))

# Colocamos los navios de los usuarios
print(ejecutar_consulta("jose", "root", "SELECT colocarNavio(1, 'portaaviones', 'C', 2, 0);"))
print(ejecutar_consulta("jose", "root", "SELECT colocarNavio(1, 'acorazado', 'G', 4, 1);"))
print(ejecutar_consulta("jose", "root", "SELECT colocarNavio(1, 'destructor', 'C', 4, 0);"))
print(ejecutar_consulta("jose", "root", "SELECT colocarNavio(1, 'submarino', 'B', 6, 1);"))

print(ejecutar_consulta("gonzalo", "root", "SELECT colocarNavio(1, 'portaaviones', 'D', 5, 0);"))
print(ejecutar_consulta("gonzalo", "root", "SELECT colocarNavio(1, 'acorazado', 'B', 7, 1);"))
print(ejecutar_consulta("gonzalo", "root", "SELECT colocarNavio(1, 'destructor', 'E', 3, 0);"))
print(ejecutar_consulta("gonzalo", "root", "SELECT colocarNavio(1, 'submarino', 'B', 2, 0);"))

# Disparamos
print(ejecutar_consulta("jose", "root", "SELECT disparar(1, 'C', 2);"))
print(ejecutar_consulta("gonzalo", "root", "SELECT disparar(1, 'G', 4);"))
print(ejecutar_consulta("jose", "root", "SELECT disparar(1, 'C', 2);"))
print(ejecutar_consulta("gonzalo", "root", "SELECT disparar(1, 'C', 2);"))
print(ejecutar_consulta("jose", "root", "SELECT disparar(1, 'C', 2);"))
print(ejecutar_consulta("gonzalo", "root", "SELECT disparar(1, 'C', 4);"))
print(ejecutar_consulta("jose", "root", "SELECT disparar(1, 'C', 2);"))
print(ejecutar_consulta("gonzalo", "root", "SELECT disparar(1, 'B', 6);"))
