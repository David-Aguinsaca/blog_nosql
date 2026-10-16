/**
 * ==============================================================================
 * GUÍA DE REFERENCIA: Operaciones CRUD en MongoDB (NoSQL) para TerraBlog
 * ==============================================================================
 * 
 * Este archivo es únicamente de REFERENCIA y documentación técnica.
 * NO debe ejecutarse de forma automática.
 * 
 * Puedes copiar y pegar estos comandos dentro de la consola interactiva 'mongosh'
 * o en MongoDB Compass (pestaña 'Mongoose / Aggregations / Queries').
 * 
 * Conexión a la consola desde la terminal:
 *   docker exec -it ecoblog_mongodb mongosh -u ecouser -p ecopassword123 --authenticationDatabase ecoblog_db
 * ==============================================================================
 */

// 0. SELECCIONAR LA BASE DE DATOS
use ecoblog_db;


// ==============================================================================
// 1. CREAR UNA PUBLICACIÓN (CREATE / INSERT)
// ==============================================================================

/**
 * Inserta una nueva publicación en la colección 'posts'.
 * En el modelo NoSQL, los comentarios se modelan como un arreglo de documentos
 * embebidos (Embedded Documents Pattern) dentro de la misma publicación.
 */
db.posts.insertOne({
  _id: "post_1728830000000",
  creatorUsername: "david",
  topic: "Energía Renovable",
  title: "Beneficios de los paneles solares fotovoltaicos en zonas urbanas",
  content: "La adopción de tecnología solar en techos urbanos reduce la dependencia de la red eléctrica convencional y amortiza su costo en pocos años.",
  createdAt: new Date(),
  isEdited: false,
  comments: []
});


// ==============================================================================
// 2. FILTRAR POR TÍTULO UNA PUBLICACIÓN (READ / FIND)
// ==============================================================================

/**
 * 2.1 Búsqueda parcial por título (insensible a mayúsculas/minúsculas - Case Insensitive):
 * Equivale a una búsqueda tipo "LIKE '%solar%'" en SQL.
 */
db.posts.find({
  title: { $regex: "solar", $options: "i" }
}).pretty();

/**
 * 2.2 Búsqueda exacta por título:
 */
db.posts.find({
  title: "Beneficios de los paneles solares fotovoltaicos en zonas urbanas"
}).pretty();

/**
 * 2.3 Búsqueda filtrando por título y ordenando por fecha de creación descendente:
 */
db.posts.find({
  title: { $regex: "energía", $options: "i" }
}).sort({
  createdAt: -1
}).pretty();


// ==============================================================================
// 3. EDITAR / ACTUALIZAR UNA PUBLICACIÓN (UPDATE)
// ==============================================================================

/**
 * 3.1 Actualizar título, temática y contenido de una publicación existente:
 * Se utiliza el operador '$set' para modificar únicamente los campos especificados.
 */
db.posts.updateOne(
  { _id: "post_1728830000000" },
  {
    $set: {
      title: "Beneficios y Retos de la Energía Solar Urbana",
      topic: "Transición Energética",
      content: "Contenido actualizado: se analiza el impacto de las baterías modernas y la eficiencia de los inversores solares.",
      isEdited: true
    }
  }
);

/**
 * 3.2 Añadir un comentario embebido dentro de la publicación (Operador $push):
 * Agrega atómicamente un nuevo objeto al array 'comments'.
 */
db.posts.updateOne(
  { _id: "post_1728830000000" },
  {
    $push: {
      comments: {
        id: "comment_1728830500000",
        postId: "post_1728830000000",
        userName: "elena_bio",
        date: new Date(),
        comment: "Excelente artículo. ¿Cuál es el costo estimado del inversor?",
        isEdited: false
      }
    }
  }
);

/**
 * 3.3 Editar un comentario embebido específico dentro de una publicación (Operador $):
 * Usa el operador posicional '$' para actualizar solo el comentario que coincida con el id.
 */
db.posts.updateOne(
  {
    _id: "post_1728830000000",
    "comments.id": "comment_1728830500000"
  },
  {
    $set: {
      "comments.$.comment": "Excelente artículo. Modifico mi duda: ¿qué garantía tienen los inversores?",
      "comments.$.isEdited": true
    }
  }
);


// ==============================================================================
// 4. ELIMINAR UNA PUBLICACIÓN (DELETE)
// ==============================================================================

/**
 * 4.1 Eliminar una publicación específica por su identificador '_id':
 */
