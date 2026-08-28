// ============================================================
// 📁 firestore_service.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem um "ARQUIVO" enorme com
//              todas as informações do seu estoque. Esse arquivo
//              é o "BIBLIOTECÁRIO" que cuida de tudo:
//              guarda, busca, atualiza e deleta informações.
// 
// 🏠 Ele é como o "GERENTE DO BANCO DE DADOS":
//    - Guarda produtos (cria)
//    - Busca produtos (lista)
//    - Atualiza produtos (edita)
//    - Remove produtos (deleta)
//    - Gerencia movimentações
//    - Gerencia lista de compras
//    - Verifica estoque e dispara notificações
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Firestore (o "arquivo" onde os dados são guardados)
import 'package:cloud_firestore/cloud_firestore.dart';
// Linha 2: Importa o Firebase Auth (para saber quem está logado)
import 'package:firebase_auth/firebase_auth.dart';
// Linhas 3-6: Importa os modelos (os "moldes" dos dados)
import '../models/produto_model.dart';      // O molde do produto
import '../models/categoria_model.dart';    // O molde da categoria
import '../models/movimento_model.dart';    // O molde da movimentação
import '../models/lista_compra_model.dart'; // O molde da lista de compras
// Linha 7: Importa o serviço de notificações (para avisar sobre estoque baixo)
import '../services/notification_service.dart';

// ============================================================
// 🏠 CLASSE FIRESTORESERVICE — O "BIBLIOTECÁRIO"
// ============================================================
// Linha 10: Define a classe FirestoreService
class FirestoreService {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" do bibliotecário
  // ============================================================
  
  // Linha 13: Instância do Firestore (o "arquivo" de dados)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Linha 14: Instância do Firebase Auth (o "sistema de crachás")
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // 🎯 GETTERS — "PERGUNTAS" QUE O BIBLIOTECÁRIO RESPONDE
  // ============================================================
  
  // Linha 17: Retorna o ID do usuário logado (o "crachá" da pessoa)
  // Se não tiver ninguém logado, retorna vazio.
  String get _userId => _auth.currentUser?.uid ?? '';
  
  // Linha 18: Verifica se o usuário está autenticado
  // Retorna true se tiver alguém logado, false se não.
  bool get _isAuthenticated => _userId.isNotEmpty;

  // ============================================================
  // 📦 PRODUTOS — "GERENCIANDO OS PRODUTOS"
  // ============================================================

