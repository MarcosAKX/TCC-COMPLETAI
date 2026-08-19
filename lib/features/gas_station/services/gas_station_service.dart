import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/gas_station_model.dart';
import '../models/station_review.dart';

class GasStationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerStation(GasStationModel station) async {
    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: station.email,
        password: station.password,
      );

      final uid = credential.user!.uid;
      final privateReference = _firestore.collection('gas_stations').doc(uid);
      final publicReference = _firestore.collection('public_stations').doc(uid);
      final privateData = <String, dynamic>{
        'uid': uid,
        'name': station.name,
        'cnpj': station.cnpj,
        'phone': station.phone,
        'email': station.email,
        'address': station.address,
        'neighborhood': station.neighborhood,
        'city': station.city,
        'type': 'gas_station',
        'fuelPrices': <String, double>{},
        'tags': <String>[],
        'services': <String>[],
        'openingHours': _defaultOpeningHours,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final batch = _firestore.batch();
      batch.set(privateReference, privateData);
      batch.set(publicReference, {
        ..._buildPublicStationData(privateData),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (_) {
      final createdUser = credential?.user;
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // Preserva a falha original do cadastro.
        }
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCurrentStationData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final document = await _firestore
        .collection('gas_stations')
        .doc(user.uid)
        .get();
    final data = document.data();
    if (data != null) {
      await _ensurePublicProfile(user.uid, data);
    }
    return data;
  }

  Stream<Map<String, dynamic>?> watchCurrentStationData() {
    return _currentStationReference().snapshots().map(
      (document) => document.data(),
    );
  }

  Future<void> updateFuelPrices(Map<String, double> fuelPrices) async {
    if (fuelPrices.values.any((price) => price <= 0 || price > 50)) {
      throw ArgumentError('Informe preços válidos para os combustíveis.');
    }

    await _updateAdministrativeFields(
      privateUpdates: {'fuelPrices': fuelPrices},
      fuelPrices: fuelPrices,
    );
  }

  Future<void> updateStationInformation({
    required Set<String> tags,
    required Set<String> services,
  }) async {
    final sortedTags = tags.toList()..sort();
    final sortedServices = services.toList()..sort();
    await _updateAdministrativeFields(
      privateUpdates: {'tags': sortedTags, 'services': sortedServices},
      tags: sortedTags,
      services: sortedServices,
    );
  }

  Future<void> updateOpeningHours(
    Map<String, Map<String, dynamic>> openingHours,
  ) async {
    await _updateAdministrativeFields(
      privateUpdates: {'openingHours': openingHours},
      openingHours: openingHours,
    );
  }

  Future<void> _updateAdministrativeFields({
    required Map<String, dynamic> privateUpdates,
    Map<String, double>? fuelPrices,
    List<String>? tags,
    List<String>? services,
    Map<String, Map<String, dynamic>>? openingHours,
  }) async {
    final privateReference = _currentStationReference();
    final publicReference = _firestore
        .collection('public_stations')
        .doc(privateReference.id);
    final documents = await Future.wait([
      privateReference.get(),
      publicReference.get(),
    ]);
    final stationData = documents[0].data();
    if (stationData == null) {
      throw StateError('Perfil do posto não encontrado.');
    }

    final publicData = _buildPublicStationData(
      stationData,
      fuelPrices: fuelPrices,
      tags: tags,
      services: services,
      openingHours: openingHours,
    );
    publicData['updatedAt'] = FieldValue.serverTimestamp();
    if (!documents[1].exists) {
      publicData['createdAt'] = FieldValue.serverTimestamp();
    }

    final batch = _firestore.batch();
    batch.update(privateReference, {
      ...privateUpdates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(publicReference, publicData, SetOptions(merge: true));
    await batch.commit();
  }

  Stream<List<StationReview>> watchCurrentStationReviews() {
    final user = _requireCurrentUser();
    return _firestore
        .collection('public_stations')
        .doc(user.uid)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(StationReview.fromDocument).toList(),
        );
  }

  Stream<Set<String>> watchReportedReviewIds() {
    final user = _requireCurrentUser();
    return _firestore
        .collection('public_stations')
        .doc(user.uid)
        .collection('review_reports')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => document.data()['reviewId'])
              .whereType<String>()
              .toSet(),
        );
  }

  Future<void> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    final user = _requireCurrentUser();
    final reportId = '${reviewId}_${user.uid}';
    await _firestore
        .collection('public_stations')
        .doc(user.uid)
        .collection('review_reports')
        .doc(reportId)
        .set({
          'reviewId': reviewId,
          'stationId': user.uid,
          'reporterUid': user.uid,
          'reason': reason,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateStationField({
    required String field,
    required String value,
  }) async {
    const editableFields = {'name', 'phone', 'address', 'neighborhood', 'city'};
    if (!editableFields.contains(field)) {
      throw ArgumentError('Campo não permitido: $field');
    }

    final normalizedValue = value.trim();
    if (!_isValidStationField(field, normalizedValue)) {
      throw ArgumentError('Valor inválido para $field.');
    }

    final privateReference = _currentStationReference();
    final publicReference = _firestore
        .collection('public_stations')
        .doc(privateReference.id);
    final documents = await Future.wait([
      privateReference.get(),
      publicReference.get(),
    ]);
    final stationData = documents[0].data();
    if (stationData == null) {
      throw StateError('Perfil do posto não encontrado.');
    }
    stationData[field] = normalizedValue;

    final publicData = _buildPublicStationData(stationData);
    publicData['updatedAt'] = FieldValue.serverTimestamp();
    if (!documents[1].exists) {
      publicData['createdAt'] = FieldValue.serverTimestamp();
    }

    final batch = _firestore.batch();
    batch.update(privateReference, {
      field: normalizedValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(publicReference, publicData, SetOptions(merge: true));
    await batch.commit();
  }

  DocumentReference<Map<String, dynamic>> _currentStationReference() {
    final user = _requireCurrentUser();
    return _firestore.collection('gas_stations').doc(user.uid);
  }

  User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Nenhum posto autenticado.');
    }
    return user;
  }

  Future<void> _ensurePublicProfile(
    String stationId,
    Map<String, dynamic> stationData,
  ) async {
    final reference = _firestore.collection('public_stations').doc(stationId);
    final document = await reference.get();
    if (document.exists) return;

    await reference.set({
      ..._buildPublicStationData(stationData),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Map<String, dynamic> _buildPublicStationData(
    Map<String, dynamic> stationData, {
    Map<String, double>? fuelPrices,
    List<String>? tags,
    List<String>? services,
    Map<String, Map<String, dynamic>>? openingHours,
  }) {
    return {
      'uid': stationData['uid'],
      'name': stationData['name'],
      'phone': stationData['phone'],
      'address': stationData['address'],
      'neighborhood': stationData['neighborhood'],
      'city': stationData['city'],
      'fuelPrices':
          fuelPrices ?? stationData['fuelPrices'] ?? <String, double>{},
      'tags': tags ?? stationData['tags'] ?? <String>[],
      'services': services ?? stationData['services'] ?? <String>[],
      'openingHours':
          openingHours ?? stationData['openingHours'] ?? _defaultOpeningHours,
    };
  }

  static const Map<String, Map<String, dynamic>> _defaultOpeningHours = {
    'monday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
    'tuesday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
    'wednesday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
    'thursday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
    'friday': {'enabled': true, 'open': '06:00', 'close': '22:00'},
    'saturday': {'enabled': true, 'open': '06:00', 'close': '20:00'},
    'sunday': {'enabled': false, 'open': '08:00', 'close': '18:00'},
  };

  bool _isValidStationField(String field, String value) {
    switch (field) {
      case 'name':
        return value.length >= 3 && value.length <= 120;
      case 'phone':
        return RegExp(r'^\d{10,11}$').hasMatch(value);
      case 'address':
        return value.length >= 3 && value.length <= 200;
      case 'neighborhood':
        return value.length >= 2 && value.length <= 100;
      case 'city':
        return value.toLowerCase() == 'bebedouro';
      default:
        return false;
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Nenhum usuário autenticado com e-mail.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: oldPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}