db.posts.deleteOne({
  _id: "post_1728830000000"
});

/**
 * 4.2 Eliminar un comentario individual dentro de una publicación (Operador $pull):
 * Quita el comentario con el 'id' dado sin borrar la publicación completa.
 */
db.posts.updateOne(
  { _id: "post_1728830000000" },
  {
    $pull: {
      comments: { id: "comment_1728830500000" }
    }
  }
);

/**
 * 4.3 Eliminar publicaciones que coincidan con un criterio de título:
 */
db.posts.deleteMany({
  title: { $regex: "prueba", $options: "i" }
});


// ==============================================================================
// 5. CONSULTAS DE CONTEO Y VALORES ÚNICOS (COUNT & DISTINCT)
// ==============================================================================

/**
 * 5.1 countDocuments(): Contar el total de documentos en la colección 'posts'.
 */
db.posts.countDocuments();

/**
 * 5.2 countDocuments() con filtro:
 * Contar cuántas publicaciones pertenecen a un autor específico.
 */
db.posts.countDocuments({ creatorUsername: "elena_verde" });

/**
 * 5.3 estimatedDocumentCount(): Conteo rápido estimado mediante metadatos (ideal para colecciones masivas).
 */
db.posts.estimatedDocumentCount();

/**
 * 5.4 distinct(): Obtener la lista de valores únicos para un campo.
 * Extrae todos los tópicos/temáticas sin duplicados existentes en las publicaciones.
 */

db.posts.distinct("topic");

/**
 * 5.5 distinct() con filtro:
 * Obtener las temáticas únicas publicadas únicamente por un usuario en particular.
 */
db.posts.distinct("topic", { creatorUsername: "carlos_solar" });

/**
 * 5.6 distinct() sobre arreglos embebidos:
 * Obtener todos los nombres de usuarios únicos que han comentado en cualquier publicación.
 */
db.posts.distinct("comments.userName");


// ==============================================================================
// 6. OPERADORES LÓGICOS: $and, $or, $nor, $not
// ==============================================================================

/**
 * 6.1 Operador $and:
 * Devuelve documentos que cumplan TODAS las condiciones dadas.
 * Ejemplo: Publicaciones de temática 'Energía Renovable' creadas por 'carlos_solar'.
 * Nota: En MongoDB el AND es implícito al separar con comas, pero '$and' es necesario
 * cuando se evalúan múltiples expresiones sobre el mismo campo o condiciones complejas.
 */
db.posts.find({
  $and: [
    { topic: "Energía Renovable" },
    { creatorUsername: "carlos_solar" }
  ]
}).pretty();

/**
 * 6.2 Operador $or:
 * Devuelve documentos que cumplan AL MENOS UNA de las condiciones.
 * Ejemplo: Publicaciones cuya temática sea 'Conservación Marina' O cuyo autor sea 'elena_verde'.
 */
db.posts.find({
  $or: [
    { topic: "Conservación Marina" },
    { creatorUsername: "elena_verde" }
  ]
}).pretty();

/**
 * 6.3 Operador $nor:
 * Devuelve documentos que NO cumplan NINGUNA de las condiciones especificadas.
 * Ejemplo: Excluir publicaciones de 'Consumo Responsable' y que tampoco pertenezcan a 'marina_oceano'.
 */
db.posts.find({
  $nor: [
    { topic: "Consumo Responsable" },
    { creatorUsername: "marina_oceano" }
  ]
}).pretty();

/**
 * 6.4 Operador $not:
 * Invierte el efecto de un operador de comparación o expresión regular.
 * Ejemplo: Publicaciones cuyo título NO contenga la palabra 'solar' (case insensitive).
 */
db.posts.find({
  title: {
    $not: { $regex: "solar", $options: "i" }
  }
}).pretty();

/**
 * 6.5 Combinación de operadores lógicos ($and con $or y $not):
 * Ejemplo: Publicaciones que sean de ('Economía Circular' O 'Biodiversidad Urbana')
 * Y cuyo autor NO sea 'carlos_solar'.
 */
db.posts.find({
  $and: [
    {
      $or: [
        { topic: "Economía Circular" },
        { topic: "Biodiversidad Urbana" }
      ]
    },
    {
      creatorUsername: { $not: { $eq: "carlos_solar" } }
    }
  ]
}).pretty();


// ==============================================================================
// 7. GESTIÓN Y CREACIÓN DE ÍNDICES (INDEXES)
// ==============================================================================

