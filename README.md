# 🌱 TerraBlog - Plataforma Móvil de Conciencia Ambiental (NoSQL MongoDB Demo)

Aplicación móvil desarrollada en **Flutter** conectada directamente a una base de datos NoSQL en **MongoDB** para la divulgación y debate sobre sostenibilidad, conservación ecológica, reforestación urbana y prácticas de cero residuos.

---

## 🍃 Base de Datos NoSQL: MongoDB en Docker

El proyecto incluye configuración de Docker Compose para levantar MongoDB 7.0 con autenticación habilitada y precarga automática de colecciones e índices mediante un script de inicialización.

### 🐘 Credenciales y Configuración de MongoDB

| Parámetro | Usuario de Aplicación | Usuario Administrador (Root) |
| :--- | :--- | :--- |
| **Base de Datos** | `ecoblog_db` | `admin` |
| **Usuario** | `ecouser` | `admin` |
| **Contraseña** | `ecopassword123` | `adminpassword123` |
| **Puerto Host** | `27017` | `27017` |
| **Base de Autenticación** | `ecoblog_db` | `admin` |

### 🔐 Variables de Entorno (`.env` y `.env.example`)

La aplicación carga la configuración y credenciales de MongoDB desde un archivo `.env` mediante `flutter_dotenv`:

```properties
MONGO_HOST=127.0.0.1
MONGO_PORT=27017
MONGO_DB_NAME=ecoblog_db
MONGO_USER=ecouser
MONGO_PASSWORD=ecopassword123
```

Para configurar un nuevo entorno:
```bash
cp .env.example .env
```
*(Nota: El archivo `.env` se encuentra ignorado en `.gitignore` para proteger las credenciales, mientras que `.env.example` permanece versionado como plantilla).*

### 🧭 Conexión desde MongoDB Compass

Abre **MongoDB Compass** y utiliza cualquiera de las siguientes URI de conexión:

- **Conexión de Aplicación (Recomendada):**
  ```text
  mongodb://ecouser:ecopassword123@localhost:27017/ecoblog_db?authSource=ecoblog_db
  ```

- **Conexión como Administrador Root:**
  ```text
  mongodb://admin:adminpassword123@localhost:27017/admin?authSource=admin
  ```

### 📦 Comandos de Docker Compose

- **Iniciar el contenedor de MongoDB en segundo plano:**
  ```bash
  docker compose up -d
  ```

- **Verificar el estado del contenedor y logs:**
  ```bash
  docker compose ps
  docker compose logs mongodb
  ```

- **Detener el contenedor:**
  ```bash
  docker compose down
  ```
  *(Para reiniciar y volver a ejecutar el script de inicialización desde cero: `docker compose down -v`)*

### 💻 Ingresar a la Base de Datos por Consola (CLI / `mongosh`)

Puedes conectarte e interactuar con la base de datos directamente desde la terminal usando la herramienta interactiva `mongosh` dentro del contenedor Docker:

1. **Ingresar como usuario de aplicación (`ecouser`):**
   ```bash
   docker exec -it ecoblog_mongodb mongosh -u ecouser -p ecopassword123 --authenticationDatabase ecoblog_db
   ```

2. **Ingresar como usuario administrador (`admin`):**
   ```bash
   docker exec -it ecoblog_mongodb mongosh -u admin -p adminpassword123 --authenticationDatabase admin
   ```

#### 📌 Comandos útiles en la consola de MongoDB:
Una vez dentro de `mongosh`:

```javascript
// Cambiar a la base de datos del proyecto
use ecoblog_db

// Ver colecciones disponibles
show collections

// Contar documentos
db.users.countDocuments()
db.posts.countDocuments()

// Consultar todos los usuarios
db.users.find().pretty()

// Consultar publicaciones y comentarios embebidos
db.posts.find().pretty()

// Buscar posts creados por un usuario específico
db.posts.find({ creatorUsername: "david" })

// Salir de mongosh
exit
```

---

## 📊 Modelo de Datos NoSQL (Document Store)

MongoDB organiza la información en documentos BSON dentro de colecciones:

### 1. Colección `users`
Almacena las cuentas de usuario registradas:
```json
{
  "_id": "user_1",
  "username": "david",
  "email": "david@planetaverde.org",
  "password": "123456",
  "createdAt": "2026-10-13T10:00:00.000Z"
}
```

