// ============================================================
// 📁 auth_service.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está na "PORTARIA" de um prédio.
//              Esse arquivo é o "SEGURANÇA" que controla quem entra,
//              quem sai e quem pode acessar o sistema.
// 
// 🏠 Ele é como o "CONTROLADOR DE ACESSO" do app:
//    - Faz login (deixa entrar)
//    - Faz cadastro (cria uma nova identidade)
//    - Faz logout (expulsa da área restrita)
//    - Lembra do usuário (guarda a chave na gaveta)
//    - Redefine senha (emite uma nova chave)
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Firebase Auth (o "sistema de crachás")
import 'package:firebase_auth/firebase_auth.dart';
// Linha 2: Importa o Firestore (o "banco de dados" dos usuários)
import 'package:cloud_firestore/cloud_firestore.dart';
// Linha 3: Importa o SharedPreferences (a "gaveta" onde guardamos as chaves)
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// 🏠 CLASSE AUTHSERVICE — O "SEGURANÇA" DO SISTEMA
// ============================================================
// Linha 6: Define a classe AuthService
// Ela é responsável por toda a autenticação do app.
class AuthService {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" do segurança
  // ============================================================
  
  // Linha 9: Instância do Firebase Auth (o "sistema de crachás")
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Linha 10: Instância do Firestore (o "banco de dados" dos usuários)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 🔑 CHAVES PARA SHARED_PREFERENCES — "NOMES DAS GAVETAS"
  // ============================================================
  // Linha 13-15: Constantes para guardar as credenciais
  // Analogia: São os "NOMES DAS GAVETAS" onde o segurança guarda
  //           o e-mail e a senha do usuário.
  static const String _keyEmail = 'user_email'; // Gaveta do e-mail
  static const String _keySenha = 'user_password'; // Gaveta da senha
  static const String _keyLembrarMe = 'lembrar_me'; // Gaveta do "lembrar-me"

  // ============================================================
  // 🎯 GETTERS — "PERGUNTAS" QUE O SEGURANÇA RESPONDE
  // ============================================================
  // Analogia: São perguntas que você faz ao segurança:
  //           "Tem alguém logado?" "Quem está logado?" etc.
  
  // Linha 19: Retorna o usuário atual (quem está dentro do prédio)
  // Exemplo: Se João está logado, retorna os dados do João.
  User? get currentUser => _auth.currentUser;
  
  // Linha 20: Verifica se tem alguém logado (tem alguém no prédio?)
  // Retorna true se tiver alguém logado, false se não.
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Linha 21: Retorna o ID do usuário atual (o "crachá" da pessoa)
  // Exemplo: "abc123" — é o número de identificação.
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Linha 22: Retorna o e-mail do usuário atual (o "e-mail" da pessoa)
  // Exemplo: "joao@email.com"
  String get currentUserEmail => _auth.currentUser?.email ?? '';
  
  // Linha 23: Stream que avisa quando o usuário muda (entra/sai)
  // Analogia: É como uma "CAMPANHINHA" que toca quando alguém entra ou sai.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Linha 24: Stream que avisa quando os dados do usuário mudam
  Stream<User?> get userChanges => _auth.userChanges();

