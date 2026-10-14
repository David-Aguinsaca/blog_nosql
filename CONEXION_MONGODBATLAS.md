# Conexión a MongoDB Atlas mediante mongosh (Ubuntu 24.04 LTS)

Guía rápida de instalación de MongoDB Shell (`mongosh`) y comandos para conectarse al clúster de base de datos del proyecto.

---

## 1. Parámetros de Conexión

* **Host:** `appambiente.astsdqz.mongodb.net`
* **Usuario:** `brayanaguinsaca_db_user`
* **Contraseña:** `<clave>` *(reemplaza este valor por tu contraseña real)*
* **Puerto:** `27017` (resuelto automáticamente mediante protocolo SRV)

---

## 2. Instalación de `mongosh` en Ubuntu 24.04 LTS

Ejecuta los siguientes comandos en tu terminal:

### Paso 1: Instalar dependencias previas
```bash
sudo apt update
sudo apt install -y gnupg curl
```

### Paso 2: Importar la clave GPG oficial de MongoDB
```bash
curl -fsSL [https://www.mongodb.org/static/pgp/server-7.0.asc](https://www.mongodb.org/static/pgp/server-7.0.asc) | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
  ```

### Paso 3: Agregar el repositorio oficial
```bash
  echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] [https://repo.mongodb.org/apt/ubuntu](https://repo.mongodb.org/apt/ubuntu) jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
```

### Paso 4: Actualizar repositorios e instalar mongosh
```bash
sudo apt update
sudo apt install -y mongodb-mongosh
```

### 3. Conexión a la Base de Datos
```bash
mongosh "mongodb+srv://appambiente.astsdqz.mongodb.net/" --apiVersion 1 --username brayanaguinsaca_db_user
```