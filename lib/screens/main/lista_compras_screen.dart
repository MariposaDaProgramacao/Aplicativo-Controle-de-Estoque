import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/firestore_service.dart';
import '../../models/lista_compra_model.dart';
import '../../main.dart';

class ListaComprasScreen extends StatefulWidget {
  const ListaComprasScreen({super.key});

  @override
  State<ListaComprasScreen> createState() => _ListaComprasScreenState();
}

class _ListaComprasScreenState extends State<ListaComprasScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  final Map<String, TextEditingController> _quantidadeControllers = {};

  @override
  void initState() {
    super.initState();
    _verificarLista();
  }

  @override
  void dispose() {
    for (final controller in _quantidadeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _verificarLista() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.verificarListaCompras();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Lista de compras atualizada!'),
          backgroundColor: BoxStockColors.sucesso,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao verificar: $e'),
          backgroundColor: BoxStockColors.alerta,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _limparComprados() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar itens comprados?'),
        content: const Text(
          'Isso removerá todos os itens marcados como comprados da lista.',
          style: TextStyle(color: BoxStockColors.textoPrincipal),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.limparItensComprados();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Itens comprados removidos!'),
                    backgroundColor: BoxStockColors.sucesso,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erro ao limpar: $e'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.alerta,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  Future<void> _compartilharLista() async {
    try {
      final itens = await _firestoreService.listarListaCompras().first;
      final itensPendentes = itens.where((i) => !i.comprado).toList();

      if (itensPendentes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📭 Nenhum item pendente para comprar!'),
            backgroundColor: BoxStockColors.informacao,
          ),
        );
        return;
      }

      final texto = _gerarTextoListaComQuantidades(itensPendentes);
      await Share.share(
        texto,
        subject: '🛒 Lista de Compras - BoxStock',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao compartilhar: $e'),
          backgroundColor: BoxStockColors.alerta,
        ),
      );
    }
  }

  String _gerarTextoListaComQuantidades(List<ListaCompra> itens) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 LISTA DE COMPRAS - BoxStock');
    buffer.writeln('=' * 40);
    buffer.writeln('📅 ${DateTime.now().toLocal().toString().split(' ')[0]}');
    buffer.writeln('');

    for (var i = 0; i < itens.length; i++) {
      final item = itens[i];
      final controller = _quantidadeControllers[item.id!];
      final quantidadeCompra = controller != null && controller.text.isNotEmpty
          ? double.tryParse(controller.text) ?? item.quantidadeFaltante
          : item.quantidadeFaltante;

      buffer.writeln('${i + 1}. ${item.produtoNome}');
      buffer.writeln('   📦 Estoque atual: ${item.quantidadeAtual.toStringAsFixed(0)} und.');
      buffer.writeln('   🛒 Comprar: ${quantidadeCompra.toStringAsFixed(0)} und.');
      buffer.writeln('   📂 ${item.categoria}');
      buffer.writeln('');
    }

    buffer.writeln('=' * 40);
    buffer.writeln('📦 BoxStock - Organização que cabe no seu bolso');
    return buffer.toString();
  }

  TextEditingController _getQuantidadeController(ListaCompra item) {
    final id = item.id!;
    if (!_quantidadeControllers.containsKey(id)) {
      final controller = TextEditingController(
        text: item.quantidadeFaltante.toStringAsFixed(0),
      );
      _quantidadeControllers[id] = controller;
    }
    return _quantidadeControllers[id]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      appBar: AppBar(
        title: const Text(
          '🛒 Lista de Compras',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: ElevatedButton.icon(
              onPressed: _compartilharLista,
              icon: const Icon(Icons.share, color: Colors.white, size: 18),
              label: const Text(
                'Compartilhar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BoxStockColors.acaoPrincipal,
                foregroundColor: Colors.white,
                elevation: 4,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _verificarLista,
            tooltip: 'Verificar agora',
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services, color: Colors.white),
            onPressed: _limparComprados,
            tooltip: 'Limpar comprados',
          ),
        ],
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
      body: _buildListaCompras(),
    );
  }

  Widget _buildListaCompras() {
    return StreamBuilder<List<ListaCompra>>(
      stream: _firestoreService.listarListaCompras(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: BoxStockColors.alerta,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar lista',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: BoxStockColors.textoPrincipal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verificarLista,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BoxStockColors.papelaoMedio,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Verificar agora'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: BoxStockColors.papelaoMedio,
            ),
          );
        }

        final itens = snapshot.data ?? [];
        final itensPendentes = itens.where((i) => !i.comprado).toList();
        final itensComprados = itens.where((i) => i.comprado).toList();

        if (itens.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResumo(itensPendentes.length, itensComprados.length),
              const SizedBox(height: 16),

              if (itensPendentes.isNotEmpty) ...[
                const Text(
                  '📋 Para Comprar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                ...itensPendentes.map((item) => _buildItemCard(item)),
                const SizedBox(height: 16),
              ],

              if (itensComprados.isNotEmpty) ...[
                const Text(
                  '✅ Já Comprados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.sucesso,
                  ),
                ),
                const SizedBox(height: 8),
                ...itensComprados.map((item) => _buildItemCard(item)),
              ],
            ],
          ),
        );
      },
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
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: BoxStockColors.papelaoClaro,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '🛒 Lista de compras vazia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Produtos com estoque baixo aparecerão aqui',
            style: TextStyle(
              color: BoxStockColors.textoPrincipal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _verificarLista,
            icon: const Icon(Icons.refresh),
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.papelaoMedio,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            label: const Text('Verificar agora'),
          ),
        ],
      ),
    );
  }

  Widget _buildResumo(int pendentes, int comprados) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumoItem(
            '🛒 Pendentes',
            pendentes.toString(),
            BoxStockColors.acaoPrincipal,
          ),
          Container(
            width: 1,
            height: 40,
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          ),
          _buildResumoItem(
            '✅ Comprados',
            comprados.toString(),
            BoxStockColors.sucesso,
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor, Color cor) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: BoxStockColors.textoPrincipal,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🔥 ITEM CARD (SEM CÍRCULO)
  // ============================================================

  Widget _buildItemCard(ListaCompra item) {
    final isComprado = item.comprado;
    final quantidadeAtual = item.quantidadeAtual.toStringAsFixed(0);
    final controller = _getQuantidadeController(item);
    final faltante = item.quantidadeFaltante.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComprado
            ? BoxStockColors.sucesso.withOpacity(0.08)
            : BoxStockColors.campos,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComprado
              ? BoxStockColors.sucesso.withOpacity(0.3)
              : BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (!isComprado) {
                    _marcarComoComprado(item);
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isComprado
                        ? BoxStockColors.sucesso
                        : BoxStockColors.papelaoClaro,
                    border: Border.all(
                      color: isComprado
                          ? BoxStockColors.sucesso
                          : BoxStockColors.papelaoClaro,
                      width: 2,
                    ),
                  ),
                  child: isComprado
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.produtoNome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isComprado
                        ? BoxStockColors.textoPrincipal
                        : BoxStockColors.textoPrincipal,
                    decoration: isComprado
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: BoxStockColors.textoPrincipal,
                ),
                onPressed: () => _removerItem(item),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (!isComprado) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BoxStockColors.fundoSecundario,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 14,
                        color: BoxStockColors.papelaoMedio,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Atual: $quantidadeAtual und.',
                        style: TextStyle(
                          fontSize: 12,
                          color: BoxStockColors.textoPrincipal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BoxStockColors.acaoPrincipal,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: BoxStockColors.acaoPrincipal,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sugestão: $faltante und.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ============================================================
            // 🔥 CAMPO DE QUANTIDADE (SEM CÍRCULO, APENAS A CAIXA)
            // ============================================================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BoxStockColors.fundoPrincipal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BoxStockColors.papelaoClaro,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    size: 18,
                    color: BoxStockColors.papelaoMedio,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Comprar:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: BoxStockColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 55,
                    height: 35,
                    decoration: BoxDecoration(
                      color: BoxStockColors.campos,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: BoxStockColors.papelaoMedio,
                        width: 1.5,
                      ),
                    ),
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BoxStockColors.acaoPrincipal,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'und.',
                    style: TextStyle(
                      fontSize: 12,
                      color: BoxStockColors.textoPrincipal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _marcarComoComprado(ListaCompra item) async {
    try {
      await _firestoreService.marcarComoComprado(item.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${item.produtoNome}" marcado como comprado!'),
          backgroundColor: BoxStockColors.sucesso,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro: $e'),
          backgroundColor: BoxStockColors.alerta,
        ),
      );
    }
  }

  Future<void> _removerItem(ListaCompra item) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover item?'),
        content: Text(
          'Deseja remover "${item.produtoNome}" da lista de compras?',
          style: const TextStyle(color: BoxStockColors.textoPrincipal),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.removerListaCompra(item.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ "${item.produtoNome}" removido!'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erro: $e'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.alerta,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}