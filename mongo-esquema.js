/**
 * Esquema de datos NoSQL para TerraBlog (MongoDB)
 * 
 * Este archivo contiene las definiciones del esquema documentadas en README.md.
 * 
 * En Mongo Modeler (mongomodeler.com / Lemoncode):
 * 1. Para importar la estructura COMPLETA del diagrama con sus colecciones (users, posts, comments)
 *    y relaciones relacionales/referenciadas:
 *    -> Puedes abrir/importar este archivo directamente con la opción "Open" (Ctrl + O) o renombrándolo a .mml / .json
 *       usando el objeto exportado `mongoModelerDiagramSchema` (o el contenido JSON de este archivo si se usa puro).
 * 
 * 2. Para importar colección por colección en el modal "Import Collection" (Ctrl + I):
 *    -> Copia y pega el JSON de cada colección individual (`importPanelUsersJson`, `importPanelPostsJson`, `importPanelCommentsJson`)
 *       o los documentos modelo embebidos.
 */

// =============================================================================
// 1. FORMATO COMPLETO PARA "OPEN" / PROYECTO MONGO MODELER (DatabaseSchemaVm v0.1)
// Compatible con Mongo Modeler (Lemoncode): tables, fields, types y relations
// =============================================================================
const mongoModelerDiagramSchema = {
  version: "0.1",
  tables: [
    {
      id: "table_users_001",
      tableName: "users",
      x: 80,
      y: 120,
      fields: [
        {
          id: "f_users_id",
          name: "_id",
          type: "objectId",
          PK: true,
          isArray: false,
          isNN: true
        },
        {
          id: "f_users_username",
          name: "username",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_users_email",
          name: "email",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_users_password",
          name: "password",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_users_createdAt",
          name: "createdAt",
          type: "date",
          PK: false,
          isArray: false,
          isNN: false
        }
      ]
    },
    {
      id: "table_posts_002",
      tableName: "posts",
      x: 480,
      y: 120,
      fields: [
        {
          id: "f_posts_id",
          name: "_id",
          type: "objectId",
          PK: true,
          isArray: false,
          isNN: true
        },
        {
          id: "f_posts_creatorUsername",
          name: "creatorUsername",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_posts_topic",
          name: "topic",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_posts_title",
          name: "title",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_posts_content",
          name: "content",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_posts_createdAt",
          name: "createdAt",
          type: "date",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_posts_isEdited",
          name: "isEdited",
          type: "bool",
          PK: false,
          isArray: false,
          isNN: true
        }
      ]
    },
    {
      id: "table_comments_003",
      tableName: "comments",
      x: 880,
      y: 120,
      fields: [
        {
          id: "f_comments_id",
          name: "_id",
          type: "string",
          PK: true,
          isArray: false,
          isNN: true
        },
        {
          id: "f_comments_postId",
          name: "postId",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_comments_parentCommentId",
          name: "parentCommentId",
          type: "string",
          PK: false,
          isArray: false,
          isNN: false
        },
        {
          id: "f_comments_userName",
          name: "userName",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_comments_date",
          name: "date",
          type: "date",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_comments_comment",
          name: "comment",
          type: "string",
          PK: false,
          isArray: false,
          isNN: true
        },
        {
          id: "f_comments_isEdited",
          name: "isEdited",
          type: "bool",
          PK: false,
          isArray: false,
          isNN: true
        }
      ]
    }
  ],
  relations: [
    {
      id: "rel_users_posts",
      fromTableId: "table_users_001",
      toTableId: "table_posts_002",
      fromFieldId: "f_users_username",
      toFieldId: "f_posts_creatorUsername",
      type: "1:M"
    },
    {
      id: "rel_posts_comments",
      fromTableId: "table_posts_002",
      toTableId: "table_comments_003",
      fromFieldId: "f_posts_id",
      toFieldId: "f_comments_postId",
      type: "1:M"
    },
    {
      id: "rel_comments_parent_self",
      fromTableId: "table_comments_003",
      toTableId: "table_comments_003",
      fromFieldId: "f_comments_id",
      toFieldId: "f_comments_parentCommentId",
      type: "1:M"
    }
  ],
  notes: [
    {
      id: "note_nosql_architecture",
      title: "TerraBlog NoSQL Schema",
      description: "Esquema desacoplado y normalizado para MongoDB.\n- users: Colección de usuarios autenticados.\n- posts: Publicaciones ambientales.\n- comments: Comentarios y subcomentarios jerárquicos (parentCommentId).",
      x: 80,
      y: 420,
      width: 320,
      height: 140
    }
  ],
  selectedElementId: null
};

// =============================================================================
// 2. FORMATO PARA MODAL "IMPORT COLLECTION / IMPORT JSON" (Ctrl + I en Mongo Modeler)
// Representación BSON/JSON extendida para inferencia automática de campos y tipos
// =============================================================================

