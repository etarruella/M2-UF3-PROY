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

cursor_ad = admin.cursor()

FILE = "HundirLaFlota.sql"

with open(WORKSPACE + FILE, "r") as f:
    sql_script = f.read()
cursor_ad.execute(sql_script)

user1 = mysql.connector.connect(
  host="localhost",
  user="gonzalo",
  password="root",
  database="battleship"
)

user2 = mysql.connector.connect(
  host="localhost",
  user="jose",
  password="root",
  database="battleship"
)

cursor_u1 = user1.cursor()
cursor_u2 = user2.cursor()

cursor_u1.execute("SELECT logUsuario()")
cursor_u2.execute("SELECT logUsuario()")