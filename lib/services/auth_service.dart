import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== GETTERS ====================

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== MÉTODOS PRINCIPAIS ====================

  Future<User?> login(String email, String senha) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );
      await _atualizarUltimoAcesso(userCredential.user!.uid);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<User?> register(String email, String senha) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );
      await _criarDocumentoUsuario(userCredential.user!);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao cadastrar: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao enviar e-mail de redefinição: $e');
    }
  }

  // ==================== MÉTODOS PRIVADOS ====================

  Future<void> _criarDocumentoUsuario(User user) async {
    try {
      await _firestore.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first ?? 'Usuário',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      throw Exception('Erro ao salvar dados do usuário: $e');
    }
  }

  Future<void> _atualizarUltimoAcesso(String uid) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      // Ignora erro
    }
  }

  // ==================== TRATAMENTO DE ERROS ====================

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return '❌ Usuário não encontrado. Verifique seu e-mail.';
      case 'wrong-password':
        return '❌ Senha incorreta. Tente novamente.';
      case 'invalid-email':
        return '❌ E-mail inválido. Digite um e-mail válido.';
      case 'user-disabled':
        return '❌ Esta conta foi desativada.';
      case 'too-many-requests':
        return '⚠️ Muitas tentativas. Tente novamente mais tarde.';
      case 'email-already-in-use':
        return '❌ Este e-mail já está em uso.';
      case 'weak-password':
        return '❌ A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return '⚠️ Erro de rede. Verifique sua conexão.';
      default:
        return '❌ Erro: ${e.message ?? 'Erro inesperado.'}';
    }
  }
}