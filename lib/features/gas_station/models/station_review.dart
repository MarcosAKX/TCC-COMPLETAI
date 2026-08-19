import 'package:cloud_firestore/cloud_firestore.dart';

class StationReview {
  final String id;
  final String userId;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StationReview({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StationReview.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final rawRating = data['rating'];
    final rawCreatedAt = data['createdAt'];
    final rawUpdatedAt = data['updatedAt'];

    return StationReview(
      id: document.id,
      userId: (data['userId'] as String?)?.trim() ?? '',
      authorName: (data['authorName'] as String?)?.trim().isNotEmpty == true
          ? (data['authorName'] as String).trim()
          : 'Usuário',
      rating: rawRating is num ? rawRating.toDouble().clamp(0, 5) : 0,
      comment: (data['comment'] as String?)?.trim() ?? '',
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
    );
  }
}
