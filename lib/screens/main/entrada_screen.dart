import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/produto_model.dart';
import '../../models/movimento_model.dart';
import '../../main.dart';

class EntradaScreen extends StatefulWidget {
  final Produto? produto;

  const EntradaScreen({super.key, this.produto});

  @override
  State<EntradaScreen> createState() => _EntradaScreenState();
}

class _EntradaScreenState extends State<EntradaScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();
  final _observacaoController = TextEditingController();
  final _buscaController = TextEditingController();

  bool _isLoading = false;
  bool _carregandoProdutos = false;
  bool _temMaisProdutos = true;
  List<Produto> _produtosEncontrados = [];
  Produto? _produtoSelecionado;
  bool _veioDaListagem = false;

  static const int _limitePorPagina = 5;

  @override
  void initState() {
    super.initState();
    _veioDaListagem = widget.produto != null;
    _produtoSelecionado = widget.produto;

    if (_veioDaListagem) {
      _buscaController.text = _produtoSelecionado!.nome;
      _produtosEncontrados = [_produtoSelecionado!];
    } else {
      _carregarProdutosIniciais();
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _precoController.dispose();
    _observacaoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  // ==================== MÉTODOS DE BUSCA ====================

  Future<void> _carregarProdutosIniciais() async {
    setState(() {
      _carregandoProdutos = true;
      _produtosEncontrados = [];
      _temMaisProdutos = true;
    });

    try {
      final produtos = await _buscarProdutos('');
      setState(() {
        _produtosEncontrados = produtos;
        _carregandoProdutos = false;
        _temMaisProdutos = produtos.length >= _limitePorPagina;
      });
    } catch (e) {
      setState(() {
        _carregandoProdutos = false;
      });
      _showErrorDialog('Erro ao carregar produtos: $e');
    }
  }

  Future<List<Produto>> _buscarProdutos(String termo) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      QuerySnapshot snapshot;

      if (termo.isEmpty) {
        snapshot = await FirebaseFirestore.instance
            .collection('produtos')
            .where('usuarioId', isEqualTo: user.uid)
            .orderBy('nome')
            .limit(_limitePorPagina)
            .get();
      } else {
        final termoLower = termo.toLowerCase();
        final termoUpper = termoLower.substring(0, termoLower.length - 1) +
            String.fromCharCode(termoLower.codeUnitAt(termoLower.length - 1) + 1);

        snapshot = await FirebaseFirestore.instance
            .collection('produtos')
            .where('usuarioId', isEqualTo: user.uid)
            .where('nome', isGreaterThanOrEqualTo: termoLower)
            .where('nome', isLessThan: termoUpper)
            .orderBy('nome')
            .limit(_limitePorPagina)
            .get();
      }

      return snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Produto.fromMap(doc.id, data);
          })
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  Future<void> _carregarMaisProdutos() async {
    if (_carregandoProdutos || !_temMaisProdutos) return;

    setState(() {
      _carregandoProdutos = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ultimoProduto = _produtosEncontrados.last;

      final snapshot = await FirebaseFirestore.instance
          .collection('produtos')
          .where('usuarioId', isEqualTo: user.uid)
          .orderBy('nome')
          .startAfter([ultimoProduto.nome])
          .limit(_limitePorPagina)
          .get();

      final novosProdutos = snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Produto.fromMap(doc.id, data);
          })
          .toList();

      setState(() {
        _produtosEncontrados.addAll(novosProdutos);
        _carregandoProdutos = false;
        _temMaisProdutos = novosProdutos.length >= _limitePorPagina;
      });
    } catch (e) {
      setState(() {
        _carregandoProdutos = false;
      });
      _showErrorDialog('Erro ao carregar mais produtos: $e');
    }
  }

  // ==================== MÉTODO DE REGISTRO ====================

  Future<void> _registrarEntrada() async {
    if (!_formKey.currentState!.validate()) return;
    if (_produtoSelecionado == null) {
      _showErrorDialog('Selecione um produto');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final quantidade = double.parse(_quantidadeController.text);
      final novaQuantidade = _produtoSelecionado!.quantidade + quantidade;

      await _firestoreService.atualizarQuantidade(
        _produtoSelecionado!.id!,
        novaQuantidade,
      );

      final user = FirebaseAuth.instance.currentUser!;
      final movimento = Movimento(
        produtoId: _produtoSelecionado!.id!,
        produtoNome: _produtoSelecionado!.nome,
        tipo: 'entrada',
        quantidade: quantidade,
        precoUnitario: double.tryParse(_precoController.text),
        observacao: _observacaoController.text.isNotEmpty
            ? _observacaoController.text
            : null,
        usuarioId: user.uid,
        usuarioEmail: user.email ?? '',
        createdAt: DateTime.now(),
      );
      await _firestoreService.criarMovimento(movimento);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ +${quantidade.toStringAsFixed(0)} unidades de "${_produtoSelecionado!.nome}" registradas!'),
          backgroundColor: BoxStockColors.sucesso,
          duration: const Duration(seconds: 3),
        ),
      );

      _quantidadeController.clear();
      _precoController.clear();
      _observacaoController.clear();
      setState(() {
        _produtoSelecionado = null;
        _buscaController.clear();
        _veioDaListagem = false;
      });
      _carregarProdutosIniciais();

    } catch (e) {
      _showErrorDialog('Erro ao registrar entrada: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      appBar: AppBar(
        title: const Text(
          '➕ Registrar Entrada',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: BoxStockColors.papelaoClaro,
              boxShadow: [
                BoxShadow(
                  color: BoxStockColors.papelaoEscuro.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== SE VEIO DA LISTAGEM, MOSTRA O PRODUTO SELECIONADO =====
                if (_veioDaListagem) _buildProdutoSelecionadoCard(),
                const SizedBox(height: 12),

                // ===== CAMPO DE BUSCA =====
                _buildBuscaField(),
                const SizedBox(height: 12),

                // ===== LISTA DE PRODUTOS =====
                _buildListaProdutos(),
                const SizedBox(height: 16),

                // ===== DIVISOR =====
                const Divider(color: BoxStockColors.papelaoClaro),
                const SizedBox(height: 16),

                // ===== QUANTIDADE =====
                _buildQuantidadeField(),
                const SizedBox(height: 16),

                // ===== PREÇO UNITÁRIO =====
                _buildPrecoField(),
                const SizedBox(height: 16),

                // ===== OBSERVAÇÃO =====
                _buildObservacaoField(),
                const SizedBox(height: 24),

                // ===== BOTÃO REGISTRAR =====
                _buildRegistrarButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== PRODUTO SELECIONADO (CARD) ====================

  Widget _buildProdutoSelecionadoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BoxStockColors.sucesso.withOpacity(0.08),
            BoxStockColors.sucesso.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BoxStockColors.sucesso.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.sucesso.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BoxStockColors.sucesso.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: BoxStockColors.sucesso,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto Selecionado',
                  style: TextStyle(
                    fontSize: 12,
                    color: BoxStockColors.sucesso,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _produtoSelecionado!.nome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BoxStockColors.papelaoClaro.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '📦 Estoque',
                  style: TextStyle(
                    fontSize: 10,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                  ),
                ),
                Text(
                  '${_produtoSelecionado!.quantidade.toStringAsFixed(0)} und.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.papelaoEscuro,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUSCA ====================

  Widget _buildBuscaField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _buscaController,
        onChanged: (value) {
          if (!_veioDaListagem) {
            _buscarProdutos(value).then((produtos) {
              setState(() {
                _produtosEncontrados = produtos;
                _temMaisProdutos = produtos.length >= _limitePorPagina;
                if (_produtosEncontrados.isNotEmpty && _produtoSelecionado == null) {
                  _produtoSelecionado = _produtosEncontrados.first;
                }
              });
            });
          }
        },
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: InputDecoration(
          hintText: _veioDaListagem
              ? '🔍 Produto já selecionado'
              : '🔍 Digite o nome do produto...',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: BoxStockColors.papelaoMedio,
          ),
          suffixIcon: _veioDaListagem
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                  ),
                  onPressed: () {
                    setState(() {
                      _veioDaListagem = false;
                      _produtoSelecionado = null;
                      _buscaController.clear();
                      _carregarProdutosIniciais();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        enabled: !_veioDaListagem,
      ),
    );
  }

  // ==================== LISTA DE PRODUTOS ====================

  Widget _buildListaProdutos() {
    if (_veioDaListagem) {
      return const SizedBox.shrink();
    }

    if (_carregandoProdutos && _produtosEncontrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(
            color: BoxStockColors.papelaoMedio,
          ),
        ),
      );
    }

    if (_produtosEncontrados.isEmpty && _buscaController.text.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BoxStockColors.campos,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 40,
                color: BoxStockColors.papelaoClaro,
              ),
              const SizedBox(height: 8),
              Text(
                'Nenhum produto encontrado',
                style: TextStyle(
                  color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_produtosEncontrados.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BoxStockColors.campos,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.search,
                size: 40,
                color: BoxStockColors.papelaoClaro,
              ),
              SizedBox(height: 8),
              Text(
                '🔍 Digite o nome do produto',
                style: TextStyle(
                  color: BoxStockColors.textoPrincipal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: BoxStockColors.campos,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: BoxStockColors.papelaoClaro.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _produtosEncontrados.length,
            itemBuilder: (context, index) {
              final produto = _produtosEncontrados[index];
              final isSelected = _produtoSelecionado?.id == produto.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _produtoSelecionado = produto;
                    _buscaController.text = produto.nome;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BoxStockColors.fundoSecundario
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: BoxStockColors.papelaoClaro.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? BoxStockColors.sucesso
                              : BoxStockColors.papelaoClaro.withOpacity(0.3),
                          border: Border.all(
                            color: isSelected
                                ? BoxStockColors.sucesso
                                : BoxStockColors.papelaoClaro.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produto.nome,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: BoxStockColors.textoPrincipal,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '📦 Estoque: ${produto.quantidade.toStringAsFixed(0)} unidades',
                              style: TextStyle(
                                fontSize: 12,
                                color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BoxStockColors.fundoSecundario,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '💰 ${produto.precoVendaFormatado}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: BoxStockColors.papelaoEscuro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_temMaisProdutos)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _carregandoProdutos ? null : _carregarMaisProdutos,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _carregandoProdutos
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: BoxStockColors.papelaoMedio,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Carregar Mais',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== QUANTIDADE ====================

  Widget _buildQuantidadeField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _quantidadeController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Quantidade *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.numbers,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite a quantidade';
          }
          final qtd = double.tryParse(value);
          if (qtd == null || qtd <= 0) {
            return 'Digite uma quantidade válida';
          }
          return null;
        },
      ),
    );
  }

  // ==================== PREÇO UNITÁRIO ====================

  Widget _buildPrecoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _precoController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Preço unitário (opcional)',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.monetization_on,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ==================== OBSERVAÇÃO ====================

  Widget _buildObservacaoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _observacaoController,
        maxLines: 2,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Observação (opcional)',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.comment,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ==================== BOTÃO REGISTRAR ====================

  Widget _buildRegistrarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registrarEntrada,
        style: ElevatedButton.styleFrom(
          backgroundColor: BoxStockColors.sucesso,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
          shadowColor: BoxStockColors.sucesso.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                '✅ Registrar Entrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}