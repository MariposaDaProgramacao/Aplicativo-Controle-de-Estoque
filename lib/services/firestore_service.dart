import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/produto_model.dart';
import '../models/categoria_model.dart';
import '../models/movimento_model.dart';

/// Serviço do Firestore para o BoxStock
/// 
/// Gerencia todas as operações de banco de dados no Cloud Firestore,
/// incluindo CRUD de produtos, movimentações, categorias e dashboard.
class FirestoreService {
  // ==================== INSTÂNCIAS ====================
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== GETTERS ====================

  /// Obtém o ID do usuário atual
  String get _userId => _auth.currentUser?.uid ?? '';

  /// Verifica se o usuário está autenticado
  bool get _isAuthenticated => _userId.isNotEmpty;

  // ==================== PRODUTOS ====================

  /// Cria um novo produto no Firestore
  /// 
  /// [produto] - Objeto Produto a ser criado
  /// 
  /// Retorna o ID do documento criado
  Future<String> criarProduto(Produto produto) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final docRef = await _firestore
          .collection('produtos')
          .add(produto.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar produto: $e');
    }
  }

  /// Lista todos os produtos do usuário atual em tempo real (Stream)
  Stream<List<Produto>> listarProdutos() {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    return _firestore
        .collection('produtos')
        .where('usuarioId', isEqualTo: _userId)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Produto.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// Pesquisa produtos pelo nome (com suporte a busca parcial)
  /// 
  /// [termo] - Termo de busca
  Stream<List<Produto>> pesquisarProdutos(String termo) {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    if (termo.isEmpty) {
      return listarProdutos();
    }

    // Firestore não tem "contains" nativo.
    // Usamos busca por prefixo com startsAt/endAt
    final termoLower = termo.toLowerCase();
    final termoUpper = termoLower.substring(0, termoLower.length - 1) +
        String.fromCharCode(termoLower.codeUnitAt(termoLower.length - 1) + 1);

    return _firestore
        .collection('produtos')
        .where('usuarioId', isEqualTo: _userId)
        .where('nome', isGreaterThanOrEqualTo: termoLower)
        .where('nome', isLessThan: termoUpper)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Produto.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// Obtém um produto pelo ID
  /// 
  /// [id] - ID do produto
  Future<Produto?> obterProduto(String id) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final doc = await _firestore.collection('produtos').doc(id).get();
      if (doc.exists) {
        return Produto.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao obter produto: $e');
    }
  }

  /// Atualiza um produto existente
  /// 
  /// [id] - ID do produto
  /// [dados] - Mapa com os campos a serem atualizados
  Future<void> atualizarProduto(String id, Map<String, dynamic> dados) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      dados['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('produtos').doc(id).update(dados);
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  /// Atualiza apenas a quantidade de um produto
  /// 
  /// [id] - ID do produto
  /// [novaQuantidade] - Nova quantidade
  Future<void> atualizarQuantidade(String id, double novaQuantidade) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      await _firestore.collection('produtos').doc(id).update({
        'quantidade': novaQuantidade,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar quantidade: $e');
    }
  }

  /// Exclui um produto
  /// 
  /// [id] - ID do produto
  Future<void> excluirProduto(String id) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Primeiro, exclui todas as movimentações do produto
      final movimentosSnapshot = await _firestore
          .collection('movimentacoes')
          .where('produtoId', isEqualTo: id)
          .get();

      for (final doc in movimentosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Depois, exclui o produto
      await _firestore.collection('produtos').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir produto: $e');
    }
  }

  /// Conta o número total de produtos do usuário
  Future<int> contarProdutos() async {
    if (!_isAuthenticated) {
      return 0;
    }

    try {
      final snapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // ==================== MOVIMENTAÇÕES ====================

  /// Registra uma movimentação (entrada ou saída)
  /// 
  /// [movimento] - Objeto Movimento a ser criado
  Future<String> criarMovimento(Movimento movimento) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final docRef = await _firestore
          .collection('movimentacoes')
          .add(movimento.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao registrar movimentação: $e');
    }
  }

  /// Lista todas as movimentações do usuário em tempo real (Stream)
  Stream<List<Movimento>> listarMovimentacoes() {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    return _firestore
        .collection('movimentacoes')
        .where('usuarioId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Movimento.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// Lista movimentações de um produto específico
  /// 
  /// [produtoId] - ID do produto
  Stream<List<Movimento>> listarMovimentacoesPorProduto(String produtoId) {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    return _firestore
        .collection('movimentacoes')
        .where('usuarioId', isEqualTo: _userId)
        .where('produtoId', isEqualTo: produtoId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Movimento.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// Lista movimentações por tipo (entrada/saída)
  /// 
  /// [tipo] - 'entrada' ou 'saida'
  Stream<List<Movimento>> listarMovimentacoesPorTipo(String tipo) {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    return _firestore
        .collection('movimentacoes')
        .where('usuarioId', isEqualTo: _userId)
        .where('tipo', isEqualTo: tipo)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Movimento.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ==================== CATEGORIAS ====================

  /// Lista categorias do usuário (Stream)
  Stream<List<Categoria>> listarCategorias() {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    return _firestore
        .collection('categorias')
        .where('usuarioId', isEqualTo: _userId)
        .orderBy('nome')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Categoria.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// Cria uma nova categoria
  Future<String> criarCategoria(Categoria categoria) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final docRef = await _firestore
          .collection('categorias')
          .add(categoria.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar categoria: $e');
    }
  }

  /// Exclui uma categoria
  Future<void> excluirCategoria(String id) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      await _firestore.collection('categorias').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir categoria: $e');
    }
  }

  /// Obtém categorias pré-definidas (para dropdown)
  List<String> getCategoriasPadrao() {
    return [
      'Informática',
      'Periféricos',
      'Eletrônicos',
      'Escritório',
      'Acessórios',
      'Alimentos',
      'Bebidas',
      'Limpeza',
      'Higiene',
      'Vestuário',
      'Calçados',
      'Livros',
      'Brinquedos',
      'Ferramentas',
      'Automotivo',
      'Construção',
      'Outros',
    ];
  }

  // ==================== DASHBOARD ====================

  /// Obtém os dados do dashboard (resumo do estoque)
  /// 
  /// Retorna um mapa com:
  /// - totalProdutos: número total de produtos
  /// - produtosSemEstoque: produtos com quantidade <= 0
  /// - produtosEstoqueBaixo: produtos com quantidade <= estoque mínimo
  /// - totalCategorias: número de categorias únicas
  /// - valorTotalEstoque: valor total do estoque
  Future<Map<String, dynamic>> obterDadosDashboard() async {
    if (!_isAuthenticated) {
      return {
        'totalProdutos': 0,
        'produtosSemEstoque': 0,
        'produtosEstoqueBaixo': 0,
        'totalCategorias': 0,
        'valorTotalEstoque': 0.0,
      };
    }

    try {
      final produtosSnapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .get();

      final produtos = produtosSnapshot.docs.map((doc) {
        return Produto.fromMap(doc.id, doc.data());
      }).toList();

      final totalProdutos = produtos.length;
      final produtosSemEstoque = produtos.where((p) => p.quantidade <= 0).length;
      final produtosEstoqueBaixo = produtos
          .where((p) => p.quantidade > 0 && p.quantidade <= p.estoqueMinimo)
          .length;

      // Conta categorias únicas
      final categoriasUnicas = produtos.map((p) => p.categoria).toSet().length;

      // Valor total do estoque
      final valorTotalEstoque = produtos.fold(0.0, (sum, p) {
        return sum + (p.quantidade * p.precoCusto);
      });

      return {
        'totalProdutos': totalProdutos,
        'produtosSemEstoque': produtosSemEstoque,
        'produtosEstoqueBaixo': produtosEstoqueBaixo,
        'totalCategorias': categoriasUnicas,
        'valorTotalEstoque': valorTotalEstoque,
      };
    } catch (e) {
      throw Exception('Erro ao obter dados do dashboard: $e');
    }
  }

  /// Obtém os produtos mais vendidos (top 5)
  Future<List<Map<String, dynamic>>> obterProdutosMaisVendidos() async {
    if (!_isAuthenticated) {
      return [];
    }

    try {
      // Busca todas as movimentações de saída
      final snapshot = await _firestore
          .collection('movimentacoes')
          .where('usuarioId', isEqualTo: _userId)
          .where('tipo', isEqualTo: 'saida')
          .get();

      // Agrupa por produto
      final Map<String, double> vendas = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final produtoId = data['produtoId'] ?? '';
        final quantidade = (data['quantidade'] ?? 0).toDouble();
        vendas[produtoId] = (vendas[produtoId] ?? 0) + quantidade;
      }

      // Ordena por quantidade
      final sorted = vendas.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Pega os top 5
      final top5 = sorted.take(5).toList();

      // Busca os nomes dos produtos
      final resultados = <Map<String, dynamic>>[];
      for (final item in top5) {
        final produto = await obterProduto(item.key);
        if (produto != null) {
          resultados.add({
            'nome': produto.nome,
            'codigo': produto.codigo,
            'quantidade': item.value,
          });
        }
      }

      return resultados;
    } catch (e) {
      return [];
    }
  }

  // ==================== MÉTODOS AUXILIARES ====================

  /// Verifica se um código de produto já existe
  Future<bool> codigoExiste(String codigo) async {
    if (!_isAuthenticated) {
      return false;
    }

    try {
      final snapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se um produto com o mesmo nome já existe
  Future<bool> nomeExiste(String nome) async {
    if (!_isAuthenticated) {
      return false;
    }

    try {
      final snapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .where('nome', isEqualTo: nome)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== EXEMPLO DE USO ====================
  /*
  // Criando instância
  final firestore = FirestoreService();

  // Criar produto
  final produto = Produto(
    nome: 'Mouse USB',
    codigo: 'MOU001',
    categoria: 'Periféricos',
    descricao: 'Mouse USB óptico',
    quantidade: 10,
    estoqueMinimo: 3,
    precoCusto: 25.00,
    precoVenda: 49.90,
    usuarioId: firestore._userId,
    createdAt: DateTime.now(),
  );
  final id = await firestore.criarProduto(produto);

  // Listar produtos
  firestore.listarProdutos().listen((produtos) {
    print('Total de produtos: ${produtos.length}');
  });

  // Registrar entrada
  final movimento = Movimento(
    produtoId: 'id_do_produto',
    produtoNome: 'Mouse USB',
    tipo: 'entrada',
    quantidade: 5,
    precoUnitario: 25.00,
    observacao: 'Compra do fornecedor',
    usuarioId: firestore._userId,
    usuarioEmail: 'usuario@email.com',
    createdAt: DateTime.now(),
  );
  await firestore.criarMovimento(movimento);

  // Dashboard
  final dashboard = await firestore.obterDadosDashboard();
  print('Total: ${dashboard['totalProdutos']}');
  print('Estoque Baixo: ${dashboard['produtosEstoqueBaixo']}');
  */
}