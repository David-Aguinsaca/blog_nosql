import 'comment_model.dart';

class BlogPostModel {
  final String id;
  final String creatorUsername;
  final DateTime createdAt;
  final String topic;
  final String title;
  final String content;
  final List<CommentModel> comments;
  final bool isEdited;

  BlogPostModel({
    required this.id,
    required this.creatorUsername,
    required this.createdAt,
    required this.topic,
    required this.title,
    required this.content,
    this.comments = const [],
    this.isEdited = false,
  });

  BlogPostModel copyWith({
    String? id,
    String? creatorUsername,
    DateTime? createdAt,
    String? topic,
    String? title,
    String? content,
    List<CommentModel>? comments,
    bool? isEdited,
  }) {
    return BlogPostModel(
      id: id ?? this.id,
      creatorUsername: creatorUsername ?? this.creatorUsername,
      createdAt: createdAt ?? this.createdAt,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      content: content ?? this.content,
      comments: comments ?? this.comments,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  Map<String, dynamic> toMap({bool includeComments = false}) {
    final map = <String, dynamic>{
      '_id': id,
      'creatorUsername': creatorUsername,
      'createdAt': createdAt.toIso8601String(),
      'topic': topic,
      'title': title,
      'content': content,
      'isEdited': isEdited,
    };
    if (includeComments) {
      map['comments'] = comments.map((c) => c.toMap()).toList();
    }
    return map;
  }

  factory BlogPostModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['createdAt'];
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final rawComments = map['comments'] as List<dynamic>? ?? [];
    final commentsList = rawComments.map((item) {
      if (item is Map) {
        return CommentModel.fromMap(Map<String, dynamic>.from(item));
      }
      return null;
    }).whereType<CommentModel>().toList();

    return BlogPostModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      creatorUsername: map['creatorUsername']?.toString() ?? '',
      createdAt: parsedDate,
      topic: map['topic']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      isEdited: map['isEdited'] == true,
      comments: commentsList,
    );
  }
}
