
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

/**
 * Búsqueda parcial por título insensible a mayúsculas/minúsculas
 * Equivale a una búsqueda tipo "LIKE '%solar%'" en SQL.
 */
db.posts.find({
  title: { $regex: "solar", $options: "i" }
}).pretty();


db.posts.find({
  title: { $regex: "energía", $options: "i" }
}).sort({
  createdAt: -1
}).pretty();


/**
 * Actualizar título, temática y contenido de una publicación existente:
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
 * Añadir un comentario embebido dentro de la publicación (Operador $push):
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
 * Editar un comentario embebido específico dentro de una publicación (Operador $):
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

/**
 *  Eliminar una publicación específica por su identificador '_id':
 */
db.posts.deleteOne({
  _id: "post_1728830000000"
});


/**
 * countDocuments(): Contar el total de documentos en la colección 'posts'.
 */
db.posts.countDocuments();

/**
 * countDocuments() con filtro:
 * Contar cuántas publicaciones pertenecen a un autor específico.
 */
db.posts.countDocuments({ creatorUsername: "elena_verde" });


/**
 * distinct(): Obtener la lista de valores únicos para un campo.
 */
db.posts.distinct("title");

/**
 * distinct() con filtro:
 * Obtener las temáticas únicas publicadas únicamente por un usuario en particular.
 */
db.posts.distinct("topic", { creatorUsername: "carlos_solar" });


/**
 * Operador $and:
 * Devuelve documentos que cumplan TODAS las condiciones dadas.
 */
db.posts.find({
  $and: [
    { topic: "Energía Renovable" },
    { creatorUsername: "carlos_solar" }
  ]
}).pretty();



/**
 * Índice simple ascendente (1):
 * Acelera las búsquedas por temática.
 */
db.posts.createIndex({ topic: 1 });

/**
 * Agrupación simple ($group) y conteo:
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
 * Desenrollar arrays ($unwind):
 * Desglosar los comentarios embebidos para analizar o filtrar a nivel de comentario individual.
 * Permite saber quiénes son los usuarios que más comentan.
 */
db.posts.aggregate([
  {
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
