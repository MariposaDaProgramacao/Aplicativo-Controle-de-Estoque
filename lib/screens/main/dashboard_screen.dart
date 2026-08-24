import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/produto_model.dart';
import '../../main.dart'; // ← IMPORTANTE: importa o BoxStockColors
import 'cadastro_produto_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic> _dados = {};
  bool _carregando = true;
  String _userName = 'Usuário';
  List<Produto> _ultimosProdutos = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _carregarNomeUsuario();
    _carregarUltimosProdutos();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await _firestoreService.obterDadosDashboard();
      setState(() {
        _dados = dados;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  Future<void> _carregarNomeUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      setState(() {
        _userName = user.email!.split('@')[0];
      });
    }
  }

  Future<void> _carregarUltimosProdutos() async {
    try {
      final produtos = await _firestoreService.listarProdutos().first;
      setState(() {
        _ultimosProdutos = produtos.take(5).toList();
      });
    } catch (e) {
      // Ignora erro
    }
  }

  void _abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroProdutoScreen(),
      ),
    ).then((_) {
      _carregarDados();
      _carregarUltimosProdutos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCabecalho(),
              const SizedBox(height: 24),
              _carregando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: BoxStockColors.papelaoMedio,
                      ),
                    )
                  : _buildCardsResumo(),
              const SizedBox(height: 24),
              _buildProdutosRecentes(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        backgroundColor: BoxStockColors.acaoPrincipal,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: BoxStockColors.papelaoMedio,
            width: 2,
          ),
        ),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ==================== CABEÇALHO ====================

  Widget _buildCabecalho() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoSecundario,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.15),
            offset: const Offset(4, 8),
            blurRadius: 20,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BoxStockColors.papelaoClaro.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: BoxStockColors.papelaoClaro.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: BoxStockColors.papelaoEscuro.withOpacity(0.1),
                  offset: const Offset(2, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.inventory_2,
              color: BoxStockColors.papelaoEscuro,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $_userName! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bem-vindo ao seu controle de estoque.',
                  style: TextStyle(
                    fontSize: 14,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: BoxStockColors.papelaoMedio.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BoxStockColors.papelaoMedio.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: BoxStockColors.sucesso,
                ),
                const SizedBox(width: 4),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BoxStockColors.sucesso,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARDS DE RESUMO ====================

  Widget _buildCardsResumo() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildCard(
          titulo: 'Total Produtos',
          valor: _dados['totalProdutos']?.toString() ?? '0',
          icone: Icons.inventory_2,
          cor: BoxStockColors.informacao,
        ),
        _buildCard(
          titulo: 'Estoque Baixo',
          valor: _dados['produtosEstoqueBaixo']?.toString() ?? '0',
          icone: Icons.warning_amber_rounded,
          cor: BoxStockColors.acaoPrincipal,
        ),
        _buildCard(
          titulo: 'Sem Estoque',
          valor: _dados['produtosSemEstoque']?.toString() ?? '0',
          icone: Icons.error_outline,
          cor: BoxStockColors.alerta,
        ),
        _buildCard(
          titulo: 'Categorias',
          valor: _dados['totalCategorias']?.toString() ?? '0',
          icone: Icons.category,
          cor: BoxStockColors.recursoSecundario,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Container(
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
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: BoxStockColors.textoPrincipal.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== ÚLTIMOS PRODUTOS ====================

  Widget _buildProdutosRecentes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 20,
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
          Row(
            children: [
              const Icon(
                Icons.inventory_2,
                color: BoxStockColors.papelaoMedio,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                '📦 Últimos Produtos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BoxStockColors.textoPrincipal,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Navegar para lista completa
                },
                style: TextButton.styleFrom(
                  foregroundColor: BoxStockColors.papelaoMedio,
                ),
                child: const Text(
                  'Ver todos →',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _carregando
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                      color: BoxStockColors.papelaoMedio,
                    ),
                  ),
                )
              : _ultimosProdutos.isEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: BoxStockColors.papelaoClaro.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '📭 Nenhum produto cadastrado ainda',
                            style: TextStyle(
                              fontSize: 16,
                              color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _ultimosProdutos.map((produto) {
                        return _buildProdutoItem(produto);
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildProdutoItem(Produto produto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: BoxStockColors.papelaoClaro.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.inventory_2,
              size: 20,
              color: BoxStockColors.papelaoMedio,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: BoxStockColors.textoPrincipal,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Cód: ${produto.codigo} | Qtd: ${produto.quantidade.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(produto),
        ],
      ),
    );
  }

  Widget _buildStatusChip(Produto produto) {
    String label;
    Color color;

    if (produto.quantidade <= 0) {
      label = 'SEM ESTOQUE';
      color = BoxStockColors.alerta;
    } else if (produto.quantidade <= produto.estoqueMinimo) {
      label = 'BAIXO';
      color = BoxStockColors.acaoPrincipal;
    } else {
      label = 'DISPONÍVEL';
      color = BoxStockColors.sucesso;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}