/**
 * 7.1 Índice simple ascendente (1):
 * Acelera las búsquedas por temática.
 */
db.posts.createIndex({ topic: 1 });

/**
 * 7.2 Índice simple descendente (-1):
 * Optimiza la ordenación de las publicaciones más recientes en el feed.
 */
db.posts.createIndex({ createdAt: -1 });

/**
 * 7.3 Índice compuesto:
 * Optimiza consultas que filtran por autor y ordenan simultáneamente por fecha de creación.
 */
db.posts.createIndex({ creatorUsername: 1, createdAt: -1 });

/**
 * 7.4 Índice único (Unique Index):
 * Evita duplicados a nivel de base de datos (por ejemplo, en usuarios).
 */
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true });

/**
 * 7.5 Índice de texto completo (Text Index):
 * Permite realizar búsquedas de texto sobre título y contenido al mismo tiempo ($text / $search).
 */
db.posts.createIndex({
  title: "text",
  content: "text"
}, {
  default_language: "spanish",
  name: "idx_posts_fulltext"
});

/**
 * 7.6 Consulta aprovechando el índice de texto:
 */
db.posts.find({
  $text: { $search: "energía solar fotovoltaicos" }
}).pretty();

/**
 * 7.7 Listar todos los índices de una colección:
 */
db.posts.getIndexes();

/**
 * 7.8 Eliminar un índice específico:
 */
// db.posts.dropIndex("idx_posts_fulltext");
// db.posts.dropIndex({ topic: 1 });


// ==============================================================================
// 8. SENTENCIAS DE AGREGACIÓN (AGGREGATION FRAMEWORK)
// ==============================================================================

/**
 * 8.1 Agrupación simple ($group) y conteo:
 * Contar cuántas publicaciones existen por cada temática (topic), ordenadas de mayor a menor.
 */
db.posts.aggregate([
  {
    $group: {
      _id: "$topic",
      totalPosts: { $sum: 1 }
    }
  },
  {
    $sort: { totalPosts: -1 }
  }
]);

/**
 * 8.2 Filtrar ($match), agrupar ($group) y calcular estadísticas:
 * Agrupar publicaciones por autor, calculando total de posts y total de comentarios acumulados.
 */
db.posts.aggregate([
  {
    // Etapa 1: Filtrar solo posts que no sean de prueba o vacíos
    $match: {
      creatorUsername: { $exists: true, $ne: "" }
    }
  },
  {
    // Etapa 2: Agrupar por usuario creador
    $group: {
      _id: "$creatorUsername",
      cantidadPublicaciones: { $sum: 1 },
      totalComentarios: { $sum: { $size: { $ifNull: ["$comments", []] } } }
    }
  },
  {
    // Etapa 3: Proyectar y renombrar campos de salida
    $project: {
      _id: 0,
      autor: "$_id",
      cantidadPublicaciones: 1,
      totalComentarios: 1
    }
  },
  {
    // Etapa 4: Ordenar por cantidad de publicaciones descendente
    $sort: { cantidadPublicaciones: -1 }
  }
]);

/**
 * 8.3 Desenrollar arrays ($unwind):
 * Desglosar los comentarios embebidos para analizar o filtrar a nivel de comentario individual.
 * Permite saber quiénes son los usuarios que más comentan.
 */
db.posts.aggregate([
  {
    // Desglosar cada elemento del arreglo 'comments' en un documento independiente
    $unwind: "$comments"
  },
  {
    // Agrupar por el usuario que comentó
    $group: {
      _id: "$comments.userName",
      totalComentariosRealizados: { $sum: 1 }
    }
  },
  {
    $sort: { totalComentariosRealizados: -1 }
  },
  {
    $limit: 5 // Top 5 usuarios más participativos en comentarios
  }
]);

/**
 * 8.4 Lookup ($lookup) - Join entre colecciones:
 * Unir la colección 'posts' con la colección 'users' para obtener información completa del perfil del creador.
 */
db.posts.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "creatorUsername",
      foreignField: "username",
      as: "autorDetalles"
    }
  },
  {
    // Convertir el array 'autorDetalles' en un objeto único
    $unwind: {
      path: "$autorDetalles",
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $project: {
      _id: 1,
      title: 1,
      topic: 1,
      createdAt: 1,
      "autor.username": "$creatorUsername",
      "autor.email": "$autorDetalles.email"
    }
  },
  {
    $limit: 10
  }
]);

