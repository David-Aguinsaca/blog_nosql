/**
 * ==============================================================================
 * GUÍA DE REFERENCIA: Operaciones CRUD en MongoDB (NoSQL) para EcoBlog
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
  comments: [] // Inicialmente sin comentarios
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