  // ============================================================
  // 📝 CRIARPRODUTO — "GUARDA UM NOVO PRODUTO"
  // ============================================================
  // Linha 24: Função que cria um novo produto no Firestore.
  // Analogia: O bibliotecário recebe um novo livro e coloca na estante.
  // 
  // Parâmetros: produto (o produto a ser guardado)
  // Retorna: O ID do produto criado
  Future<String> criarProduto(Produto produto) async {
    // Linha 25-27: Verifica se o usuário está logado
    // Se não estiver, lança um erro (não pode guardar sem crachá)
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta guardar o produto
      // Linha 31-33: Adiciona o produto ao Firestore
      // Analogia: O bibliotecário coloca o livro na estante.
      final docRef = await _firestore
          .collection('produtos') // Vai na "gaveta" de produtos
          .add(produto.toMap()); // Guarda o produto (converte para mapa)
      
      // Linha 35: Verifica se o produto precisa ir para a lista de compras
      // Analogia: O bibliotecário verifica se o livro está em falta.
      await verificarListaCompras();
      
      // Linha 36: Verifica se o estoque está baixo e dispara notificação
      // Analogia: O bibliotecário avisa se o livro está acabando.
      await verificarEstoqueENotificar();
      
      // Linha 38: Retorna o ID do produto criado
      return docRef.id;
    } catch (e) { // Se deu erro
      throw Exception('Erro ao criar produto: $e');
    }
  }

  // ============================================================
  // 📋 LISTARPRODUTOS — "MOSTRA TODOS OS PRODUTOS"
  // ============================================================
  // Linha 45: Função que lista todos os produtos do usuário.
  // Analogia: O bibliotecário mostra todos os livros da estante.
  // 
  // Retorna: Um Stream (lista que se atualiza em tempo real)
  Stream<List<Produto>> listarProdutos() {
    // Linha 46-48: Se não estiver autenticado, retorna uma lista vazia
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    // Linha 50-58: Busca todos os produtos do usuário no Firestore
    return _firestore
        .collection('produtos') // Vai na "gaveta" de produtos
        .where('usuarioId', isEqualTo: _userId) // Só do usuário logado
        .orderBy('nome') // Ordena por nome (A-Z)
        .snapshots() // Escuta mudanças em tempo real
        .map((snapshot) { // Converte os resultados
          return snapshot.docs.map((doc) {
            return Produto.fromMap(doc.id, doc.data()); // Converte para Produto
          }).toList();
        });
  }

  // ============================================================
  // 🔍 PESQUISARPRODUTOS — "PROCURA PRODUTOS PELO NOME"
  // ============================================================
  // Linha 63: Função que pesquisa produtos pelo nome.
  // Analogia: O bibliotecário procura livros pelo título.
  // 
  // Parâmetros: termo (o que o usuário quer pesquisar)
  // Retorna: Um Stream com os produtos encontrados
  Stream<List<Produto>> pesquisarProdutos(String termo) {
    // Linha 64-66: Se não estiver autenticado, retorna lista vazia
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    // Linha 68: Se o termo de busca estiver vazio, lista todos os produtos
    if (termo.isEmpty) {
      return listarProdutos();
    }

    // Linha 72-74: Prepara o termo de busca (tudo minúsculo)
    // Analogia: O bibliotecário ignora maiúsculas/minúsculas.
    final termoLower = termo.toLowerCase();
    final termoUpper = termoLower.substring(0, termoLower.length - 1) +
        String.fromCharCode(termoLower.codeUnitAt(termoLower.length - 1) + 1);

    // Linha 76-86: Busca produtos com nome parecido
    return _firestore
        .collection('produtos')
        .where('usuarioId', isEqualTo: _userId) // Só do usuário
        .where('nome', isGreaterThanOrEqualTo: termoLower) // Começa com o termo
        .where('nome', isLessThan: termoUpper) // Termina antes do próximo
        .orderBy('nome') // Ordena por nome
        .snapshots() // Escuta mudanças
        .map((snapshot) { // Converte os resultados
          return snapshot.docs.map((doc) {
            return Produto.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ============================================================
  // 🔍 OBTERPRODUTO — "PEGA UM PRODUTO ESPECÍFICO"
  // ============================================================
  // Linha 91: Função que busca um produto pelo ID.
  // Analogia: O bibliotecário pega um livro específico pelo código.
  // 
  // Parâmetros: id (o ID do produto)
  // Retorna: O produto encontrado, ou null se não existir
  Future<Produto?> obterProduto(String id) async {
    // Linha 92-94: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta buscar o produto
      // Linha 97: Busca o produto no Firestore pelo ID
      final doc = await _firestore.collection('produtos').doc(id).get();
      
      // Linha 98: Se o produto existe...
      if (doc.exists) {
        return Produto.fromMap(doc.id, doc.data()!); // Converte para Produto
      }
      return null; // Se não existe, retorna null
    } catch (e) { // Se deu erro
      throw Exception('Erro ao obter produto: $e');
    }
  }

  // ============================================================
  // ✏️ ATUALIZARPRODUTO — "ATUALIZA UM PRODUTO"
  // ============================================================
  // Linha 111: Função que atualiza um produto existente.
  // Analogia: O bibliotecário corrige as informações de um livro.
  // 
  // Parâmetros: id (o ID do produto), dados (as informações novas)
  Future<void> atualizarProduto(String id, Map<String, dynamic> dados) async {
    // Linha 112-114: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta atualizar o produto
      // Linha 117: Adiciona a data de atualização
      // Analogia: O bibliotecário anota quando o livro foi corrigido.
      dados['updatedAt'] = DateTime.now().toIso8601String();
      
      // Linha 118: Atualiza o produto no Firestore
      await _firestore.collection('produtos').doc(id).update(dados);
      
      // Linha 120-121: Verifica a lista de compras e notifica se necessário
      await verificarListaCompras();
      await verificarEstoqueENotificar();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao atualizar produto: $e');
    }
  }

  // ============================================================
  // 🔢 ATUALIZARQUANTIDADE — "ATUALIZA SÓ A QUANTIDADE"
  // ============================================================
  // Linha 128: Função que atualiza apenas a quantidade de um produto.
  // Analogia: O bibliotecário atualiza quantos livros têm na estante.
  // 
  // Parâmetros: id (o ID do produto), novaQuantidade (a nova quantidade)
  Future<void> atualizarQuantidade(String id, double novaQuantidade) async {
    // Linha 129-131: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta atualizar a quantidade
      // Linha 134-138: Atualiza a quantidade no Firestore
      await _firestore.collection('produtos').doc(id).update({
        'quantidade': novaQuantidade, // A nova quantidade
        'updatedAt': DateTime.now().toIso8601String(), // Data da atualização
      });
      
      // Linha 140-141: Verifica a lista de compras e notifica se necessário
      await verificarListaCompras();
      await verificarEstoqueENotificar();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao atualizar quantidade: $e');
    }
  }

  // ============================================================
  // 🗑️ EXCLUIRPRODUTO — "APAGA UM PRODUTO"
  // ============================================================
  // Linha 148: Função que exclui um produto.
  // Analogia: O bibliotecário remove um livro da estante.
  // 
  // Parâmetros: id (o ID do produto a ser excluído)
  Future<void> excluirProduto(String id) async {
    // Linha 149-151: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta excluir o produto
      // Linha 155-160: Remove o produto da lista de compras (se estiver lá)
      final listaSnapshot = await _firestore
          .collection('lista_compras')
          .where('produtoId', isEqualTo: id)
          .where('usuarioId', isEqualTo: _userId)
          .get();

      for (final doc in listaSnapshot.docs) {
        await doc.reference.delete(); // Apaga cada item da lista
      }

      // Linha 164-168: Remove as movimentações do produto
      final movimentosSnapshot = await _firestore
          .collection('movimentacoes')
          .where('produtoId', isEqualTo: id)
          .get();

      for (final doc in movimentosSnapshot.docs) {
        await doc.reference.delete(); // Apaga cada movimentação
      }

      // Linha 171: Remove o produto
      await _firestore.collection('produtos').doc(id).delete();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao excluir produto: $e');
    }
  }

  // ============================================================
  // 🔢 CONTARPRODUTOS — "CONTA QUANTOS PRODUTOS TÊM"
  // ============================================================
  // Linha 178: Função que conta quantos produtos o usuário tem.
  // Analogia: O bibliotecário conta quantos livros têm na estante.
  // 
  // Retorna: O número de produtos
  Future<int> contarProdutos() async {
    // Linha 179-181: Se não estiver autenticado, retorna 0
    if (!_isAuthenticated) {
      return 0;
    }

    try { // Tenta contar os produtos
      // Linha 184-187: Busca todos os produtos do usuário
      final snapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .get();
      return snapshot.docs.length; // Retorna a quantidade
    } catch (e) { // Se deu erro
      return 0; // Retorna 0
    }
  }

  // ============================================================
  // 📜 MOVIMENTAÇÕES — "GERENCIANDO AS MOVIMENTAÇÕES"
  // ============================================================

  // ============================================================
  // 📝 CRIARMOVIMENTO — "REGISTRA UMA MOVIMENTAÇÃO"
  // ============================================================
  // Linha 197: Função que registra uma movimentação (entrada/saída).
  // Analogia: O bibliotecário registra quando um livro entra ou sai.
  // 
  // Parâmetros: movimento (o movimento a ser registrado)
  // Retorna: O ID do movimento criado
  Future<String> criarMovimento(Movimento movimento) async {
    // Linha 198-200: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta registrar a movimentação
      // Linha 203-205: Adiciona o movimento ao Firestore
      final docRef = await _firestore
          .collection('movimentacoes')
          .add(movimento.toMap());
      
      // Linha 207: Verifica o estoque e dispara notificação se necessário
      await verificarEstoqueENotificar();
      
      // Linha 209: Retorna o ID do movimento criado
      return docRef.id;
    } catch (e) { // Se deu erro
      throw Exception('Erro ao registrar movimentação: $e');
    }
  }

  // ============================================================
  // 📋 LISTARMOVIMENTACOES — "MOSTRA TODAS AS MOVIMENTAÇÕES"
  // ============================================================
  // Linha 216: Função que lista todas as movimentações do usuário.
  // Analogia: O bibliotecário mostra todos os registros de entrada/saída.
  // 
  // Retorna: Um Stream (lista que se atualiza em tempo real)
  Stream<List<Movimento>> listarMovimentacoes() {
    // Linha 217-219: Se não estiver autenticado, retorna lista vazia
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    // Linha 221-230: Busca todas as movimentações do usuário
    return _firestore
        .collection('movimentacoes')
        .where('usuarioId', isEqualTo: _userId) // Só do usuário
        .orderBy('createdAt', descending: true) // As mais recentes primeiro
        .snapshots() // Escuta mudanças em tempo real
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Movimento.fromMap(doc.id, doc.data()); // Converte para Movimento
          }).toList();
        });
  }

  // ============================================================
  // 📋 LISTARMOVIMENTACOESPORPRODUTO — "MOSTRA MOVIMENTAÇÕES DE UM PRODUTO"
  // ============================================================
  // Linha 235: Função que lista movimentações de um produto específico.
  // 
  // Parâmetros: produtoId (o ID do produto)
  Stream<List<Movimento>> listarMovimentacoesPorProduto(String produtoId) {
    // Linha 236-238: Se não estiver autenticado, retorna lista vazia
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    // Linha 240-249: Busca movimentações do produto
    return _firestore
        .collection('movimentacoes')
        .where('usuarioId', isEqualTo: _userId)
        .where('produtoId', isEqualTo: produtoId) // Só do produto específico
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Movimento.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ============================================================
  // 📋 LISTARMOVIMENTACOESPORTIPO — "MOSTRA MOVIMENTAÇÕES POR TIPO"
  // ============================================================
  // Linha 254: Função que lista movimentações por tipo (entrada/saída).
  // 
  // Parâmetros: tipo ('entrada' ou 'saida')
  Stream<List<Movimento>> listarMovimentacoesPorTipo(String tipo) {
    // Linha 255-257: Se não estiver autenticado, retorna lista vazia
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    // Linha 259-268: Busca movimentações do tipo especificado
    return _firestore
        .collection('movimentacoes')
        .where('usuarioId', isEqualTo: _userId)
        .where('tipo', isEqualTo: tipo) // Só do tipo especificado
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Movimento.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ============================================================
  // 🏷️ CATEGORIAS — "GERENCIANDO AS CATEGORIAS"
  // ============================================================

  // ============================================================
  // 📋 LISTARCATEGORIAS — "MOSTRA TODAS AS CATEGORIAS"
  // ============================================================
  // Linha 273: Função que lista todas as categorias do usuário.
  Stream<List<Categoria>> listarCategorias() {
    // Linha 274-276: Se não estiver autenticado, retorna lista vazia
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    // Linha 278-287: Busca todas as categorias do usuário
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

  // ============================================================
  // 📝 CRIARCATEGORIA — "CRIA UMA NOVA CATEGORIA"
  // ============================================================
  // Linha 292: Função que cria uma nova categoria.
  Future<String> criarCategoria(Categoria categoria) async {
    // Linha 293-295: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta criar a categoria
      // Linha 298-300: Adiciona a categoria ao Firestore
      final docRef = await _firestore
          .collection('categorias')
          .add(categoria.toMap());
      return docRef.id;
    } catch (e) { // Se deu erro
      throw Exception('Erro ao criar categoria: $e');
    }
  }

  // ============================================================
  // 🗑️ EXCLUIRCATEGORIA — "EXCLUI UMA CATEGORIA"
  // ============================================================
  // Linha 307: Função que exclui uma categoria.
  Future<void> excluirCategoria(String id) async {
    // Linha 308-310: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta excluir a categoria
      await _firestore.collection('categorias').doc(id).delete();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao excluir categoria: $e');
    }
  }

  // ============================================================
  // 📋 GETCATEGORIASPADRAO — "LISTA DE CATEGORIAS PRONTAS"
  // ============================================================
  // Linha 318: Função que retorna a lista de categorias padrão.
  // Analogia: O bibliotecário tem uma lista de categorias pré-definidas.
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
  // 🛒 LISTA DE COMPRAS — "GERENCIANDO A LISTA DE COMPRAS"
  // ============================================================

  // ============================================================
  // 📝 ADICIONARLISTACOMPRA — "ADICIONA À LISTA DE COMPRAS"
  // ============================================================
  // Linha 341: Função que adiciona um item à lista de compras.
  // Analogia: O bibliotecário coloca um livro na lista de reservas.
  Future<String> adicionarListaCompra(ListaCompra item) async {
    // Linha 342-344: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta adicionar à lista
      // Linha 347-353: Verifica se o item já existe na lista
      final existing = await _firestore
          .collection('lista_compras')
          .where('produtoId', isEqualTo: item.produtoId)
          .where('usuarioId', isEqualTo: _userId)
          .where('comprado', isEqualTo: false)
          .limit(1)
          .get();

      // Linha 355-362: Se já existe, atualiza a quantidade
      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        await doc.reference.update({
          'quantidadeNecessaria': item.quantidadeNecessaria,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return doc.id;
      }

      // Linha 366-368: Se não existe, cria um novo
      final docRef = await _firestore
          .collection('lista_compras')
          .add(item.toMap());
      return docRef.id;
    } catch (e) { // Se deu erro
      throw Exception('Erro ao adicionar à lista de compras: $e');
    }
  }

  // ============================================================
  // 📋 LISTARLISTACOMPRAS — "MOSTRA A LISTA DE COMPRAS"
  // ============================================================
  // Linha 375: Função que lista todos os itens da lista de compras.
  Stream<List<ListaCompra>> listarListaCompras() {
    // Linha 376-378: Se não estiver autenticado, retorna lista vazia
    if (!_isAuthenticated) {
      return Stream.value([]);
    }

    // Linha 380-389: Busca todos os itens da lista de compras
    return _firestore
        .collection('lista_compras')
        .where('usuarioId', isEqualTo: _userId)
        .orderBy('comprado') // Primeiro os pendentes (false), depois os comprados (true)
        .orderBy('createdAt', descending: true) // Os mais recentes primeiro
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ListaCompra.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ============================================================
  // ✅ MARCARCOMCOMPRADO — "MARCA COMO COMPRADO"
  // ============================================================
  // Linha 394: Função que marca um item como comprado.
  // Analogia: O bibliotecário risca o livro da lista de reservas.
  Future<void> marcarComoComprado(String id) async {
    // Linha 395-397: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta marcar como comprado
      await _firestore
          .collection('lista_compras')
          .doc(id)
          .update({
        'comprado': true, // Marca como comprado
        'updatedAt': FieldValue.serverTimestamp(), // Data da atualização
      });
    } catch (e) { // Se deu erro
      throw Exception('Erro ao marcar como comprado: $e');
    }
  }

  // ============================================================
  // 🗑️ REMOVERLISTACOMPRA — "REMOVE DA LISTA DE COMPRAS"
  // ============================================================
  // Linha 412: Função que remove um item da lista de compras.
  Future<void> removerListaCompra(String id) async {
    // Linha 413-415: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta remover o item
      await _firestore.collection('lista_compras').doc(id).delete();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao remover da lista de compras: $e');
    }
  }

  // ============================================================
  // 🗑️ LIMPARITENSCOMPRADOS — "LIMPA OS ITENS COMPRADOS"
  // ============================================================
  // Linha 424: Função que remove todos os itens marcados como comprados.
  Future<void> limparItensComprados() async {
    // Linha 425-427: Verifica se o usuário está logado
    if (!_isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try { // Tenta limpar os itens comprados
      // Linha 430-434: Busca todos os itens comprados
      final snapshot = await _firestore
          .collection('lista_compras')
          .where('usuarioId', isEqualTo: _userId)
          .where('comprado', isEqualTo: true)
          .get();

      // Linha 436-438: Remove cada item
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) { // Se deu erro
      throw Exception('Erro ao limpar itens comprados: $e');
    }
  }

  // ============================================================
  // 🔥 VERIFICARLISTACOMPRAS — "VERIFICA A LISTA DE COMPRAS AUTOMATICAMENTE"
  // ============================================================
  // Linha 445: Função que verifica automaticamente se algum produto
  // precisa ser adicionado à lista de compras.
  // Analogia: O bibliotecário verifica periodicamente quais livros
  //           estão acabando e coloca na lista de reservas.
  Future<void> verificarListaCompras() async {
    // Linha 446: Se não estiver autenticado, não faz nada
    if (!_isAuthenticated) return;

    try { // Tenta verificar
      // Linha 449-451: Busca todos os produtos do usuário
      final produtosSnapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .get();

      // Linha 453: Para cada produto...
      for (final doc in produtosSnapshot.docs) {
        final data = doc.data(); // Pega os dados do produto
        final quantidade = (data['quantidade'] ?? 0).toDouble(); // Quantidade atual
        final estoqueMinimo = (data['estoqueMinimo'] ?? 0).toDouble(); // Estoque mínimo

        // Linha 459: Se o estoque está abaixo ou igual ao mínimo...
        if (quantidade <= estoqueMinimo) {
          // Linha 460: Converte para Produto
          final produto = Produto.fromMap(doc.id, data);
          
          // Linha 461-473: Cria um item da lista de compras
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
          // Linha 474: Adiciona à lista de compras
          await adicionarListaCompra(item);
        } else {
          // Linha 476-482: Se o estoque está OK, remove da lista de compras
          final listaSnapshot = await _firestore
              .collection('lista_compras')
              .where('produtoId', isEqualTo: doc.id)
              .where('usuarioId', isEqualTo: _userId)
              .where('comprado', isEqualTo: false)
              .get();

          for (final itemDoc in listaSnapshot.docs) {
            await itemDoc.reference.delete(); // Remove da lista
          }
        }
      }
    } catch (e) { // Se deu erro
      print('Erro ao verificar lista de compras: $e');
    }
  }

  // ============================================================
  // 🔔 VERIFICARESTOQUEENOTIFICAR — "VERIFICA ESTOQUE E NOTIFICA"
  // ============================================================
  // Linha 491: Função que verifica se algum produto está com estoque
  // baixo e dispara uma notificação.
  // Analogia: O bibliotecário avisa quando um livro está acabando.
  Future<void> verificarEstoqueENotificar() async {
    // Linha 492: Se não estiver autenticado, não faz nada
    if (!_isAuthenticated) return;

    try { // Tenta verificar o estoque
      // Linha 495-497: Busca todos os produtos do usuário
      final produtosSnapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .get();

      int contador = 0; // Contador para os IDs das notificações

      // Linha 501: Para cada produto...
      for (final doc in produtosSnapshot.docs) {
        final data = doc.data(); // Pega os dados do produto
        final quantidade = (data['quantidade'] ?? 0).toDouble(); // Quantidade atual
        final estoqueMinimo = (data['estoqueMinimo'] ?? 0).toDouble(); // Estoque mínimo
        final nome = data['nome'] ?? 'Produto'; // Nome do produto

        // Linha 507: Se o estoque está abaixo ou igual ao mínimo...
        if (quantidade <= estoqueMinimo) {
          contador++; // Incrementa o contador
          final faltam = estoqueMinimo - quantidade; // Calcula quantos faltam

          // Linha 511-516: Mostra uma notificação
          await NotificationService.mostrarNotificacao(
            id: contador, // ID da notificação
            titulo: '⚠️ Estoque Baixo!', // Título
            corpo: '$nome está com apenas $quantidade und. Faltam $faltam.', // Mensagem
            payload: 'produto_${doc.id}', // Dados extras
          );
        }
      }
    } catch (e) { // Se deu erro
      print('Erro ao verificar estoque: $e');
    }
  }

  // ============================================================
  // 📊 DASHBOARD — "DADOS PARA O PAINEL DE CONTROLE"
  // ============================================================

  // ============================================================
  // 📊 OBTERDADOSDASHBOARD — "PEGA OS DADOS DO DASHBOARD"
  // ============================================================
  // Linha 525: Função que obtém os dados para o Dashboard.
  // Analogia: O bibliotecário prepara um resumo de tudo que tem na biblioteca.
  // 
  // Retorna: Um mapa com total de produtos, estoque baixo, etc.
  Future<Map<String, dynamic>> obterDadosDashboard() async {
    // Linha 526-535: Se não estiver autenticado, retorna dados zerados
    if (!_isAuthenticated) {
      return {
        'totalProdutos': 0,
        'produtosSemEstoque': 0,
        'produtosEstoqueBaixo': 0,
        'totalCategorias': 0,
        'valorTotalEstoque': 0.0,
      };
    }

    try { // Tenta obter os dados
      // Linha 538-540: Busca todos os produtos do usuário
      final produtosSnapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .get();

      // Linha 542-544: Converte para lista de Produto
      final produtos = produtosSnapshot.docs.map((doc) {
        return Produto.fromMap(doc.id, doc.data());
      }).toList();

      // Linha 546: Total de produtos
      final totalProdutos = produtos.length;
      
      // Linha 547: Produtos sem estoque (quantidade <= 0)
      final produtosSemEstoque = produtos.where((p) => p.quantidade <= 0).length;
      
      // Linha 548-550: Produtos com estoque baixo (quantidade <= estoque mínimo)
      final produtosEstoqueBaixo = produtos
          .where((p) => p.quantidade > 0 && p.quantidade <= p.estoqueMinimo)
          .length;

      // Linha 552: Total de categorias únicas
      final categoriasUnicas = produtos.map((p) => p.categoria).toSet().length;

      // Linha 554-556: Valor total do estoque (quantidade * preço de custo)
      final valorTotalEstoque = produtos.fold(0.0, (sum, p) {
        return sum + (p.quantidade * p.precoCusto);
      });

      // Linha 558-565: Retorna os dados
      return {
        'totalProdutos': totalProdutos,
        'produtosSemEstoque': produtosSemEstoque,
        'produtosEstoqueBaixo': produtosEstoqueBaixo,
        'totalCategorias': categoriasUnicas,
        'valorTotalEstoque': valorTotalEstoque,
      };
    } catch (e) { // Se deu erro
      throw Exception('Erro ao obter dados do dashboard: $e');
    }
  }

  // ============================================================
  // 📊 OBTERPRODUTOSMAISVENDIDOS — "PRODUTOS MAIS VENDIDOS"
  // ============================================================
  // Linha 571: Função que retorna os 5 produtos mais vendidos.
  // Analogia: O bibliotecário mostra os livros mais emprestados.
  // 
  // Retorna: Lista dos 5 produtos mais vendidos
  Future<List<Map<String, dynamic>>> obterProdutosMaisVendidos() async {
    // Linha 572-574: Se não estiver autenticado, retorna lista vazia
    if (!_isAuthenticated) {
      return [];
    }

    try { // Tenta obter os produtos mais vendidos
      // Linha 577-580: Busca todas as movimentações de saída
      final snapshot = await _firestore
          .collection('movimentacoes')
          .where('usuarioId', isEqualTo: _userId)
          .where('tipo', isEqualTo: 'saida')
          .get();

      // Linha 582-587: Agrupa as vendas por produto
      final Map<String, double> vendas = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final produtoId = data['produtoId'] ?? '';
        final quantidade = (data['quantidade'] ?? 0).toDouble();
        vendas[produtoId] = (vendas[produtoId] ?? 0) + quantidade;
      }

      // Linha 589-590: Ordena por quantidade (do maior para o menor)
      final sorted = vendas.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Linha 592: Pega os 5 primeiros
      final top5 = sorted.take(5).toList();

      // Linha 594-603: Busca os nomes dos produtos
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
    } catch (e) { // Se deu erro
      return [];
    }
  }

  // ============================================================
  // 🔧 MÉTODOS AUXILIARES — "FERRAMENTAS EXTRAS"
  // ============================================================

  // ============================================================
  // 🔍 CODIGOEXISTE — "VERIFICA SE O CÓDIGO JÁ EXISTE"
  // ============================================================
  // Linha 613: Função que verifica se um código de produto já existe.
  // Analogia: O bibliotecário verifica se um livro com esse código já existe.
  // 
  // Parâmetros: codigo (o código a ser verificado)
  // Retorna: true se existe, false se não
  Future<bool> codigoExiste(String codigo) async {
    // Linha 614-616: Se não estiver autenticado, retorna false
    if (!_isAuthenticated) {
      return false;
    }

    try { // Tenta verificar
      // Linha 619-623: Busca um produto com o código especificado
      final snapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty; // Retorna true se encontrou
    } catch (e) { // Se deu erro
      return false; // Retorna false
    }
  }

  // ============================================================
  // 🔍 NOMEEXISTE — "VERIFICA SE O NOME JÁ EXISTE"
  // ============================================================
  // Linha 630: Função que verifica se um nome de produto já existe.
  // Analogia: O bibliotecário verifica se um livro com esse título já existe.
  // 
  // Parâmetros: nome (o nome a ser verificado)
  // Retorna: true se existe, false se não
  Future<bool> nomeExiste(String nome) async {
    // Linha 631-633: Se não estiver autenticado, retorna false
    if (!_isAuthenticated) {
      return false;
    }

    try { // Tenta verificar
      // Linha 636-640: Busca um produto com o nome especificado
      final snapshot = await _firestore
          .collection('produtos')
          .where('usuarioId', isEqualTo: _userId)
          .where('nome', isEqualTo: nome)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty; // Retorna true se encontrou
    } catch (e) { // Se deu erro
      return false; // Retorna false
    }
  }
}