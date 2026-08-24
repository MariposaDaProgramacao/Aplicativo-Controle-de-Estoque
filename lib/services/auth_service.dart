import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CHAVES PARA SHARED_PREFERENCES ====================
  static const String _keyEmail = 'user_email';
  static const String _keySenha = 'user_password';
  static const String _keyLembrarMe = 'lembrar_me';

  // ==================== GETTERS ====================

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String get currentUserId => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get userChanges => _auth.userChanges();

  // ==================== LOGIN COM LEMBRAR-ME ====================

  Future<User?> login(String email, String senha, {bool lembrarMe = false}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );

      if (lembrarMe) {
        await _salvarCredenciais(email.trim(), senha.trim());
      } else {
        await _limparCredenciais();
      }

      await _atualizarUltimoAcesso(userCredential.user!.uid);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // ==================== LOGIN AUTOMÁTICO ====================

  Future<User?> loginAutomatico() async {
    try {
      final credenciais = await _carregarCredenciais();
      if (credenciais == null) return null;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: credenciais['email']!,
        password: credenciais['senha']!,
      );

      await _atualizarUltimoAcesso(userCredential.user!.uid);
      return userCredential.user;
    } catch (e) {
      await _limparCredenciais();
      return null;
    }
  }

  Future<bool> deveLembrar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyLembrarMe) ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== SALVAR / CARREGAR / LIMPAR CREDENCIAIS ====================

  Future<void> _salvarCredenciais(String email, String senha) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keySenha, senha);
      await prefs.setBool(_keyLembrarMe, true);
    } catch (e) {
      print('Erro ao salvar credenciais: $e');
    }
  }

  Future<Map<String, String>?> _carregarCredenciais() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_keyEmail);
      final senha = prefs.getString(_keySenha);
      final lembrarMe = prefs.getBool(_keyLembrarMe) ?? false;

      if (email != null && senha != null && lembrarMe) {
        return {'email': email, 'senha': senha};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _limparCredenciais() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyEmail);
      await prefs.remove(_keySenha);
      await prefs.setBool(_keyLembrarMe, false);
    } catch (e) {
      print('Erro ao limpar credenciais: $e');
    }
  }

  // ==================== CADASTRO ====================

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

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    try {
      await _limparCredenciais();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  // ==================== REDEFINIÇÃO DE SENHA ====================

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao enviar e-mail de redefinição: $e');
    }
  }

  // ==================== ATUALIZAR E-MAIL (CORRIGIDO) ====================

  Future<void> updateEmail(String novoEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      // 🔥 MÉTODO MAIS RECENTE E SEGURO
      await user.verifyBeforeUpdateEmail(novoEmail.trim());

      // Atualiza o Firestore
      await _firestore.collection('usuarios').doc(user.uid).update({
        'email': novoEmail.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': false,
      });

      // Envia e-mail de verificação
      await user.sendEmailVerification();

    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao atualizar e-mail: $e');
    }
  }

  // ==================== ATUALIZAR SENHA ====================

  Future<void> updatePassword(String novaSenha) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }
      await user.updatePassword(novaSenha.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao atualizar senha: $e');
    }
  }

  // ==================== REAUTENTICAR ====================

  Future<void> reauthenticate(String senha) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }
      if (user.email == null) {
        throw Exception('Usuário não tem e-mail cadastrado');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: senha.trim(),
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao reautenticar: $e');
    }
  }

  // ==================== EXCLUIR CONTA ====================

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      await _firestore.collection('usuarios').doc(user.uid).delete();

      final produtosSnapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: user.uid)
          .get();

      for (final doc in produtosSnapshot.docs) {
        await doc.reference.delete();
      }

      final movimentosSnapshot = await _firestore
          .collection('movimentacoes')
          .where('usuarioId', isEqualTo: user.uid)
          .get();

      for (final doc in movimentosSnapshot.docs) {
        await doc.reference.delete();
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao excluir conta: $e');
    }
  }

  // ==================== MÉTODOS PRIVADOS ====================

  Future<void> _criarDocumentoUsuario(User user) async {
    try {
      await _firestore.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first ?? 'Usuário',
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
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

  // ==================== MÉTODOS DE VERIFICAÇÃO ====================

  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erro ao enviar e-mail de verificação: $e');
    }
  }

  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Erro ao recarregar usuário: $e');
    }
  }
}