import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/movimento_model.dart';
import '../../main.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _filtroTipo = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      appBar: AppBar(
        title: const Text(
          '📜 Histórico',
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
      body: Column(
        children: [
          // ===== FILTROS =====
          _buildFiltros(),
          // ===== LISTA DE MOVIMENTAÇÕES =====
          Expanded(
            child: _buildListaMovimentacoes(),
          ),
        ],
      ),
    );
  }

  // ==================== FILTROS ====================

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildFiltroButton('📋 Todos', 'todos', Colors.grey.shade600),
          const SizedBox(width: 8),
          _buildFiltroButton('➕ Entradas', 'entrada', BoxStockColors.sucesso),
          const SizedBox(width: 8),
          _buildFiltroButton('➖ Saídas', 'saida', BoxStockColors.acaoPrincipal),
        ],
      ),
    );
  }

  Widget _buildFiltroButton(String label, String tipo, Color cor) {
    final isSelected = _filtroTipo == tipo;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _filtroTipo = tipo;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? cor : BoxStockColors.campos,
          foregroundColor: isSelected ? Colors.white : BoxStockColors.textoPrincipal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: isSelected ? cor : BoxStockColors.papelaoClaro.withOpacity(0.3),
            width: 2,
          ),
          elevation: isSelected ? 4 : 0,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ==================== LISTA DE MOVIMENTAÇÕES ====================

  Widget _buildListaMovimentacoes() {
    return StreamBuilder<List<Movimento>>(
      stream: _firestoreService.listarMovimentacoes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                    'Erro ao carregar histórico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: BoxStockColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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

        var movimentos = snapshot.data ?? [];

        if (_filtroTipo != 'todos') {
          movimentos = movimentos.where((m) => m.tipo == _filtroTipo).toList();
        }

        if (movimentos.isEmpty) {
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
                    Icons.history,
                    size: 56,
                    color: BoxStockColors.papelaoClaro,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '📜 Nenhuma movimentação',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _filtroTipo == 'todos'
                      ? 'Registre entradas e saídas para ver o histórico'
                      : 'Nenhuma movimentação do tipo selecionado',
                  style: TextStyle(
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: movimentos.length,
          itemBuilder: (context, index) {
            final movimento = movimentos[index];
            return _buildMovimentoCard(movimento);
          },
        );
      },
    );
  }

  // ==================== CARD DO MOVIMENTO ====================

  Widget _buildMovimentoCard(Movimento movimento) {
    final isEntrada = movimento.isEntrada;
    final cor = isEntrada ? BoxStockColors.sucesso : BoxStockColors.acaoPrincipal;
    final icone = isEntrada ? Icons.add_box : Icons.remove_shopping_cart;
    final simbolo = isEntrada ? '+' : '-';
    final label = isEntrada ? 'ENTRADA' : 'SAÍDA';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
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
          // Linha 1: Ícone + Nome + Quantidade
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: cor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icone,
                  color: cor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movimento.produtoNome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: BoxStockColors.textoPrincipal,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$label • ${movimento.dataFormatada}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$simbolo${movimento.quantidade.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
              ),
            ],
          ),
          // Linha 2: Observação (se tiver)
          if (movimento.observacao != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BoxStockColors.fundoPrincipal,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: BoxStockColors.papelaoClaro.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.comment,
                    size: 14,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      movimento.observacao!,
                      style: TextStyle(
                        fontSize: 12,
                        color: BoxStockColors.textoPrincipal.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Linha 3: Usuário e Preço
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    movimento.usuarioEmail,
                    style: TextStyle(
                      fontSize: 11,
                      color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
              if (movimento.precoUnitario != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BoxStockColors.fundoSecundario,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '💰 ${movimento.precoUnitarioFormatado}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: BoxStockColors.papelaoEscuro,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}