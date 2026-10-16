
/**
 * Inserta una nueva publicación en la colección 'posts'.
 * En este modelo NoSQL relacional normalizado, los comentarios se almacenan en su
 * propia colección 'comments', vinculados mediante la referencia 'postId'.
 */
db.posts.insertOne({
  _id: "post_1728830000000",
  creatorUsername: "david",
  topic: "Energía Renovable",
  title: "Beneficios de los paneles solares fotovoltaicos en zonas urbanas",
  content: "La adopción de tecnología solar en techos urbanos reduce la dependencia de la red eléctrica convencional y amortiza su costo en pocos años.",
  createdAt: new Date(),
  isEdited: false
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
 * Añadir un comentario raíz vinculado a la publicación en la colección 'comments'
 * (parentCommentId es null porque es un comentario principal del post):
 */
db.comments.insertOne({
  _id: "comment_1728830500000",
  postId: "post_1728830000000",
  parentCommentId: null,
  userName: "elena_bio",
  date: new Date(),
  comment: "Excelente artículo. ¿Cuál es el costo estimado del inversor?",
  isEdited: false
});

/**
 * Añadir un sub-comentario (respuesta a otro comentario):
 * parentCommentId apunta al '_id' del comentario padre.
 */
db.comments.insertOne({
  _id: "comment_1728830600000",
  postId: "post_1728830000000",
  parentCommentId: "comment_1728830500000",
  userName: "carlos_solar",
  date: new Date(),
  comment: "El costo promedio de un inversor híbrido de 3kW ronda los 800 - 1.200 USD.",
  isEdited: false
});

/**
 * Editar un comentario específico por su identificador '_id':
 */
db.comments.updateOne(
  { _id: "comment_1728830500000" },
  {
    $set: {
      comment: "Excelente artículo. Modifico mi duda: ¿qué garantía tienen los inversores?",
      isEdited: true
    }
  }
);

/**
 * Consultar comentarios y sub-comentarios de una publicación específica ordenados por fecha:
 */
db.comments.find({
  postId: "post_1728830000000"
}).sort({ date: 1 }).pretty();

/**
 * Consultar solo las respuestas a un comentario específico:
 */
db.comments.find({
  parentCommentId: "comment_1728830500000"
}).pretty();

/**
 * Eliminar un comentario y sus respuestas en cascada:
 */
db.comments.deleteMany({
  $or: [
    { _id: "comment_1728830500000" },
    { parentCommentId: "comment_1728830500000" }
  ]
});

/**
 * Eliminar una publicación y sus comentarios en cascada:
 */
db.posts.deleteOne({ _id: "post_1728830000000" });
db.comments.deleteMany({ postId: "post_1728830000000" });

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
 * Unir publicaciones con sus comentarios mediante el operador $lookup:
 */
db.posts.aggregate([
  {
    $lookup: {
      from: "comments",
      localField: "_id",
      foreignField: "postId",
      as: "comments"
    }
  }
]);

/**
 * Agrupación simple ($group) en la colección 'comments':
 * Permite saber quiénes son los usuarios que más comentan.
 */
db.comments.aggregate([
  {
    $group: {
      _id: "$userName",
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

