class Comment {
  final int? id;
  final int bookingId;
  final String commenterName;
  final String commentText;
  final DateTime timestamp;

  Comment({
    this.id,
    required this.bookingId,
    required this.commenterName,
    required this.commentText,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'commenterName': commenterName,
      'commentText': commentText,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      bookingId: map['bookingId'],
      commenterName: map['commenterName'],
      commentText: map['commentText'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
