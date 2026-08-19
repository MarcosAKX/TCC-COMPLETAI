import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  // =========================
  // FIREBASE INSTANCES
  // =========================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // CADASTRO DE USUÁRIO
  // =========================

  Future<void> registerUser(UserModel user) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      final String uid = credential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'type': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // createUserWithEmailAndPassword autentica imediatamente. Se a gravação
      // do perfil falhar, remove a conta recém-criada para evitar órfãos.
      final createdUser = credential?.user;
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // Mantém a exceção original. Uma limpeza definitiva deve ser feita
          // por uma rotina administrativa caso o Firebase também falhe aqui.
        }
      }
      rethrow;
    }
  }

  // =========================
  // LOGIN EMAIL/SENHA
  // =========================

  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // =========================
  // BUSCAR DADOS DO USUÁRIO
  // =========================

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    return doc.data();
  }

  // =========================
  // ATUALIZAR NOME
  // =========================

  Future<void> updateName(String name) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Nenhum usuário autenticado.');
    }

    final normalizedName = name.trim();
    if (normalizedName.length < 3) {
      throw ArgumentError('Nome inválido.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'name': normalizedName,
    });
  }

  // =========================
  // ATUALIZAR CELULAR
  // =========================

  Future<void> updatePhone(String phone) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Nenhum usuário autenticado.');
    }

    final normalizedPhone = phone.trim();
    if (!RegExp(r'^\d{10,11}$').hasMatch(normalizedPhone)) {
      throw ArgumentError('Celular inválido.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'phone': normalizedPhone,
    });
  }

  // =========================
  // ALTERAR SENHA
  // =========================

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

  // =========================
  // ESQUECI MINHA SENHA
  // =========================

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
