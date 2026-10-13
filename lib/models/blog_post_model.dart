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
}
