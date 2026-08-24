import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/produto_model.dart';
import '../../widgets/campo_busca.dart';
import '../../widgets/status_estoque.dart';
import '../../main.dart';
import 'cadastro_produto_screen.dart';
import 'entrada_screen.dart';
import 'saida_screen.dart';
import 'detalhes_produto_screen.dart';

class ListagemProdutosScreen extends StatefulWidget {
  const ListagemProdutosScreen({super.key});

  @override
  State<ListagemProdutosScreen> createState() => _ListagemProdutosScreenState();
}

class _ListagemProdutosScreenState extends State<ListagemProdutosScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _buscaController = TextEditingController();

  List<Produto> _todosProdutos = [];
  List<Produto> _produtosFiltrados = [];
  bool _carregando = false;
  bool _temMaisProdutos = true;
  String _termoBusca = '';
  DocumentSnapshot? _ultimoDocumento;
  static const int _limitePorPagina = 5;

  @override
  void initState() {
    super.initState();
    _carregarProdutosIniciais();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // ==================== MÉTODOS DE CARREGAMENTO ====================

  Future<void> _carregarProdutosIniciais() async {
    setState(() {
      _carregando = true;
      _todosProdutos = [];
      _produtosFiltrados = [];
      _temMaisProdutos = true;
      _ultimoDocumento = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('produtos')
          .where('usuarioId', isEqualTo: user.uid)
          .orderBy('nome')
          .get();

      final todos = snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Produto.fromMap(doc.id, data);
          })
          .toList();

      setState(() {
        _todosProdutos = todos;
        _carregando = false;
        _aplicarFiltro();
      });
    } catch (e) {
      setState(() {
        _carregando = false;
      });
      _showErrorDialog('Erro ao carregar produtos: $e');
    }
  }

  void _aplicarFiltro() {
    final termo = _termoBusca.toLowerCase().trim();
    
    if (termo.isEmpty) {
      setState(() {
        _produtosFiltrados = _todosProdutos.take(_limitePorPagina).toList();
        _temMaisProdutos = _todosProdutos.length > _limitePorPagina;
        _ultimoDocumento = null;
      });
    } else {
      final filtrados = _todosProdutos.where((produto) {
        final nomeMatch = produto.nome.toLowerCase().contains(termo);
        final codigoMatch = produto.codigo.toLowerCase().contains(termo);
        return nomeMatch || codigoMatch;
      }).toList();

      setState(() {
        _produtosFiltrados = filtrados.take(_limitePorPagina).toList();
        _temMaisProdutos = filtrados.length > _limitePorPagina;
        _ultimoDocumento = null;
      });
    }
  }

  void _buscarProdutos(String termo) {
    setState(() {
      _termoBusca = termo;
    });
    _aplicarFiltro();
  }

  void _carregarMaisProdutos() {
    if (_carregando || !_temMaisProdutos) return;

    final termo = _termoBusca.toLowerCase().trim();
    List<Produto> todosFiltrados;

    if (termo.isEmpty) {
      todosFiltrados = _todosProdutos;
    } else {
      todosFiltrados = _todosProdutos.where((produto) {
        final nomeMatch = produto.nome.toLowerCase().contains(termo);
        final codigoMatch = produto.codigo.toLowerCase().contains(termo);
        return nomeMatch || codigoMatch;
      }).toList();
    }

    final startIndex = _produtosFiltrados.length;
    final endIndex = startIndex + _limitePorPagina;

    if (startIndex >= todosFiltrados.length) {
      setState(() {
        _temMaisProdutos = false;
      });
      return;
    }

    final novosProdutos = todosFiltrados.sublist(
      startIndex,
      endIndex > todosFiltrados.length ? todosFiltrados.length : endIndex,
    );

    setState(() {
      _produtosFiltrados.addAll(novosProdutos);
      _temMaisProdutos = endIndex < todosFiltrados.length;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: BoxStockColors.alerta),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: BoxStockColors.papelaoMedio,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      body: SafeArea(
        child: Column(
          children: [
            // ===== CAMPO DE BUSCA =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: CampoBusca(
                controller: _buscaController,
                onChanged: _buscarProdutos,
                hintText: '🔍 Buscar produtos...',
              ),
            ),
            // ===== LISTA DE PRODUTOS =====
            Expanded(
              child: _carregando && _todosProdutos.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: BoxStockColors.papelaoMedio,
                      ),
                    )
                  : _produtosFiltrados.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _carregarProdutosIniciais,
                          color: BoxStockColors.papelaoMedio,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _produtosFiltrados.length + (_temMaisProdutos ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _produtosFiltrados.length) {
                                return _buildLoadMoreButton();
                              }
                              final produto = _produtosFiltrados[index];
                              return _buildProdutoCard(produto);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: BoxStockColors.papelaoEscuro.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              _termoBusca.isEmpty
                  ? Icons.inventory_2_outlined
                  : Icons.search_off,
              size: 56,
              color: BoxStockColors.papelaoClaro,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _termoBusca.isEmpty
                ? '📦 Nenhum produto cadastrado'
                : '🔍 Nenhum produto encontrado para "$_termoBusca"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _termoBusca.isEmpty
                ? 'Clique no botão + para adicionar'
                : 'Tente buscar com outro termo',
            style: TextStyle(
              fontSize: 14,
              color: BoxStockColors.textoPrincipal.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _carregando
            ? const CircularProgressIndicator(
                color: BoxStockColors.papelaoMedio,
              )
            : ElevatedButton(
                onPressed: _carregarMaisProdutos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BoxStockColors.fundoSecundario,
                  foregroundColor: BoxStockColors.textoPrincipal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: BoxStockColors.papelaoClaro.withOpacity(0.3),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_downward, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Carregar Mais Produtos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ==================== CARD DO PRODUTO ====================

  Widget _buildProdutoCard(Produto produto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: BoxStockColors.papelaoClaro.withOpacity(0.2),
            offset: const Offset(-2, -2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha 1: Nome + Status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BoxStockColors.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Código: ${produto.codigo}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              StatusEstoque(
                status: produto.situacaoEstoque,
                quantidade: produto.quantidade,
                estoqueMinimo: produto.estoqueMinimo,
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Linha 2: Categoria + Preço
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BoxStockColors.fundoSecundario,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📂 ${produto.categoria}',
                    style: TextStyle(
                      fontSize: 12,
                      color: BoxStockColors.textoPrincipal.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BoxStockColors.fundoSecundario,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '💰 ${produto.precoVendaFormatado}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.papelaoEscuro,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 🔥 BOTÃO DETALHES (APENAS ELE!)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.visibility,
                label: 'Ver Detalhes',
                color: BoxStockColors.papelaoMedio,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesProdutoScreen(produto: produto),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 150,
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}