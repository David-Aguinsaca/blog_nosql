class CommentModel {
  final String id;
  final String postId;
  final String? parentCommentId;
  final String userName;
  final DateTime date;
  final String comment;
  final bool isEdited;

  CommentModel({
    required this.id,
    required this.postId,
    this.parentCommentId,
    required this.userName,
    required this.date,
    required this.comment,
    this.isEdited = false,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    String? parentCommentId,
    bool clearParentCommentId = false,
    String? userName,
    DateTime? date,
    String? comment,
    bool? isEdited,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      parentCommentId: clearParentCommentId
          ? null
          : (parentCommentId ?? this.parentCommentId),
      userName: userName ?? this.userName,
      date: date ?? this.date,
      comment: comment ?? this.comment,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'postId': postId,
      'parentCommentId': parentCommentId,
      'userName': userName,
      'date': date.toIso8601String(),
      'comment': comment,
      'isEdited': isEdited,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['date'];
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return CommentModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      postId: map['postId']?.toString() ?? '',
      parentCommentId: map['parentCommentId']?.toString(),
      userName: map['userName']?.toString() ?? '',
      date: parsedDate,
      comment: map['comment']?.toString() ?? '',
      isEdited: map['isEdited'] == true,
    );
  }
}
