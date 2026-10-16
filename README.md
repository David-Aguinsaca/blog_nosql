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

## 📊 Esquema y Modelo de Datos NoSQL (MongoDB)

El diseño de la base de datos sigue el modelo orientado a documentos (**Document Store**) de MongoDB, implementando el patrón de **documentos embebidos** (*Embedded Pattern*) para almacenar los comentarios directamente dentro de cada publicación, minimizando la latencia y eliminando la necesidad de *joins* relacionales.

### 🗂️  del Esquema

```mermaid
erDiagram
    users {
        ObjectId_or_String _id PK "Identificador único"
        string username UK "Nombre de usuario (único)"
        string email UK "Correo electrónico (único)"
        string password "Contraseña en texto o hash"
    }

    posts {
        ObjectId_or_String _id PK "Identificador único de publicación"
        string creatorUsername FK "Nombre de usuario del autor"
        string topic "Tema o categoría ambiental"
        string title "Título de la publicación"
        string content "Cuerpo o contenido del post"
        date createdAt "Fecha y hora de creación (ISO-8601)"
        bool isEdited "Bandera de edición"
        array comments "Lista de comentarios embebidos"
    }

    comments_embedded {
        string id PK "Identificador único del comentario"
        string postId FK "ID de la publicación padre"
        string userName "Nombre del autor del comentario"
        date date "Fecha y hora del comentario"
        string comment "Texto del comentario"
        bool isEdited "Bandera de edición"
    }

    users ||--o{ posts : "crea"
    posts ||--|{ comments_embedded : "contiene embebido"
```

---

### 1. Colección: `users`

Almacena las credenciales y perfiles de los usuarios de la plataforma.

#### Estructura de Campos:

| Campo | Tipo BSON | Requerido | Descripción / Restricciones |
| :--- | :--- | :---: | :--- |
| `_id` | `String` / `ObjectId` | Sí | Clave primaria única del usuario. |
| `username` | `String` | Sí | Nombre de usuario. Índice único (`unique: true`). |
| `email` | `String` | Sí | Correo electrónico. Índice único (`unique: true`). |
| `password` | `String` | Sí | Contraseña para autenticación. |

#### Índices de la colección:
- `{ username: 1 }` (Unique)
- `{ email: 1 }` (Unique)

#### Documento de Ejemplo:
```json
{
  "_id": "user_670d3810a9f3b1234567890a",
  "username": "david",
  "email": "david@planetaverde.org",
  "password": "miPasswordSeguro123",
  "createdAt": "2026-10-13T10:00:00.000Z"
}
```

---

### 2. Colección: `posts`

Almacena los artículos y publicaciones. Los comentarios se guardan como subdocumentos embebidos en el arreglo `comments`.

#### Estructura de Campos:

| Campo | Tipo BSON | Requerido | Descripción / Restricciones |
| :--- | :--- | :---: | :--- |
| `_id` | `String` / `ObjectId` | Sí | Identificador único del post. |
| `creatorUsername` | `String` | Sí | Nombre de usuario del creador (autor). Indexado. |
| `topic` | `String` | Sí | Categoría ecológica (*Energía Renovable*, *Reforestación*, etc.). Indexado. |
| `title` | `String` | Sí | Título descriptivo de la publicación. |
| `content` | `String` | Sí | Contenido completo del post. |
| `createdAt` | `Date` / `String (ISO)` | Sí | Fecha de publicación. Índice descendente para ordenar cronológicamente. |
| `isEdited` | `Boolean` | Sí | Indica si la publicación fue editada (`true`/`false`). |
| `comments` | `Array<Subdocument>` | No | Lista de comentarios embebidos asociados al post. |

#### Subdocumento Embebido: `comments`

| Campo | Tipo | Requerido | Descripción |
| :--- | :--- | :---: | :--- |
| `id` | `String` | Sí | Identificador único del comentario (ej. generado con timestamp/UUID). |
| `postId` | `String` | Sí | Referencia al post contenedor. |
| `userName` | `String` | Sí | Nombre de usuario del autor del comentario. |
| `date` | `Date` / `String (ISO)` | Sí | Fecha y hora en que se envió el comentario. |
| `comment` | `String` | Sí | Texto o contenido del comentario. |
| `isEdited` | `Boolean` | Sí | Indica si el comentario fue modificado. |

#### Índices de la colección:
- `{ createdAt: -1 }`: Ordenamiento cronológico eficiente del feed.
- `{ creatorUsername: 1 }`: Filtrado rápido por autor ("Mis Publicaciones").
- `{ topic: 1 }`: Filtrado por categorías temáticas.

#### Documento de Ejemplo:
```json
{
  "_id": "post_670d3890a9f3b1234567890b",
  "creatorUsername": "david",
  "topic": "Energía Renovable",
  "title": "Impacto de la energía solar comunitaria en zonas rurales",
  "content": "La instalación de microrredes solares comunitarias promueve la independencia energética...",
  "createdAt": "2026-10-13T13:45:00.000Z",
  "isEdited": false,
  "comments": [
    {
      "id": "comm_1728827100000",
      "postId": "post_670d3890a9f3b1234567890b",
      "userName": "elena_bio",
      "date": "2026-10-13T14:45:00.000Z",
      "comment": "Excelente iniciativa. ¿Tienen mediciones del ahorro estimado?",
      "isEdited": false
    }
  ]
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

### 💬 Sistema de Comentarios Embebidos
- **Bottom Sheet interactivo**: Panel deslizante para interactuar con los comentarios.
- **Operaciones Atómicas NoSQL**:
  - Adición usando operador `$push`.
  - Actualización usando operador `$set` con selector posicional.
  - Eliminación usando operador `$pull`.

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

