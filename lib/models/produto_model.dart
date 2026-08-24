import 'package:cloud_firestore/cloud_firestore.dart';

class Produto {
  final String? id;
  final String nome;
  final String codigo;
  final String categoria;
  final String descricao;
  final double quantidade;
  final double estoqueMinimo;
  final double precoCusto;
  final double precoVenda;
  final String usuarioId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Produto({
    this.id,
    required this.nome,
    required this.codigo,
    required this.categoria,
    required this.descricao,
    required this.quantidade,
    required this.estoqueMinimo,
    required this.precoCusto,
    required this.precoVenda,
    required this.usuarioId,
    required this.createdAt,
    this.updatedAt,
  });

  // ==================== CONVERSÃO ====================

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'codigo': codigo,
      'categoria': categoria,
      'descricao': descricao,
      'quantidade': quantidade,
      'estoqueMinimo': estoqueMinimo,
      'precoCusto': precoCusto,
      'precoVenda': precoVenda,
      'usuarioId': usuarioId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // 🔥 CORRIGIDO: LÊ TIMESTAMP CORRETAMENTE
  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Produto(
      id: id,
      nome: map['nome'] ?? '',
      codigo: map['codigo'] ?? '',
      categoria: map['categoria'] ?? '',
      descricao: map['descricao'] ?? '',
      quantidade: (map['quantidade'] ?? 0).toDouble(),
      estoqueMinimo: (map['estoqueMinimo'] ?? 0).toDouble(),
      precoCusto: (map['precoCusto'] ?? 0).toDouble(),
      precoVenda: (map['precoVenda'] ?? 0).toDouble(),
      usuarioId: map['usuarioId'] ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
    );
  }

  // ==================== CÓPIA ====================

  Produto copyWith({
    String? id,
    String? nome,
    String? codigo,
    String? categoria,
    String? descricao,
    double? quantidade,
    double? estoqueMinimo,
    double? precoCusto,
    double? precoVenda,
    String? usuarioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      codigo: codigo ?? this.codigo,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      quantidade: quantidade ?? this.quantidade,
      estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo,
      precoCusto: precoCusto ?? this.precoCusto,
      precoVenda: precoVenda ?? this.precoVenda,
      usuarioId: usuarioId ?? this.usuarioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== STATUS ====================

  String get situacaoEstoque {
    if (quantidade <= 0) return 'Sem Estoque';
    if (quantidade <= estoqueMinimo) return 'Estoque Baixo';
    return 'Disponível';
  }

  String get situacaoCor {
    if (quantidade <= 0) return '#FF4444';
    if (quantidade <= estoqueMinimo) return '#FF8C00';
    return '#4CAF50';
  }

  String get situacaoIcone {
    if (quantidade <= 0) return 'error_outline';
    if (quantidade <= estoqueMinimo) return 'warning_amber_rounded';
    return 'check_circle_outline';
  }

  String get statusColor {
    if (quantidade <= 0) return 'vermelho';
    if (quantidade <= estoqueMinimo) return 'laranja';
    return 'verde';
  }

  // ==================== CÁLCULOS ====================

  double get valorTotalEstoque => quantidade * precoCusto;

  double get lucroPorUnidade => precoVenda - precoCusto;

  double get margemLucro {
    if (precoCusto <= 0) return 0;
    return (lucroPorUnidade / precoCusto) * 100;
  }

  // ==================== VALIDAÇÕES ====================

  bool get isEstoqueCritico => quantidade <= estoqueMinimo;

  bool get isSemEstoque => quantidade <= 0;

  bool get isDisponivel => quantidade > estoqueMinimo;

  // ==================== FORMATAÇÃO ====================

  String get precoCustoFormatado =>
      'R\$ ${precoCusto.toStringAsFixed(2).replaceAll('.', ',')}';

  String get precoVendaFormatado =>
      'R\$ ${precoVenda.toStringAsFixed(2).replaceAll('.', ',')}';

  String get valorTotalEstoqueFormatado =>
      'R\$ ${valorTotalEstoque.toStringAsFixed(2).replaceAll('.', ',')}';
}