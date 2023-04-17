import mysql.connector

USER = "erik"
HOST = "localhost"
PASSWD = "root"
WORKSPACE = "/home/erik/workspace/M2-PROY-UF3/"

admin = mysql.connector.connect(
  host=HOST,
  user=USER,
  password=PASSWD,
  database="mysql"
)

mycursor = admin.cursor()

FILES = ["HundirLaFlota.sql", "Usuarios.sql", "RutinasDelUsuario.sql"]
for FILE in FILES:
    with open(WORKSPACE + FILE, "r") as f:
        sql_script = f.read()
mycursor.execute(sql_script)