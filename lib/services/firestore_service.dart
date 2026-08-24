import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/produto_model.dart';
import '../models/categoria_model.dart';
import '../models/movimento_model.dart';
import '../models/lista_compra_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';
  bool get _isAuthenticated => _userId.isNotEmpty;

  // ============================================================
  // 📦 PRODUTOS
  // ============================================================

  Future<String> criarProduto(Produto produto) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final docRef = await _firestore
          .collection('produtos')
          .add(produto.toMap());
      
      // Verifica se o produto precisa ser adicionado à lista de compras
      await verificarListaCompras();
      
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar produto: $e');
    }
  }

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

  Stream<List<Produto>> pesquisarProdutos(String termo) {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    if (termo.isEmpty) {
      return listarProdutos();
    }

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

  Future<void> atualizarProduto(String id, Map<String, dynamic> dados) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      dados['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('produtos').doc(id).update(dados);
      
      // Verifica se o produto precisa ser adicionado à lista de compras
      await verificarListaCompras();
    } catch (e) {
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  Future<void> atualizarQuantidade(String id, double novaQuantidade) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      await _firestore.collection('produtos').doc(id).update({
        'quantidade': novaQuantidade,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      // Verifica se o produto precisa ser adicionado à lista de compras
      await verificarListaCompras();
    } catch (e) {
      throw Exception('Erro ao atualizar quantidade: $e');
    }
  }

  Future<void> excluirProduto(String id) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Remove o produto da lista de compras primeiro
      final listaSnapshot = await _firestore
          .collection('lista_compras')
          .where('produtoId', isEqualTo: id)
          .where('usuarioId', isEqualTo: _userId)
          .get();

      for (final doc in listaSnapshot.docs) {
        await doc.reference.delete();
      }

      // Remove movimentações do produto
      final movimentosSnapshot = await _firestore
          .collection('movimentacoes')
          .where('produtoId', isEqualTo: id)
          .get();

      for (final doc in movimentosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Remove o produto
      await _firestore.collection('produtos').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao excluir produto: $e');
    }
  }

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

  // ============================================================
  // 📜 MOVIMENTAÇÕES
  // ============================================================

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

  // ============================================================
  // 🏷️ CATEGORIAS
  // ============================================================

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

  // ============================================================
  // 🛒 LISTA DE COMPRAS
  // ============================================================

  Future<String> adicionarListaCompra(ListaCompra item) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Verifica se o item já existe na lista
      final existing = await _firestore
          .collection('lista_compras')
          .where('produtoId', isEqualTo: item.produtoId)
          .where('usuarioId', isEqualTo: _userId)
          .where('comprado', isEqualTo: false)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        // Se já existe, atualiza a quantidade
        final doc = existing.docs.first;
        await doc.reference.update({
          'quantidadeNecessaria': item.quantidadeNecessaria,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return doc.id;
      }

      // Se não existe, cria um novo
      final docRef = await _firestore
          .collection('lista_compras')
          .add(item.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar à lista de compras: $e');
    }
  }

  Stream<List<ListaCompra>> listarListaCompras() {
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    return _firestore
        .collection('lista_compras')
        .where('usuarioId', isEqualTo: _userId)
        .orderBy('comprado')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ListaCompra.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Future<void> marcarComoComprado(String id) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      await _firestore
          .collection('lista_compras')
          .doc(id)
          .update({
        'comprado': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao marcar como comprado: $e');
    }
  }

  Future<void> removerListaCompra(String id) async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      await _firestore.collection('lista_compras').doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao remover da lista de compras: $e');
    }
  }

  Future<void> limparItensComprados() async {
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final snapshot = await _firestore
          .collection('lista_compras')
          .where('usuarioId', isEqualTo: _userId)
          .where('comprado', isEqualTo: true)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Erro ao limpar itens comprados: $e');
    }
  }

  // ============================================================
  // 🔥 MÉTODO PÚBLICO - VERIFICAÇÃO AUTOMÁTICA
  // ============================================================

  /// Verifica automaticamente se algum produto precisa ser adicionado à lista de compras
  /// Este método é público e pode ser chamado de qualquer lugar
  Future<void> verificarListaCompras() async {
    if (!_isAuthenticated) return;

    try {
      final produtosSnapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .get();

      for (final doc in produtosSnapshot.docs) {
        final data = doc.data();
        final quantidade = (data['quantidade'] ?? 0).toDouble();
        final estoqueMinimo = (data['estoqueMinimo'] ?? 0).toDouble();

        // Se o estoque está abaixo ou igual ao mínimo, adiciona à lista
        if (quantidade <= estoqueMinimo) {
          final produto = Produto.fromMap(doc.id, data);
          final item = ListaCompra(
            produtoId: doc.id,
            produtoNome: produto.nome,
            codigo: produto.codigo,
            categoria: produto.categoria,
            quantidadeNecessaria: estoqueMinimo - quantidade + 1,
            quantidadeAtual: quantidade,
            estoqueMinimo: estoqueMinimo,
            usuarioId: _userId,
            comprado: false,
            createdAt: DateTime.now(),
          );
          await adicionarListaCompra(item);
        } else {
          // Se o estoque está acima do mínimo, remove da lista de compras
          final listaSnapshot = await _firestore
              .collection('lista_compras')
              .where('produtoId', isEqualTo: doc.id)
              .where('usuarioId', isEqualTo: _userId)
              .where('comprado', isEqualTo: false)
              .get();

          for (final itemDoc in listaSnapshot.docs) {
            await itemDoc.reference.delete();
          }
        }
      }
    } catch (e) {
      print('Erro ao verificar lista de compras: $e');
    }
  }

  // ============================================================
  // 📊 DASHBOARD
  // ============================================================

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

      final categoriasUnicas = produtos.map((p) => p.categoria).toSet().length;

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

  Future<List<Map<String, dynamic>>> obterProdutosMaisVendidos() async {
    if (!_isAuthenticated) {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('movimentacoes')
          .where('usuarioId', isEqualTo: _userId)
          .where('tipo', isEqualTo: 'saida')
          .get();

      final Map<String, double> vendas = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final produtoId = data['produtoId'] ?? '';
        final quantidade = (data['quantidade'] ?? 0).toDouble();
        vendas[produtoId] = (vendas[produtoId] ?? 0) + quantidade;
      }

      final sorted = vendas.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final top5 = sorted.take(5).toList();

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

  // ============================================================
  // 🔧 MÉTODOS AUXILIARES
  // ============================================================

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
}