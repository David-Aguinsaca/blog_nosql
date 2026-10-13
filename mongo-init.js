// ========================================================
// Script de Inicialización de MongoDB para EcoBlog (NoSQL)
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

// 4. Insertar Datos de Prueba (Seed Data)
const now = new Date();

appDb.users.insertMany([
  {
    _id: 'user_1',
    username: 'david',
    email: 'david@planetaverde.org',
    password: '123456',
    createdAt: new Date(now.getTime() - 7 * 24 * 3600 * 1000)
  },
  {
    _id: 'user_2',
    username: 'elena_bio',
    email: 'elena@ecovida.org',
    password: '123456',
    createdAt: new Date(now.getTime() - 6 * 24 * 3600 * 1000)
  },
  {
    _id: 'user_3',
    username: 'marina_eco',
    email: 'marina@bosques.org',
    password: '123456',
    createdAt: new Date(now.getTime() - 5 * 24 * 3600 * 1000)
  },
  {
    _id: 'user_4',
    username: 'santiago_clima',
    email: 'santiago@clima.org',
    password: '123456',
    createdAt: new Date(now.getTime() - 4 * 24 * 3600 * 1000)
  }
]);

appDb.posts.insertMany([
  {
    _id: 'seed_post_1',
    creatorUsername: 'david',
    createdAt: new Date(now.getTime() - 3 * 3600 * 1000),
    topic: 'Energía Renovable',
    title: 'Impacto de la energía solar comunitaria en zonas rurales',
    content: 'La instalación de microrredes solares comunitarias no solo disminuye las emisiones de gases de efecto invernadero, sino que impulsa la autonomía energética en comunidades aisladas. Este modelo descentralizado es clave para una transición justa hacia energías limpias.',
    isEdited: false,
    comments: [
      {
        id: 'seed_comm_1',
        postId: 'seed_post_1',
        userName: 'elena_bio',
        date: new Date(now.getTime() - 2 * 3600 * 1000),
        comment: 'Excelente iniciativa. Las microrredes reducen pérdidas de transmisión drásticamente.',
        isEdited: false
      },
      {
        id: 'seed_comm_2',
        postId: 'seed_post_1',
        userName: 'marina_eco',
        date: new Date(now.getTime() - 1 * 3600 * 1000),
        comment: '¿Tienen proyectos pilotos activos en la región andina?',
        isEdited: false
      }
    ]
  },
  {
    _id: 'seed_post_2',
    creatorUsername: 'david',
    createdAt: new Date(now.getTime() - 26 * 3600 * 1000),
    topic: 'Cero Residuos',
    title: 'Hábitos diarios para reducir el plástico de un solo uso en casa',
    content: 'Adoptar el estilo de vida zero waste no requiere perfección, sino constancia. Reemplazar bolsas plásticas por tela, comprar granos a granel y reutilizar frascos de vidrio son pasos sencillos que evitan kilogramos de residuos plásticos que terminan en ríos y océanos.',
    isEdited: false,
    comments: [
      {
        id: 'seed_comm_3',
        postId: 'seed_post_2',
        userName: 'elena_bio',
        date: new Date(now.getTime() - 18 * 3600 * 1000),
        comment: 'Completamente de acuerdo, los pequeños hábitos suman un impacto masivo.',
        isEdited: false
      }
    ]
  },
  {
    _id: 'seed_post_3',
    creatorUsername: 'marina_eco',
    createdAt: new Date(now.getTime() - 48 * 3600 * 1000),
    topic: 'Reforestación Urbana',
    title: 'Bosques de bolsillo: biodiversidad en medio del concreto',
    content: 'El método Miyawaki demuestra que es posible sembrar bosques densos de vegetación nativa en espacios urbanos reducidos. Estos oasis no solo disminuyen la temperatura en las ciudades, sino que atraen aves polinizadoras y mejoran la calidad del aire respirable.',
    isEdited: false,
    comments: [
      {
        id: 'seed_comm_4',
        postId: 'seed_post_3',
        userName: 'david',
        date: new Date(now.getTime() - 24 * 3600 * 1000),
        comment: 'Hemos plantado 20 árboles nativos en el parque central con este método.',
        isEdited: false
      }
    ]
  },
  {
    _id: 'seed_post_4',
    creatorUsername: 'santiago_clima',
    createdAt: new Date(now.getTime() - 72 * 3600 * 1000),
    topic: 'Biodiversidad',
    title: 'Importancia vital de los corredores biológicos para polinizadores',
    content: 'Las abejas y mariposas enfrentan fragmentación en sus hábitats debido a la expansión urbana y pesticidas. Crear jardines con flores silvestres nativas en balcones y aceras conecta sus rutas y protege la seguridad alimentaria global.',
    isEdited: false,
    comments: []
  }
]);

print(' Inicialización de MongoDB completada para ecoblog_db');
