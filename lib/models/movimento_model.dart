import 'package:flutter/material.dart';

/// Modelo de Movimentação para o BoxStock
/// 
/// Representa uma movimentação de entrada ou saída de produtos
/// com todos os seus atributos e métodos para manipulação.
class Movimento {
  // ==================== ATRIBUTOS ====================
  final String? id;
  final String produtoId;
  final String produtoNome;
  final String tipo; // 'entrada' ou 'saida'
  final double quantidade;
  final double? precoUnitario;
  final String? observacao;
  final String usuarioId;
  final String usuarioEmail;
  final DateTime createdAt;

  // ==================== CONSTRUTOR ====================
  Movimento({
    this.id,
    required this.produtoId,
    required this.produtoNome,
    required this.tipo,
    required this.quantidade,
    this.precoUnitario,
    this.observacao,
    required this.usuarioId,
    required this.usuarioEmail,
    required this.createdAt,
  });

  // ==================== MÉTODOS DE CONVERSÃO ====================

  /// Converte o objeto para um Map (para enviar ao Firestore)
  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'produtoNome': produtoNome,
      'tipo': tipo,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
      'observacao': observacao,
      'usuarioId': usuarioId,
      'usuarioEmail': usuarioEmail,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Converte um Map (do Firestore) para um objeto Movimento
  factory Movimento.fromMap(String id, Map<String, dynamic> map) {
    return Movimento(
      id: id,
      produtoId: map['produtoId'] ?? '',
      produtoNome: map['produtoNome'] ?? '',
      tipo: map['tipo'] ?? '',
      quantidade: (map['quantidade'] ?? 0).toDouble(),
      precoUnitario: map['precoUnitario']?.toDouble(),
      observacao: map['observacao'],
      usuarioId: map['usuarioId'] ?? '',
      usuarioEmail: map['usuarioEmail'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // ==================== MÉTODOS DE CÓPIA ====================

  /// Cria uma cópia da movimentação com alguns campos alterados
  Movimento copyWith({
    String? id,
    String? produtoId,
    String? produtoNome,
    String? tipo,
    double? quantidade,
    double? precoUnitario,
    String? observacao,
    String? usuarioId,
    String? usuarioEmail,
    DateTime? createdAt,
  }) {
    return Movimento(
      id: id ?? this.id,
      produtoId: produtoId ?? this.produtoId,
      produtoNome: produtoNome ?? this.produtoNome,
      tipo: tipo ?? this.tipo,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      observacao: observacao ?? this.observacao,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioEmail: usuarioEmail ?? this.usuarioEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ==================== MÉTODOS DE FORMATAÇÃO ====================

  /// Retorna o tipo de movimentação formatado
  String get tipoLabel {
    return tipo == 'entrada' ? 'Entrada' : 'Saída';
  }

  /// Retorna o ícone do tipo de movimentação
  String get tipoIcon {
    return tipo == 'entrada' ? '➕' : '➖';
  }

  /// Retorna a cor do tipo de movimentação
  Color get tipoColor {
    return tipo == 'entrada' ? Colors.green : Colors.red;
  }

  /// Retorna o símbolo da quantidade
  String get quantidadeSimbolo {
    return tipo == 'entrada' ? '+$quantidade' : '-$quantidade';
  }

  /// Formata a data de criação
  String get dataFormatada {
    final dia = createdAt.day.toString().padLeft(2, '0');
    final mes = createdAt.month.toString().padLeft(2, '0');
    final ano = createdAt.year;
    final hora = createdAt.hour.toString().padLeft(2, '0');
    final minuto = createdAt.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano - $hora:$minuto';
  }

  /// Formata a data apenas (sem hora)
  String get dataApenas {
    final dia = createdAt.day.toString().padLeft(2, '0');
    final mes = createdAt.month.toString().padLeft(2, '0');
    final ano = createdAt.year;
    return '$dia/$mes/$ano';
  }

  /// Formata a hora apenas
  String get horaApenas {
    final hora = createdAt.hour.toString().padLeft(2, '0');
    final minuto = createdAt.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Formata o preço unitário para moeda brasileira
  String get precoUnitarioFormatado {
    if (precoUnitario == null) return '--';
    return 'R\$ ${precoUnitario!.toStringAsFixed(2)}';
  }

  /// Calcula o valor total da movimentação
  double get valorTotal {
    if (precoUnitario == null) return 0;
    return quantidade * precoUnitario!;
  }

  /// Formata o valor total para moeda brasileira
  String get valorTotalFormatado {
    if (precoUnitario == null) return '--';
    return 'R\$ ${valorTotal.toStringAsFixed(2)}';
  }

  // ==================== MÉTODOS DE VALIDAÇÃO ====================

  /// Verifica se a movimentação é do tipo entrada
  bool get isEntrada => tipo == 'entrada';

  /// Verifica se a movimentação é do tipo saída
  bool get isSaida => tipo == 'saida';

  // ==================== MÉTODO DE DESCRIÇÃO ====================

  /// Retorna uma descrição detalhada da movimentação
  String get descricaoDetalhada {
    final tipoTexto = tipoLabel.toLowerCase();
    final qtd = quantidade.toStringAsFixed(1);
    return '$tipoTexto de $qtd unidade(s) do produto "$produtoNome"';
  }

  // ==================== EXEMPLO DE USO ====================
  /*
  // Criando uma movimentação de entrada
  final movimento = Movimento(
    produtoId: 'prod123',
    produtoNome: 'Mouse USB',
    tipo: 'entrada',
    quantidade: 10,
    precoUnitario: 25.00,
    observacao: 'Compra do fornecedor XYZ',
    usuarioId: 'user123',
    usuarioEmail: 'usuario@email.com',
    createdAt: DateTime.now(),
  );

  // Verificando dados
  print(movimento.tipoLabel); // 'Entrada'
  print(movimento.quantidadeSimbolo); // '+10'
  print(movimento.dataFormatada); // '20/08/2026 - 14:30'
  print(movimento.valorTotalFormatado); // 'R$ 250.00'
  */
}