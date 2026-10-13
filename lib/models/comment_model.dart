class CommentModel {
  final String id;
  final String postId;
  final String userName;
  final DateTime date;
  final String comment;
  final bool isEdited;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userName,
    required this.date,
    required this.comment,
    this.isEdited = false,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userName,
    DateTime? date,
    String? comment,
    bool? isEdited,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
