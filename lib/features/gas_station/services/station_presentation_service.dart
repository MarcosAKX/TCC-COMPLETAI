import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/station_presentation.dart';
import 'gas_station_service.dart';

abstract interface class StationPresentationBoundary {
  String? get currentUserId;

  Future<Map<String, dynamic>?> loadStation(String stationId);

  Future<Uint8List?> loadCover(String stationId);

  Future<void> commitPresentation({
    required String stationId,
    required Uint8List? coverBytes,
    required String stationBrand,
    required bool removeCover,
  });
}

class StationPresentationService {
  StationPresentationService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      _injectedBoundary = null;

  StationPresentationService.withBoundary(StationPresentationBoundary boundary)
    : _auth = null,
      _firestore = null,
      _injectedBoundary = boundary;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final StationPresentationBoundary? _injectedBoundary;

  late final StationPresentationBoundary _boundary =
      _injectedBoundary ??
      _FirebaseStationPresentationBoundary(
        auth: _auth!,
        firestore: _firestore!,
      );

  Future<StationPresentation> loadCurrent() async {
    final stationId = _requireCurrentUserId();
    final data = await _boundary.loadStation(stationId);
    if (data == null) {
      throw StateError('Perfil do posto não encontrado.');
    }
    final presentation = StationPresentation.fromMap(data);
    final coverBytes = await _boundary.loadCover(stationId);
    return StationPresentation(
      coverImageBytes: coverBytes,
      stationBrand: presentation.stationBrand,
    );
  }

  Future<StationPresentation> savePresentation({
    required StationPresentation current,
    required String stationBrand,
    StationCoverImage? newCover,
  }) async {
    final stationId = _requireCurrentUserId();
    final normalizedBrand = _normalizeBrand(stationBrand);
    await _boundary.commitPresentation(
      stationId: stationId,
      coverBytes: newCover?.bytes,
      stationBrand: normalizedBrand,
      removeCover: false,
    );
    return StationPresentation(
      coverImageBytes: newCover?.bytes ?? current.coverImageBytes,
      stationBrand: normalizedBrand,
    );
  }

  Future<StationPresentation> removeCover({
    required StationPresentation current,
    required String stationBrand,
  }) async {
    final stationId = _requireCurrentUserId();
    final normalizedBrand = _normalizeBrand(stationBrand);
    await _boundary.commitPresentation(
      stationId: stationId,
      coverBytes: null,
      stationBrand: normalizedBrand,
      removeCover: true,
    );
    return StationPresentation(stationBrand: normalizedBrand);
  }

  String _requireCurrentUserId() {
    final stationId = _boundary.currentUserId;
    if (stationId == null) {
      throw StateError('Nenhum posto autenticado.');
    }
    return stationId;
  }

  String _normalizeBrand(String stationBrand) {
    final value = stationBrand.trim();
    if (value.length < 2 || value.length > 60) {
      throw ArgumentError('Informe uma bandeira entre 2 e 60 caracteres.');
    }
    return value;
  }
}

class _FirebaseStationPresentationBoundary
    implements StationPresentationBoundary {
  const _FirebaseStationPresentationBoundary({
    required this.auth,
    required this.firestore,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  @override
  String? get currentUserId => auth.currentUser?.uid;

  @override
  Future<Map<String, dynamic>?> loadStation(String stationId) async {
    final snapshot = await firestore
        .collection('gas_stations')
        .doc(stationId)
        .get();
    return snapshot.data();
  }

  @override
  Future<Uint8List?> loadCover(String stationId) async {
    final snapshot = await firestore
        .collection('station_covers')
        .doc(stationId)
        .get();
    final data = snapshot.data();
    if (data == null || data['contentType'] != 'image/jpeg') return null;
    final value = data['bytes'];
    final byteSize = data['byteSize'];
    if (value is! Blob ||
        byteSize is! int ||
        byteSize != value.bytes.lengthInBytes ||
        byteSize > StationCoverProcessor.maxOutputBytes) {
      return null;
    }
    return value.bytes;
  }

  @override
  Future<void> commitPresentation({
    required String stationId,
    required Uint8List? coverBytes,
    required String stationBrand,
    required bool removeCover,
  }) async {
    final privateReference = firestore
        .collection('gas_stations')
        .doc(stationId);
    final publicReference = firestore
        .collection('public_stations')
        .doc(stationId);
    final coverReference = firestore
        .collection('station_covers')
        .doc(stationId);

    await firestore.runTransaction<void>((transaction) async {
      final privateDocument = await transaction.get(privateReference);
      final publicDocument = await transaction.get(publicReference);
      final stationData = privateDocument.data();
      if (stationData == null) {
        throw StateError('Perfil do posto não encontrado.');
      }

      transaction.update(privateReference, {
        'stationBrand': stationBrand,
        'coverImagePath': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final publicData = publicDocument.exists
          ? <String, dynamic>{
              'stationBrand': stationBrand,
              'coverImagePath': FieldValue.delete(),
              'updatedAt': FieldValue.serverTimestamp(),
            }
          : <String, dynamic>{
              ...buildPublicStationData({
                ...stationData,
                'stationBrand': stationBrand,
              }),
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            };
      transaction.set(publicReference, publicData, SetOptions(merge: true));

      if (coverBytes != null) {
        transaction.set(coverReference, {
          'stationId': stationId,
          'bytes': Blob(coverBytes),
          'contentType': StationCoverProcessor.contentType,
          'byteSize': coverBytes.lengthInBytes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else if (removeCover) {
        transaction.delete(coverReference);
      }
    });
  }
}