  // ============================================================
  // 🔑 LOGIN — "DEIXA O USUÁRIO ENTRAR"
  // ============================================================
  // Linha 27: Função que faz o login do usuário.
  // Analogia: O segurança verifica a identidade e deixa a pessoa entrar.
  // 
  // Parâmetros:
  //   - email: o e-mail (a "identidade" da pessoa)
  //   - senha: a senha (a "senha" da pessoa)
  //   - lembrarMe: se deve guardar as credenciais (se deve dar uma "chave extra")
  // 
  // Retorna: O usuário que entrou (ou lança um erro)
  Future<User?> login(String email, String senha, {bool lembrarMe = false}) async {
    try { // Tenta fazer o login
      // Linha 32-35: Chama o Firebase Auth para fazer o login.
      // Analogia: O segurança verifica o crachá e a senha.
      // .trim() = remove espaços em branco.
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );

      // Linha 37: Se o usuário marcou "Lembrar-me"...
      if (lembrarMe) {
        // Linha 38: Guarda o e-mail e a senha na gaveta (SharedPreferences)
        await _salvarCredenciais(email.trim(), senha.trim());
      } else {
        // Linha 40: Se não marcou, limpa a gaveta (apaga as credenciais)
        await _limparCredenciais();
      }

      // Linha 43: Atualiza a data do último acesso no banco de dados
      await _atualizarUltimoAcesso(userCredential.user!.uid);
      
      // Linha 44: Retorna o usuário que entrou
      return userCredential.user;
    } on FirebaseAuthException catch (e) { // Se o Firebase deu erro
      // Linha 46: Trata o erro e lança uma mensagem amigável
      throw _handleAuthError(e);
    } catch (e) { // Se outro erro aconteceu
      // Linha 48: Lança um erro genérico
      throw Exception('Erro ao fazer login: $e');
    }
  }

  // ============================================================
  // 🤖 LOGIN AUTOMÁTICO — "ENTRA SOZINHO"
  // ============================================================
  // Linha 53: Função que tenta fazer login automático.
  // Analogia: O segurança lembra que você já esteve aqui antes
  //           e te deixa entrar sem mostrar o crachá de novo.
  // 
  // Retorna: O usuário logado automaticamente, ou null se não conseguir.
  Future<User?> loginAutomatico() async {
    try { // Tenta fazer o login automático
      // Linha 56: Carrega as credenciais da gaveta (SharedPreferences)
      final credenciais = await _carregarCredenciais();
      
      // Linha 57: Se não tem credenciais, retorna null (não entra)
      if (credenciais == null) return null;

      // Linha 59-62: Tenta fazer login com as credenciais salvas
      // Analogia: O segurança usa a chave reserva que estava guardada.
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: credenciais['email']!, // Pega o e-mail guardado
        password: credenciais['senha']!, // Pega a senha guardada
      );

      // Linha 64: Atualiza a data do último acesso
      await _atualizarUltimoAcesso(userCredential.user!.uid);
      
      // Linha 65: Retorna o usuário que entrou
      return userCredential.user;
    } catch (e) { // Se deu erro (credenciais inválidas, etc.)
      // Linha 67: Limpa as credenciais (joga fora a chave reserva)
      await _limparCredenciais();
      return null; // Não entra
    }
  }

  // ============================================================
  // 🔍 DEVELEMBRAR — "O USUÁRIO QUER SER LEMBRADO?"
  // ============================================================
  // Linha 71: Função que verifica se o usuário deve ser lembrado.
  // Analogia: O segurança olha na gaveta para ver se tem
  //           uma anotação dizendo "Este usuário quer ser lembrado".
  // 
  // Retorna: true se o usuário quer ser lembrado, false se não.
  Future<bool> deveLembrar() async {
    try { // Tenta verificar
      // Linha 74: Abre a gaveta (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      // Linha 75: Pega o valor da gaveta "lembrar_me" (ou false se não tiver)
      return prefs.getBool(_keyLembrarMe) ?? false;
    } catch (e) { // Se deu erro
      return false; // Assume que não quer ser lembrado
    }
  }

  // ============================================================
  // 💾 SALVAR / CARREGAR / LIMPAR CREDENCIAIS — "MEXENDO NA GAVETA"
  // ============================================================

  // ============================================================
  // 💾 _SALVARCREDENCIAIS — "GUARDA NA GAVETA"
  // ============================================================
  // Linha 83: Função que salva e-mail e senha.
  // Analogia: O segurança guarda uma cópia da chave na gaveta.
  Future<void> _salvarCredenciais(String email, String senha) async {
    try { // Tenta salvar
      // Linha 86: Abre a gaveta (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      // Linha 87-89: Guarda o e-mail, a senha e a informação "lembrar-me"
      await prefs.setString(_keyEmail, email); // Guarda o e-mail
      await prefs.setString(_keySenha, senha); // Guarda a senha
      await prefs.setBool(_keyLembrarMe, true); // Marca "lembrar-me" como true
    } catch (e) { // Se deu erro
      print('Erro ao salvar credenciais: $e'); // Mostra o erro no console
    }
  }

  // ============================================================
  // 📂 _CARREGARCREDENCIAIS — "PEGA DA GAVETA"
  // ============================================================
  // Linha 94: Função que carrega e-mail e senha salvos.
  // Analogia: O segurança abre a gaveta e pega a chave reserva.
  // 
  // Retorna: Um mapa com e-mail e senha, ou null se não tiver.
  Future<Map<String, String>?> _carregarCredenciais() async {
    try { // Tenta carregar
      // Linha 97: Abre a gaveta (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      
      // Linha 98-100: Pega os valores da gaveta
      final email = prefs.getString(_keyEmail); // Pega o e-mail
      final senha = prefs.getString(_keySenha); // Pega a senha
      final lembrarMe = prefs.getBool(_keyLembrarMe) ?? false; // Pega "lembrar-me"

      // Linha 102-104: Se tem e-mail, senha e "lembrar-me" está marcado...
      if (email != null && senha != null && lembrarMe) {
        return {'email': email, 'senha': senha}; // Retorna as credenciais
      }
      return null; // Se não, retorna null
    } catch (e) { // Se deu erro
      return null; // Retorna null
    }
  }

  // ============================================================
  // 🗑️ _LIMPARCREDENCIAIS — "ESVAZIA A GAVETA"
  // ============================================================
  // Linha 111: Função que limpa as credenciais salvas.
  // Analogia: O segurança joga fora a chave reserva e limpa a gaveta.
  Future<void> _limparCredenciais() async {
    try { // Tenta limpar
      // Linha 114: Abre a gaveta (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      // Linha 115-117: Remove o e-mail, a senha e o "lembrar-me"
      await prefs.remove(_keyEmail); // Remove o e-mail
      await prefs.remove(_keySenha); // Remove a senha
      await prefs.setBool(_keyLembrarMe, false); // Marca "lembrar-me" como false
    } catch (e) { // Se deu erro
      print('Erro ao limpar credenciais: $e'); // Mostra o erro no console
    }
  }

  // ============================================================
  // 📝 CADASTRO — "CRIA UMA NOVA IDENTIDADE"
  // ============================================================
  // Linha 123: Função que cadastra um novo usuário.
  // Analogia: A pessoa vai na portaria e faz um novo crachá.
  // 
  // Parâmetros:
  //   - email: o e-mail (a "identidade" da pessoa)
  //   - senha: a senha (a "senha" da pessoa)
  // 
  // Retorna: O usuário criado (ou lança um erro)
  Future<User?> register(String email, String senha) async {
    try { // Tenta criar a conta
      // Linha 127-130: Chama o Firebase Auth para criar a conta.
      // Analogia: O segurança cria um novo crachá no sistema.
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );

      // Linha 132: Salva os dados do usuário no Firestore (banco de dados)
      await _criarDocumentoUsuario(userCredential.user!);
      
      // Linha 133: Retorna o usuário criado
      return userCredential.user;
    } on FirebaseAuthException catch (e) { // Se o Firebase deu erro
      throw _handleAuthError(e); // Trata o erro
    } catch (e) { // Se outro erro aconteceu
      throw Exception('Erro ao cadastrar: $e');
    }
  }

  // ============================================================
  // 🚪 LOGOUT — "EXPULSA DA ÁREA RESTRITA"
  // ============================================================
  // Linha 141: Função que faz o logout.
  // Analogia: O segurança pede para a pessoa sair do prédio.
  Future<void> logout() async {
    try { // Tenta fazer logout
      // Linha 144: Limpa as credenciais (joga fora a chave)
      await _limparCredenciais();
      // Linha 145: Chama o Firebase Auth para deslogar
      await _auth.signOut();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  // ============================================================
  // 🔑 REDEFINIÇÃO DE SENHA — "EMITE UMA NOVA CHAVE"
  // ============================================================
  // Linha 151: Função que envia e-mail para redefinir a senha.
  // Analogia: A pessoa perdeu a chave e o segurança envia uma nova
  //           pelo correio (e-mail).
  Future<void> resetPassword(String email) async {
    try { // Tenta enviar o e-mail
      // Linha 154: Chama o Firebase Auth para enviar o e-mail.
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) { // Se deu erro
      throw _handleAuthError(e); // Trata o erro
    } catch (e) { // Se outro erro aconteceu
      throw Exception('Erro ao enviar e-mail de redefinição: $e');
    }
  }

  // ============================================================
  // ✏️ ATUALIZAR E-MAIL — "TROCA A IDENTIDADE"
  // ============================================================
  // Linha 163: Função que atualiza o e-mail do usuário.
  // Analogia: A pessoa mudou de nome e o segurança atualiza o crachá.
  Future<void> updateEmail(String novoEmail) async {
    try { // Tenta atualizar o e-mail
      // Linha 166: Pega o usuário atual
      final user = _auth.currentUser;
      
      // Linha 167-169: Se não tem usuário logado, lança um erro
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      // Linha 172: Tenta atualizar o e-mail com verificação.
      // Analogia: O segurança pede para confirmar a nova identidade.
      await user.verifyBeforeUpdateEmail(novoEmail.trim());

      // Linha 175-179: Atualiza o e-mail no Firestore (banco de dados)
      await _firestore.collection('usuarios').doc(user.uid).update({
        'email': novoEmail.trim(),
        'updatedAt': FieldValue.serverTimestamp(), // Data da atualização
        'emailVerified': false, // O e-mail precisa ser verificado de novo
      });

      // Linha 182: Envia e-mail de verificação para o novo e-mail
      await user.sendEmailVerification();

    } on FirebaseAuthException catch (e) { // Se deu erro
      throw _handleAuthError(e); // Trata o erro
    } catch (e) { // Se outro erro aconteceu
      throw Exception('Erro ao atualizar e-mail: $e');
    }
  }

  // ============================================================
  // ✏️ ATUALIZAR SENHA — "TROCA A SENHA"
  // ============================================================
  // Linha 190: Função que atualiza a senha do usuário.
  // Analogia: A pessoa quer trocar a senha do cofre.
  Future<void> updatePassword(String novaSenha) async {
    try { // Tenta atualizar a senha
      // Linha 193: Pega o usuário atual
      final user = _auth.currentUser;
      
      // Linha 194-196: Se não tem usuário logado, lança um erro
      if (user == null) {
        throw Exception('Usuário não está logado');
      }
      
      // Linha 197: Tenta atualizar a senha
      await user.updatePassword(novaSenha.trim());
    } on FirebaseAuthException catch (e) { // Se deu erro
      throw _handleAuthError(e); // Trata o erro
    } catch (e) { // Se outro erro aconteceu
      throw Exception('Erro ao atualizar senha: $e');
    }
  }

  // ============================================================
  // 🔄 REAUTENTICAR — "VERIFICA A IDENTIDADE NOVAMENTE"
  // ============================================================
  // Linha 206: Função que reautentica o usuário.
  // Analogia: O segurança pede para a pessoa mostrar o crachá de novo
  //           antes de fazer algo importante.
  Future<void> reauthenticate(String senha) async {
    try { // Tenta reautenticar
      // Linha 209: Pega o usuário atual
      final user = _auth.currentUser;
      
      // Linha 210-212: Se não tem usuário logado, lança um erro
      if (user == null) {
        throw Exception('Usuário não está logado');
      }
      
      // Linha 213-215: Se o usuário não tem e-mail, lança um erro
      if (user.email == null) {
        throw Exception('Usuário não tem e-mail cadastrado');
      }

      // Linha 217-219: Cria a credencial com e-mail e senha
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: senha.trim(),
      );
      
      // Linha 220: Tenta reautenticar
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) { // Se deu erro
      throw _handleAuthError(e); // Trata o erro
    } catch (e) { // Se outro erro aconteceu
      throw Exception('Erro ao reautenticar: $e');
    }
  }

  // ============================================================
  // 🗑️ EXCLUIR CONTA — "APAGA O CRAChÁ"
  // ============================================================
  // Linha 230: Função que exclui a conta do usuário.
  // Analogia: A pessoa quer sair do sistema e o segurança
  //           apaga o crachá e todos os registros.
  Future<void> deleteAccount() async {
    try { // Tenta excluir a conta
      // Linha 233: Pega o usuário atual
      final user = _auth.currentUser;
      
      // Linha 234-236: Se não tem usuário logado, lança um erro
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      // Linha 239: Remove o usuário do Firestore (banco de dados)
      await _firestore.collection('usuarios').doc(user.uid).delete();

      // Linha 241-245: Remove todos os produtos do usuário
      final produtosSnapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: user.uid)
          .get();

      for (final doc in produtosSnapshot.docs) {
        await doc.reference.delete(); // Apaga cada produto
      }

      // Linha 249-253: Remove todas as movimentações do usuário
      final movimentosSnapshot = await _firestore
          .collection('movimentacoes')
          .where('usuarioId', isEqualTo: user.uid)
          .get();

      for (final doc in movimentosSnapshot.docs) {
        await doc.reference.delete(); // Apaga cada movimentação
      }

      // Linha 256: Exclui a conta do Firebase Authentication
      await user.delete();
    } on FirebaseAuthException catch (e) { // Se deu erro
      throw _handleAuthError(e); // Trata o erro
    } catch (e) { // Se outro erro aconteceu
      throw Exception('Erro ao excluir conta: $e');
    }
  }

  // ============================================================
  // 📝 MÉTODOS PRIVADOS — "FERRAMENTAS INTERNAS"
  // ============================================================

  // ============================================================
  // 📝 _CRIARDOCUMENTOUSUARIO — "CRIA A FICHA DO USUÁRIO"
  // ============================================================
  // Linha 264: Função que cria o documento do usuário no Firestore.
  // Analogia: O segurança cria uma ficha com os dados da pessoa.
  Future<void> _criarDocumentoUsuario(User user) async {
    try { // Tenta criar o documento
      // Linha 266-277: Salva os dados do usuário no Firestore
      await _firestore.collection('usuarios').doc(user.uid).set({
        'uid': user.uid, // O ID do usuário
        'email': user.email, // O e-mail do usuário
        'displayName': user.displayName ?? user.email?.split('@').first ?? 'Usuário', // Nome de exibição
        'photoURL': user.photoURL, // URL da foto
        'emailVerified': user.emailVerified, // E-mail verificado?
        'createdAt': FieldValue.serverTimestamp(), // Data de criação
        'updatedAt': FieldValue.serverTimestamp(), // Data de atualização
        'lastLogin': FieldValue.serverTimestamp(), // Último login
        'isActive': true, // Conta ativa
      });
    } catch (e) { // Se deu erro
      throw Exception('Erro ao salvar dados do usuário: $e');
    }
  }

  // ============================================================
  // 📝 _ATUALIZARULTIMOACESSO — "REGISTRA A ÚLTIMA VISITA"
  // ============================================================
  // Linha 282: Função que atualiza a data do último acesso.
  // Analogia: O segurança anota a hora que a pessoa entrou.
  Future<void> _atualizarUltimoAcesso(String uid) async {
    try { // Tenta atualizar
      // Linha 285-288: Atualiza o último login no Firestore
      await _firestore.collection('usuarios').doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(), // Data e hora do login
        'isActive': true, // Conta ativa
      });
    } catch (e) { // Se deu erro (não crítico)
      // Ignora erro
    }
  }

  // ============================================================
  // ❌ TRATAMENTO DE ERROS — "TRADUZ OS ERROS"
  // ============================================================
  // Linha 295: Função que traduz os erros do Firebase em mensagens amigáveis.
  // Analogia: O segurança recebe um comunicado do sistema e
  //           explica para a pessoa em palavras simples.
  String _handleAuthError(FirebaseAuthException e) {
    // Linha 296: Switch que verifica o código do erro
    switch (e.code) {
      // Linha 297-298: Usuário não encontrado
      case 'user-not-found':
        return '❌ Usuário não encontrado. Verifique seu e-mail.';
      
      // Linha 299-300: Senha incorreta
      case 'wrong-password':
        return '❌ Senha incorreta. Tente novamente.';
      
      // Linha 301-302: E-mail inválido
      case 'invalid-email':
        return '❌ E-mail inválido. Digite um e-mail válido.';
      
      // Linha 303-304: Conta desativada
      case 'user-disabled':
        return '❌ Esta conta foi desativada.';
      
      // Linha 305-306: Muitas tentativas
      case 'too-many-requests':
        return '⚠️ Muitas tentativas. Tente novamente mais tarde.';
      
      // Linha 307-308: E-mail já em uso (cadastro)
      case 'email-already-in-use':
        return '❌ Este e-mail já está em uso.';
      
      // Linha 309-310: Senha muito fraca
      case 'weak-password':
        return '❌ A senha é muito fraca. Use pelo menos 6 caracteres.';
      
      // Linha 311-312: Erro de rede
      case 'network-request-failed':
        return '⚠️ Erro de rede. Verifique sua conexão.';
      
      // Linha 313-314: Qualquer outro erro
      default:
        return '❌ Erro: ${e.message ?? 'Erro inesperado.'}';
    }
  }

  // ============================================================
  // ✅ MÉTODOS DE VERIFICAÇÃO — "PERGUNTAS SOBRE O USUÁRIO"
  // ============================================================

  // ============================================================
  // ✅ ISAUTHENTICATED — "O USUÁRIO ESTÁ LOGADO?"
  // ============================================================
  // Linha 320: Função que verifica se o usuário está autenticado.
  // Analogia: O segurança verifica se tem alguém dentro do prédio.
  bool isAuthenticated() {
    return _auth.currentUser != null; // Retorna true se tiver alguém logado
  }

  // ============================================================
  // ✅ ISEMAILVERIFIED — "O E-MAIL FOI VERIFICADO?"
  // ============================================================
  // Linha 325: Função que verifica se o e-mail do usuário foi verificado.
  // Analogia: O segurança verifica se a identidade da pessoa foi confirmada.
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false; // Retorna true se verificado
  }

  // ============================================================
  // 📧 SENDEMAILVERIFICATION — "ENVIA E-MAIL DE VERIFICAÇÃO"
  // ============================================================
  // Linha 329: Função que envia e-mail de verificação.
  // Analogia: O segurança envia uma carta para confirmar a identidade.
  Future<void> sendEmailVerification() async {
    try { // Tenta enviar o e-mail
      // Linha 332: Pega o usuário atual
      final user = _auth.currentUser;
      
      // Linha 333-335: Se não tem usuário logado, lança um erro
      if (user == null) {
        throw Exception('Usuário não está logado');
      }
      
      // Linha 336: Envia o e-mail de verificação
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) { // Se deu erro
      throw _handleAuthError(e); // Trata o erro
    } catch (e) { // Se outro erro aconteceu
      throw Exception('Erro ao enviar e-mail de verificação: $e');
    }
  }

  // ============================================================
  // 🔄 RELOADUSER — "RECARREGA OS DADOS DO USUÁRIO"
  // ============================================================
  // Linha 346: Função que recarrega os dados do usuário.
  // Analogia: O segurança atualiza a ficha da pessoa com as informações mais recentes.
  Future<void> reloadUser() async {
    try { // Tenta recarregar
      // Linha 349: Recarrega os dados do usuário
      await _auth.currentUser?.reload();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao recarregar usuário: $e');
    }
  }
}