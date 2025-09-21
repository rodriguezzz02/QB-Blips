---

## 📌 QB Blip Manager

Gestor de blips para servidores QBCore 2025 con soporte a ox_lib y oxmysql.
Permite a los administradores crear, editar y eliminar blips dinámicamente desde un menú en el juego, con persistencia en base de datos.


---

## 🚀 Características

Comando /createblips (solo administradores).

Menú principal con 3 opciones:

Crear Blip

Editar Blip

Eliminar Blip


Crear Blip:

Nombre interno.

Label (nombre visible en mapa).

ID del sprite (icono del blip).

Coordenadas (posición actual o introducir manualmente).

Tamaño (scale).

Color.

Opción para hacerlo visible solo a un trabajo específico.


Editar Blip:

Lista de blips existentes.

Formulario editable con todos los valores.

Confirmación antes de actualizar.


Eliminar Blip:

Lista de blips creados.

Confirmación antes de borrar.


Persistencia con oxmysql:

Los blips se guardan en base de datos.

Se cargan automáticamente al iniciar el recurso.

Cambios en blips (crear/editar/eliminar) actualizan la DB y a todos los jugadores en vivo.




---
```

## 📂 Archivos del recurso

qb-blipmanager/
 ├── fxmanifest.lua   → Manifest del recurso
 ├── server.lua       → Lógica del servidor (oxmysql + sync)
 ├── client.lua       → Menús con ox_lib + render de blips
 └── blips.sql        → Script SQL para crear la tabla de blips

```
---

## 🛠️ Instalación

1. Copia la carpeta qb-blipmanager en tu directorio resources/[standalone].


2. Importa el archivo blips.sql en tu base de datos.
```

CREATE TABLE IF NOT EXISTS blips (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  label VARCHAR(50) NOT NULL,
  sprite INT NOT NULL,
  scale FLOAT NOT NULL,
  color INT NOT NULL,
  x FLOAT NOT NULL,
  y FLOAT NOT NULL,
  z FLOAT NOT NULL,
  jobOnly TINYINT(1) DEFAULT 0,
  jobName VARCHAR(50) DEFAULT NULL
);

```
3. Asegúrate de tener instalados:

- **[qb-core](https://github.com/qbcore-framework/qb-core)**  
- **[ox_lib](https://github.com/overextended/ox_lib)**  
- **[oxmysql](https://github.com/overextended/oxmysql)**  



4. Añade en tu server.cfg:
```
ensure oxmysql
ensure ox_lib
ensure qb-core
ensure qb-blipmanager
```



---

## ⚡ Uso

Ejecuta el comando /createblips en el juego (solo admins).

Se abrirá el menú con opciones para crear, editar o eliminar blips.

Los cambios se aplican en tiempo real y se guardan en la base de datos.



---

## 📜 Permisos

El comando /createblips solo está disponible para usuarios con el grupo admin en QBCore.
Si usas un sistema de permisos diferente, modifica el isAdmin() en server.lua.


---

## 🧩 Dependencias

qb-core

ox_lib

oxmysql



---

## 📝 Créditos

Creado para la comunidad de QBCore ES/Latam.
Autor: TuNombre.


---