### 2. Colección `posts` (Colección Referenciada)
Almacena las publicaciones del blog. Los comentarios ya no se embeben aquí, sino que se gestionan de forma desacoplada y escalable en la colección `comments`:
```json
{
  "_id": "post_seed_001",
  "creatorUsername": "david",
  "topic": "Energía Renovable",
  "title": "Impacto de la energía solar comunitaria en zonas rurales",
  "content": "La instalación de microrredes solares comunitarias...",
  "createdAt": "2026-10-13T13:45:00.000Z",
  "isEdited": false
}
```

### 3. Colección `comments` (Relación con Posts y Sub-comentarios)
Almacena los comentarios y respuestas. Cada documento se relaciona con una publicación mediante `postId` y puede ser una respuesta a otro comentario mediante el campo autorreferencial `parentCommentId` (`null` si es un comentario principal/raíz):
```json
{
  "_id": "comment_1728830500000",
  "postId": "post_seed_001",
  "parentCommentId": null,
  "userName": "elena_bio",
  "date": "2026-10-13T14:45:00.000Z",
  "comment": "Excelente iniciativa.",
  "isEdited": false
}
```
Y una respuesta a ese comentario:
```json
{
  "_id": "comment_1728830600000",
  "postId": "post_seed_001",
  "parentCommentId": "comment_1728830500000",
  "userName": "carlos_solar",
  "date": "2026-10-13T15:10:00.000Z",
  "comment": "Totalmente de acuerdo, además ahorra costos en la red eléctrica.",
  "isEdited": false
}
```

---

## 🚀 Características Principales

### 🔐 Autenticación y Usuarios
- **Autenticación directa en MongoDB**: Búsqueda y registro reactivo en la colección `users`.
- **Validación de formularios**: Validación de correo, usuario y contraseña.
- **Términos y Condiciones**: Modal interactivo de aceptación obligatoria.
- **Cierre de sesión seguro**.

### 📝 Gestión de Publicaciones (Blog)
- **Feed interactivo conectado a MongoDB**: Carga cronológica de posts directamente de la colección `posts`.
- **Búsqueda en tiempo real**: Filtrado por título reactivo.
- **Creación de publicaciones**: Inserción directa en MongoDB con validación.
- **Edición y eliminación**: Actualizaciones y eliminaciones sincronizadas en tiempo real con MongoDB.
- **Mis Publicaciones**: Vista exclusiva para administrar los posts del usuario activo.
- **Indicador de Conexión en la App**: Chip visual en la pantalla principal (🟢 *MongoDB: Conectado* / 🟡 *MongoDB: Offline* con reintento táctil).

### 💬 Sistema de Comentarios y Sub-comentarios
- **Colección Relacionada e Independiente**: Los comentarios residen en `comments`, mejorando la escalabilidad del documento principal.
- **Sub-comentarios / Respuestas Anidadas**: Permite responder directamente a comentarios existentes mediante autorreferencia (`parentCommentId`).
- **Eliminación en Cascada**:
  - Al borrar un post se eliminan todos sus comentarios en `comments`.
  - Al borrar un comentario se eliminan en cascada sus respuestas anidadas.
- **Bottom Sheet interactivo**: Panel deslizante con visualización jerárquica indentada para respuestas y botón "Responder".

---

## 🏗️ Arquitectura del Proyecto

```text
blog_nosql/
├── compose.yaml          # Despliegue Docker de MongoDB 7.0 con autenticación
├── mongo-init.js         # Script JS de inicialización (roles, índices y seed data)
├── lib/
│   ├── controllers/      # Controladores de estado (Provider)
│   │   ├── auth_controller.dart
│   │   └── blog_controller.dart
│   ├── models/           # Modelos de datos con serialización BSON (toMap/fromMap)
│   │   ├── blog_post_model.dart
│   │   ├── comment_model.dart
│   │   └── user_model.dart
│   ├── services/         # Capa de conexión directa a base de datos
│   │   └── mongo_service.dart (mongo_dart)
│   ├── theme/            # Tema visual Material 3
│   │   └── app_theme.dart
│   ├── views/            # Pantallas de la aplicación
│   │   ├── auth/         # Login y Registro
│   │   ├── comments/     # BottomSheet interactivo de comentarios
│   │   ├── home/         # Feed principal con indicador de conexión MongoDB
│   │   └── posts/        # Creación, edición y administración de posts
│   ├── widgets/          # Diálogos y componentes reutilizables
│   └── main.dart         # Punto de entrada de la aplicación
└── test/                 # Pruebas automatizadas (Unitarias y Widget tests)
```

---

## 👤 Registro y Acceso de Usuarios

