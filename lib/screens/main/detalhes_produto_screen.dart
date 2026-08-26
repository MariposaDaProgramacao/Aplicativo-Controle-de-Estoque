import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/produto_model.dart';
import '../../main.dart';
import 'entrada_screen.dart';
import 'saida_screen.dart';
import 'cadastro_produto_screen.dart';

class DetalhesProdutoScreen extends StatelessWidget {
  final Produto produto;

  const DetalhesProdutoScreen({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      appBar: AppBar(
        title: Text(
          produto.nome,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildValuesCard(),
            const SizedBox(height: 20),

            // ============================================================
            // 🔥 BOTÕES MAIS PARA CIMA (SEM ESPAÇO EXTRA NO FINAL)
            // ============================================================
            _buildActionButtons(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== CABEÇALHO ====================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BoxStockColors.papelaoClaro.withOpacity(0.2),
            BoxStockColors.papelaoClaro.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: BoxStockColors.papelaoClaro.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.inventory_2,
              size: 32,
              color: BoxStockColors.papelaoMedio,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
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
                      child: Text(
                        '📂 ${produto.categoria}',
                        style: TextStyle(
                          fontSize: 12,
                          color: BoxStockColors.textoPrincipal.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        '🏷️ ${produto.codigo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: BoxStockColors.textoPrincipal.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD DE INFORMAÇÕES ====================

  Widget _buildInfoCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Informações do Produto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            '📦 Quantidade em estoque',
            '${produto.quantidade.toStringAsFixed(0)} unidades',
          ),
          const Divider(color: BoxStockColors.papelaoClaro),
          _buildInfoRow(
            '⚠️ Estoque mínimo',
            '${produto.estoqueMinimo.toStringAsFixed(0)} unidades',
          ),
          if (produto.descricao.isNotEmpty) ...[
            const Divider(color: BoxStockColors.papelaoClaro),
            _buildInfoRow('📝 Descrição', produto.descricao),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: BoxStockColors.textoPrincipal.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BoxStockColors.textoPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD DE STATUS ====================

  Widget _buildStatusCard() {
    String status;
    Color cor;
    IconData icone;

    if (produto.quantidade <= 0) {
      status = 'Sem Estoque';
      cor = BoxStockColors.alerta;
      icone = Icons.error_outline;
    } else if (produto.quantidade <= produto.estoqueMinimo) {
      status = 'Estoque Baixo';
      cor = BoxStockColors.acaoPrincipal;
      icone = Icons.warning_amber_rounded;
    } else {
      status = 'Disponível';
      cor = BoxStockColors.sucesso;
      icone = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.1),
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
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Situação do Estoque',
                  style: TextStyle(
                    fontSize: 12,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              produto.quantidade <= 0
                  ? 'CRÍTICO'
                  : produto.quantidade <= produto.estoqueMinimo
                      ? 'ATENÇÃO'
                      : 'OK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD DE VALORES ====================

  Widget _buildValuesCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Valores',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildValueItem(
                  'Preço de Custo',
                  produto.precoCustoFormatado,
                  BoxStockColors.informacao,
                ),
              ),
              Expanded(
                child: _buildValueItem(
                  'Preço de Venda',
                  produto.precoVendaFormatado,
                  BoxStockColors.sucesso,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '💰 Valor total em estoque',
                  style: TextStyle(
                    fontSize: 13,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.7),
                  ),
                ),
                Text(
                  produto.valorTotalEstoqueFormatado,
                  style: const TextStyle(
                    fontSize: 18,
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

  Widget _buildValueItem(String label, String value, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: BoxStockColors.textoPrincipal.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTÕES DE AÇÃO (AJUSTADOS) ====================

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: BoxStockColors.campos.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 🔥 BOTÃO ENTRADA
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_box,
                label: 'Entrada',
                color: BoxStockColors.sucesso,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EntradaScreen(produto: produto),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // 🔥 BOTÃO SAÍDA
            Expanded(
              child: _buildActionButton(
                icon: Icons.remove_shopping_cart,
                label: 'Saída',
                color: BoxStockColors.acaoPrincipal,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SaidaScreen(produto: produto),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // 🔥 BOTÃO EDITAR
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit,
                label: 'Editar',
                color: BoxStockColors.informacao,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastroProdutoScreen(produto: produto),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            // 🔥 BOTÃO EXCLUIR
            Expanded(
              child: _buildActionButton(
                icon: Icons.delete,
                label: 'Excluir',
                color: BoxStockColors.alerta,
                onPressed: () {
                  _confirmarExclusao(context);
                },
              ),
            ),
          ],
        ),
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
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          elevation: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CONFIRMAR EXCLUSÃO ====================

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: BoxStockColors.alerta),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text(
          'Deseja realmente excluir o produto\n"${produto.nome}"?',
          style: const TextStyle(color: BoxStockColors.textoPrincipal),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: BoxStockColors.textoPrincipal,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              Navigator.pop(context); // Fecha a tela de detalhes

              try {
                await FirebaseFirestore.instance
                    .collection('produtos')
                    .doc(produto.id)
                    .delete();

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Produto excluído com sucesso!'),
                    backgroundColor: BoxStockColors.sucesso,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erro ao excluir: $e'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.alerta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}