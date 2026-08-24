import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Movimento {
  final String? id;
  final String produtoId;
  final String produtoNome;
  final String tipo;
  final double quantidade;
  final double? precoUnitario;
  final String? observacao;
  final String usuarioId;
  final String usuarioEmail;
  final DateTime createdAt;

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

  // 🔥 CORRIGIDO: LÊ TIMESTAMP CORRETAMENTE
  factory Movimento.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

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
      createdAt: parseDate(map['createdAt']),
    );
  }

  String get tipoLabel => tipo == 'entrada' ? 'Entrada' : 'Saída';

  String get tipoIcon => tipo == 'entrada' ? '➕' : '➖';

  Color get tipoColor => tipo == 'entrada' ? Colors.green : Colors.red;

  String get quantidadeSimbolo => tipo == 'entrada' ? '+$quantidade' : '-$quantidade';

  String get dataFormatada {
    final dia = createdAt.day.toString().padLeft(2, '0');
    final mes = createdAt.month.toString().padLeft(2, '0');
    final ano = createdAt.year;
    final hora = createdAt.hour.toString().padLeft(2, '0');
    final minuto = createdAt.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano - $hora:$minuto';
  }

  String get dataApenas {
    final dia = createdAt.day.toString().padLeft(2, '0');
    final mes = createdAt.month.toString().padLeft(2, '0');
    final ano = createdAt.year;
    return '$dia/$mes/$ano';
  }

  String get horaApenas {
    final hora = createdAt.hour.toString().padLeft(2, '0');
    final minuto = createdAt.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  String get precoUnitarioFormatado {
    if (precoUnitario == null) return '--';
    return 'R\$ ${precoUnitario!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double get valorTotal {
    if (precoUnitario == null) return 0;
    return quantidade * precoUnitario!;
  }

  String get valorTotalFormatado {
    if (precoUnitario == null) return '--';
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  bool get isEntrada => tipo == 'entrada';

  bool get isSaida => tipo == 'saida';

  String get descricaoDetalhada {
    final tipoTexto = tipoLabel.toLowerCase();
    final qtd = quantidade.toStringAsFixed(1);
    return '$tipoTexto de $qtd unidade(s) do produto "$produtoNome"';
  }
}