El proyecto inicia limpio, sin usuarios ni publicaciones mockup precargadas:

- Puedes registrar nuevos usuarios directamente desde la pantalla de **Registro** de la aplicación móvil (aceptando los Términos y Condiciones).
- Los usuarios registrados y sus publicaciones se persistirán inmediatamente en las colecciones `users` y `posts` de MongoDB.
- Si deseas insertar datos manualmente para pruebas o administración, puedes hacerlo desde **MongoDB Compass** o mediante la consola interactiva `mongosh`.

---

## 🛠️ Requisitos e Instalación

1. **Requisitos:**
   - [Docker](https://docs.docker.com/get-docker/) y Docker Compose.
   - [MongoDB Compass](https://www.mongodb.com/products/tools/compass) (instalado para visualización).
   - [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x+ con Dart 3.12+.

2. **Levantar la Base de Datos:**
   ```bash
   docker compose up -d
   ```

3. **Descargar Dependencias de Flutter:**
   ```bash
   flutter pub get
   ```

4. **Ejecutar la Aplicación:**
   - En **Linux Desktop**:
     ```bash
     flutter run -d linux
     ```
   - En **Emulador / Dispositivo Android**:
     Para conectar directamente el emulador o dispositivo a la máquina local, ejecuta:
     ```bash
     adb reverse tcp:27017 tcp:27017
     flutter run
     ```
     > **💡 Nota de red:** La aplicación detecta automáticamente la IP alcanzable (`127.0.0.1`, `10.4.15.14`, `10.0.2.2` o `10.0.3.2`). Si cambias de red o usas otra IP, puedes presionar o mantener pulsado el chip **MongoDB: Conectado / Offline** en la pantalla principal para cambiar el Host en el diálogo interactivo.

---

## 📱 Generación de APK para Dispositivos Físicos (Android)

Para generar el paquete instalable `.apk` y utilizar la aplicación directamente en teléfonos o tablets físicas sin necesidad de tener el equipo conectado por cable a la computadora:

### 1. Requisitos Previos
- **Configuración de Conexión (`.env`):** Asegúrate de que el archivo `.env` apunte a una dirección accesible desde el dispositivo móvil:
  - **MongoDB Atlas (Recomendado):** `MONGO_HOST=appambiente.astsdqz.mongodb.net` (funciona con datos móviles o Wi-Fi).
  - **Docker Local:** Si usas Docker en tu PC, el teléfono y la computadora deben estar en la **misma red Wi-Fi** y `MONGO_HOST` debe tener la IP local de tu PC (ej. `192.168.1.X` o `10.4.15.14`).
- **Permisos de Red:** La aplicación ya cuenta con `<uses-permission android:name="android.permission.INTERNET"/>` en su `AndroidManifest.xml`.

---

### 2. Comandos de Compilación

Abre una terminal en la raíz del proyecto y ejecuta:

#### Opción A: APK Release universal (Recomendado)
Genera un único archivo `.apk` compatible con la mayoría de arquitecturas de procesadores Android:

```bash
flutter build apk --release
```
📍 **Ubicación del archivo generado:**
```text
build/app/outputs/flutter-apk/app-release.apk
```

#### Opción B: APKs divididos por arquitectura (APK más liviano)
Reduce el tamaño del instalador generando un APK específico para cada tipo de procesador (`armeabi-v7a`, `arm64-v8a`, `x86_64`):

```bash
flutter build apk --release --split-per-abi
```
📍 **Ubicación de los archivos generados:**
```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  (Para el 95% de teléfonos modernos)
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (Para dispositivos más antiguos)
```

---

### 3. Instalación en el Dispositivo Físico

Puedes transferir e instalar el archivo generado por cualquiera de estos métodos:

1. **Vía USB con ADB (Directo):**
   Conecta tu teléfono con *Depuración USB* activada y ejecuta:
   ```bash
   flutter install
   # O directamente con adb:
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Sin cables (Manual):**
   - Envía el archivo `app-release.apk` a tu teléfono vía **Google Drive**, **WhatsApp**, **Telegram** o cable USB.
   - En tu teléfono, abre el archivo descargado.
   - Si Android lo solicita, activa el permiso de **"Instalar aplicaciones de fuentes desconocidas"** para ese medio.
   - Presiona **Instalar** y abre la app.

---

## 🧪 Pruebas Automatizadas

Ejecutar la suite completa de pruebas:

```bash
flutter test
```
*Las pruebas cubren autenticación, consultas, CRUD de posts y comentarios, y el árbol de widgets.*

