import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../gas_station/models/public_gas_station.dart';
import '../../gas_station/models/station_presentation.dart';
import '../../gas_station/models/station_review.dart';

class PublicStationService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PublicStationService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  Future<List<PublicGasStation>> getStations() async {
    final collection = _firestore.collection('public_stations');
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await collection.get(const GetOptions(source: Source.server));
    } on FirebaseException catch (serverError) {
      debugPrint(
        'Servidor indisponível ao atualizar postos: '
        '${serverError.code} - ${serverError.message}. Usando cache.',
      );
      snapshot = await collection.get(const GetOptions(source: Source.cache));
    }
    final bebedouroStations = snapshot.docs.where((document) {
      final city = document.data()['city'];
      return city is String && city.trim().toLowerCase() == 'bebedouro';
    });

    return Future.wait(
      bebedouroStations.map((document) async {
        final station = PublicGasStation.fromDocument(document);
        List<StationReview> reviews;
        try {
          reviews = await getReviews(station.id);
        } on FirebaseException catch (error) {
          // Uma avaliação indisponível não deve impedir a atualização dos
          // preços e das informações dos demais postos.
          debugPrint(
            'Falha ao carregar avaliações de ${station.id}: '
            '${error.code} - ${error.message}',
          );
          reviews = const [];
        }
        final average = reviews.isEmpty
            ? 0.0
            : reviews.fold<double>(0, (total, item) => total + item.rating) /
                  reviews.length;
        return station.withRating(average: average, count: reviews.length);
      }),
    );
  }

  Future<PublicGasStation> getStation(String stationId) async {
    final document = await _firestore
        .collection('public_stations')
        .doc(stationId)
        .get();
    final reviews = await getReviews(stationId);

    if (!document.exists) {
      throw StateError('Posto não encontrado.');
    }

    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (total, item) => total + item.rating) /
              reviews.length;
    final station = PublicGasStation.fromDocument(
      document,
      averageRating: average,
      reviewCount: reviews.length,
    );
    try {
      final coverDocument = await _firestore
          .collection('station_covers')
          .doc(stationId)
          .get();
      final coverData = coverDocument.data();
      final value = coverData?['bytes'];
      final byteSize = coverData?['byteSize'];
      if (coverData?['contentType'] != 'image/jpeg' ||
          value is! Blob ||
          byteSize is! int ||
          byteSize != value.bytes.lengthInBytes ||
          byteSize > StationCoverProcessor.maxOutputBytes) {
        return station;
      }
      return station.withCoverImageBytes(value.bytes);
    } on FirebaseException catch (error) {
      debugPrint('Falha ao carregar capa de ${station.id}: ${error.code}.');
      return station;
    }
  }

  Future<List<StationReview>> getReviews(String stationId) async {
    final collection = _firestore
        .collection('public_stations')
        .doc(stationId)
        .collection('reviews');
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await collection.get(const GetOptions(source: Source.server));
    } on FirebaseException {
      snapshot = await collection.get(const GetOptions(source: Source.cache));
    }
    final reviews = snapshot.docs.map(StationReview.fromDocument).toList();
    reviews.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return reviews;
  }

  Future<void> submitReview({
    required String stationId,
    required int rating,
    required String comment,
  }) async {
    final user = _requireUser();
    if (rating < 1 || rating > 5) {
      throw ArgumentError('A nota deve estar entre 1 e 5.');
    }
    final normalizedComment = comment.trim();
    if (normalizedComment.length < 3 || normalizedComment.length > 500) {
      throw ArgumentError('A avaliação deve ter entre 3 e 500 caracteres.');
    }

    final userDocument = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final authorName =
        (userDocument.data()?['name'] as String?)?.trim() ?? 'Usuário';
    final reference = _firestore
        .collection('public_stations')
        .doc(stationId)
        .collection('reviews')
        .doc(user.uid);
    final existingReview = await reference.get();
    final data = <String, dynamic>{
      'userId': user.uid,
      'authorName': authorName,
      'rating': rating,
      'comment': normalizedComment,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existingReview.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await reference.set(data, SetOptions(merge: true));
  }

  Stream<bool> watchIsFavorite(String stationId) {
    final user = _requireUser();
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(stationId)
        .snapshots()
        .map((document) => document.exists);
  }

  Future<void> setFavorite({
    required String stationId,
    required bool favorite,
  }) async {
    final user = _requireUser();
    final reference = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(stationId);
    if (favorite) {
      await reference.set({
        'stationId': stationId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await reference.delete();
    }
  }

  Future<void> reportStation({
    required String stationId,
    required String reason,
    String details = '',
  }) async {
    final user = _requireUser();
    await _firestore
        .collection('public_stations')
        .doc(stationId)
        .collection('reports')
        .doc(user.uid)
        .set({
          'stationId': stationId,
          'reporterUid': user.uid,
          'reason': reason,
          'details': details.trim(),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> reportReview({
    required String stationId,
    required String reviewId,
    required String reason,
  }) async {
    final user = _requireUser();
    final reportId = '${reviewId}_${user.uid}';
    await _firestore
        .collection('public_stations')
        .doc(stationId)
        .collection('review_reports')
        .doc(reportId)
        .set({
          'reviewId': reviewId,
          'stationId': stationId,
          'reporterUid': user.uid,
          'reason': reason,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Faça login para continuar.');
    }
    return user;
  }
}
