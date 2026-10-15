
const dbName = 'ecoblog_db';
const appDb = typeof db !== 'undefined' ? db.getSiblingDB(dbName) : null;

if (!appDb) {
  print('Error: El objeto global "db" no está disponible. Asegúrate de ejecutar este script con mongosh.');
} else {
  print(`Iniciando carga de datos de prueba (Seeders) en [${dbName}]...`);

  // ============================================================================
  // 2. DATOS DE PRUEBA: 3 USUARIOS
  // ============================================================================
  // Contraseña en texto plano para los 3 usuarios de prueba: "password123"
  // Hasheada con BCrypt (costo 10) para no almacenar texto plano en MongoDB
  const mockUsers = [
    {
      _id: "user_seed_001",
      username: "elena_verde",
      email: "elena.verde@ecoblog.org",
      password: "$2a$10$vEu6iBgLChIOQOpjT1tYQOwdhroYjjtoVjjz47a4PmvG66oQthHUy"
    },
    {
      _id: "user_seed_002",
      username: "carlos_solar",
      email: "carlos.solar@ecoblog.org",
      password: "$2a$10$vEu6iBgLChIOQOpjT1tYQOwdhroYjjtoVjjz47a4PmvG66oQthHUy"
    },
    {
      _id: "user_seed_003",
      username: "marina_oceano",
      email: "marina.oceano@ecoblog.org",
      password: "$2a$10$vEu6iBgLChIOQOpjT1tYQOwdhroYjjtoVjjz47a4PmvG66oQthHUy"
    }
  ];

  const mockPosts = [
    {
      _id: "post_seed_001",
      creatorUsername: "elena_verde",
      topic: "Economía Circular",
      title: "Principios básicos del compostaje doméstico en departamentos",
      content: "Aprender a compostar en espacios reducidos permite transformar hasta un 50% de nuestros residuos orgánicos diarios en abono fértil para plantas urbanas, reduciendo drásticamente las emisiones de metano en vertederos.",
      createdAt: new Date("2026-10-01T10:00:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_002",
      creatorUsername: "carlos_solar",
      topic: "Energía Renovable",
      title: "Transición a sistemas fotovoltaicos aislados y conectados a red",
      content: "El avance de los inversores híbridos y el abaratamiento de las baterías de litio ferrofosfato (LiFePO4) hacen viable la microgeneración eléctrica distribuida en hogares y pequeños comercios.",
      createdAt: new Date("2026-10-02T11:30:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_003",
      creatorUsername: "marina_oceano",
      topic: "Conservación Marina",
      title: "El impacto de los microplásticos en los ecosistemas de arrecifes",
      content: "Estudios oceanográficos recientes confirman la presencia masiva de fibras sintéticas en organismos filtradores, alterando las cadenas tróficas y requiriendo un replanteamiento de la industria textil global.",
      createdAt: new Date("2026-10-03T09:15:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_004",
      creatorUsername: "elena_verde",
      topic: "Biodiversidad Urbana",
      title: "Creación de corredores biológicos mediante techos y muros verdes",
      content: "La vegetación autóctona en azoteas mitiga el efecto isla de calor urbano, disminuye el gasto energético en climatización y brinda refugio vital para polinizadores como abejas y mariposas.",
      createdAt: new Date("2026-10-04T14:20:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_005",
      creatorUsername: "carlos_solar",
      topic: "Movilidad Sostenible",
      title: "Electromovilidad y el futuro del transporte público urbano",
      content: "Sustituir flotas de buses diésel por buses 100% eléctricos no solo reduce toneladas de dióxido de carbono anuales, sino que también elimina la contaminación acústica en centros urbanos congestionados.",
      createdAt: new Date("2026-10-05T16:45:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_006",
      creatorUsername: "marina_oceano",
      topic: "Gestión del Agua",
      title: "Técnicas ancestrales y modernas de captación de agua de lluvia",
      content: "El almacenamiento pasivo de aguas pluviales para uso en riego y sanitarios disminuye la presión sobre acuíferos sobreexplotados y previene inundaciones repentinas en cuencas urbanizadas.",
      createdAt: new Date("2026-10-06T08:00:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_007",
      creatorUsername: "elena_verde",
      topic: "Consumo Responsable",
      title: "Desafío Residuo Cero: Estrategias para compras a granel",
      content: "Reemplazar empaques desechables de un solo uso por bolsas de tela reutilizables y frascos de vidrio fomenta el comercio local y disminuye los residuos no biodegradables generados semanalmente.",
      createdAt: new Date("2026-10-07T12:10:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_008",
      creatorUsername: "carlos_solar",
      topic: "Arquitectura Bioclimática",
      title: "Aislamiento térmico natural y ventilación cruzada en edificios",
      content: "Diseñar edificaciones considerando la trayectoria solar y los vientos dominantes minimiza la necesidad de calefacción artificial y aire acondicionado, optimizando la huella ecológica de la construcción.",
      createdAt: new Date("2026-10-08T15:30:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_009",
      creatorUsername: "marina_oceano",
      topic: "Protección de Humedales",
      title: "Los manglares como barreras naturales frente al cambio climático",
      content: "Los bosques de mangle capturan hasta cuatro veces más carbono que los bosques terrestres (carbono azul) y sirven de amortiguadores esenciales frente al oleaje de tormentas tropicales.",
      createdAt: new Date("2026-10-09T17:00:00Z").toISOString(),
      isEdited: false,
      comments: []
    },
    {
      _id: "post_seed_010",
      creatorUsername: "elena_verde",
      topic: "Agricultura Regenerativa",
      title: "Restauración de suelos agrícolas sin agroquímicos sintéticos",
      content: "La rotación de cultivos, los abonos verdes y la labranza mínima reactivan los microorganismos benéficos del suelo, mejorando la retención hídrica y asegurando cosechas ricas en nutrientes.",
      createdAt: new Date("2026-10-10T18:25:00Z").toISOString(),
      isEdited: false,
      comments: []
    }
  ];

  for (const user of mockUsers) {
    appDb.users.updateOne(
      { _id: user._id },
      { $set: user },
      { upsert: true }
    );
  }
  print(`✅ 3 usuarios procesados correctamente en la colección 'users'.`);

  /*
   * --------------------------------------------------------------------------
   * ALTERNATIVAS USANDO 'insertMany' DIRECTO:
   * --------------------------------------------------------------------------
   *
   * 1. Inserción directa en lote (Falla con duplicados si ya existen):
   *    appDb.users.insertMany(mockUsers);
   *
   * 2. Inserción en lote tolerante a duplicados ({ ordered: false }):
   *    // Inserta los que no existan e ignora los que ya existan sin frenar la ejecución:
   *    try {
   *      appDb.users.insertMany(mockUsers, { ordered: false });
   *    } catch (e) {
   *      print('Aviso: Algunos usuarios ya existían en la base de datos.');
   *    }
   *
   * 3. Limpiar previamente la colección e insertar en lote:
   *    // appDb.users.deleteMany({});
   *    // appDb.users.insertMany(mockUsers);
   * --------------------------------------------------------------------------
   */

  // Enfoque por defecto: for + updateOne con upsert:true
  for (const post of mockPosts) {
    appDb.posts.updateOne(
      { _id: post._id },
      { $set: post },
      { upsert: true }
    );
  }
  print(`✅ 10 publicaciones de prueba (sin comentarios) procesadas en la colección 'posts'.`);

  /*
   * --------------------------------------------------------------------------
   * ALTERNATIVAS USANDO 'insertMany' DIRECTO:
   * --------------------------------------------------------------------------
   *
   * 1. Inserción directa en lote:
   *    appDb.posts.insertMany(mockPosts);
   *
   * 2. Inserción en lote tolerante a duplicados:
   *    try {
   *      appDb.posts.insertMany(mockPosts, { ordered: false });
   *    } catch (e) {
   *      print('Aviso: Algunas publicaciones ya existían en la base de datos.');
   *    }
   *
   * 3. Limpiar previamente la colección e insertar en lote:
   *    // appDb.posts.deleteMany({});
   *    // appDb.posts.insertMany(mockPosts);
   * --------------------------------------------------------------------------
   */

  print('Sembrado de datos de prueba finalizado con éxito.');
}

