import 'package:flutter/material.dart';

/// Widget que exibe o status do estoque de um produto
/// 
/// Mostra de forma visual a situação do produto:
/// - Disponível (verde)
/// - Estoque Baixo (laranja)
/// - Sem Estoque (vermelho)
class StatusEstoque extends StatelessWidget {
  final String status;
  final double quantidade;
  final double estoqueMinimo;
  final bool showIcon;
  final bool compact;

  const StatusEstoque({
    super.key,
    required this.status,
    required this.quantidade,
    required this.estoqueMinimo,
    this.showIcon = true,
    this.compact = false,
  });

  /// Retorna a cor baseada no status
  Color _getStatusColor() {
    if (quantidade <= 0) return Colors.red.shade700;
    if (quantidade <= estoqueMinimo) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  /// Retorna o ícone baseado no status
  IconData _getStatusIcon() {
    if (quantidade <= 0) return Icons.error_outline;
    if (quantidade <= estoqueMinimo) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline;
  }

  /// Retorna o texto do status
  String _getStatusLabel() {
    if (quantidade <= 0) return 'SEM ESTOQUE';
    if (quantidade <= estoqueMinimo) return 'ESTOQUE BAIXO';
    return 'DISPONÍVEL';
  }

  /// Retorna o texto curto do status
  String _getStatusLabelShort() {
    if (quantidade <= 0) return 'SEM';
    if (quantidade <= estoqueMinimo) return 'BAIXO';
    return 'OK';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final label = compact ? _getStatusLabelShort() : _getStatusLabel();
    final icon = _getStatusIcon();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              color: color,
              size: compact ? 14 : 18,
            ),
            if (!compact) const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Versão estendida do StatusEstoque com mais informações
class StatusEstoqueDetalhado extends StatelessWidget {
  final String nome;
  final double quantidade;
  final double estoqueMinimo;
  final double? precoVenda;
  final VoidCallback? onTap;

  const StatusEstoqueDetalhado({
    super.key,
    required this.nome,
    required this.quantidade,
    required this.estoqueMinimo,
    this.precoVenda,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final label = _getStatusLabel();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9B3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.shade800.withOpacity(0.15),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
          border: Border.all(
            color: Colors.brown.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Informações principais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 14,
                        color: Colors.brown.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${quantidade.toStringAsFixed(0)} unidades',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (precoVenda != null) ...[
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.brown.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'R\$ ${precoVenda!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (quantidade <= 0) return Colors.red.shade700;
    if (quantidade <= estoqueMinimo) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  IconData _getStatusIcon() {
    if (quantidade <= 0) return Icons.error_outline;
    if (quantidade <= estoqueMinimo) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline;
  }

  String _getStatusLabel() {
    if (quantidade <= 0) return 'SEM ESTOQUE';
    if (quantidade <= estoqueMinimo) return 'ESTOQUE BAIXO';
    return 'DISPONÍVEL';
  }
}

/// Widget de status em forma de "bolinha" (indicador)
class StatusBolinha extends StatelessWidget {
  final double quantidade;
  final double estoqueMinimo;
  final double tamanho;

  const StatusBolinha({
    super.key,
    required this.quantidade,
    required this.estoqueMinimo,
    this.tamanho = 12,
  });

  @override
  Widget build(BuildContext context) {
    Color cor;
    if (quantidade <= 0) {
      cor = Colors.red;
    } else if (quantidade <= estoqueMinimo) {
      cor = Colors.orange;
    } else {
      cor = Colors.green;
    }

    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}