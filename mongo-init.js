// ========================================================
// Script de Inicialización de MongoDB para TerraBlog (NoSQL)
// Se ejecuta automáticamente al crear el contenedor
// ========================================================

const dbName = 'ecoblog_db';
const appUser = 'ecouser';
const appPassword = 'ecopassword123';

const appDb = db.getSiblingDB(dbName);

// 1. Crear usuario de aplicación para ecoblog_db
appDb.createUser({
  user: appUser,
  pwd: appPassword,
  roles: [
    { role: 'readWrite', db: dbName },
    { role: 'dbAdmin', db: dbName }
  ]
});

// 2. Crear Colecciones
appDb.createCollection('users');
appDb.createCollection('posts');

// 3. Crear Índices
appDb.users.createIndex({ username: 1 }, { unique: true });
appDb.users.createIndex({ email: 1 }, { unique: true });
appDb.posts.createIndex({ createdAt: -1 });
appDb.posts.createIndex({ creatorUsername: 1 });
appDb.posts.createIndex({ topic: 1 });

print(' Inicialización de MongoDB completada para ecoblog_db (sin datos mockup)');
