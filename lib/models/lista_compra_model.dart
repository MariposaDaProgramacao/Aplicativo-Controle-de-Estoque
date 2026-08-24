import 'package:cloud_firestore/cloud_firestore.dart';

class ListaCompra {
  final String? id;
  final String produtoId;
  final String produtoNome;
  final String codigo;
  final String categoria;
  final double quantidadeNecessaria;
  final double quantidadeAtual;
  final double estoqueMinimo;
  final String usuarioId;
  final bool comprado;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ListaCompra({
    this.id,
    required this.produtoId,
    required this.produtoNome,
    required this.codigo,
    required this.categoria,
    required this.quantidadeNecessaria,
    required this.quantidadeAtual,
    required this.estoqueMinimo,
    required this.usuarioId,
    this.comprado = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId,
      'produtoNome': produtoNome,
      'codigo': codigo,
      'categoria': categoria,
      'quantidadeNecessaria': quantidadeNecessaria,
      'quantidadeAtual': quantidadeAtual,
      'estoqueMinimo': estoqueMinimo,
      'usuarioId': usuarioId,
      'comprado': comprado,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // 🔥 CORRIGIDO: LÊ TIMESTAMP CORRETAMENTE
  factory ListaCompra.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return ListaCompra(
      id: id,
      produtoId: map['produtoId'] ?? '',
      produtoNome: map['produtoNome'] ?? '',
      codigo: map['codigo'] ?? '',
      categoria: map['categoria'] ?? '',
      quantidadeNecessaria: (map['quantidadeNecessaria'] ?? 0).toDouble(),
      quantidadeAtual: (map['quantidadeAtual'] ?? 0).toDouble(),
      estoqueMinimo: (map['estoqueMinimo'] ?? 0).toDouble(),
      usuarioId: map['usuarioId'] ?? '',
      comprado: map['comprado'] ?? false,
      createdAt: parseDate(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null,
    );
  }

  double get quantidadeFaltante {
    final faltante = estoqueMinimo - quantidadeAtual;
    return faltante > 0 ? faltante : 0;
  }

  bool get precisaComprar => quantidadeAtual <= estoqueMinimo && !comprado;
}