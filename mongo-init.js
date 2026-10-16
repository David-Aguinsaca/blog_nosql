const dbName = 'ecoblog_db';
const appUser = 'ecouser';
const appPassword = 'ecopassword123';

const appDb = db.getSiblingDB(dbName);

appDb.createUser({
  user: appUser,
  pwd: appPassword,
  roles: [
    { role: 'readWrite', db: dbName },
    { role: 'dbAdmin', db: dbName }
  ]
});

appDb.createCollection('users');
appDb.createCollection('posts');

appDb.users.createIndex({ username: 1 }, { unique: true });
appDb.users.createIndex({ email: 1 }, { unique: true });
appDb.posts.createIndex({ createdAt: -1 });
appDb.posts.createIndex({ creatorUsername: 1 });
appDb.posts.createIndex({ topic: 1 });

print(' Inicialización de MongoDB completada para ecoblog_db (sin datos mockup)');
