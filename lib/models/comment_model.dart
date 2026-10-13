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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
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
      id: map['id']?.toString() ?? '',
      postId: map['postId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? '',
      date: parsedDate,
      comment: map['comment']?.toString() ?? '',
      isEdited: map['isEdited'] == true,
    );
  }
}