// Colección: users
const importPanelUsersJson = {
  _id: { $oid: "670d3810a9f3b1234567890a" },
  username: "david",
  email: "david@planetaverde.org",
  password: "miPasswordSeguro123",
  createdAt: { $date: "2026-10-13T10:00:00.000Z" }
};

// Colección: posts (Modelo desacoplado según README.md Sección 2)
const importPanelPostsJson = {
  _id: { $oid: "670d3810a9f3b1234567890b" },
  creatorUsername: "david",
  topic: "Energía Renovable",
  title: "Impacto de la energía solar comunitaria en zonas rurales",
  content: "La instalación de microrredes solares comunitarias promueve la independencia energética...",
  createdAt: { $date: "2026-10-13T13:45:00.000Z" },
  isEdited: false
};

// Colección: comments (Colección desacoplada y autorreferencial para sub-comentarios)
const importPanelCommentsJson = {
  _id: "comment_1728830500000",
  postId: "post_seed_001",
  parentCommentId: "comment_parent_optional_id",
  userName: "elena_bio",
  date: { $date: "2026-10-13T14:45:00.000Z" },
  comment: "Excelente iniciativa.",
  isEdited: false
};

// Patrón alternativo documentado en el diagrama Mermaid: posts con comments embebidos
const importPanelPostsWithEmbeddedCommentsJson = {
  _id: { $oid: "670d3810a9f3b1234567890c" },
  creatorUsername: "david",
  topic: "Energía Renovable",
  title: "Impacto de la energía solar comunitaria en zonas rurales",
  content: "La instalación de microrredes solares comunitarias promueve la independencia energética...",
  createdAt: { $date: "2026-10-13T13:45:00.000Z" },
  isEdited: false,
  comments: [
    {
      id: "comment_seed_001",
      postId: "post_seed_001",
      userName: "elena_bio",
      date: { $date: "2026-10-13T14:45:00.000Z" },
      comment: "Excelente iniciativa.",
      isEdited: false
    }
  ]
};

// =============================================================================
// 3. VALIDACIÓN ESTRICTA MONGODB ($jsonSchema para db.createCollection)
// =============================================================================
const mongoValidationSchemas = {
  users: {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["username", "email", "password"],
        properties: {
          _id: {
            bsonType: ["objectId", "string"],
            description: "Identificador único del usuario"
          },
          username: {
            bsonType: "string",
            description: "Nombre de usuario requerido y único"
          },
          email: {
            bsonType: "string",
            description: "Correo electrónico requerido y único"
          },
          password: {
            bsonType: "string",
            description: "Contraseña cifrada o en texto"
          },
          createdAt: {
            bsonType: "date",
            description: "Fecha de registro del usuario"
          }
        }
      }
    }
  },
  posts: {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["creatorUsername", "topic", "title", "content", "createdAt"],
        properties: {
          _id: {
            bsonType: ["objectId", "string"],
            description: "Identificador único de publicación"
          },
          creatorUsername: {
            bsonType: "string",
            description: "Nombre de usuario del autor"
          },
          topic: {
            bsonType: "string",
            description: "Tema o categoría ambiental"
          },
          title: {
            bsonType: "string",
            description: "Título de la publicación"
          },
          content: {
            bsonType: "string",
            description: "Cuerpo o contenido del post"
          },
          createdAt: {
            bsonType: "date",
            description: "Fecha y hora de creación (ISO-8601)"
          },
          isEdited: {
            bsonType: "bool",
            description: "Bandera de edición"
          }
        }
      }
    }
  },
  comments: {
    validator: {
      $jsonSchema: {
        bsonType: "object",
        required: ["postId", "userName", "date", "comment"],
        properties: {
          _id: {
            bsonType: "string",
            description: "Identificador único del comentario"
          },
          postId: {
            bsonType: ["objectId", "string"],
            description: "ID de la publicación padre"
          },
          parentCommentId: {
            bsonType: ["string", "null"],
            description: "ID del comentario padre si es sub-comentario"
          },
          userName: {
            bsonType: "string",
            description: "Nombre del autor del comentario"
          },
          date: {
            bsonType: "date",
            description: "Fecha y hora del comentario"
          },
          comment: {
            bsonType: "string",
            description: "Texto del comentario"
          },
          isEdited: {
            bsonType: "bool",
            description: "Bandera de edición"
          }
        }
      }
    }
  }
};

// Exportar para uso en módulos Node.js / JavaScript
if (typeof module !== "undefined" && module.exports) {
  module.exports = {
    mongoModelerDiagramSchema,
    importPanelUsersJson,
    importPanelPostsJson,
    importPanelCommentsJson,
    importPanelPostsWithEmbeddedCommentsJson,
    mongoValidationSchemas
  };
}

// También exportamos directamente el esquema de Mongo Modeler en la raíz para compatibilidad JSON pura:
console.log("Esquema de Mongo Modeler preparado exitosamente.");
